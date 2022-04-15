local helpers = require "spec.helpers"
local cjson    = require "cjson"

local PLUGIN_NAME = "cluster-stats"
local test_node_id = "00000000-0000-0000-0000-000000000000"

local function get_num_nodes(admin_client)
    local res = admin_client:send{
        method="GET",
        path = "/cluster-stats"
    }
    local raw = assert.res_status(200,res)
    local body = cjson.decode(raw)
    return body.num_nodes
end

for _, strategy in helpers.each_strategy() do
    describe("Plugin: "..PLUGIN_NAME.."API tests - ",function ()

        local admin_client, bp, db

        setup(function ()

            bp, db = helpers.get_db_utils(strategy, {"plugins"},{PLUGIN_NAME})

            assert(helpers.start_kong({
                database   = strategy,
                nginx_conf = "spec/fixtures/custom_nginx.template",
                plugins = "bundled, " .. PLUGIN_NAME,
            }))

            assert(bp.plugins:insert {
                name = PLUGIN_NAME,
            })

            admin_client = helpers.admin_client()

        end)

        it("should return 200 on /cluster-stats endpoint",function ()
            local res = admin_client:send{
                method="GET",
                path = "/cluster-stats"
            }
            assert.res_status(200,res)
        end)

        it("should return num_nodes = 1", function ()
            local num_nodes = get_num_nodes(admin_client)
            assert.same(1, num_nodes) -- A node is created by kong for testing
        end)

        it("should return num_nodes = 2", function ()
            -- Inserting test node in db
            -- Total nodes = 2 
            -- (1 test node is created by kong)
            db.cluster_stats_heartbeat:insert({node_id = test_node_id})
            
            local num_nodes = get_num_nodes(admin_client)
            assert.same(2, num_nodes)
        end)

        it("check for stale nodes", function()
            -- Inserting test node in db
            -- Total nodes = 2 
            -- (1 test node is created by kong)
            db.cluster_stats_heartbeat:insert({node_id = test_node_id})

            -- Updating timestamp of created node to epoch start time
            db.cluster_stats_heartbeat:update({node_id = test_node_id}, {
                updated_at = 0
            })
            -- Sleep for 5 secons so that changes made are reflected 
            ngx.sleep(5)

            local num_nodes = get_num_nodes(admin_client)
            assert.same(1, num_nodes)
        end)

        it("check for delete nodes", function()
            db.cluster_stats_heartbeat:insert({node_id = test_node_id})
            db.cluster_stats_heartbeat:delete({node_id = test_node_id})

            local num_nodes = get_num_nodes(admin_client)
            assert.same(1, num_nodes)
        end)

        teardown(function ()
            if admin_client then
                admin_client:close()
            end
            helpers.stop_kong()
            db:truncate()
        end)
    end)
end
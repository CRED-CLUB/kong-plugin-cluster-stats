local helpers = require "spec.helpers"
local PLUGIN_NAME = "cluster-stats"

for _, strategy in helpers.each_strategy() do
    describe("Plugin: "..PLUGIN_NAME.."API tests",function ()

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
                config = {
                    heartbeat_send_interval_in_secs =1,
                    heartbeat_cleanup_interval_in_secs = 60,
                    heartbeat_fetch_not_older_than_in_secs = 30,
                    heartbeat_cleanup_older_than_in_secs = 60,
                }
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

        teardown(function ()
            admin_client:close()
            helpers.stop_kong()
            db:truncate()
        end)
    end)
end
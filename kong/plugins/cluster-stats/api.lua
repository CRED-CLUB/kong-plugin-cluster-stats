local repo = require 'kong.plugins.cluster-stats.repo'
local config = require 'kong.plugins.cluster-stats.config'

local ngx_now = ngx.now
local kong = kong

return {
  ["/cluster-stats"] = {
    before = function(self, db, helpers) end,
    GET = function(self, db, helpers)
      local n = repo.count_heartbeats_not_older_than(ngx_now() -
                                                       config.heartbeat_fetch_not_older_than_in_secs)
      -- return 500 on error i.e when count returned is -1
      if n < 0 then return kong.response.exit(500, "error") end
      kong.response.set_header("Content-Type", "application/json")
      return kong.response.exit(200, {num_nodes = n})
    end
  }
}

local _M = {}

local repo = require 'kong.plugins.cluster-stats.repo'
local config = require 'kong.plugins.cluster-stats.config'

local ngx = ngx
local ngx_now = ngx.now
local kong = kong

-- run these functions only if master

function _M.send_heartbeat(self, id)
  if ngx.worker.id() == 0 then repo.upsert_heartbeat(id) end
end

function _M.register_node(self, id)
  if ngx.worker.id() == 0 then repo.upsert_heartbeat(id) end
end

function _M.run_cleanup(self, duration)
  if ngx.worker.id() == 0 then
    repo.delete_heartbeats_older_than(ngx_now() - duration)
  end
end

return _M

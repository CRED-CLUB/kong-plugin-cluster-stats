local worker = require 'kong.plugins.cluster-stats.worker'
local config = require 'kong.plugins.cluster-stats.config'
local BasePlugin = require 'kong.plugins.base_plugin'

local node = kong.node
local timer_every = ngx.timer.every

local ClusterStatsHandler = BasePlugin:extend()

ClusterStatsHandler.VERSION = "0.1.0"
ClusterStatsHandler.PRIORITY = 902

function ClusterStatsHandler:new()
  ClusterStatsHandler.super.new(self, "cluster-stats-plugin")
end

-- init_worker() runs as soon as the plugin is loaded
-- It doesn't need the plugin to be enabled
function ClusterStatsHandler:init_worker()
  -- unique node id, uuid
  local node_id = node.get_id()
  ClusterStatsHandler.super.init_worker(self)
  worker:register_node(node_id)
  -- schedule heartbeat
  timer_every(config.HEARTBEAT_SEND_INTERVAL_IN_SECS, worker.send_heartbeat,
              node_id)
  -- schedule cleanup
  timer_every(config.HEARTBEAT_CLEANUP_INTERVAL_IN_SECS, worker.run_cleanup,
              config.HEARTBEAT_CLEANUP_OLDER_THAN_IN_SEC)
end

return ClusterStatsHandler

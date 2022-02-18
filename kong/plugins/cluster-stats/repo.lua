local _M = {}

local ngx_now = ngx.now
local string_format = string.format
local kong = kong
local connector = kong.db.connector

local CLEANUP_SQL_TEMPLATE =
  "DELETE FROM cluster_stats_heartbeat WHERE EXTRACT(EPOCH FROM updated_at) < %d"
local NUM_NODES_SQL_TEMPLATE =
  "SELECT COUNT(1) FROM cluster_stats_heartbeat WHERE EXTRACT(EPOCH FROM updated_at) > %d"

function _M.insert_heartbeat(id)
  local entity, err = kong.db.cluster_stats_heartbeat:insert({node_id = id})
  if err ~= nil then kong.log.err("error in insert: ", err) end
end

function _M.update_heartbeat(id)
  local entity, err = kong.db.cluster_stats_heartbeat:update({node_id = id},
                                                             {node_id = id}, {
    updated_at = ngx_now()
  })
  if err ~= nil then kong.log.err("error in update: ", err) end
end

function _M.delete_heartbeats_older_than(timestamp)
  local sql = string_format(CLEANUP_SQL_TEMPLATE, timestamp)
  local _, err, _, _ = connector:query(sql)
  if err ~= nil then kong.log.err("error running cleanup: ", err) end
end

function _M.count_heartbeats_not_older_than(timestamp)
  local sql = string_format(NUM_NODES_SQL_TEMPLATE, timestamp)
  local rows, err, _, _ = connector:query(sql)
  if err ~= nil then kong.log.err("error running num nodes: ", err) end
  if rows then return rows[1]["count"] end
  -- return -1 on error
  return -1
end

return _M

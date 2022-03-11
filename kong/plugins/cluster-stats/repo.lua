local _M = {}

local ngx_now = ngx.now
local string_format = string.format
local kong = kong
local connector = kong.db.connector

local db_type = kong.configuration.database

-- Using DB specefic queries

local CLEANUP_SQL_TEMPLATE 
local NUM_NODES_SQL_TEMPLATE
local NODES_CLEANUP_SQL_TEMPLATE

if (db_type=='postgres')
then 
  CLEANUP_SQL_TEMPLATE = "DELETE FROM cluster_stats_heartbeat WHERE EXTRACT(EPOCH FROM updated_at) < %d"
  NUM_NODES_SQL_TEMPLATE = "SELECT COUNT(1) FROM cluster_stats_heartbeat WHERE EXTRACT(EPOCH FROM updated_at) > %d"
else
  -- Queries for cassandra 
  NODES_CLEANUP_SQL_TEMPLATE = "SELECT node_id FROM cluster_stats_heartbeat WHERE updated_at < %d ALLOW FILTERING;"
  CLEANUP_SQL_TEMPLATE = "DELETE FROM cluster_stats_heartbeat WHERE node_id IN %s"
  NUM_NODES_SQL_TEMPLATE = "SELECT COUNT(1) FROM cluster_stats_heartbeat WHERE updated_at > %d ALLOW FILTERING;"
end

local function convert_to_string(rows)
  
  local result = ""

  for k,v in pairs(rows) do
    if(rows[k]["node_id"] ~= nil) then result = result .. "'" .. rows[k]["node_id"] .. "'," end
  end
  
  -- Remove leading commas from the result
  if result ~= "" then
    result = result:sub(1, result:len()-1)
  end

  return "("..result..")"
end

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

  if(db_type=='postgres') then
    local cleanup_postgres_sql = string_format(CLEANUP_SQL_TEMPLATE, timestamp)
    local _, err, _, _ = connector:query(cleanup_postgres_sql)
    
    if err ~= nil then kong.log.err("error running cleanup: ", err) end
  else 
    local get_cleanup_nodes_sql = string_format(NODES_CLEANUP_SQL_TEMPLATE, timestamp)
    local rows, err, _, _ = connector:query(get_cleanup_nodes_sql)

    if err ~= nil then kong.log.err("error running cleanup: ", err) return end
  
    local nodes_to_cleanup = convert_to_string(rows)

    local cleanup_cassandra_sql = string_format(CLEANUP_SQL_TEMPLATE, nodes_to_cleanup)
    local _, err, _, _ = connector:query(cleanup_cassandra_sql)
    if err ~= nil then kong.log.err("error running cleanup: ", err) end  
  end
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

local _M = {}

-- interval at which to write heartbeat in db
_M.heartbeat_send_interval_in_secs = 1

-- interval at which to cleanup stale heartbeat entries in db
_M.heartbeat_cleanup_interval_in_secs = 60

-- maximum duration to look back while fetching heartbeat records
_M.heartbeat_fetch_not_older_than_in_secs = 3

-- cleaup heartbeat records older than
_M.heartbeat_cleanup_older_than_in_secs = 60

return _M

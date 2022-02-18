local _M = {}

-- interval at which to write heartbeat in db
_M.HEARTBEAT_SEND_INTERVAL_IN_SECS = 1

-- interval at which to cleanup stale heartbeat entries in db
_M.HEARTBEAT_CLEANUP_INTERVAL_IN_SECS = 60

-- maximum duration to look back while fetching heartbeat records
_M.HEARTBEAT_FETCH_NOT_OLDER_THAN_IN_SEC = 3

-- cleaup heartbeat records older than
_M.HEARTBEAT_CLEANUP_OLDER_THAN_IN_SEC = 60

return _M

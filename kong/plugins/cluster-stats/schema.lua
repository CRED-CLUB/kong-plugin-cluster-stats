local typedefs = require "kong.db.schema.typedefs"

return {
  name = "cluster-stats",
  fields = {
    {
      -- this plugin will only be applied to Services or Routes
      consumer = typedefs.no_consumer
    },
    {
      -- Will only run with Nginx HTTP module
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
          {
            heartbeat_send_interval_in_secs = {
              type = "integer",
              required = true,
              default = 1,
              gt = 1
            }
          },
          {
            heartbeat_cleanup_interval_in_secs = {
              type = "integer",
              required = true,
              default = 60,
              gt = 1
            }
          },
          {
            heartbeat_fetch_not_older_than_in_secs = {
              type = "integer",
              required = true,
              default = 3,
              gt = 1
            }
          },
          {
            heartbeat_cleanup_older_than_in_secs = {
              type = "integer",
              required = true,
              default = 60,
              gt = 1
            }
          },
        }
      }
    }
  }
}

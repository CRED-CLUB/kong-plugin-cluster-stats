return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "cluster_stats_heartbeat" (
        "created_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "updated_at"   TIMESTAMP WITH TIME ZONE     DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "node_id"      TEXT                         UNIQUE,
        PRIMARY KEY("node_id")
      );

      DO $$
      BEGIN
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]]
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS cluster_stats_heartbeat (
        updated_at  timestamp,
        created_at  timestamp,
        node_id     text,
        PRIMARY KEY (node_id),
      );
    ]]
  }
}

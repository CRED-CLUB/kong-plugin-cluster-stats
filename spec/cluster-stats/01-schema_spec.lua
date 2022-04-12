local PLUGIN_NAME = "cluster-stats"
local schema_def = require("kong.plugins." .. PLUGIN_NAME .. ".schema")
local validator = require("spec.helpers").validate_plugin_config_schema


describe("Plugin: " .. PLUGIN_NAME .. " (schema), ", function()
  it("no config passes", function()
    assert(validator({}, schema_def))
  end)
  it("full conf validates", function()
    assert(validator({
      heartbeat_send_interval_in_secs =2,
      heartbeat_cleanup_interval_in_secs = 120,
      heartbeat_fetch_not_older_than_in_secs = 3,
      heartbeat_cleanup_older_than_in_secs = 180,
    }, schema_def))
  end)
  it("invalid values fail",function ()
    local config = {heartbeat_send_interval_in_secs = -2}
    local ok, err = validator(config,schema_def)
    assert.falsy(ok)
    assert.same({heartbeat_send_interval_in_secs='value must be greater than 0'},err.config)
  end)
end)

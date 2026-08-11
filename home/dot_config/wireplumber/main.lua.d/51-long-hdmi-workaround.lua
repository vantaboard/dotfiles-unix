-- WirePlumber 0.4.x (Lua) overrides for long passive HDMI + NVIDIA HDA.
-- Detected stack: wireplumber 0.4.17 / pipewire 1.0.5 (not 0.5 .conf syntax).
--
-- 1) Disable suspend-on-idle so ALSA nodes are not constantly suspended over
--    an unstable ELD/jack link (suspend/resume crackle).
-- 2) Point the NVIDIA HDMI card at an ACP profile-set that ignores jack/ELD
--    state so profiles stay available when the handshake drops.

table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.*" },
    },
    {
      { "node.name", "matches", "alsa_input.*" },
    },
  },
  apply_properties = {
    ["session.suspend-timeout-seconds"] = 0,
  },
})

table.insert(alsa_monitor.rules, {
  matches = {
    {
      -- NVIDIA GPU HDMI audio (GA104 HDA on this host).
      { "device.name", "equals", "alsa_card.pci-0000_01_00.1" },
    },
    {
      { "device.nick", "equals", "HDA NVidia" },
    },
  },
  apply_properties = {
    ["api.alsa.use-acp"] = true,
    ["api.acp.auto-profile"] = false,
    ["api.acp.auto-port"] = false,
    ["device.profile-set"] = "hdmi-force-available.conf",
    ["device.profile"] = "output:hdmi-stereo",
  },
})

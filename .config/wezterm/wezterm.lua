-- ================================================================
-- wezterm.lua - Configuração do WezTerm
-- ================================================================

local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- ===== SHELL =====
config.default_prog = { '/bin/zsh' }

-- ===== MULTIPLEXADOR (Sessões Persistente) =====
config.unix_domains = {
  {
    name = 'unix',
  },
}

-- Isso NÃO afeta o 'connect', apenas o menu GUI
-- config.launch_menu = {
--   {
--     label = "Top",
--     args = { "top" },
--   },
--   {
--     label = "Bash",
--     args = { "bash", "-l" },
--   },
--   {
--     label = "Connect to Mux",
--     args = { "wezterm", "connect", "unix" },
--   },
-- }

config.skip_close_confirmation_for_processes_named = {
  'bash', 'zsh', 'fish', 'tmux', 'nvim', 'vim', 'ssh', 'sudo',
}

-- ===== CORES =====
config.colors = {
  foreground = '#d7dae0',
  background = '#16191d',
  
  cursor_bg = '#528bff',
  cursor_fg = 'rgba(255, 255, 255, 0.8)',
  cursor_border = 'rgba(33, 38, 44, 0.2)',
  
  selection_fg = '#abb2bf',
  selection_bg = 'rgba(171, 178, 191, 0.2)',
  
  scrollbar_thumb = 'rgba(79, 86, 102, 0.2)',
  split = 'rgba(171, 178, 191, 0.2)',
  
  ansi = {
    '#3f4451',
    '#e05561',
    '#8cc265',
    '#d18f52',
    '#4aa5f0',
    '#c162de',
    '#42b3c2',
    '#d7dae0',
  },
  
  brights = {
    '#4f5666',
    '#ff616e',
    '#a5e075',
    '#f0a45d',
    '#4dc4ff',
    '#de73ff',
    '#4cd1e0',
    '#e6e6e6',
  },

  indexed = {[136] = '#af8700'},
  compose_cursor = '#528bff',
}

-- ===== WINDOW FRAME =====
config.window_frame = {
  active_titlebar_bg = '#16191d',
  inactive_titlebar_bg = '#16191d',
  
  font = wezterm.font('JetBrains Mono'),
  font_size = 12.0,

  border_left_width = '0.2cell',
  border_right_width = '0.2cell',
  border_bottom_height = '0.1cell',
  border_top_height = '0.1cell',
  border_left_color = 'rgba(171, 178, 191, 0.2)',
  border_right_color = 'rgba(171, 178, 191, 0.2)',
  border_bottom_color = 'rgba(171, 178, 191, 0.2)',
  border_top_color = 'rgba(171, 178, 191, 0.2)',
}

-- ===== FONTE =====
config.font = wezterm.font('JetBrains Mono')
config.font_size = 13.0
config.line_height = 1.5

-- ===== JANELA =====
config.window_decorations = 'NONE'
config.enable_tab_bar = false
config.window_background_opacity = 0.85

config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

-- ===== SCROLL =====
config.enable_scroll_bar = true
config.scrollback_lines = 10000
config.scroll_to_bottom_on_input = true

-- ===== INPUT =====
config.use_dead_keys = false
config.use_ime = false

-- ===== VISUAL BELL =====
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}

-- ===== VARIÁVEIS DE AMBIENTE =====
config.set_environment_variables = {
  TERM = 'wezterm',
  DISABLE_AUTO_TITLE = 'true',
}

-- ===== CURSOR =====
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- CRÍTICO: Desabilita otimizações que causam flicker
config.force_reverse_video_cursor = false

-- ===== PERFORMANCE =====
config.webgpu_preferred_adapter = {
  backend = 'Vulkan',
  device = 29695,
  device_type = 'DiscreteGpu',
  driver = 'radv',
  driver_info = 'Mesa 25.0.7 (git-742a20f48c)',
  name = 'AMD Radeon RX 6600 (RADV NAVI23)',
  vendor = 4098,
}

config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 60
config.animation_fps = 1

-- ===== WAYLAND =====
config.enable_wayland = true

-- ===== MOUSE BINDINGS =====
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = wezterm.action.ScrollByLine(-1),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = wezterm.action.ScrollByLine(1),
  },
}

-- ===== KEYBINDINGS =====
config.keys = {
  {
    key = 'l',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        return
      end
      window:perform_action(wezterm.action.ScrollToBottom, pane)
      local height = pane:get_dimensions().viewport_rows
      local blank_viewport = string.rep('\n', height)
      wezterm.sleep_ms(25)
      pane:inject_output(blank_viewport)
      pane:inject_output('\x1b[H\x1b[2J')
      pane:send_text('\n\x0c')
    end)
  },
  -- {
  --   key = 'p',
  --   mods = 'CTRL|SHIFT',
  --   action = wezterm.action.ShowLauncher,
  -- },
}

return config

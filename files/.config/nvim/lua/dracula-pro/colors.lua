-- Color palette for Dracula Pro

local M = {}

M.default = {
  none = "NONE",

  -- Base colors
  bg = "#22212C",
  bg_dark = "#010010",
  bg_darker = "#010010",
  bg_light = "#43414E",
  bg_highlight = "#43414E",
  bg_visual = "#454158",
  bg_search = "#43414E",
  bg_sidebar = "#010010",
  bg_statusline = "#010010",
  bg_float = "#43414E",
  bg_popup = "#43414E",

  fg = "#F8F8F2",
  fg_dark = "#CDCDC8",
  fg_gutter = "#504C67",
  fg_sidebar = "#F8F8F2",
  fg_float = "#F8F8F2",

  -- Accent colors
  black = "#010010",
  border = "#504C67",
  border_highlight = "#9580FF",
  comment = "#7970A9",

  -- Syntax colors
  red = "#FF9580",
  orange = "#FFFF80",
  yellow = "#FFFF80",
  green = "#8AFF80",
  cyan = "#80FFEA",
  blue = "#9580FF",
  blue0 = "#9580FF",
  blue1 = "#9580FF",
  blue2 = "#80FFEA",
  blue5 = "#FF80BF",
  blue6 = "#99FFEE",
  blue7 = "#9580FF",
  magenta = "#FF80BF",
  magenta2 = "#FF99CC",
  purple = "#FF80BF",
  teal = "#80FFEA",
  dark3 = "#CDCDC8",
  dark5 = "#CDCDC8",
  green1 = "#8AFF80",
  green2 = "#8AFF80",
  red1 = "#FF9580",

  -- Bright variants
  bright_red = "#FFAA99",
  bright_green = "#A2FF99",
  bright_yellow = "#FFFF99",
  bright_blue = "#AA99FF",
  bright_magenta = "#FF99CC",
  bright_cyan = "#99FFEE",

  -- Terminal colors
  terminal_black = "#22212C",

  -- Semantic syntax colors (for accurate theme reproduction)
  syntax_string = "#FFFF80",
  syntax_function = "#8AFF80",
  syntax_variable = "#F8F8F2",
  syntax_keyword = "#FF80BF",
  syntax_class = "#9580FF",
  syntax_constant = "#80FFEA",

  -- Diagnostic colors
  error = "#FF9580",
  warning = "#FFFF80",
  info = "#80FFEA",
  hint = "#504C67",
  todo = "#9580FF",

  -- Git colors
  git = {
    add = "#8AFF80",
    change = "#FFFF80",
    delete = "#FF9580",
    ignore = "#504C67",
  },

  -- Diff colors
  diff = {
    add = "#5DD458",
    delete = "#D16D5B",
    change = "#D3D457",
    text = "#FFFF80",
  },
}

function M.setup(opts)
  opts = opts or {}
  return M.default
end

return M

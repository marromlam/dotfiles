local api, notify, fmt, augroup =
  vim.api, vim.notify, string.format, mrl.augroup

---@alias HLAttrs {from: string, attr: "fg" | "bg", alter: integer}

---@class HLData
---@field fg string
---@field bg string
---@field bold boolean
---@field italic boolean
---@field undercurl boolean
---@field underline boolean
---@field underdotted boolean
---@field underdashed boolean
---@field underdouble boolean
---@field strikethrough boolean
---@field reverse boolean
---@field nocombine boolean
---@field link string
---@field default boolean

---@class HLArgs
---@field blend integer?
---@field fg (string | HLAttrs)?
---@field bg (string | HLAttrs)?
---@field sp (string | HLAttrs)?
---@field bold boolean?
---@field italic boolean?
---@field undercurl boolean?
---@field underline boolean?
---@field underdotted boolean?
---@field underdashed boolean?
---@field underdouble boolean?
---@field strikethrough boolean?
---@field reverse boolean?
---@field nocombine boolean?
---@field link string?
---@field default boolean?
---@field clear boolean?
---@field inherit string?

local enable_italics = false
local attrs = {
  fg = true,
  bg = true,
  sp = true,
  blend = true,
  bold = true,
  italic = enable_italics,
  standout = true,
  underline = true,
  undercurl = true,
  underdouble = true,
  underdotted = true,
  underdashed = true,
  strikethrough = true,
  reverse = true,
  nocombine = true,
  link = true,
  default = true,
}

---@private
---@param opts {name: string?, link: boolean?}?
---@param ns integer?
---@return HLData
local function get_hl_as_hex(opts, ns)
  ns, opts = ns or 0, opts or {}
  opts.link = opts.link ~= nil and opts.link or false
  local hl = api.nvim_get_hl(ns, opts)
  hl.fg = hl.fg and ('#%06x'):format(hl.fg)
  hl.bg = hl.bg and ('#%06x'):format(hl.bg)
  return hl
end

--- Change the brightness of a color, negative numbers darken and positive ones brighten
---see:
--- 1. https://stackoverflow.com/q/5560248
--- 2. https://stackoverflow.com/a/37797380
---@param color string A hex color
---@param percent number a negative number darkens and a positive one brightens
---@return string
local function tint(color, percent)
  assert(
    color and percent,
    'cannot alter a color without specifying a color and percentage'
  )
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6), 16)
  if not r or not g or not b then return 'NONE' end
  local blend = function(component)
    component = math.floor(component * (1 + percent))
    return math.min(math.max(component, 0), 255)
  end
  return fmt('#%02x%02x%02x', blend(r), blend(g), blend(b))
end

--- Blend two hex colors using an alpha for the foreground.
--- `alpha = 0` returns bg, `alpha = 1` returns fg.
---@param bg string hex color (#RRGGBB)
---@param fg string hex color (#RRGGBB)
---@param alpha number 0..1
---@return string
local function blend(bg, fg, alpha)
  assert(bg and fg and alpha ~= nil, 'blend(bg, fg, alpha) requires 3 args')
  if type(bg) ~= 'string' or type(fg) ~= 'string' then return 'NONE' end
  if bg == 'NONE' or fg == 'NONE' then return 'NONE' end
  if not bg:match('^#%x%x%x%x%x%x$') or not fg:match('^#%x%x%x%x%x%x$') then
    return 'NONE'
  end
  alpha = math.min(math.max(alpha, 0), 1)

  local br, bgc, bb =
    tonumber(bg:sub(2, 3), 16),
    tonumber(bg:sub(4, 5), 16),
    tonumber(bg:sub(6, 7), 16)
  local fr, fgc, fb =
    tonumber(fg:sub(2, 3), 16),
    tonumber(fg:sub(4, 5), 16),
    tonumber(fg:sub(6, 7), 16)
  if not br or not bgc or not bb or not fr or not fgc or not fb then
    return 'NONE'
  end

  local function mix(b, f) return math.floor((1 - alpha) * b + alpha * f + 0.5) end
  return fmt('#%02x%02x%02x', mix(br, fr), mix(bgc, fgc), mix(bb, fb))
end

-- Blend two hex colors with alpha compositing
-- @param fg_hex: foreground color in hex format (e.g., "#ff0000" or "ff0000")
-- @param bg_hex: background color in hex format
-- @param alpha: alpha value for foreground (0.0 to 1.0), defaults to 0.5
-- @return: blended color in hex format
local function blend_colors(fg_hex, bg_hex, alpha)
  alpha = alpha or 0.5

  if type(fg_hex) ~= 'string' or type(bg_hex) ~= 'string' then return 'NONE' end
  if fg_hex == 'NONE' or bg_hex == 'NONE' then return 'NONE' end

  -- Remove '#' if present
  fg_hex = fg_hex:gsub('#', '')
  bg_hex = bg_hex:gsub('#', '')

  if #fg_hex ~= 6 or #bg_hex ~= 6 then return 'NONE' end

  -- Parse hex colors to RGB
  local fg_r = tonumber(fg_hex:sub(1, 2), 16)
  local fg_g = tonumber(fg_hex:sub(3, 4), 16)
  local fg_b = tonumber(fg_hex:sub(5, 6), 16)

  local bg_r = tonumber(bg_hex:sub(1, 2), 16)
  local bg_g = tonumber(bg_hex:sub(3, 4), 16)
  local bg_b = tonumber(bg_hex:sub(5, 6), 16)

  if not fg_r or not fg_g or not fg_b or not bg_r or not bg_g or not bg_b then
    return 'NONE'
  end

  alpha = math.min(math.max(alpha, 0), 1)

  -- Alpha blend: out = fg * alpha + bg * (1 - alpha)
  local out_r = math.floor(fg_r * alpha + bg_r * (1 - alpha) + 0.5)
  local out_g = math.floor(fg_g * alpha + bg_g * (1 - alpha) + 0.5)
  local out_b = math.floor(fg_b * alpha + bg_b * (1 - alpha) + 0.5)

  -- Convert back to hex
  return string.format('#%02x%02x%02x', out_r, out_g, out_b)
end

local function normalize_hex(hex)
  if type(hex) ~= 'string' then return nil end
  hex = hex:gsub('#', '')
  if #hex ~= 6 then return nil end
  return hex:lower()
end

-- Convert RGB (0..255) to HSL (0..1)
local function rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local maxc, minc = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (maxc + minc) / 2

  if maxc ~= minc then
    local d = maxc - minc
    s = l > 0.5 and d / (2 - maxc - minc) or d / (maxc + minc)

    if maxc == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif maxc == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l
end

-- Convert HSL (0..1) to RGB (0..255 ints)
local function hsl_to_rgb(h, s, l)
  local function hue_to_rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end

  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1 / 3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1 / 3)
  end

  return math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5)
end

-- Darken a color by scaling HSL lightness while preserving hue/saturation.
-- `lightness_factor` in 0..1: lower is darker.
local function darken_hsl(hex, lightness_factor)
  lightness_factor = lightness_factor or 0.0
  local h = normalize_hex(hex)
  if not h then return 'NONE' end
  local r = tonumber(h:sub(1, 2), 16)
  local g = tonumber(h:sub(3, 4), 16)
  local b = tonumber(h:sub(5, 6), 16)
  if not r or not g or not b then return 'NONE' end

  local hh, ss, ll = rgb_to_hsl(r, g, b)

  if lightness_factor > 0 then
    -- Lighten: move toward 1.0 (white)
    ll = ll + (1 - ll) * lightness_factor
  else
    -- Darken: move toward 0.0 (black)
    ll = ll * (1 + lightness_factor)
  end

  ll = math.min(math.max(ll, 0), 1)
  r, g, b = hsl_to_rgb(hh, ss, ll)
  return fmt('#%02x%02x%02x', r, g, b)
end

--- Compute an alpha (0..1) such that blend(bg, fg, alpha) ~= target.
--- Returns a best-effort alpha (averaged across RGB channels) and clamps to [0,1].
---@param bg string hex color (#RRGGBB)
---@param fg string hex color (#RRGGBB)
---@param target string hex color (#RRGGBB)
---@return number
local function blend_alpha(bg, fg, target)
  if
    type(bg) ~= 'string'
    or type(fg) ~= 'string'
    or type(target) ~= 'string'
    or bg == 'NONE'
    or fg == 'NONE'
    or target == 'NONE'
    or not bg:match('^#%x%x%x%x%x%x$')
    or not fg:match('^#%x%x%x%x%x%x$')
    or not target:match('^#%x%x%x%x%x%x$')
  then
    return 0.5
  end

  local br, bgc, bb =
    tonumber(bg:sub(2, 3), 16),
    tonumber(bg:sub(4, 5), 16),
    tonumber(bg:sub(6, 7), 16)
  local fr, fgc, fb =
    tonumber(fg:sub(2, 3), 16),
    tonumber(fg:sub(4, 5), 16),
    tonumber(fg:sub(6, 7), 16)
  local tr, tgc, tb =
    tonumber(target:sub(2, 3), 16),
    tonumber(target:sub(4, 5), 16),
    tonumber(target:sub(6, 7), 16)
  if
    not br
    or not bgc
    or not bb
    or not fr
    or not fgc
    or not fb
    or not tr
    or not tgc
    or not tb
  then
    return 0.5
  end

  local function alpha_for(b, f, t)
    local denom = (f - b)
    if denom == 0 then return nil end
    return (t - b) / denom
  end

  local alphas = {
    alpha_for(br, fr, tr),
    alpha_for(bgc, fgc, tgc),
    alpha_for(bb, fb, tb),
  }

  local sum, n = 0, 0
  for _, a in ipairs(alphas) do
    if a and a == a and a ~= math.huge and a ~= -math.huge then
      sum, n = sum + a, n + 1
    end
  end
  local a = n > 0 and (sum / n) or 0.5
  return math.min(math.max(a, 0), 1)
end

local err_warn = vim.schedule_wrap(function(group, attribute)
  notify(
    fmt(
      'failed to get highlight %s for attribute %s\n%s',
      group,
      attribute,
      debug.traceback()
    ),
    'ERROR',
    {
      title = fmt('Highlight - get(%s)', group),
    }
  ) -- stylua: ignore
end)

---Get the value a highlight group whilst handling errors, fallbacks as well as returning a gui value
---If no attribute is specified return the entire highlight table
---in the right format
---@param group string
---@param attribute string?
---@param fallback string?
---@return string
---@overload fun(group: string): HLData
local function get(group, attribute, fallback)
  assert(group, 'cannot get a highlight without specifying a group name')
  local data = get_hl_as_hex({ name = group })
  if not attribute then return data end

  assert(
    attrs[attribute],
    ('the attribute passed in is invalid: %s'):format(attribute)
  )
  local color = data[attribute] or fallback
  if not color then
    if vim.v.vim_did_enter == 0 then
      api.nvim_create_autocmd('User', {
        pattern = 'LazyDone',
        once = true,
        callback = function() err_warn(group, attribute) end,
      })
    else
      vim.schedule(function() err_warn(group, attribute) end)
    end
    return 'NONE'
  end
  return color
end

---@param hl string | HLAttrs
---@param attr string
---@return HLData
local function resolve_from_attribute(hl, attr)
  if type(hl) ~= 'table' or not hl.from then return hl end
  local colour = get(hl.from, hl.attr or attr)
  if hl.alter then colour = tint(colour, hl.alter) end
  return colour
end

--- Sets a neovim highlight with some syntactic sugar. It takes a highlight table and converts
--- any highlights specified as `GroupName = {fg = { from = 'group'}}` into the underlying colour
--- by querying the highlight property of the from group so it can be used when specifying highlights
--- as a shorthand to derive the right colour.
--- For example:
--- ```lua
---   M.set({ MatchParen = {fg = {from = 'ErrorMsg'}}})
--- ```
--- This will take the foreground colour from ErrorMsg and set it to the foreground of MatchParen.
--- NOTE: this function must NOT mutate the options table as these are re-used when the colorscheme is updated
---
---@param name string
---@param opts HLArgs
---@overload fun(ns: integer, name: string, opts: HLArgs)
local function set(ns, name, opts)
  if type(ns) == 'string' and type(name) == 'table' then
    opts, name, ns = name, ns, 0
  end

  vim.validate({
    opts = { opts, 'table' },
    name = { name, 'string' },
    ns = { ns, 'number' },
  })

  local hl = opts.clear and {} or get_hl_as_hex({ name = opts.inherit or name })
  for attribute, hl_data in pairs(opts) do
    local new_data = resolve_from_attribute(hl_data, attribute)
    if attrs[attribute] then hl[attribute] = new_data end
  end

  mrl.pcall(fmt('setting highlight "%s"', name), api.nvim_set_hl, ns, name, hl)
end

---Apply a list of highlights
---@param hls {[string]: HLArgs}[]
---@param namespace integer?
local function all(hls, namespace)
  vim.iter(hls):each(function(hl) set(namespace or 0, next(hl)) end)
end

--- Set window local highlights
---@param name string
---@param win_id number
---@param hls HLArgs[]
local function set_winhl(name, win_id, hls)
  local namespace = api.nvim_create_namespace(name)
  all(hls, namespace)
  api.nvim_win_set_hl_ns(win_id, namespace)
end

---------------------------------------------------------------------------------
-- Plugin highlights
---------------------------------------------------------------------------------
--- Takes the overrides for each theme and merges the lists, avoiding duplicates and ensuring
--- priority is given to specific themes rather than the fallback
---@param theme {  [string]: HLArgs[] }
---@return HLArgs[]
local function add_theme_overrides(theme)
  local res, seen = {}, {}
  local list = vim.list_extend(theme[vim.g.colors_name] or {}, theme['*'] or {})
  for _, hl in ipairs(list) do
    local n = next(hl)
    if not seen[n] then res[#res + 1] = hl end
    seen[n] = true
  end
  return res
end
---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param opts HLArgs[] | { theme: table<string, HLArgs[]> }
local function plugin(name, opts)
  -- Options can be specified by theme name so check if they have been or there is a general
  -- definition otherwise use the opts as is
  if opts.theme then
    opts = add_theme_overrides(opts.theme)
    if not next(opts) then return end
  end
  vim.schedule(function() all(opts) end)
  augroup(fmt('%sHighlightOverrides', name:gsub('^%l', string.upper)), {
    event = 'ColorScheme',
    command = function()
      vim.schedule(function() all(opts) end)
    end,
  })
end

mrl.highlight = {
  get = get,
  set = set,
  all = all,
  tint = tint,
  blend = blend,
  blend_colors = blend_colors,
  blend_alpha = blend_alpha,
  rgb_to_hsl = rgb_to_hsl,
  hsl_to_rgb = hsl_to_rgb,
  darken_hsl = darken_hsl,
  plugin = plugin,
  set_winhl = set_winhl,
}

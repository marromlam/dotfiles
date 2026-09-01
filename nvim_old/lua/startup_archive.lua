local M = {}

-- Extensions recognised as archive/compound-document formats that Neovim's
-- zipPlugin (or similar) handles by mounting a virtual filesystem.  When one
-- of these is opened at startup the initial buffer can render blank in
-- interactive mode even though it works fine after a manual `:e`.
local ARCHIVE_EXTS = {
  zip = true, docx = true, xlsx = true, pptx = true,
  odt = true, ods = true, odp = true,
  jar = true, war = true, ear = true,
  epub = true, apk = true, xpi = true,
}

-- Build a normalised context table from raw startup information.
-- @param opts table  { argc, arg0, zip_exts, retry_done, buftype, filetype, line_count, lines }
-- @return table ctx
function M.build_ctx(opts)
  local ctx = {
    argc         = opts.argc or 0,
    arg0         = opts.arg0 or '',
    retry_done   = opts.retry_done or false,
    buftype      = opts.buftype or '',
    filetype     = opts.filetype or '',
    line_count   = opts.line_count or 0,
    lines        = opts.lines or {},
  }

  ctx.is_single_arg = ctx.argc == 1

  -- Determine the file extension (lowercased, no leading dot).
  local ext = ctx.arg0:match('%.([^%.]+)$')
  ctx.ext = ext and ext:lower() or ''

  -- Check against built-in list first, then any extra exts from g:zipPlugin_ext.
  ctx.is_archive_arg = ARCHIVE_EXTS[ctx.ext] == true

  if not ctx.is_archive_arg and opts.zip_exts then
    local extra = type(opts.zip_exts) == 'string' and opts.zip_exts or ''
    for e in extra:gmatch('[^,%.%s]+') do
      if e:lower() == ctx.ext then
        ctx.is_archive_arg = true
        break
      end
    end
  end

  -- The buffer looks blank when it has no real content lines.
  local has_content = false
  for _, line in ipairs(ctx.lines) do
    if line ~= '' then
      has_content = true
      break
    end
  end
  ctx.looks_blank = not has_content

  return ctx
end

-- Decide whether to issue a deferred `:edit` to recover a blank archive buffer.
-- Returns true when the buffer appears genuinely empty (needs retry), false when
-- it already has content (immediate re-open is fine either way per the caller).
-- @param ctx table  Result of build_ctx()
-- @return boolean
function M.should_retry_startup_edit(ctx)
  return ctx.looks_blank
end

return M

# jdhao/nvim-config Improvement Adoption Plan

## Goal
Adopt high-value patterns from `jdhao/nvim-config` into your existing Neovim setup at `~/.config/nvim` without breaking your current workflows (AI tooling, DAP, Obsidian, TeX, custom UI).

## Scope (exact improvements to implement)
1. Per-server LSP overrides in `after/lsp/*.lua`.
2. Diagnostic UX helpers (quickfix actions + optional cursor-line float behavior).
3. Startup Neovim version compatibility check.
4. Optional backup policy with dedicated backup directory.
5. Add and integrate two plugins:
   - `gbprod/yanky.nvim`
   - `MeanderingProgrammer/render-markdown.nvim`

## Non-goals
- No migration to jdhao’s full structure.
- No replacement of your plugin architecture (`lua/custom/plugins/*`).
- No indentation policy changes (keep your current 4-space defaults unless you choose otherwise).

## Current Baseline (what we preserve)
- Existing startup flow in `init.lua` and `lua/lazyloader.lua`.
- Current LSP setup centered in `lua/custom/plugins/lsp.lua`.
- Existing diagnostics styling and custom statuscolumn behavior.
- AI/copilot/codecompanion, DAP, testing, Obsidian, TeX workflows.

## Execution Strategy
Use an incremental, reversible rollout. Each phase should be committed independently and verified before moving to the next.

Recommended branch name:
- `nvim/jdhao-improvements`

Recommended commit sequence:
1. `nvim: add version guard utility and startup check`
2. `nvim: split lsp server overrides into after/lsp files`
3. `nvim: add diagnostic quickfix helpers`
4. `nvim: add optional backup policy`
5. `nvim: add yanky and render-markdown plugins`
6. `nvim: tune keymaps and docs for jdhao-derived improvements`

---

## Phase 0: Safety + Snapshot

### 0.1 Backup current config state
- Ensure dotfiles repo is clean enough to isolate changes.
- Snapshot plugin lock and key files:
  - `~/.config/nvim/init.lua`
  - `~/.config/nvim/lua/options.lua`
  - `~/.config/nvim/lua/custom/plugins/lsp.lua`
  - `~/.config/nvim/lua/custom/plugins/init.lua`
  - `~/.config/nvim/lazy-lock.json`

### 0.2 Define quick rollback command
- Roll back only nvim config paths if needed:
  - `git restore -- files/.config/nvim`
- If lockfile updates are undesired, revert lockfile only.

### 0.3 Baseline verification (before changes)
Run and capture:
- `nvim --version`
- `nvim --headless '+Lazy! sync' +qa`
- `nvim --headless '+checkhealth' +qa`
- Manual smoke:
  - Open Python/Lua/Markdown file.
  - Confirm LSP attach.
  - Confirm current diagnostic behavior.

Acceptance:
- Baseline should be clean enough to detect regressions introduced by this plan.

---

## Phase 1: Add Version Compatibility Guard

### Objective
Fail early (with clear message) when Neovim version is incompatible.

### Implementation
1. Add helper function (new file suggested):
   - `lua/custom/version.lua` (or `lua/tools.lua` if preferred by your conventions).
2. Implement minimum-version check using semantic parsing.
3. Call it near top of `init.lua` after `vim.loader` setup.

### Suggested behavior
- Define expected minimum explicitly, e.g. `0.11.6`.
- If current version is lower:
  - `vim.notify` with `ERROR` level and actionable text.
  - Return/abort before deeper plugin initialization.

### Validation
- Validate on your installed version (should pass).
- Temporarily simulate lower version in unit-like helper test (if easy) or manual function invocation.

Acceptance:
- Startup message is clear if incompatible.
- No behavior changes when compatible.

---

## Phase 2: Introduce Per-Server LSP Overrides in `after/lsp`

### Objective
Keep global LSP defaults centralized while moving server-specific settings into isolated files for maintainability.

### Target structure
- `after/lsp/lua_ls.lua`
- `after/lsp/pyright.lua`
- `after/lsp/ruff.lua`
- `after/lsp/clangd.lua`
- Add more gradually as needed.

### Implementation steps
1. Create `after/lsp/` directory.
2. Keep shared capabilities/on_attach/defaults in `lua/custom/plugins/lsp.lua`.
3. Move only per-server `settings`, `init_options`, and custom `on_attach` adjustments into each file.
4. In LSP setup flow, load overrides if file exists:
   - Merge default server config + override table.
5. Ensure fallback works if no override file exists.

### Important constraints
- Do not duplicate global handlers/capabilities per file.
- Keep Mason installation list centralized.
- Keep your basedpyright/ruff/sonarlint custom logic unchanged unless intentionally refactored.

### Validation
- Open one file per language server and confirm:
  - server attaches
  - diagnostics appear
  - code actions/rename/hover remain functional
- Run `:LspInfo` and verify no duplicate server configs.

Acceptance:
- Behavior is unchanged for existing servers.
- New server-specific edits become localized to `after/lsp/*.lua`.

---

## Phase 3: Add Diagnostic UX Helpers

### Objective
Adopt practical diagnostic-to-quickfix helpers inspired by jdhao while preserving your current visual style.

### Features to add
1. Keymaps to push diagnostics into quickfix:
   - workspace (open buffers/window scope)
   - current buffer
   - optionally severity-filtered variants (ERROR/WARN)
2. Optional cursor-line diagnostic float autocmd:
   - Open float only when cursor moves to new position.
   - Respect mode/context to avoid noise.

### Implementation location
- New module recommended: `lua/custom/diagnostics.lua`
- Wire from `init.lua` or plugin/lsp setup after diagnostics are available.

### Keymap examples (adapt to your leader conventions)
- `<leader>qw` -> workspace diagnostics to quickfix
- `<leader>qb` -> buffer diagnostics to quickfix
- `<leader>qe` -> errors only

### Safety guardrails
- Debounce or cursor-position cache to prevent repetitive floats.
- Disable float in insert mode and maybe while completion menu is open.
- Do not override your existing tiny-inline-diagnostic choices unless explicit.

### Validation
- Trigger diagnostics intentionally and test all mappings.
- Confirm quickfix list is populated correctly.
- Verify no excessive float popups during normal movement.

Acceptance:
- Faster diagnostic triage with minimal UI disruption.

---

## Phase 4: Add Optional Backup Policy

### Objective
Increase file safety by enabling explicit backup files in a controlled directory.

### Implementation
In `lua/options.lua`:
1. Define backup dir under stdpath data, e.g.:
   - `vim.fn.stdpath('data') .. '/backup//'`
2. Ensure directory exists on startup (`vim.fn.mkdir(..., 'p')`).
3. Enable:
   - `vim.opt.backup = true`
   - `vim.opt.backupdir = <dir>`
   - `vim.opt.backupcopy = 'yes'`
4. Reuse/align with `wildignore` for `backupskip` if desired.

### Optional toggle (recommended)
- Add user-controlled flag:
  - `vim.g.enable_file_backup = true`
- Gate backup setup behind this flag for quick opt-out.

### Validation
- Edit and save a file, confirm backup file appears in backup dir.
- Verify no permission/performance issues.
- Confirm `undofile` still works as expected.

Acceptance:
- Backups are created reliably and confined to one directory.

---

## Phase 5: Add `yanky.nvim` and `render-markdown.nvim`

### 5.1 `gbprod/yanky.nvim`

#### Objective
Improve yank/put ergonomics with history and better paste actions.

#### Implementation
1. Add plugin spec in your existing plugin organization (likely `lua/custom/plugins/init.lua` or a dedicated file).
2. Configure minimal-first:
   - history ring
   - preserve cursor on put where appropriate
3. Add non-conflicting keymaps:
   - Keep default `p/P` unless you explicitly want replacement.
   - Add discoverable mappings under `<leader>y...`.

#### Validation
- Yank multiple entries; cycle/select from history.
- Verify no conflicts with existing text objects/comment tools.

Acceptance:
- Yank history works; no regression in default paste behavior.

### 5.2 `MeanderingProgrammer/render-markdown.nvim`

#### Objective
Improve Markdown readability in-editor (especially useful with Obsidian notes).

#### Implementation
1. Add plugin spec with lazy-load on markdown filetypes.
2. Configure conservative defaults first:
   - headings, lists, code fences rendered
   - avoid aggressive conceal if it clashes with your current UI
3. Ensure compatibility with existing markdown plugins (`plasticboy/vim-markdown`, Obsidian).

#### Validation
- Open large markdown note and checklist-heavy note.
- Confirm performance is acceptable.
- Confirm Obsidian commands/workflow still work.

Acceptance:
- Markdown rendering improves readability without harming editing speed.

---

## Phase 6: Documentation + Operationalization

### 6.1 Document changes
Update `files/.config/nvim/README.md` (or local notes) with:
- Why each improvement was adopted.
- New keymaps.
- Toggle flags (`enable_file_backup`, diagnostic float behavior).
- Where server-specific LSP config now lives (`after/lsp`).

### 6.2 Add maintenance conventions
- Rule: global LSP behavior in `lua/custom/plugins/lsp.lua`; server exceptions in `after/lsp/*.lua`.
- Rule: new diagnostic UX features go through `lua/custom/diagnostics.lua`.
- Rule: plugin additions should start minimal; expand only after validation.

---

## Validation Matrix (end-to-end)

Run after all phases:
1. `nvim --headless '+Lazy! sync' +qa`
2. `nvim --headless '+checkhealth' +qa`
3. Language smoke tests:
   - Python: hover, rename, diagnostics, code actions
   - Lua: diagnostics + formatting
   - Markdown: render plugin behavior + Obsidian commands
4. UX smoke tests:
   - quickfix diagnostic mappings
   - yank history operations
   - startup timing check (ensure no obvious slowdown)

Success criteria:
- No startup errors.
- No lost existing features.
- New behaviors are additive and predictable.

---

## Risk Register

1. LSP config drift during split
- Risk: duplicate handlers/capabilities or missing per-server settings.
- Mitigation: keep shared defaults central; move only server-specific tables.

2. Diagnostic noise
- Risk: cursor float becomes distracting.
- Mitigation: default off or strictly gated by mode + movement cache.

3. Backup side-effects
- Risk: extra disk usage or unexpected backup behavior.
- Mitigation: feature flag + dedicated backup dir + docs.

4. Plugin keymap conflicts
- Risk: `yanky` mappings override muscle memory.
- Mitigation: start with namespaced leader mappings only.

5. Markdown rendering clashes
- Risk: conceal/render conflicts with existing markdown stack.
- Mitigation: lazy-load + conservative options + easy disable toggle.

---

## Rollback Plan

Per phase rollback:
- Revert only files touched in that phase.
- Keep changes isolated by commit for surgical rollback.

Emergency rollback:
- Restore `files/.config/nvim` to previous commit.
- Re-sync plugins with lockfile state.

Post-rollback verification:
- `nvim --headless '+checkhealth' +qa`
- Open Python + Markdown file and verify baseline behavior.

---

## Estimated Effort
- Phase 0: 15–20 min
- Phase 1: 15 min
- Phase 2: 45–90 min (depends on current server complexity)
- Phase 3: 20–40 min
- Phase 4: 10–20 min
- Phase 5: 30–50 min
- Phase 6 + final verification: 20–30 min

Total: ~2.5 to 5 hours (single focused session).

---

## Recommended Order (strict)
1. Version guard
2. LSP split (`after/lsp`)
3. Diagnostic helpers
4. Backup policy
5. New plugins (`yanky`, `render-markdown`)
6. Documentation and final validation

This order minimizes blast radius and makes regressions easy to isolate.

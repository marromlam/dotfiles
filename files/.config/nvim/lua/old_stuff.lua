-- old stuff
-- vim.cmd [[
--   vmap <leader>sk ::w !kitty @ --to=tcp:localhost:$KITTY_PORT send-text --match=num:1 --stdin<CR><CR>
--   autocmd TermOpen * setlocal nonumber norelativenumber
--   autocmd TermOpen * setlocal scl=no
--
--   if has('nvim') && executable('nvr')
--     " pip3 install neovim-remote
--     let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
--     let $EDITOR='nvr --nostart --remote-tab-wait +"set bufhidden=delete"'
--   endif
--   nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>
--   set path+=**,.,,
-- ]]

-- cfilter plugin allows filtering down an existing quickfix list
vim.cmd.packadd 'cfilter'

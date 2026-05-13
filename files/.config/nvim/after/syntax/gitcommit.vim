" Runs after runtime/syntax/gitcommit.vim.
" gitcommitSummary already links the whole first line to Keyword (a distinctive
" color). We leave that intact and add the prefix (word:) linked to a bolder
" group so it stands out from the rest of the summary line.
syn match gitcommitConventionalType '^\w\+!*:' contained containedin=gitcommitSummary
hi link gitcommitConventionalType DiagnosticWarn

" RGB Bubble dark palette for Vim; terminal colors are provided by the terminal.
set background=dark
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'rgb-bubble'
let g:airline_theme = 'minimalist'

hi Normal       guifg=#E6F0FF guibg=#0A101B ctermfg=15 ctermbg=0
hi NormalNC     guifg=#A8B5C8 guibg=#0A101B ctermfg=8 ctermbg=0
hi Cursor       guifg=#0A101B guibg=#F8FBFF ctermfg=0 ctermbg=15
hi CursorLine   guibg=#111B2A ctermbg=8
hi CursorColumn guibg=#111B2A ctermbg=8
hi LineNr       guifg=#53647D ctermfg=8
hi CursorLineNr guifg=#73A3FF gui=bold ctermfg=12 cterm=bold
hi SignColumn   guifg=#8D9DB4 guibg=#0A101B ctermfg=8 ctermbg=0
hi VertSplit    guifg=#263B58 guibg=#0A101B ctermfg=8 ctermbg=0
hi StatusLine   guifg=#E6F0FF guibg=#111B2A ctermfg=15 ctermbg=8
hi StatusLineNC guifg=#8D9DB4 guibg=#0A101B ctermfg=8 ctermbg=0
hi Pmenu        guifg=#E6F0FF guibg=#111B2A ctermfg=15 ctermbg=8
hi PmenuSel     guifg=#F8FBFF guibg=#263B58 ctermfg=15 ctermbg=4
hi Search       guifg=#0A101B guibg=#F3CC78 ctermfg=0 ctermbg=11
hi IncSearch    guifg=#0A101B guibg=#FF7184 ctermfg=0 ctermbg=9
hi Visual       guibg=#263B58 ctermbg=4
hi MatchParen   guifg=#65DCE2 gui=bold ctermfg=14 cterm=bold
hi Comment      guifg=#8D9DB4 gui=italic ctermfg=8 cterm=italic
hi Constant     guifg=#F3CC78 ctermfg=11
hi String       guifg=#4AD69A ctermfg=10
hi Character    guifg=#65DCE2 ctermfg=14
hi Number       guifg=#F3CC78 ctermfg=11
hi Boolean      guifg=#FF9C76 ctermfg=9
hi Identifier   guifg=#C9D8ED ctermfg=15
hi Function     guifg=#73A3FF ctermfg=12
hi Statement    guifg=#D19AFF ctermfg=13
hi Keyword      guifg=#D19AFF ctermfg=13
hi PreProc      guifg=#65DCE2 ctermfg=14
hi Type         guifg=#65DCE2 ctermfg=14
hi Special      guifg=#FF9C76 ctermfg=9
hi Error        guifg=#F8FBFF guibg=#63303D ctermfg=15 ctermbg=1
hi WarningMsg   guifg=#F3CC78 ctermfg=11
hi Todo         guifg=#0A101B guibg=#73A3FF gui=bold ctermfg=0 ctermbg=12 cterm=bold
hi DiffAdd      guifg=#4AD69A guibg=#142A24 ctermfg=10 ctermbg=0
hi DiffDelete   guifg=#FF7184 guibg=#301B25 ctermfg=9 ctermbg=0
hi DiffChange   guifg=#73A3FF guibg=#142033 ctermfg=12 ctermbg=0
hi DiffText     guifg=#F8FBFF guibg=#263B58 gui=bold ctermfg=15 ctermbg=4 cterm=bold
hi DiagnosticError guifg=#FF7184 ctermfg=9
hi DiagnosticWarn  guifg=#F3CC78 ctermfg=11
hi DiagnosticInfo  guifg=#73A3FF ctermfg=12
hi DiagnosticHint  guifg=#65DCE2 ctermfg=14

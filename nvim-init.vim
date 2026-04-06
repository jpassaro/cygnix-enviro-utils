set runtimepath^=~/.vim runtimepath+=~/.vim/after
set shortmess-=F
let &packpath = &runtimepath
" Neovim ignores COLORFGBG for background detection (uses OSC 11 instead).
" Parse it manually so iterm-new/vim-light light-background sessions work.
if !empty($COLORFGBG)
    let s:bg_idx = str2nr(matchstr($COLORFGBG, '\d\+$'))
    if s:bg_idx >= 7 && s:bg_idx != 8
        set background=light
    else
        set background=dark
    endif
endif
source ~/.vimrc

"lua require('jp-metals')

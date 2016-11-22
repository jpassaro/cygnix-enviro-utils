" see https://realpython.com/blog/python/vim-and-python-a-match-made-in-heaven/
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"call vundle#begin('~/custom/bundle/location')

" required
Plugin 'gmarik/Vundle.vim'

" my plugins
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-scripts/mru.vim'
Plugin 'jnurmine/Zenburn'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'isRuslan/vim-es6'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-surround.git'
Plugin 'tpope/vim-abolish.git'
Plugin 'tpope/vim-repeat.git'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-indent'
Plugin 'kana/vim-textobj-line'
Plugin 'b4winckler/vim-angry'
Plugin 'bkad/CamelCaseMotion'
Plugin 'nvie/vim-flake8'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

call camelcasemotion#CreateMotionMappings('<leader>')

" let python_highlight_numbers=1
" let python_highlight_exceptions=1
" let python_highlight_space_errors=1
" let python_no_builtin_highlight=1
syntax on

"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=red guibg=darkred
autocmd BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" shortcut for unfolding a fold.
" nnoremap <space> za
" Disabled so I can learn the keybindings

" never not!
set number

set backspace=start,indent,eol
set hidden

" display tabs everywhere, with width 8, and use spaces instead when entering
" new content
set list listchars=tab:⟩— tabstop=8 expandtab softtabstop=4 shiftwidth=4
" formerly the tabstop bits were in an autocmd, now they set by default.
" autocmd Filetype javascript,html,jinja,vim,python,gitcommit setlocal ...

" but bash is a special baby, for some reason 2-char indent works better
autocmd Filetype sh setlocal softtabstop=2 shiftwidth=2

au BufEnter /private/tmp/crontab.* setlocal backupcopy=yes

set hlsearch " highlights a completed search
set incsearch " jumps to and highlights a search as you type
" use \n to temporarily suppress search highlighting
nnoremap <Leader>n :noh<CR>

" set a useful statusline
set ruler laststatus=2

"timestamp in ruler pulled from vim wikia
"window dimensions in ruler entirely my own (-:
"TODO add git branch...
set rulerformat=%47(%{strftime('%e\ %b\ %T\ %p')}\ %5l,%-6(%c%V%)\ %P%10((%{winwidth(0)}x%{winheight(0)})%)%)

" mark 72nd column in git commit messages
autocmd Filetype gitcommit setlocal colorcolumn=+0

" similar but mark a little ahead since there's no real need to enforce it
autocmd Filetype python,vim setlocal textwidth=78
autocmd Filetype python,vim setlocal colorcolumn=+2

" mark the column with this subtle grey
autocmd Filetype python,gitcommit,vim highlight ColorColumn ctermbg=235

" no autowrap on text
autocmd Filetype python setlocal formatoptions-=t
" continue comment on <Enter> in Insert mode
autocmd Filetype python setlocal formatoptions+=r

" don't autocomment in vimscripts. however, leave 'c' so that it can autowrap
" a very long comment like this one
autocmd Filetype vim setlocal fo-=ro

" create custom vim-surround setting for {% %} and {# #} blocks in jinja
" got the first one from SO i think, link now lost. The others are all me.
autocmd Filetype jinja
        \ let b:surround_{char2nr('^')} = "{% \1{% \1 %}\r{% end\1\r .*\r\1 %}"
autocmd Filetype jinja
        \ let b:surround_{char2nr('%')} = "{% \r %}"
autocmd Filetype jinja
        \ let b:surround_{char2nr('#')} = "{# \r #}"

" enact syntax folds to fight the incredible verbosity of these email templates
autocmd BufRead,BufNewFile app/templates/email/*.html
            \ setlocal foldmethod=syntax
" see vim-dir/after/syntax/html.vim for custom htmlFold definition. The
" built-in folds are pretty nice too (-:

" for debugging syntax settings, copied from vim wikia
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

autocmd BufRead,BufNewFile .log setf gitcommit

" sets :make to run f8diff and read errors into a quickfix list.
" errorformat copied from nvie/vim-flake8
command SetPyMake setlocal makeprg=f8diff makeef=logs/flake.err errorformat="%f:%l:%c: %m\,%f:%l: %m"
autocmd Filetype python SetPyMake

function AutoFlake()
    " sets Flake8 to automatically run upon writing a file
    autocmd BufWrite <buffer> call Flake8()
endfunction
" create the above autocmd when a file is marked with '# autoflake'
autocmd BufReadPost *.py if getline('$') =~ '^\s*\#.*\bautoflake' | call AutoFlake() | endif

function GitNoCommit()
    " abandon a git commit message, but save the results.
    if expand('%') == ".log"
        " ... that's where we would be saving the file. Ya goofed.
        echo "you're working on .log right now you lumbering halfwit."
        return
    endif
    1,/^#/-1 write! .log
    %delete
    write
    quit
endfunction
autocmd Filetype gitcommit command Nocommit call GitNoCommit()

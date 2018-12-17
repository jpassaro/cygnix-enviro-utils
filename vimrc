" see https://realpython.com/blog/python/vim-and-python-a-match-made-in-heaven/
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" let g:vundle_default_git_proto = 'ssh'
" ^^ instead of that, use git config to replace https with ssh. See
" git-aliases
let s:vundlepath=expand('~/.vim/bundle/Vundle.vim')
if isdirectory(s:vundlepath)
    let &rtp .= ','.s:vundlepath
    call vundle#begin()
    "call vundle#begin('~/custom/bundle/location')

    " required
    Plugin 'gmarik/Vundle.vim'

    " my plugins

    " really good python folds
    " but, sadly, slow things down in a 2000+ line file
    Plugin 'tmhedberg/SimpylFold'

    " good python indenting
    Plugin 'vim-scripts/indentpython.vim'

    " inherited from the vimscript from the link at top. I don't actively use this.
    " Plugin 'vim-scripts/mru.vim'

    " likewise... though now that I read the docs and try the color scheme, I may
    " want to try this out!
    " Plugin 'jnurmine/Zenburn'

    " A jinja plugin. Abandoned because it doesn't handle nested comments properly
    Plugin 'Glench/Vim-Jinja2-Syntax'

    " Plugin for ES6 which Zeconomy uses extensively.
    Plugin 'isRuslan/vim-es6'

    " Git utilities. :Gdiff and :Gblame are very useful.
    Plugin 'tpope/vim-fugitive'

    " I use ack regularly in bash to inspect code; and this is an
    " invaluable navigation aid if I actually want to edit around the results.
    " Perhaps needless to say you have to have ack to use. Command :Ack.
    " Only pitfall, sometimes: https://github.com/mileszs/ack.vim/issues/199
    " One of my most-used plugins.
    Plugin 'mileszs/ack.vim'

    " Utilities for surrounding braces. Vim comes with a few text object utilities
    " along these lines but those just help you specify a selection or a motion;
    " this goes further and lets you manipulate the surrounding braces. Frequently
    " used: ys{motion}b to surround the contents of motion with parentheses, ds)
    " to delete surround parentheses (and keep interior content), cSbb to put
    " content on separate line(s) from parens.
    " So, so useful.
    Plugin 'jpassaro/vim-surround'

    " Spelling utilities. I mostly use for :Subvert.
    Plugin 'tpope/vim-abolish'

    " in the tpope/* utilities, some complex commands are defined; this basically
    " instructs the "." to treat each one as a single command. Very useful.
    Plugin 'tpope/vim-repeat'

    " prereq for many custom text objects that I find invaluable. I don't really
    " use it directly.
    Plugin 'kana/vim-textobj-user'

    " indent-based text objects. ai for everything at this indent level or above;
    " ii restricts further to the current paragraph. super useful.
    Plugin 'kana/vim-textobj-indent'

    " al means whole line; il means line minus surrounding whitespace.
    " Occasionally useful.
    Plugin 'kana/vim-textobj-line'

    " text objects based on arguments to a function. ia is the current argument,
    " aa is that plus whitespace and one comma if present. Do not use outside
    " braces.  However it seems to play reasonably nicely with {} and [].
    " Very important.
    Plugin 'b4winckler/vim-angry'

    " name explains itself. example: *C*amelCaseMotion, after \w, navigates to
    " Camel*C*aseMotion. Works with snake_case as well. Provides text objects for
    " inner words as well. So, so useful.
    Plugin 'bkad/CamelCaseMotion'

    " Lets you run flake8 on your script. Works well and very useful; not sure why
    " I'm so unexcited to document it.
    Plugin 'nvie/vim-flake8'

    " Useful largely for highlighting csv file. Has many commands beginning with
    " CSV, found them well-documented the few times I've needed them.
    Plugin 'chrisbra/csv.vim'

    " A bunch of ]-mappings. [q / ]q move you through quickfix list, [f / ]f move
    " through arg files, &c. [e / ]e moves current line or selection up or down by
    " [count] lines; [<space> / ]<space> adds lines above or before this line
    " instead of calling o<Esc> or O<Esc>. Saves a lot of time.
    Plugin 'tpope/vim-unimpaired'

    " runs make and shit asynchronously. ack.vim has this as an optional
    " dependency; it improves performance very noticeably and seems to solve an
    " extremely annoying problem I was running into occasionally
    " (https://github.com/mileszs/ack.vim/issues/199). Highly recommend, at least
    " with ack.vim.
    Plugin 'tpope/vim-dispatch'

    " adds endif, done, etc in bash and vimL, one day jinja.
    Plugin 'tpope/vim-endwise'

    " autocomplete; untested
    " been having performance problems, don't know if this is why but can't hurt
    " Plugin 'davidhalter/jedi-vim'

    " instead we try this which seems to be more popular. Requires MacVim.
    " holy shit, real performance issues... maybe my computer sucks
    " Plugin 'Valloric/YouCompleteMe'

    " syntastic is working pretty well... mostly replaces vim-flake8 too!
    Plugin 'vim-syntastic/syntastic'

    " compiler settings for eslint
    Plugin 'salomvary/vim-eslint-compiler'

    " workflow helper, for SQL especially
    Plugin 'krisajenkins/vim-pipe'

    " syntax highlighter for postgres-specific SQL
    "Plugin 'krisajenkins/vim-postgresql-syntax'

    " recommended by SimpylFold to speed up folding (it's pretty bad for large
    " files...
    Plugin 'Konfekt/FastFold'

    " graphviz -- digraphs
    Plugin 'wannesm/wmgraphviz.vim'

    " read coverage report
    Plugin 'mgedmin/coverage-highlight.vim'

    " mscgen syntax
    Plugin 'goodell/vim-mscgen'

    " possible improvement on previous jinja plugin. Abandoned in favor of custom
    " fix in .vim/after/syntax/jinja.vim
    " Plugin 'mitsuhiko/vim-jinja'

    " support for direnv files and settings
    Plugin 'direnv/direnv.vim'

    " new and improved python syntax
    Plugin 'vim-python/python-syntax'

    " more tpope: xml autofill
    Plugin 'tpope/vim-ragtag'

    " maybe puts git line status in the 'gutter'?
    Plugin 'airblade/vim-gitgutter'

    " adds useful stuff like :Chmod
    Plugin 'tpope/vim-eunuch'

    " cross-editor text properties
    Plugin 'editorconfig/editorconfig-vim'

    " better statusline plugin
    Plugin 'itchyny/lightline.vim'

    " All Plugins must be added before the following line
    call vundle#end()            " required
else
    echoerr 'Vundle was not found. Consider executing "git clone gh:gmarik/Vundle.vim ~/.vim/bundle/Vundle.vim"'
    unlet s:vundlepath
endif

filetype plugin indent on    " required

function CheckVundle(featurename)
    let result = exists('s:vundlepath')
    if ! ( result || empty(a:featurename) )
        echoerr 'need vundle installed to support' a:featurename
    endif
    return result
endfunction

" \w, \b, \e, a\w, i\w ... etc, motions for moving inside a camel case word.
if CheckVundle('camel case mappings')
    silent! call camelcasemotion#CreateMotionMappings('<leader>')
endif

" syntax highlighting! I think.
syntax on

"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=red guibg=darkred
autocmd ColorScheme * highlight BadWhitespace ctermbg=red guibg=darkred
autocmd BufRead,BufNewFile * match BadWhitespace /\s\+$/

" shortcut for unfolding a fold.
" nnoremap <space> za
" Disabled in favor of using z-* keybindings directly, which are somewhat more
" powerful and more useful.

" number lines, always, no exceptions
set number

" backspace works globally
set backspace=start,indent,eol
" keeps buffers around if you "abandon" them. I don't entirely understand it.
set hidden

" display this funny unicode thing for every tab everywhere, with width 8
set list listchars=tab:⟩— tabstop=8
" use spaces instead when entering new content, and let my tabs have width 4.
" shiftwidth too, see docs for distinction.
set expandtab softtabstop=4 shiftwidth=4
" formerly the tabstop bits were in a filetype autocmd; now we set them
" globally.
" autocmd Filetype javascript,html,jinja,vim,python,gitcommit setlocal ...

" bash is a special baby, for some reason I find 2-char indent works better
autocmd Filetype sh setlocal softtabstop=2 shiftwidth=2

" I do not remember how this got in here. It seems fine.
au BufEnter /private/tmp/crontab.* setlocal backupcopy=yes

set hlsearch " highlights a completed search
set incsearch " jumps to and highlights a search as you type
" use \n to temporarily suppress search highlighting
nnoremap <Leader>n :<C-U>noh<CR>:<CR>

set laststatus=2
if CheckVundle('fancy status line')
    let g:lightline = {
                \ 'colorscheme': 'Tomorrow_Night_Eighties',
                \ 'active': {
                \    'left': [
                \       ['mode'],
                \       ['readonly', 'filename', 'modified'],
                \       ['branchname', 'timestamp']
                \    ],
                \    'right': [
                \       ['jpdimensions'],
                \       ['lineinfo', 'percent'],
                \       ['charvaluehex', 'fileformat', 'filetype'],
                \    ]
                \  },
                \  'component': {
                \    'charvaluehex': '0x%B',
                \    'jpdimensions': '(%{winwidth(0)}x%{winheight(0)})',
                \    'percent': '%P',
                \    'fileformat': '%{&ff==#"unix"?"":&ff}',
                \    'filetype': '%{&ft}'
                \  },
                \  'component_visible_condition': {
                \    'fileformat': '&ff==#"unix" || &ff',
                \    'filetype': '&ft'
                \  },
                \  'component_function': {
                \    'timestamp': 'JPtimestamp',
                \    'branchname': 'JPshortGitHead'
                \  }
                \}
    function JPtimestamp()
        return strftime('%e %b %T')
    endfunction
    if ! exists('g:jpmaxgitbrlen')
        let g:jpmaxgitbrlen = 12
    endif
    function JPshortGitHead()
        return fugitive#head()[0 : g:jpmaxgitbrlen]
    endfunction
else
    " set a useful statusline
    set ruler

    " timestamp in ruler pulled from vim wikia
    " window dimensions in ruler entirely my own (-: it took some doing!
    set rulerformat=%47(%{strftime('%b\ %T\ %p')}\ %5l,%-6(%c%V%)\ %P%10((%{winwidth(0)}x%{winheight(0)})%)%)
endif


" mark the right border with a subtle grey. That's 80 in python/vimL, 72 in
" commit messages, for now the biggest places I care about line length.
autocmd Filetype python,gitcommit,vim,bash highlight ColorColumn ctermbg=235
" soft limit, no real need to enforce.
autocmd Filetype python,vim,bash setlocal colorcolumn=+2 textwidth=78
" no autowrap on text
autocmd Filetype python setlocal formatoptions-=t
" continue comment on <Enter> in Insert mode
autocmd Filetype python,bash setlocal formatoptions+=r
" strict limit; textwidth=72 from distro plugin, and it also sets
" formatoptions to my liking
autocmd Filetype gitcommit setlocal colorcolumn=+0 " textwidth is already 72

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

" enact syntax folds to fight the incredible verbosity of zeconomy email
" templates. see vim-dir/after/syntax/html.vim for custom htmlFold definition.
" The built-in folds are pretty nice too (-:
autocmd BufRead,BufNewFile app/templates/email/*.html
            \ setlocal foldmethod=syntax

" for debugging syntax settings, copied from vim wikia
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" sets :make to run f8diff and read errors into a quickfix list.
" errorformat copied from nvie/vim-flake8
command SetPyMake setlocal makeprg=f8diff makeef=/tmp/flake.err errorformat="%f:%l:%c: %m\,%f:%l: %m"
autocmd Filetype python SetPyMake

" my convention is to save temporary git files as "./.log"
autocmd BufRead,BufNewFile .log setf gitcommit

" define command :Nocommit to abandon a git commit message but save the results
autocmd Filetype gitcommit command Nocommit call GitNoCommit()
function GitNoCommit()
    if expand('%') == ".log"
        " ... that's where we would be saving the file. Ya goofed.
        echo "you're working on .log right now you lumbering halfwit."
        return
    endif
    write! .log
    %delete
    write
    quit
endfunction

" helpful wildcard settings
set wildmode=full wildmenu
" displays full list of wildcard matches as you tab through them

" set splitright

" search code base for whole-word matches of current word. Kind of like "*"
" across a whole project instead of a file.
nnoremap gb :Ack -Qw <cword><CR>
" same but cWORD indicates non-space "word" instead of token-defined "word"
nnoremap gB :Ack -Qw <cWORD><CR>

autocmd BufRead,BufNewFile Dockerfile.* setlocal filetype=dockerfile

" vizualizes fold structure
autocmd FileType python set foldcolumn=4

" function DeleteBackward(count, newline) abort
"     exec "normal! ". a:count . "X"
"     if a:newline
"         normal! i<CR><Esc>
"         repeat#set("\<Plug>JpassaroDeleteBackwardNewline", count)
"     else
"         repeat#set("\<Plug>JpassaroDeleteBackward", count)
"     endif
" endfunction
" nnoremap <silent> <Plug>JPassaroDeleteBackward :<C-U>call DeleteBackward(v:count1)
" delete backward then start an insert.
" TODO: try and figure out how to use repeat.vim on this.
nnoremap <unique> S Xi
nnoremap <unique> zS Xi<CR><Esc>

" A bunch of stuff to populate the search register and highlight the results.
" Inspired by something on the msgboard that points out you don't always want
" the usual "*" behavior of navigating to the next match in order to get the
" highlighting.
" Note: The direction bit doesn't work right now. I think vim resets
" v:searchforward after a function. TODO: see if I can override
function SetSearch(patt, direction, ...)
    let thing = a:patt
    if a:0
        let thing = escape(thing, '\')
    endif
    let @/ = thing
    let v:searchforward = a:direction
endfunction

" highlight matches of the current word
nnoremap <silent> z* :call SetSearch(expand("<cword>"), 1, 1)<CR>:set hls<CR>
" highlight matches of the current word when they appear as a word
nnoremap <silent> Z* :call SetSearch("<".expand("<cword>").">", 1, 1)<CR>:set hls<CR>
" like z* but set search direction to backward
nnoremap <silent> z# :call SetSearch(expand("<cword>"), 0, 1)<CR>:set hls<CR>
" like Z* but set search direction to backward
nnoremap <silent> Z# :call SetSearch('\<'.expand("<cword>").'\>', 0, 1)<CR>:set hls<CR>

" to use with motion operators and visual mode
" doesn't work with linewise selection/motions or block selection
function SetSearchFromSelection(type, direction, ...)
    let sel_save = &selection
    let reg_save = @@
    let proceed = 1
    if a:0
        silent exe "normal! gvy"
    elseif a:type == 'char'
        silent exe "normal! `[v`]y"
    else
        proceed = 0
    endif

    if proceed == 1
        call SetSearch('\V' . @@, a:direction)
    endif

    let &selection = sel_save
    let @@ = reg_save

    let &hlsearch = 1
endfunction

" search for next/last instance of selection. Normally keeps you in visual and
" just moves cursor to next word, which is sensible but rarely useful for me.
vnoremap <silent> * :<C-U>call SetSearchFromSelection(visualmode(), 1, 1)<CR>n<CR>
vnoremap <silent> # :<C-U>call SetSearchFromSelection(visualmode(), 0, 1)<CR>n<CR>

" like the above mappings but without navigating.
vnoremap <silent> z* :<C-U>call SetSearchFromSelection(visualmode(), 1, 1)<CR>:set hls<CR>
vnoremap <silent> z# :<C-U>call SetSearchFromSelection(visualmode(), 0, 1)<CR>:set hls<CR>

" place text under motions into search register and highlight them. only words
" with character-wise motions.
nnoremap <silent> =* :set operatorfunc=OperatorSetSearchForward<CR>g@
nnoremap <silent> =# :set operatorfunc=OperatorSetSearchBackward<CR>g@
function OperatorSetSearchForward(type)
    call SetSearchFromSelection(a:type, 1)
endfunction
function OperatorSetSearchBackward(type)
    call SetSearchFromSelection(a:type, 0)
endfunction

" tried zenburn... it was okay but not always.
" I'm currently liking slate for html...
colorscheme slate

function! NewlineBefore() abort
    let l:nlcount = v:count1
    while col('.') >= 2 && getline('.')[col('.')-2] =~ '\s'
        normal! h
    endwhile
    execute "normal! " . l:nlcount . "i\<cr>"
    silent! call repeat#set("\<Plug>PassaroNewlineBefore")
endfunction

nnoremap <unique> <Plug>PassaroNewlineBefore :<C-U>call NewlineBefore()<CR>

" Another unimpaired-style mapping to create newlines.
nnoremap <unique> [<CR> :<C-U>call NewlineBefore()<CR>
nnoremap <unique> ]<CR> a<CR><Esc><C-O>

" tell ack.vim to use dispatch
let g:ack_use_dispatch = 1
let g:dispatch_use_shell_escape = 1

" syntastic settings
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_python_checkers = ['flake8']
" let g:syntastic_python_flake8_args = '--select=E901,F821,F401,F841,F812'


function OverridePermissiveFlake8()
    let lastline = getline('$')
    if lastline =~? '^\s*\#.*autoflake'
        let b:syntastic_python_flake8_args = ''
    elseif lastline =~? '^\s*#.*dirtyflake'
        let b:syntastic_python_flake8_args = '--select=E901'
    endif
endfunction
autocmd FileType python call OverridePermissiveFlake8()

autocmd FileType javascript compiler eslint

autocmd BufRead,BufNewFile *.har set filetype=json

function! LoanCalc() abort
    normal! G
    read !python ~/.vim/loan-calc.py %
endfunction

autocmd FileType json command! LoanCalc :call LoanCalc()<CR>

let g:SimpylFold_fold_import = 0

let g:WMGraphviz_output = 'png'

autocmd filetype dot let b:vimpipe_command="dot-pipe -o"

" unimpaired: ]<C-Q> doesn't work for unknown reasons, providing an alternative
nmap [Z <Plug>unimpairedQPFile
nmap ]Z <Plug>unimpairedQNFile

" used with builtin python indenter, see :help ft-pythong-indent
" let g:pyindent_open_paren = '&sw'
" let g:pyindent_continue = '&sw'

" suggested by vim_use mailing list
set t_u7=
set t_RV=

" for vim-python/python-syntax
let g:python_highlight_all = 1
let g:python_highlight_string_templates = 0

" enable vim-pipe on selections
vnoremap <silent> <LocalLeader>r :<C-U>'<,'> call VimPipe()<CR>
nnoremap <silent> <LocalLeader>r :<C-U>. call VimPipe()<CR>
let g:vimpipe_invoke_map = '<LocalLeader>R'

" vim-pipe mysql
function SetupMysqlVimpipe(db, host, user, password)
    let b:vimpipe_command = "mysql " . a:db
                \ . " --host=" . a:host
                \ . " --user=" . a:user
                \ . " --password='" . a:password
                \ . "' --table"
endfunction

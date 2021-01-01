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
    " Plugin 'direnv/direnv.vim'

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

    " typescript
    Plugin 'leafgarland/typescript-vim'

    " date increments (primarily for .progress/log)
    Plugin 'tpope/vim-speeddating'

    " new shiny color scheme
    Plugin 'altercation/vim-colors-solarized'

    " pug templates for node development
    Plugin 'digitaltoad/vim-pug'

    " All Plugins must be added before the following line
    call vundle#end()            " required
else
    echoerr 'Vundle was not found. Consider executing "git clone gh:VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim"'
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

" special babies in which for some reason 2-char indent works better
autocmd Filetype sh,scala,yaml setlocal softtabstop=2 shiftwidth=2

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
autocmd Filetype python,gitcommit,vim,bash,pullrequest highlight ColorColumn ctermbg=235
" soft limit, no real need to enforce.
autocmd Filetype python,vim,bash,markdown,rst setlocal colorcolumn=+2 textwidth=78
autocmd FileType pullrequest setlocal textwidth=72
" no autowrap on text
autocmd Filetype python setlocal formatoptions-=t
" continue comment on <Enter> in Insert mode
autocmd Filetype python,bash setlocal formatoptions+=r
" strict limit; textwidth=72 from distro plugin, and it also sets
" formatoptions to my liking
autocmd Filetype gitcommit,pullrequest setlocal colorcolumn=+0 " textwidth is already 72

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
command SetPyMake setlocal makeprg=flake8 makeef=/tmp/flake.err errorformat="%f:%l:%c: %m\,%f:%l: %m"
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

" highlight matches of the current word
nmap <silent> z* <Plug>JpvimrcNohi:call SetSearch(expand("<cword>"))<CR>:let v:searchforward = 1<CR>
" highlight matches of the current word when they appear as a word
nmap <silent> Z* <Plug>JpvimrcNohi:call SetSearch("<".expand("<cword>").">")<CR>:let v:searchforward = 1<CR>
" like the above but with cWORD instead of cword (i.e. iW instead of iw)
nmap <silent> <Leader>z* <Plug>JpvimrcNohi:call SetSearch(expand("<cWORD>"))<CR>:let v:searchforward = 1<CR>
nmap <silent> <Leader>Z* <Plug>JpvimrcNohi:call SetSearch("<".expand("<cWORD>").">")<CR>:let v:searchforward = 1<CR>
" like the above but set search direction to backward
nmap <silent> z# <Plug>JpvimrcNohi:call SetSearch(expand("<cword>"))<CR>:let v:searchforward = 0<CR>
nmap <silent> Z# <Plug>JpvimrcNohi:call SetSearch('\<'.expand("<cword>").'\>')<CR>:let v:searchforward = 0<CR>
nmap <silent> <Leader>z# <Plug>JpvimrcNohi:call SetSearch(expand("<cWORD>"))<CR>:let v:searchforward = 0<CR>
nmap <silent> <Leader>Z# <Plug>JpvimrcNohi:call SetSearch("<".expand("<cWORD>").">")<CR>:let v:searchforward = 0<CR>

" search for next/last use of cWORD
nmap <silent> <Leader>* <Leader>z*n
nmap <silent> <Leader># <Leader>z#n

" search for next/last instance of selection. Normally keeps you in visual and
" just moves cursor to next word, which is sensible but rarely useful for me.
vmap <silent> z* <Plug>JpvimrcNohi:call SetSearchFromSelection(visualmode())<CR>:let v:searchforward = 1<CR>
vmap <silent> z# <Plug>JpvimrcNohi:call SetSearchFromSelection(visualmode())<CR>:let v:searchforward = 0<CR>
" like the above mappings but navigate as well.
vmap <silent> * z*n
vmap <silent> # z#n

" place text under motions into search register and highlight them. only works
" with character-wise motions.
nmap <silent> =* <Plug>JpvimrcNohi:<C-U>set operatorfunc=SetSearchFromSelection<CR>g@
nmap <silent> g=* <Plug>JpvimrcNohi:<C-U>set operatorfunc=SetSearchFromSelectionCaseInsensitive<CR>g@

" this doesn't work because i can't call let v:searchforward afterward
"nmap <silent> =# <Plug>JpvimrcNohi:<C-U>set operatorfunc=SetSearchBackward<CR>g@
nmap <silent> =# :echoerr '(jpvimrc) searching backward from a motion is not supported'<CR>

" this is undone at the end of a function, so it has to be done directly in
" the mapping. Likewise the :let v:searchforward = ?
map <silent> <Plug>JpvimrcNohi :<C-U>set nohlsearch<CR>

" set the search pattern and direction and activate hlsearch
function SetSearch(patt)
    let thing = a:patt
    let @/ = thing
    set hlsearch
endfunction

" to use with motion operators and visual mode
" doesn't work with linewise selection/motions or block selection
function s:setSearchFromSelection(type)
    let sel_save = &selection
    let reg_save = @@
    try
        if a:type == 'v' " visualmode() in char mode
            silent exe "normal! gvy"
        elseif a:type == 'char' " from g@ for character motions
            silent exe "normal! `[v`]y"
        else
            throw '(jpvimrc) cannot set search pattern from a non-char selection'
        endif

        call SetSearch('\V' . @@)
    finally
        let &selection = sel_save
        let @@ = reg_save
    endtry
endfunction

function SetSearchFromSelection(type) abort
    try
        call s:setSearchFromSelection(a:type)
    catch /^(jpvimrc)/
        echoerr v:exception
    endtry
endfunction

" tried zenburn... it was okay but not always.
" I'm currently liking slate for html...
if $ITERM_PROFILE =~? 'solarized' && CheckVundle('solarized')
    colorscheme solarized
else
    colorscheme slate
endif

function! NewlineNearCursor(where) abort
    let nlcount = v:count1
    let origcol = col('.')
    let leftcol = col('.')
    let curline = getline('.')
    if a:where == 'before'
        let action = 'i'
        while leftcol >= 2 && curline[leftcol-2] =~ '\s'
            let leftcol -= 1
        endwhile
        let repeatable = "\<Plug>JpvimrcNewlineBeforeCursor"
    elseif a:where == 'after'
        let action = 'a'
        let leftcol += 1
        let repeatable = "\<Plug>JpvimrcNewlineAfterCursor"
    else
        throw '(jpvimrc) bad argument "' . a:where . '"'
    endif
    let rightcol = max([origcol, leftcol])
    while rightcol <= len(curline) && curline[rightcol-1] =~ '\s'
        let rightcol += 1
    endwhile
    if rightcol > leftcol
        call cursor(curline, leftcol)
        execute 'normal! "_' . (rightcol - leftcol) . 'x'
        let action = 'i'
    endif
    execute "normal! " nlcount . action . "\<CR>"
    silent! call repeat#set(repeatable, nlcount)
endfunction

nnoremap <unique> <Plug>JpvimrcNewlineBeforeCursor :<C-U>call NewlineNearCursor("before")<CR>
nnoremap <unique> <Plug>JpvimrcNewlineAfterCursor :<C-U>call NewlineNearCursor("after")<CR>

" Another unimpaired-style mapping to create newlines.
nmap <unique> [<CR> <Plug>JpvimrcNewlineBeforeCursor
nmap <unique> ]<CR> <Plug>JpvimrcNewlineAfterCursor

" tell ack.vim to use dispatch
let g:ack_use_dispatch = 1
let g:dispatch_use_shell_escape = 1

" syntastic settings
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_python_checkers = ['flake8', 'mypy']
" let g:syntastic_python_flake8_args = '--select=E901,F821,F401,F841,F812'
let g:syntastic_sh_shellcheck_args = '-x'


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

if $TERM_PROGRAM =~? 'iterm'
    let &t_SI = "\<ESC>]1337;CursorShape=1\x7"  " vertical bar
    let &t_SR = "\<ESC>]1337;CursorShape=2\x7"  " underline
    let &t_EI = "\<ESC>]1337;CursorShape=0\x7"  " block
endif

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

" i am getting so tired of syntax errors when sh files use bash
" constructions...
let g:bash_is_sh = 1

" make sure there is time to finish syntax highlighting
set redrawtime=4000 " usually 2000

" how long gitgutter has to wait before updating lines
set updatetime=250

autocmd BufEnter */mothersback/ts/*.ts let b:syntastic_checkers = ["tsc", "tslint"]

autocmd BufRead,BufNewFile *.njk set filetype=jinja

autocmd BufRead,BufNewFile */.progress/log.txt call SetUpProgressLog()
autocmd BufRead,BufNewFile ~/_progress/log.txt call SetUpProgressLog()

function SetUpProgressLog()
    if exists('b:jp_progress_log_setup')
        return
    endif
    let b:jp_progress_log_setup = 1
    autocmd BufWritePost <buffer> call SaveProgressCopy()
    "map <buffer> <Leader>r :<C-U>call ResetProgressLog()<CR>
    command -buffer ProgressNext call ResetProgressLog()
endfunction

function ProgressLogDate()
    if ! search('^\vDate: \zs\d{4}-\d{2}-\d{2}%(.*/)@!', 'cw')
        throw '(jpvimrc) Unable to find a "Date:" line (does it have slash?)'
    endif
endfunction

function SaveProgressCopy()
    let oldlnum = line('.')
    let oldcnum = col('.')
    try
        call ProgressLogDate()
        let backup = expand('%') . '.vimbak.' . expand('<cfile>')
        exec "write!" backup
    finally
        call cursor(oldlnum, oldcnum)
    endtry
endfunction

if ! exists('g:jpvimrc_progress_todaygoal')
    let g:jpvimrc_progress_todaygoal = '@goalsfortoday'
endif
if ! exists('g:jpvimrc_progress_todayactual')
    let g:jpvimrc_progress_todayactual = '@actualaccomplishment'
endif
if ! exists('g:jpvimrc_progress_tmrwgoal')
    let g:jpvimrc_progress_tmrwgoal = '@nextdaygoals'
endif

function SearchForwardOrBust(patt)
    if ! search('.\+' . a:patt . '$')
        throw '(jpvimrc) did not find "' . a:patt . '" ahead of current cursor'
    endif
    return line('.')
endfunction

function ResetProgressLog() abort
    let todaygoal = g:jpvimrc_progress_todaygoal
    let todayactual = g:jpvimrc_progress_todayactual
    let tmrwgoal = g:jpvimrc_progress_tmrwgoal
    silent write
    call ProgressLogDate()
    exec "normal!" "C" . strftime("%Y-%m-%d")
    let  toinsert = ['']
    let  deletestart = 1 + SearchForwardOrBust(todaygoal)
    call extend(toinsert, [getline(SearchForwardOrBust(todayactual)), '', ''])
    let  deleteend = SearchForwardOrBust(tmrwgoal)
    call extend(toinsert, [getline('.'), '', ''])

    call deletebufline('%', deletestart, deleteend)

    call search('{END LOG}', 'cw')
    call append(line('.') - 1, toinsert)
    call search(g:jpvimrc_progress_todayactual . '$', 'b')
    call cursor(1 + line('.'), 0) " equiv: normal j0
endfunction

autocmd FileType jinja call RagtagInit()

hi Define ctermfg=10

nnoremap <unique> <Leader>c :<C-U>helpclose<CR>

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'fatih/vim-go'
au FileType go set noexpandtab shiftwidth=2
call vundle#end()
" au BufRead,BufNewFile *.cf set ft=cf3
" au BufRead,BufNewFile *.go set ft=go
syntax on
set tabstop=5       " number of visual spaces per TAB
set softtabstop=5   " number of spaces in tab when editing
set shiftwidth=5    " number of spaces for < and >"
set expandtab       " tabs are spaces
set nonumber              " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
filetype indent on      " load filetype-specific indent files
set wildmenu            " visual autocomplete for command menu
set showmatch           " {([])}
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set paste               " set paste
hi Comment ctermfg=111
" colorscheme delek
:autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/
:autocmd Syntax * highlight ExtraWhitespace ctermbg=red guibg=red
:autocmd BufWritePre * :%s/\s\+$//e

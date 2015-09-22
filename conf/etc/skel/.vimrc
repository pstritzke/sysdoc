" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set nobackup		" do not keep a backup file, use versions instead

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
    set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &term =~ '256color' || &t_Co > 2
    set t_ut=
    set t_Co=256
    syntax on
    set hlsearch
    colorscheme desert
endif


set wrap                

" Only do this part when compiled with support for autocommands.
if has("autocmd")


    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

endif " has("autocmd")


set clipboard+=unnamed
" set clipboard=autoselect 
set paste
set pastetoggle=<f5>

set nowrap                      " don't wrap lines
set tabstop=8     " tabs are at proper location
set expandtab     " don't use actual tab character (ctrl-v)
set shiftwidth=4  " indenting is 4 spaces
set softtabstop=4 
set backspace=indent,eol,start  " backspace through everything in insert mode

set autoindent    " turns it on
set smartindent   " does the right thing (mostly) in programs
set cindent       " stricter rules for C programs

map <F2> :tabnew 
map <F3> :tabprevious<CR>
map <F4> :tabnext<CR>

" Show Line Numbers
set nu
set complete=.,b,u,]
set wildmode=longest,list:longest
set completeopt=menu,preview

set backupdir=~/.vim
set directory=~/.vim

set spell spelllang=en_us

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


" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

set clipboard=autoselect 

set nowrap                      " don't wrap lines
set tabstop=8 softtabstop=4 shiftwidth=4      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
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

set backupdir=~/.vim,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim,~/.tmp,~/tmp,/var/tmp,/tmp
set pastetoggle=<f5>

set spell spelllang=en_us

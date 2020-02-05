set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tomasr/molokai'
Plugin 'morhetz/gruvbox'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on

colorscheme molokai

" colorscheme gruvbox
" set background=dark
" let g:gruvbox_contrast_light='hard'
" let g:gruvbox_contrast_dark='hard'

syntax on

set vb t_vb=
set showcmd
set showmatch

set cino =:0    " don't indent case statements
set cino+=g0    " don't indent class visibility specifiers
set cino+=N-s   " don't indent inside a namespace
set cino+=t0    " don't indent function return types on their own line
set cino+=(0    " align to parens

set formatoptions=croqnjt
set backspace=indent,eol,start
set virtualedit=block
set shortmess=aIA
set ls=2
set ruler
set scrolloff=3
set nowrap
set nu
set smartcase

set wildignore+=*.o,*.so,*.dll,*.a,*.vi,*.exe,*.cd,*.obj
set wildignore+=*.ko,tags
set wildignore+=*.sln,*.vcproj,*.vspscc,*.dsw,*.dsp
set wildignore+=*.png,*.pdf,*.bmp,*.jpg,*.jpeg,*.gif

" Some easier movement
nmap <C-h> <C-w><C-h>
nmap <C-j> <C-w><C-j>
nmap <C-k> <C-w><C-k>
nmap <C-l> <C-w><C-l>

cmap w!! w !sudo tee % >/dev/null
com! CD cd %:p:h

set ts=8 sw=8 sts=8 noexpandtab

au BufRead,BufNewFile *.dtsi set filetype=dts
au BufRead,BufNewFile *.dtso set filetype=dts
au BufRead,BufNewFile *.its set filetype=dts

au FileType java setl sw=4 sts=4 ts=4 noexpandtab
au FileType python setl sw=4 sts=4 ts=4 expandtab
au FileType haskell setl sw=4 sts=4 ts=8 expandtab
au FileType cpp setl sw=8 sts=8 ts=8 noexpandtab

set cinkeys=0{,0},0),:,0#,!^F,o,O,e,*0<comma>

set backupdir=~/.vim-backup

set colorcolumn=80

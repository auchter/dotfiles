{ config, pkgs, lib, ... }:

{
  imports = [
    ./graphical.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "a";
  home.homeDirectory = "/home/a";

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  programs.password-store = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Michael Auchter";
    userEmail = "a@phire.org";
    aliases = {
      # From https://stackoverflow.com/a/5188364
      list-branches = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
    };
    ignores = [ ".*.sw*" "*.o" "*.ko" "*.pyc" ];
    extraConfig = {
      core = {
        editor = "vim";
      };
      merge = {
        renamelimit = 65535;
        ff = "only";
      };
      pull.ff = "only";
      rerere.enabled = "true";
      am.threeWay = true;
      init.defaultBranch = "main";
    };
  };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      media_library_primary_tag = "album_artist";
      display_bitrate = "yes";
      mouse_support = "no";
      message_delay_time = 2;
      playlist_separate_albums = "yes";
      playlist_display_mode = "columns";
      browser_display_mode = "columns";
      search_engine_display_mode = "columns";
      seek_time = "10";
      ignore_diacritics = "yes";
    };
    bindings =
      let
        bindChain = key: cmds: [ { key = "${key}"; command = cmds;  } ];
        bindMultiple = key: cmds: map (cmd: { key = "${key}"; command = "${cmd}"; }) cmds;
      in
        bindChain "j" "scroll_down" ++
        bindChain "J" [ "select_item" "scroll_down" ] ++
        bindChain "k" "scroll_up" ++
        bindChain "K" [ "select_item" "scroll_up" ] ++
        bindChain "ctrl-u" "page_up" ++
        bindChain "ctrl-d" "page_down" ++
        bindMultiple "l" [ "show_lyrics" "next_column" "slave_screen" ] ++
        bindMultiple "h" [ "previous_column" "master_screen" ];
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      fugitive
      gitgutter
      gruvbox
      molokai
      nerdtree
      vim-git
      vim-nix
    ];
    extraConfig = ''
      set nocompatible
      filetype plugin indent on

      colorscheme gruvbox
      set background=dark
      let g:gruvbox_contrast_light='hard'
      let g:gruvbox_contrast_dark='hard'

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
      set wildignore+=*.dtb,*.dtbo

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
      " au FileType cpp setl sw=4 sts=4 ts=4 expandtab
      au FileType cmake setl sw=4 sts=4 ts=4 expandtab
      au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

      set cinkeys=0{,0},0),:,0#,!^F,o,O,e,*0<comma>

      set backupdir=~/.vim/backup

      set colorcolumn=80

      " nerdtree
      nmap <leader>nv :NERDTreeToggleVCS<CR>
      nmap <leader>nt :NERDTreeToggle<CR>
      nmap <leader>nf :NERDTreeFind<CR>
      let NERDTreeRespectWildIgnore=1
    '';
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "screen-256color";
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ ];
    };
    initExtra = ''
      setopt prompt_subst
      autoload colors
      colors
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' formats '%F{green}%s%F{7} %F{2}(%F{blue}%b%F{2})%f '
      zstyle ':vcs_info:*' enable git

      PS1=' ''${vcs_info_msg_0_}%F{green}%n@%m%k %F{blue}%1~ %# %b%f%k'
      RPROMPT='''

      precmd() {
         title "zsh" "%m" "%55<...<%~"
         vcs_info 'prompt'
      }

      bindkey '^P' reverse-menu-complete
      bindkey '^N' expand-or-complete

      setopt CORRECT
      setopt COMPLETE_IN_WORD
    '';
    shellAliases = {
      f="fg";
      ls="ls --color=auto";

      gdc="git describe --contains";
      grm="git commit --reuse-message=HEAD@{1}";

      bb="bitbake";
      fixssh="eval $(tmux showenv -s SSH_AUTH_SOCK)";
      hm-switch = "home-manager switch --flake ~/dotfiles";
    };
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

if has("nvim")
  let g:plug_home = stdpath('data') . '/plugged'
endif

call plug#begin()

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'cohama/lexima.vim'

if has("nvim")
  Plug 'neovim/nvim-lspconfig'
  Plug 'glepnir/lspsaga.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do' : ':TSUpdate'}

  " completition
  "Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
  " 9000+ Snippets
  "Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

  " telescope
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  Plug 'hoob3rt/lualine.nvim'

  Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}

  Plug 'Chiel92/vim-autoformat'
  Plug 'mhartington/formatter.nvim'
  Plug 'easymotion/vim-easymotion'
  " Plug 'tmhedberg/SimpylFold'

  let g:vimspector_enable_mappings = 'HUMAN'
  Plug 'puremourning/vimspector'

  Plug 'vim-test/vim-test'

  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

  Plug 'othree/html5.vim'
  Plug 'pangloss/vim-javascript'
  Plug 'evanleck/vim-svelte', {'branch': 'main'}


  Plug 'tpope/vim-dadbod'
  Plug 'kristijanhusak/vim-dadbod-ui'
  Plug 'jparise/vim-graphql'

  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'

  Plug 'mfussenegger/nvim-dap'
  Plug 'theHamsta/nvim-dap-virtual-text'
  Plug 'rcarriga/nvim-dap-ui'
  Plug 'nvim-neotest/nvim-nio'


  Plug 'mrcjkb/rustaceanvim'
  " Plug 'simrat39/rust-tools.nvim'  " --- DEPRECATED
  "
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'

  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'

  Plug 'kiyoon/jupynium.nvim', { 'do': 'pip3 install --user .' }
  " Plug 'kiyoon/jupynium.nvim', { 'do': 'conda run --no-capture-output -n jupynium pip install .' }
  Plug 'rcarriga/nvim-notify'   " optional
  Plug 'stevearc/dressing.nvim' " optional, UI for :JupyniumKernelSelect


  Plug 'dccsillag/magma-nvim', { 'do': ':UpdateRemotePlugins' }
  
 " Plug 'hkupty/iron.nvim'
 " Plug 'kana/vim-textobj-user'

 " Plug 'kana/vim-textobj-line'
 " Plug 'GCBallesteros/vim-textobj-hydrogen'
 " Plug 'GCBallesteros/jupytext.vim'

  " Plug 'GCBallesteros/NotebookNavigator.nvim'
  " Plug 'anuvyklack/hydra.nvim'
  " Plug 'echasnovski/mini.comment'
  " Plug 'hkupty/iron.nvim'

  " Plug 'anuvyklack/fold-preview.nvim'
  " Plug 'anuvyklack/pretty-fold.nvim'
  " Plug 'anuvyklack/keymap-amend.nvim'
  " Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  Plug 'David-Kunz/gen.nvim'


  Plug 'stevearc/aerial.nvim'

  Plug 'dylon/vim-antlr'

  Plug 'kaarmu/typst.vim'

  Plug 'nvim-lua/plenary.nvim'
  Plug 'andythigpen/nvim-coverage'

  Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

  Plug 'vimwiki/vimwiki'
  Plug 'tools-life/taskwiki'

  Plug 'zaldih/themery.nvim'
  Plug 'wuelnerdotexe/vim-enfocado'

  Plug 'mistricky/codesnap.nvim', { 'do': 'make' }

  Plug 'folke/which-key.nvim'
endif

call plug#end()

" Jupytext
" let g:jupytext_fmt = 'py'
" let g:jupytext_style = 'hydrogen'
" 
" " Send cell to IronRepl and move to next cell.
" " Depends on the text object defined in vim-textobj-hydrogen
" " You first need to be connected to IronRepl
" 
" nmap ]x ctrih/^# %%<CR><CR>
" 
" luafile $HOME/.config/nvim/plugins.lua

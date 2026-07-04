-- ============================================================================
-- Fresh Neovim Setup
-- ============================================================================
-- Keep ~/.vimrc for regular Vim and IdeaVim. This config intentionally starts
-- small and only carries over muscle-memory basics.

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap.set
local opt = vim.opt

-- ============================================================================
-- Leaders
-- ============================================================================

vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- ============================================================================
-- Options
-- ============================================================================

-- General
opt.backup = false
opt.title = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.synmaxcol = 240
opt.clipboard = "unnamedplus"

-- UI
opt.mouse = "a"
opt.wrap = false
opt.visualbell = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.showmatch = true
opt.colorcolumn = "80"
opt.scrolloff = 2
opt.sidescrolloff = 2
opt.termguicolors = true

-- Editing
opt.smartindent = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

-- Folding
opt.foldmethod = "marker"
opt.foldlevelstart = 10

-- ============================================================================
-- Keymaps
-- ============================================================================

keymap({ "n", "x" }, "<Space>", ":", { desc = "Command mode" })
keymap("n", "<CR>", "<cmd>nohlsearch<CR><CR>", { silent = true, desc = "Clear search" })
keymap("n", "U", "<C-r>", { desc = "Redo" })
keymap({ "n", "x" }, "+", "<C-a>", { desc = "Increment number" })
keymap({ "n", "x" }, "-", "<C-x>", { desc = "Decrement number" })
keymap("n", "<leader>s", "<cmd>setlocal spell!<CR>", { desc = "Toggle spell" })
keymap({ "n", "x" }, "n", "nzzzv", { desc = "Next search centered" })
keymap({ "n", "x" }, "N", "Nzzzv", { desc = "Previous search centered" })
keymap("n", "<leader>e", "<cmd>Lexplore<CR>", { silent = true, desc = "Open netrw" })

-- ============================================================================
-- Autocommands
-- ============================================================================

api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ============================================================================
-- Markdown Editing
-- ============================================================================

vim.g.md_fmt_on_save = false

local function prettier_markdown(prose_wrap)
  if fn.executable("prettier") == 0 then
    vim.notify("prettier: command not found", vim.log.levels.ERROR)
    return
  end

  local filepath = fn.expand("%:p")
  if filepath == "" then
    filepath = "stdin.md"
  end

  local view = fn.winsaveview()
  vim.cmd(
    "%!prettier --prose-wrap "
      .. fn.shellescape(prose_wrap or vim.b.md_prose_wrap or "always")
      .. " --stdin-filepath "
      .. fn.shellescape(filepath)
  )

  if vim.v.shell_error ~= 0 then
    vim.cmd("undo")
    vim.notify("prettier: format failed", vim.log.levels.ERROR)
  end

  fn.winrestview(view)
end

local function markdown_wrap(prose_wrap, textwidth)
  vim.b.md_prose_wrap = prose_wrap
  vim.opt_local.textwidth = textwidth
  prettier_markdown(prose_wrap)
  vim.notify("Markdown hard wrap: " .. (textwidth > 0 and "ON" or "OFF") .. " for this buffer")
end

api.nvim_create_user_command("MdFmtToggle", function()
  vim.g.md_fmt_on_save = not vim.g.md_fmt_on_save
  vim.opt_local.textwidth = vim.g.md_fmt_on_save and 80 or 0
  vim.notify("Markdown format-on-save: " .. (vim.g.md_fmt_on_save and "ON" or "OFF"))
end, {})

api.nvim_create_user_command("MdUnwrap", function()
  markdown_wrap("never", 0)
end, {})

api.nvim_create_user_command("MdHardWrap", function()
  markdown_wrap("always", 80)
end, {})

api.nvim_create_user_command("MdSoftWrap", function()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
end, {})

api.nvim_create_user_command("MdNoSoftWrap", function()
  vim.opt_local.wrap = false
  vim.opt_local.linebreak = false
  vim.opt_local.breakindent = false
end, {})

api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.colorcolumn = ""
    vim.opt_local.textwidth = 0
    vim.opt_local.complete:append("kspell")

    keymap("x", "<leader>l", "<Esc>`<i[<Esc>`>la]()<Esc>i", { buffer = event.buf, desc = "Wrap link" })
    keymap("n", "<leader>l", "<Esc>bi[<Esc>ea]()<Esc>i", { buffer = event.buf, desc = "Wrap word link" })
    keymap("n", "<leader>L", "<Esc>bi[<Esc>$a]()<Esc>i", { buffer = event.buf, desc = "Wrap line link" })
  end,
})

api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.md", "*.markdown" },
  callback = function()
    if vim.g.md_fmt_on_save then
      prettier_markdown()
    end
  end,
})

-- ============================================================================
-- Plugin Manager
-- ============================================================================

local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

opt.runtimepath:prepend(lazypath)

-- ============================================================================
-- Plugins
-- ============================================================================

local treesitter_parsers = {
  "bash",
  "fish",
  "html",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "vim",
  "yaml",
}

local treesitter_filetypes = {
  "bash",
  "fish",
  "html",
  "json",
  "lua",
  "markdown",
  "vim",
  "yaml",
  "zsh",
}

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(treesitter_parsers):wait(300000)
    end,
    config = function()
      require("nvim-treesitter").setup()
      api.nvim_create_autocmd("FileType", {
        pattern = treesitter_filetypes,
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {
      heading = {
        width = "full",
        sign = false,
        position = "inline",
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        width = "full",
        sign = true,
        conceal_delimiters = true,
        language = true,
        border = "none",
      },
      pipe_table = { style = "full" },
      quote = { enabled = false },
      sign = { enabled = false },
    },
  },
}, {
  change_detection = { notify = false },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

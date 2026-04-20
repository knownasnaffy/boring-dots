vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

-- Mostly disable mouse
vim.o.mouse = 'r'

vim.o.termguicolors = true

-- Sync system clipboard
vim.o.clipboard = "unnamedplus"

vim.o.linebreak = true
vim.o.breakindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

vim.opt.colorcolumn = "81"

-- Time before writing to swapfile after you stop typing
vim.o.updatetime = 250
-- Time before map sequence is considered to have ended
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Substitution live preview window command
vim.o.inccommand = 'split'

vim.o.cursorline = true
vim.o.scrolloff = 10

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- if performing an operation that would fail due to unsaved changes in the
-- buffer (like `:q`), instead raise a dialog asking if you wish to save the
-- current file(s)
vim.o.confirm = true

vim.opt.iskeyword:remove '-'
vim.opt.iskeyword:remove '_'

vim.cmd('filetype plugin on')
vim.cmd('syntax on')



local map = vim.keymap.set

map('i', '<M-q>', '<Esc>')
map('i', '<M-s>', '<Esc><Cmd>w<CR>a')
map('n', '<M-s>', '<Cmd>w<CR>')
map('n', '<M-r>', '<C-r>')

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', 'g;', function()
  local url = vim.fn.expand '<cfile>'
  if url ~= '' then vim.fn.jobstart({ 'xdg-open', url }, { detach = true }) end
end, { desc = 'Open stuff under cursor' })

map('t', '<M-q>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })


map({ 'n', 'x' }, 'J', '<C-d>')
map({ 'n', 'x' }, 'K', '<C-u>')

map({ 'n', 'x' }, '<M-d>', '<C-d>')
map({ 'n', 'x' }, '<M-f>', '<C-f>')
map({ 'n', 'x' }, '<M-u>', '<C-u>')
map({ 'n', 'x' }, '<M-b>', '<C-b>')


map({ 'n', 'x' }, '<leader>h', '^', {
  desc = 'Move to the first non-blank character in the line'
})
map({ 'n', 'x' }, '<leader>l', '$', {
  desc = 'Move to the last character in the line'
})
map('n', '0', 'g0', { desc = 'Move to beginning of display line' })
map('n', '$', 'g$', { desc = 'Move to end of display line' })

map({ 'n', 'x', 'o' }, 'j', 'gj', { desc = 'Move down by display line' })
map({ 'n', 'x', 'o' }, 'k', 'gk', { desc = 'Move up by display line' })

map({ 'n', 'x' }, 'gj', 'J', { desc = 'Join line' })
map({ 'n', 'x' }, 'gk', 'K', { desc = 'Look up keyword definition' })

map({ 'n', 'x', 'i' }, '<A-n>', '<C-n>', { desc = 'Next item' })
map({ 'n', 'x', 'i' }, '<A-p>', '<C-p>', { desc = 'Previous item' })

map({ 'c', 'i' }, '<A-w>', '<C-w>', { desc = 'Delete word backward' })
map({ 'c', 'i' }, '<A-d>', '<C-Del>', { desc = 'Delete word forward' })

map({ 'n' }, '<A-o>', '<C-o>')
map({ 'n' }, '<A-i>', '<C-i>')

local function wcmd(cmd)
  return function ()
    vim.cmd.wincmd(cmd)
  end
end

local function move_or_exec(dir, cmd)
  return function()
    local current = vim.fn.winnr()
    local target = vim.fn.winnr(dir)

    if target == current then
      -- no window in that direction
      vim.fn.jobstart(cmd, { detach = true })
    else
      vim.cmd.wincmd(dir)
    end
  end
end

map('n', '<leader>wh', move_or_exec( "h", "i3-msg focus left"),
  { desc = 'Move focus to the left window' })
map('n', '<leader>wl', move_or_exec( "l", "i3-msg focus right"),
  { desc = 'Move focus to the right window' })
map('n', '<leader>wj', move_or_exec( "j", "i3-msg focus down"),
  { desc = 'Move focus to the lower window' })
map('n', '<leader>wk', move_or_exec( "k", "i3-msg focus up"),
  { desc = 'Move focus to the upper window' })
map('n', '<leader>ww', '<C-w>w', { desc = 'Switch window' })
map('n', '<leader>wW', wcmd("W"), { desc = 'Switch window' })

map('n', '<leader>w+', wcmd("+"), { desc = 'Increase window height' })
map('n', '<leader>w-', wcmd('-'), { desc = 'Decrease window height' })
map('n', '<leader>w>', wcmd('>'), { desc = 'Increase window width' })
map('n', '<leader>w<', wcmd('<'), { desc = 'Decrease window width' })

map('n', '<leader>ws', wcmd('s'), { desc = 'Split window horizontally' })
map('n', '<leader>wv', wcmd('v'), { desc = 'Split window vertically' })
map('n', '<leader>wm', wcmd('_'), { desc = 'Maximize window' })
map('n', '<leader>wr', wcmd('='), { desc = 'Reset window sizes' })

map('n', '<leader>wH', wcmd('H'), { desc = 'Move current window to the left' })
map('n', '<leader>wL', wcmd('L'), { desc = 'Move current window to the right' })
map('n', '<leader>wJ', wcmd('J'),
  { desc = 'Move current window to the bottom' })
map('n', '<leader>wK', wcmd('K'), { desc = 'Move current window to the top' })

map('n', '<leader>wq', wcmd('q'), { desc = 'Close current window' })
map('n', '<leader>woq', wcmd('o'), { desc = 'Close other windows' })
map('n', '<leader>waq', '<Cmd>qa<CR>', { desc = 'Close all windows' })

map('n', '<leader>wtn', '<Cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<leader>wtc', '<Cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<leader>wth', '<Cmd>tabn<CR>', { desc = 'Previous tab' })
map('n', '<leader>wtl', '<Cmd>tabN<CR>', { desc = 'Next tab' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank({timeout=200}) end,
})



vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  -- 'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/vimwiki/vimwiki',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/mason-org/mason.nvim'
})

vim.cmd.packadd("nvim.undotree")
map('n', '<leader>u', '<Cmd>Undotree<CR>', { desc = 'Open Undo Tree' })

vim.cmd.packadd("vimwiki")
map('n', '<leader>vi', '<Cmd>VimwikiIndex<CR>')
map('n', '<leader>vg', '<Cmd>VimwikiGoto<CR>')
map('n', '<leader>vs', ':VimwikiSearch ')
map('n', '<leader>vb', '<Cmd>VimwikiBacklinks<CR>')
map('n', '<leader>vtt', '<Cmd>VimwikiToggleListItem<CR>')
map('n', '<leader>vdi', '<Cmd>VimwikiDiaryIndex<CR>')
map('n', '<leader>vdt', '<Cmd>VimwikiMakeDiaryNote<CR>')
map('n', '<leader>vdy', '<Cmd>VimwikiMakeYesterdayDiaryNote<CR>')

require('guess-indent').setup({
  on_space_options = {
    ["expandtab"] = true,
    ["tabstop"] = "detected",
    ["softtabstop"] = "detected",
    ["shiftwidth"] = "detected",
  },
})

require('mason').setup()
map('n', '<leader>om', '<Cmd>Mason<CR>')

vim.pack.add({'https://github.com/nvim-mini/mini.nvim'})

local miniextra = require('mini.extra')
miniextra.setup()
local gen_ai_spec = miniextra.gen_ai_spec

require('mini.ai').setup({
  custom_textobjects = {
    B = gen_ai_spec.buffer(),
    D = gen_ai_spec.diagnostic(),
    I = gen_ai_spec.indent(),
    L = gen_ai_spec.line(),
    N = gen_ai_spec.number(),
  },
})

require('mini.comment').setup()
require('mini.move').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.bracketed').setup({
  comment = { suffix = 'gc', options = {} },
})

local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    { mode = { 'n', 'x' }, keys = '<Leader>' },

    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    { mode = { 'n', 'x' }, keys = 'g' },

    { mode = { 'n', 'x' }, keys = "'" },
    { mode = { 'n', 'x' }, keys = '`' },

    -- Registers
    { mode = { 'n', 'x' }, keys = '"' },
    { mode = { 'i', 'c' }, keys = '<C-r>' },

    -- `z` key
    { mode = { 'n', 'x' }, keys = 'z' },
  },
  clues = {
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  }
})

require('mini.cmdline').setup()

require('mini.diff').setup({
  view = {
    style = 'sign',
    signs = { add = '▍', change = '▍', delete = '▍' },
  }
})
map('n', '<leader>th', MiniDiff.toggle_overlay, {
  desc = "Toggle git hunk overlay"
})

require('mini.files').setup({
  mappings = {
    go_in       = 'L',
    go_in_plus  = 'l',
  }
})
map('n', '<leader>e', MiniFiles.open, {desc = "Open file manager"})

require('mini.git').setup()
map('n', '<leader>gs', MiniGit.show_at_cursor,
  { desc = "Show git object at cursor" })
map('n', '<leader>ge', '<Cmd>Git status<CR>', {desc = "Git status"})
map('n', '<leader>gc', '<Cmd>Git commit<CR>', {desc = "Git commit"})
map('n', '<leader>gC', '<Cmd>Git commit --amend --no-edit<CR>',
  { desc = "Git commit amend" })
map('n', '<leader>ga', '<Cmd>Git add %<CR>', {desc = "Git add current file"})
map('n', '<leader>gA', '<Cmd>Git add .<CR>', {desc = "Git add all files"})
map('n', '<leader>gu', '<Cmd>Git restore --staged %<CR>', {desc = "Git add current file"})
map('n', '<leader>gU', '<Cmd>Git restore --staged .<CR>', {desc = "Git add current file"})

require('mini.pick').setup()
map('n', '<leader>sf', MiniPick.builtin.files, {desc = "Search files"})
map('n', '<leader>sg', MiniPick.builtin.grep_live, {desc = "Grep files live"})
map('n', '<leader>sh', MiniPick.builtin.help, {desc = "Search help pages"})
map('n', '<leader>sr', MiniPick.builtin.resume, {desc = "Resume latest picker"})
map('n', '<leader>sd', MiniExtra.pickers.diagnostic,
  { desc = "Search diagnostics" })
map('n', '<leader>sc', MiniExtra.pickers.commands,
  { desc = "Search commands" })
map('n', '<leader>sb', MiniExtra.pickers.git_branches,
  { desc = "Search git branches" })
map('n', '<leader>sk', MiniExtra.pickers.keymaps, { desc = "Search keymaps" })
map('n', '<leader>sq', function()
    MiniExtra.pickers.list({scope='quickfix'})
  end, { desc = "Search quickfix list" })
map('n', '<leader>sm', MiniExtra.pickers.manpages, { desc = "Search manpages" })
map('n', '<leader>so', MiniExtra.pickers.oldfiles, { desc = "Search old files" })


require('mini.cursorword').setup()
require('mini.icons').setup()

require('mini.notify').setup()
map('n', '<leader>sn', MiniNotify.show_history, {desc = "Show notifications"})

local starter = require('mini.starter')
starter.setup({
  evaluate_single = false,
  items = {
      starter.sections.builtin_actions(),
      starter.sections.pick(),
      starter.sections.recent_files(5, true),
      starter.sections.sessions(5, true)
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(""),
      starter.gen_hook.aligning('center', 'center'),
  },
  silent = false,
})

require('mini.tabline').setup()
vim.api.nvim_set_hl(0, "MiniTablineFill", { link = "Tabline" })
vim.api.nvim_set_hl(0, "MiniTablineHidden", { link = "MiniTablineFill" })
vim.api.nvim_set_hl(0, "MiniTablineCurrent", { link = "Normal" })

require('mini.trailspace').setup()
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
  end,
})

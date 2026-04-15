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

-- vim.o.signcolumn = 'yes'

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

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

vim.opt.iskeyword:remove '-'
vim.opt.iskeyword:remove '_'



local map = vim.keymap.set

map('i', '<M-q>', '<Esc>')
map('i', '<M-s>', '<Esc><Cmd>w<CR>a')
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


map({ 'n', 'x' }, '<leader>h', '^', { desc = 'Move to the first non-blank character in the line' })
map({ 'n', 'x' }, '<leader>l', '$', { desc = 'Move to the last character in the line' })
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


map('n', '<leader>wh', '<C-w>h', { desc = 'Move focus to the left window' })
map('n', '<leader>wl', '<C-w>l', { desc = 'Move focus to the right window' })
map('n', '<leader>wj', '<C-w>j', { desc = 'Move focus to the lower window' })
map('n', '<leader>wk', '<C-w>k', { desc = 'Move focus to the upper window' })
map('n', '<leader>ww', '<C-w>w', { desc = 'Switch window' })

map('n', '<leader>w+', '<C-w>+', { desc = 'Increase window height' })
map('n', '<leader>w-', '<C-w>-', { desc = 'Decrease window height' })
map('n', '<leader>w>', '<C-w>>', { desc = 'Increase window width' })
map('n', '<leader>w<', '<C-w><', { desc = 'Decrease window width' })

map('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
map('n', '<leader>wm', '<C-w>| <C-w>_', { desc = 'Maximize window' })
map('n', '<leader>wr', '<C-w>=', { desc = 'Reset window sizes' })

map('n', '<leader>wH', '<C-w>H', { desc = 'Move current window to the left' })
map('n', '<leader>wL', '<C-w>L', { desc = 'Move current window to the right' })
map('n', '<leader>wJ', '<C-w>J', { desc = 'Move current window to the bottom' })
map('n', '<leader>wK', '<C-w>K', { desc = 'Move current window to the top' })

map('n', '<leader>wq', '<Cmd>q<CR>', { noremap = false, desc = 'Close current window' })
map('n', '<leader>woq', '<C-w>o', { desc = 'Close other windows' })
map('n', '<leader>waq', '<Cmd>qa<CR>', { desc = 'Close all windows' })

map('n', '<leader>wtn', '<Cmd>tabnew<CR>', { desc = '[N]ew tab' })
map('n', '<leader>wtc', '<Cmd>tabclose<CR>', { desc = '[C]lose tab' })
map('n', '<leader>wth', '<Cmd>tabn<CR>', { desc = 'Previous tab' })
map('n', '<leader>wtl', '<Cmd>tabN<CR>', { desc = 'Next tab' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

vim.cmd.packadd("nvim.undotree")
map('n', '<leader>u', '<Cmd>Undotree<CR>', { desc = 'Open [U]ndo Tree' })

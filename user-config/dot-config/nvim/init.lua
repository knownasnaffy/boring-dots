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

vim.pack.add({"https://github.com/folke/tokyonight.nvim"})
require('tokyonight').setup()
vim.cmd.colorscheme("tokyonight-night")



local map = vim.keymap.set

map('i', '<M-q>', '<Esc>')
map('i', '<M-s>', '<Esc><Cmd>w<CR>a')
map('n', '<M-s>', '<Cmd>w<CR>')
map('n', '<M-r>', '<C-r>')

map('n', '<M-S-j>', '<Cmd>copy +0<CR>')
map('n', '<M-S-k>', '<Cmd>copy -1<CR>')

map('x', '<M-S-j>', ":copy '><CR>gv")
map('x', '<M-S-k>', ":copy -1<CR>gv")

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
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/romgrk/barbar.nvim',
  'https://github.com/olimorris/persisted.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/akinsho/toggleterm.nvim',
  'https://github.com/iamcco/markdown-preview.nvim',
  'https://github.com/folke/snacks.nvim'
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

require('mini.bracketed').setup()

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
local gh_apply = function() return MiniDiff.operator('apply') .. 'gh' end
map('n', '<leader>gha', gh_apply, { expr = true, remap = true })
local gh_reset = function() return MiniDiff.operator('reset') .. 'gh' end
map('n', '<leader>ghr', gh_reset, { expr = true, remap = true })


require('mini.files').setup({
  mappings = {
    go_in       = 'L',
    go_in_plus  = 'l',
  }
})

local function open_mini_files_here()
  local buf_name = vim.api.nvim_buf_get_name(0)

  if buf_name == "" then
    MiniFiles.open(vim.loop.cwd())
  else
    MiniFiles.open(buf_name)
  end
end
map('n', '<leader>e', open_mini_files_here, {desc = "Open file manager"})

require('mini.git').setup()

local function run_git(cmd, success_msg, opts)
  local data = MiniGit.get_buf_data(0)

  if not data or not data.root then
    vim.notify('Not in a Git repository')
    return
  end

  if opts and opts.block_during_in_progress and data.in_progress ~= '' then
    vim.notify('Git operation in progress: ' .. data.in_progress)
    return
  end

  vim.system(cmd, { cwd = data.root, text = true }, function(obj)
    if obj.code == 0 then
      vim.notify(success_msg)
    else
      vim.notify('Git failed: ' .. obj.stderr)
    end
  end)
end

map('n', '<leader>gc', function()
  local data = MiniGit.get_buf_data(0)

  if not data or not data.root then
    vim.notify('Not in a Git repository')
    return
  end

  local message = vim.fn.input 'Commit message: '

  if message ~= '' then
    local command = { 'git', 'commit', '-m', message }
    vim.system(command, { cwd = data.root, text = true }, function(obj)
      if obj.code == 0 then
        vim.notify(obj.stdout)
      else
        vim.notify('Git failed: ' .. obj.stderr)
      end
    end)

  else print 'Commit canceled.' end
end, {desc = "Git commit"})
map('n', '<leader>gC', '<Cmd>Git commit --amend --no-edit<CR>',
  { desc = "Git commit amend" })

map('n', '<leader>ga', '<Cmd>Git add %<CR>', {desc = "Git add current file"})
map('n', '<leader>gA', '<Cmd>Git add .<CR>', {desc = "Git add all files"})
map('n', '<leader>gu', '<Cmd>Git restore --staged %<CR>',
  {desc = "Git add current file"})
map('n', '<leader>gU', '<Cmd>Git restore --staged .<CR>',
  {desc = "Git add current file"})
map('n', '<leader>gl', '<Cmd>Git log<CR>', {desc = "Git log"})

map('n', '<leader>gp', function()
  run_git({ 'git', 'push' }, 'Pushed changes to remote.')
end, { desc = "Git push" })
map('n', '<leader>gP', function()
  run_git({ 'git', 'pull' }, 'Pulled changes from remote.', {
    block_during_in_progress = true,
  })
end, { desc = "Git pull" })
map('n', '<leader>gF', function()
  run_git({ 'git', 'fetch' }, 'Fetched changes from remote.')
end, { desc = "Git fetch" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.cmd("startinsert")
  end,
})

require('mini.pick').setup()

require('mini.cursorword').setup()

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('mini.notify').setup()
map('n', '<leader>sn', MiniNotify.show_history, {desc = "Show notifications"})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    require('mini.trailspace').trim()
    require('mini.trailspace').trim_last_lines()
  end,
})

require('persisted').setup({
  should_save = function ()
    if vim.bo.filetype == "snacks_dashboard" then
      return false
    end

    local cwd = vim.loop.cwd()  -- fast + clean

    local blocklist = {
      vim.fn.expand("~"), vim.fn.expand("~/.config")
    }

    for _, path in ipairs(blocklist) do
      if cwd == path then
        return false
      end
    end

    return true
  end
})

require('snacks').setup({
  buffdelete = { enabled = true },
  dashboard = {
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File",
          action = Snacks.picker.files },
        { icon = " ", key = "g", desc = "Find Text",
          action = Snacks.picker.grep },
        { icon = " ", key = "r", desc = "Recent Files",
          action = Snacks.picker.recent },
        { icon = " ", key = "s", desc = "Restore Session",
          action = ":Persisted load" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = 'keys', gap = 1, padding = 1 },
    },
  },
  gitbrowse = {
    what = "branch"
  },
  picker = {
        ui_select = true,
        sources = {
          files = {
            hidden = true,
          },
          grep = {
            hidden = true,
          },
        },
        win = {
          -- input window
          input = {
            keys = {
              ['<M-q>'] = { 'cancel', mode = 'i' },
              ['<M-Space>'] = { 'select_and_next', mode = { 'i', 'n' } },
              ['<M-S-Space>'] = { 'select_and_prev', mode = { 'i', 'n' } },
              ['<M-a>'] = { 'select_all', mode = { 'i', 'n' } },
              ['<M-w>'] = { '<c-s-w>', mode = { 'i' }, expr = true, desc = 'delete word' },
              ['<M-j>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<M-k>'] = { 'list_up', mode = { 'i', 'n' } },
              ['<M-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
              ['<M-i>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
              ['<M-Tab>'] = { 'cycle_win', mode = { 'i', 'n' } },
              ['<M-b>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
              ['<M-f>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<M-S-k>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
              ['<M-S-l>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
              ['<M-s>'] = { 'edit_split', mode = { 'i', 'n' } },
              ['<M-S-s>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
              ['<M-r><M-a>'] = { 'insert_cWORD', mode = 'i' },
              ['<M-r><M-f>'] = { 'insert_file', mode = 'i' },
              ['<M-r><M-l>'] = { 'insert_line', mode = 'i' },
              ['<M-r><M-p>'] = { 'insert_file_full', mode = 'i' },
            },
            b = {
              minipairs_disable = true,
            },
          },
          -- preview window
          preview = {
            keys = {
              ['<M-Tab>'] = { 'cycle_win', mode = { 'i', 'n' } },
            },
          },
          -- result list window
          list = {
            keys = {
              ['<M-q>'] = 'cancel',
              ['<M-Tab>'] = { 'cycle_win', mode = { 'i', 'n' } },
              ['<M-Space>'] = { 'select_and_next', mode = { 'i', 'n' } },
              ['<M-S-Space>'] = { 'select_and_prev', mode = { 'i', 'n' } },
              ['<a-d>'] = 'inspect',
              ['<M-h>'] = 'toggle_hidden',
              ['<M-i>'] = 'toggle_ignored',
              ['<M-a>'] = 'select_all',
              ['<M-b>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
              ['<M-f>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<M-s>'] = { 'edit_split', mode = { 'i', 'n' } },
              ['<M-S-s>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
            },
            wo = {
              conceallevel = 2,
              concealcursor = 'nvc',
            },
          },
        },
      },
  quickfile = { enabled = true },
  scope = {},
  statuscolumn = {}
})

map('n', '<leader>sf', function() Snacks.picker.files() end, {desc = "Search files"})
map('n', '<leader>sg', function() Snacks.picker.grep() end, {desc = "Grep files live"})
map('n', '<leader>/', function() Snacks.picker.lines() end, {desc = "Fuzzy search lines"})
map('n', '<leader>so', function() Snacks.picker.recent() end, { desc = "Search old files" })

map('n', '<leader>sr', function() Snacks.picker.resume() end, {desc = "Resume latest picker"})
map('n', '<leader>ss', function() Snacks.picker.pickers() end, { desc = "Search snacks pickers" })

map('n', '<leader>sh', function() Snacks.picker.help() end, {desc = "Search help pages"})
map('n', '<leader>sd', function() Snacks.picker.diagnostics() end,
  { desc = "Search diagnostics" })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = "Search keymaps" })
map('n', '<leader>si', function() Snacks.picker.icons() end, { desc = "Search keymaps" })
map('n', '<leader>sq', function()
    MiniExtra.pickers.list({scope='quickfix'})
end, { desc = "Search quickfix list" })
map('n', '<leader>sm', function() Snacks.picker.man() end, { desc = "Search manpages" })

map('n', '<leader>sN', function()
  Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
end, { desc = "Search neovim files" })


map('n', '<leader>gb', function()
        Snacks.picker.git_branches {
          all = true,
          win = {
            input = {
              keys = {
                ['<M-a>'] = { 'git_branch_add', mode = { 'n', 'i' } },
                ['<M-S-d>'] = { 'git_branch_del', mode = { 'n', 'i' } },
              },
            },
          },
        }
end, { desc = "Search git branches" })
map('n', '<leader>ge', function() Snacks.picker.git_status() end, { desc = "Search manpages" })
map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = "Search manpages" })
map('n', '<leader>gB', function() Snacks.gitbrowse() end,
  { desc = 'Open current git remote in browser' })


vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    Snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})

vim.g.barbar_auto_setup = false
require('barbar').setup({
  auto_hide = 0,
  animation = false,
  highlight_visible = true,
  icons = {
    button = false,
    filetype = {
      custom_colors = false,
      enabled = true,
    },
    separator_at_end = false,
  }
})

vim.opt.sessionoptions:append 'globals'
vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = 'PersistedSavePre',
  group = vim.api.nvim_create_augroup('PersistedHooks', {}),
  callback = function()
    vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
  end,
})

local function buffer_switch(direction)
  local count = vim.v.count > 0 and vim.v.count or 1
  vim.cmd((direction == 'next' and 'BufferNext ' or 'BufferPrevious ') .. count)
end

map('n', '<A-.>', function() buffer_switch 'next' end,
  { desc = 'Go to next buffer' })
map('n', '<A-,>', function() buffer_switch 'previous' end,
  { desc = 'Go to previous buffer' })

map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>')
map('n', '<A->>', '<Cmd>BufferMoveNext<CR>')

map('n', '<leader>br', '<Cmd>BufferRestore<CR>',
  { desc = 'Restore last close buffer' })

map('n', '<A-S-p>', '<Cmd>BufferPin<CR>')

map('n', '<leader>bp', '<Cmd>BufferPick<CR>',
  { desc = 'Magic buffer Picker' })
map('n', '<leader>bd', '<Cmd>BufferPickDelete<CR>',
  { desc = 'Magic buffer Deleter' })

map('n', '<leader>bqo', function() Snacks.bufdelete.other() end,
  { desc = 'Close Other buffers' })
map('n', '<A-q>', function() Snacks.bufdelete() end,
  { desc = 'Close Current buffer' })

map('n', '<leader>bwc', '<Cmd>w<CR>', { desc = 'Write Current file' })
map('n', '<leader>bwa', '<Cmd>wa<CR>', { desc = 'Write All files' })

map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>')
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>')
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>')
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>')
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>')
map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>')
map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>')
map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>')
map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>')
map('n', '<A-0>', '<Cmd>BufferLast<CR>')

require('toggleterm').setup({--[[ things you want to change go here]]
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
    -- on_open = function()
    --   vim.cmd 'startinsert'
    -- end, -- function to run when the terminal opens
  })


map('n', '<A-`>', ':ToggleTerm<CR>', { desc = 'Toggle terminal' })
map('t', '<A-`>', '<Cmd>ToggleTerm<CR>', { desc = 'Hide terminal' })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "toggleterm",
  callback = function()
    vim.opt_local.laststatus = 0
  end,
})

-- vim.cmd.packadd("markdown-preview")
vim.fn["mkdp#util#install"]()
map('n', '<leader>om', '<Cmd>MarkdownPreview<CR>', { desc = 'Open markdown preview' })

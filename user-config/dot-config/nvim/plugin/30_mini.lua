-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- This file contains configuration of the MINI parts of the config.
-- It contains only configs for the 'mini.nvim' plugin (installed in 'init.lua').
--
-- 'mini.nvim' is a library of modules. Each is enabled independently via
-- `require('mini.xxx').setup()` convention. It creates all intended side effects:
-- mappings, autocommands, highlight groups, etc. It also creates a global
-- `MiniXxx` table that can be later used to access module's features.
--
-- Every module's `setup()` function accepts an optional `config` table to
-- adjust its behavior. See the structure of this table at `:h MiniXxx.config`.
--
-- See `:h mini.nvim-general-principles` for more general principles.
--
-- Here each module's `setup()` has a brief explanation of what the module is for,
-- its usage examples (uses Leader mappings from 'plugin/20_keymaps.lua'), and
-- possible directions for more info.
-- For more info about a module see its help page (`:h mini.xxx` for 'mini.xxx').

-- To minimize the time until first screen draw, modules are enabled in two steps:
-- - Step one enables everything that is needed for first draw with `now()`.
--   Sometimes needed only if Neovim is started as `nvim -- path/to/file`.
-- - Everything else is delayed until the first draw with `later()`.
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Step one ===================================================================
-- Common configuration presets. Example usage:
-- - `<C-s>` in Insert mode - save and go to Normal mode
-- - `go` / `gO` - insert empty line before/after in Normal mode
-- - `gy` / `gp` - copy / paste from system clipboard
-- - `\` + key - toggle common options. Like `\h` toggles highlighting search.
-- - `<C-hjkl>` (four combos) - navigate between windows.
-- - `<M-hjkl>` in Insert/Command mode - navigate in that mode.
--
-- See also:
-- - `:h MiniBasics.config.options` - list of adjusted options
-- - `:h MiniBasics.config.mappings` - list of created mappings
-- - `:h MiniBasics.config.autocommands` - list of created autocommands
now(function()
  require('mini.basics').setup({
    -- Manage options in 'plugin/10_options.lua' for didactic purposes
    options = { basic = false },
    mappings = {},
  })
end)

-- Icon provider. Usually no need to use manually. It is used by plugins like
-- 'mini.pick', 'mini.files', 'mini.statusline', and others.
now(function()
  -- Set up to not prefer extension-based icon for some extensions
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
  -- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
  now_if_args(MiniIcons.mock_nvim_web_devicons)

  -- Add LSP kind icons. Useful for 'mini.completion'.
  later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications provider. Shows all kinds of notifications in the upper right
-- corner (by default). Example usage:
-- - `:h vim.notify()` - show notification (hides automatically)
-- - `<Leader>en` - show notification history
--
-- See also:
-- - `:h MiniNotify.config` for some of common configuration examples.
now(function() require('mini.notify').setup() end)

-- Session management. A thin wrapper around `:h mksession` that consistently
-- manages session files. Example usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sd` - delete previously started session
now(function() require('mini.sessions').setup() end)

-- Start screen. This is what is shown when you open Neovim like `nvim`.
-- Example usage:
-- - Type prefix keys to limit available candidates
-- - Navigate down/up with `<C-n>` and `<C-p>`
-- - Press `<CR>` to select an entry
--
-- See also:
-- - `:h MiniStarter-example-config` - non-default config examples
-- - `:h MiniStarter-lifecycle` - how to work with Starter buffer
now(function()
  local starter = require('mini.starter')
  starter.setup({
    evaluate_single = true,
    items = {
      starter.sections.sessions(5, true),
      starter.sections.recent_files(5, true),
      starter.sections.builtin_actions(),
    },
    footer = ""
  })
end)

-- Statusline. Sets `:h 'statusline'` to show more info in a line below window.
-- Example usage:
-- - Left most section indicates current mode (text + highlighting).
-- - Second from left section shows "developer info": Git, diff, diagnostics, LSP.
-- - Center section shows the name of displayed buffer.
-- - Second to right section shows more buffer info.
-- - Right most section shows current cursor coordinates and search results.
--
-- See also:
-- - `:h MiniStatusline-example-content` - example of default content. Use it to
--   configure a custom statusline by setting `config.content.active` function.
now(function() require('mini.statusline').setup() end)

-- Tabline. Sets `:h 'tabline'` to show all listed buffers in a line at the top.
-- Buffers are ordered as they were created. Navigate with `[b` and `]b`.
now(function()
local function listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

require('mini.tabline').setup({
  format = function(buf_id, label)
    local bufs = listed_buffers()

    local index
    for i, buf in ipairs(bufs) do
      if buf == buf_id then
        index = i
        break
      end
    end

    return string.format(' [%d] %s ', index, label)
  end,
})
end)

-- Step one or two ============================================================
-- Load now if Neovim is started like `nvim -- path/to/file`, otherwise - later.
-- This ensures a correct behavior for files opened during startup.

-- Completion and signature help. Implements async "two stage" autocompletion:
-- - Based on attached LSP servers that support completion.
-- - Fallback (based on built-in keyword completion) if there is no LSP candidates.
--
-- Example usage in Insert mode with attached LSP:
-- - Start typing text that should be recognized by LSP (like variable name).
-- - After 100ms a popup menu with candidates appears.
-- - Press `<Tab>` / `<S-Tab>` to navigate down/up the list. These are set up
--   in 'mini.keymap'. You can also use `<C-n>` / `<C-p>`.
-- - During navigation there is an info window to the right showing extra info
--   that the LSP server can provide about the candidate. It appears after the
--   candidate stays selected for 100ms. Use `<C-f>` / `<C-b>` to scroll it.
-- - Navigating to an entry also changes buffer text. If you are happy with it,
--   keep typing after it. To discard completion completely, press `<C-e>`.
-- - After pressing special trigger(s), usually `(`, a window appears that shows
--   the signature of the current function/method. It gets updated as you type
--   showing the currently active parameter.
--
-- Example usage in Insert mode without an attached LSP or in places not
-- supported by the LSP (like comments):
-- - Start typing a word that is present in current or opened buffers.
-- - After 100ms popup menu with candidates appears.
-- - Navigate with `<Tab>` / `<S-Tab>` or `<C-n>` / `<C-p>`. This also updates
--   buffer text. If happy with choice, keep typing. Stop with `<C-e>`.
--
-- It also works with snippet candidates provided by LSP server. Best experience
-- when paired with 'mini.snippets' (which is set up in this file).
-- now_if_args(function()
--   -- Customize post-processing of LSP responses for a better user experience.
--   -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
--   local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
--   local process_items = function(items, base)
--     return MiniCompletion.default_process_items(items, base, process_items_opts)
--   end
--   require('mini.completion').setup({
--     lsp_completion = {
--       -- Without this config autocompletion is set up through `:h 'completefunc'`.
--       -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
--       -- (sets up only when needed) and makes it possible to use `<C-u>`.
--       source_func = 'omnifunc',
--       auto_setup = false,
--       process_items = process_items,
--     },
--   })
--
--   -- Set 'omnifunc' for LSP completion only when needed.
--   local on_attach = function(ev)
--     vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
--   end
--   Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")
--
--   -- Advertise to servers that Neovim now supports certain set of completion and
--   -- signature features through 'mini.completion'.
--   vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
-- end)

-- Navigate and manipulate file system
--
-- Navigation is done using column view (Miller columns) to display nested
-- directories, they are displayed in floating windows in top left corner.
--
-- Manipulate files and directories by editing text as regular buffers.
--
-- Example usage:
-- - `<Leader>ed` - open current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
--
-- Basic navigation:
-- - `l` - go in entry at cursor: navigate into directory or open file
-- - `h` - go out of focused directory
-- - Navigate window as any regular buffer
-- - Press `g?` inside explorer to see more mappings
--
-- Basic manipulation:
-- - After any following action, press `=` in Normal mode to synchronize, read
--   carefully about actions, press `y` or `<CR>` to confirm
-- - New entry: press `o` and type its name; end with `/` to create directory
-- - Rename: press `C` and type new name
-- - Delete: type `dd`
-- - Move/copy: type `dd`/`yy`, navigate to target directory, press `p`
--
-- See also:
-- - `:h MiniFiles-navigation` - more details about how to navigate
-- - `:h MiniFiles-manipulation` - more details about how to manipulate
-- - `:h MiniFiles-examples` - examples of common setups
now_if_args(function()
  -- Enable directory/file preview
  local MiniFiles = require('mini.files')

  MiniFiles.setup({
    windows = { preview = false, width_preview = 100 },
    mappings = {
      go_in = 'L',
      go_in_plus = 'l',
      mark_set = 'M',
    },
  })

  -- Credits for the following mini.files features: https://github.com/drowning-cat/nvim/blob/main/plugin/30_mini_files.lua
  local buf_get_path = function(buf)
    local path = vim.api.nvim_buf_get_name(buf):match('^minifiles://%d+/(.*)$')
    local stat = vim.uv.fs_stat(path)
    return path, stat
  end

  local set_cursor_path = function(win, path)
    win = win or 0
    local buf = vim.api.nvim_win_get_buf(win)
    for i = 1, vim.api.nvim_buf_line_count(buf) do
      if MiniFiles.get_fs_entry(buf, i).path == path then
        vim.api.nvim_win_set_cursor(win, { i, 0 })
        break
      end
    end
  end

  local get_preview_win = function()
    if not MiniFiles.config.windows.preview then return end
    local ok, state = pcall(MiniFiles.get_explorer_state)
    if not ok or not state then return end
    local rmost_win = state.windows[#state.windows].win_id
    if rmost_win == vim.api.nvim_get_current_win() then return end
    return state.windows[#state.windows].win_id
  end

  local preview_win_call = function(callback)
    local win = get_preview_win()
    if win then vim.api.nvim_win_call(win, callback) end
  end

  local get_selected = function()
    local mode = vim.api.nvim_get_mode().mode
    local is_visual = mode == 'v' or mode == 'V' or mode == vim.keycode('<C-v>')
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local ln_range = { row, row }
    if is_visual then
      local row_start, row_end = row, vim.fn.line('v')
      ln_range = { math.min(row_start, row_end), math.max(row_start, row_end) }
    end
    local selected = {}
    for ln = ln_range[1], ln_range[2] do
      local fs_entry = MiniFiles.get_fs_entry(0, ln)
      if fs_entry then table.insert(selected, fs_entry) end
    end
    return selected
  end

  local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end

  local yank_path = function(mode)
    mode = mode or 'absolute'

    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)

    local register = vim.v.register
    local selected = get_selected()
    local notify = vim.schedule_wrap(vim.notify)

    if vim.tbl_isempty(selected) then
      notify('No paths to yank', vim.log.levels.WARN)
      return
    end

    local paths = vim
      .iter(selected)
      :map(function(fs_entry)
        if mode == 'relative' then
          return vim.fn.fnamemodify(fs_entry.path, ':.')
        end

        return fs_entry.path
      end)
      :totable()

    local copy_str = table.concat(paths, '\n')

    vim.fn.setreg(register, copy_str)

    notify(
      string.format(
        'Yanked %d %s (%s)',
        #selected,
        #selected == 1 and 'path' or 'paths',
        mode
      )
    )
  end

  local toggle_preview = function()
    local is_preview = MiniFiles.config.windows.preview
    local is_preview_next = not is_preview
    MiniFiles.config.windows.preview = is_preview_next
    MiniFiles.trim_right()
    MiniFiles.refresh({ windows = { preview = is_preview_next } })
    if is_preview then
      local branch = MiniFiles.get_explorer_state().branch
      table.remove(branch)
      MiniFiles.set_branch(branch)
    end
  end

  local norm_in_preview = function(keys)
    preview_win_call(function()
      local key = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.cmd.norm({ key, bang = true })
    end)
  end

  local search_grep = function()
    local MiniPick = require('mini.pick')
    local entry = MiniFiles.get_fs_entry()
    if not entry then return end
    local parent = vim.fn.fnamemodify(entry.path, ':h')
    MiniFiles.close()
    vim.notify(parent)
    MiniPick.builtin.grep_live({}, { source = { cwd = parent } })
  end

  local search_files = function()
    local MiniPick = require('mini.pick')
    local entry = MiniFiles.get_fs_entry()
    if not entry then return end
    local parent = vim.fn.fnamemodify(entry.path, ':h')
    MiniFiles.close()
    MiniPick.builtin.files({}, { source = { cwd = parent } })
  end

  local set_bookmark = function(id, local_path, opts)
    MiniFiles.set_bookmark(id, function()
      local path = type(local_path) == 'function' and local_path() or local_path
      if type(path) ~= 'string' then return end
      path = vim.fs.abspath(path)
      local stat = vim.uv.fs_stat(path)
      if not stat then return end
      vim.schedule(function() set_cursor_path(0, path) end)
      return vim.fs.dirname(path)
    end, opts)
  end

  local mark_set = function()
    local id = vim.fn.getcharstr()
    if not id or id == '' or id == '\27' then return end
    local path = MiniFiles.get_fs_entry().path
    set_bookmark(id, path)
    vim.notify('Bookmark ' .. vim.inspect(id) .. ' is set')
  end

  local mark_goto = function() -- Copied from mini.files ditto
    local id = vim.fn.getcharstr()
    if id == nil then return end
    local data = MiniFiles.get_explorer_state().bookmarks[id]
    if data == nil then
      return vim.notify(
        'No bookmark with id ' .. vim.inspect(id),
        vim.log.levels.WARN
      )
    end

    local path = data.path
    if vim.is_callable(path) then path = path() end

    local fs_is_imaginary_path = function(target_path)
      return target_path:sub(-1) == '\000'
    end
    local fs_is_present_path = function(target_path)
      return vim.loop.fs_stat(target_path) ~= nil
        and not fs_is_imaginary_path(target_path)
    end
    local fs_get_type = function(target_path)
      if
        not (
          not fs_is_imaginary_path(target_path)
          and fs_is_present_path(target_path)
        )
      then
        return nil
      end
      return vim.fn.isdirectory(target_path) == 1 and 'directory' or 'file'
    end

    local is_valid_path = type(path) == 'string'
      and fs_get_type(vim.fn.expand(path)) == 'directory'
    if not is_valid_path then
      return vim.notify(
        'Bookmark path should be a valid path to directory',
        vim.log.levels.WARN
      )
    end

    local state = MiniFiles.get_explorer_state()
    if not state then return end
    MiniFiles.set_bookmark(
      "'",
      state.branch[state.depth_focus],
      { desc = 'Before latest jump' }
    )
    MiniFiles.set_branch({ path })
  end

  local define_bookmarks = function()
    local target_win = MiniFiles.get_explorer_state().target_window
    local target_buf = vim.api.nvim_win_get_buf(target_win)
    set_bookmark(
      't',
      vim.api.nvim_buf_get_name(target_buf),
      { desc = 'Target file' }
    )
    set_bookmark(
      'n',
      vim.fn.stdpath('config') .. '/init.lua',
      { desc = 'Neovim Config' }
    )
    set_bookmark(
      'p',
      vim.fn.stdpath('data') .. '/site/pack/core/opt',
      { desc = 'Plugins' }
    )
    -- This bookmark will take us inside the directory whereas the ones above will just make the targets focused
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Cwd' })
    MiniFiles.set_bookmark(
      'c',
      vim.fn.expand('~/boring-dots'),
      { desc = 'System Config' }
    )
  end

  Config.new_autocmd(
    'User',
    'MiniFilesExplorerOpen',
    define_bookmarks,
    'Add bookmarks'
  )

  local integrate_mini_clue = function(e)
    if MiniClue then MiniClue.ensure_buf_triggers(e.data.buf_id) end
  end

  Config.new_autocmd(
    'User',
    'MiniFilesBufferCreate',
    integrate_mini_clue,
    'Make mini.clue work with mini.files'
  )

  local define_keymaps = function(e)
    local buf_map = function(mode, lhs, rhs, opts)
      vim.keymap.set(
        mode,
        lhs,
        rhs,
        vim.tbl_extend('keep', opts or {}, { buffer = e.data.buf_id })
      )
    end
      -- stylua: ignore start
      buf_map("n", "'", function() mark_goto() end, { desc = "Set mark" }) -- Got overriden for some reason, so defined again
      buf_map("n", "m", function() mark_set() end, { desc = "Set mark" })
      buf_map("n", "gx", function() ui_open() end, { desc = "OS open" })
      buf_map({ "n", "v" }, "yfr", function() yank_path("relative") end, { desc = "Yank path (relative)" })
      buf_map({ "n", "v" }, "yfa", function() yank_path("absolute") end, { desc = "Yank path (absolute)" })
      buf_map("n", "<C-Space>", function() toggle_preview() end, { desc = "Toggle preview" })
      buf_map("n", "<C-b>", function() norm_in_preview("<C-u>") end, { desc = "Scroll preview backwards" })
      buf_map("n", "<C-f>", function() norm_in_preview("<C-d>") end, { desc = "Scroll preview upwards" })
      buf_map("n", "<Leader>fg", function() search_grep() end, { desc = "Search grep" })
      buf_map("n", "<Leader>ff", function() search_files() end, { desc = "Search files" })
  end

  Config.new_autocmd(
    'User',
    'MiniFilesBufferCreate',
    define_keymaps,
    'Define mini.files buffer keymaps'
  )

  local validate_file = function(path)
    local fd, _, err = vim.uv.fs_open(path, 'r', 1)
    if not fd then return err, nil end
    local is_binary = vim.uv.fs_read(fd, 1024):find('\0') ~= nil
    vim.uv.fs_close(fd)
    return false, is_binary
  end

  local files_preview_ns = vim.api.nvim_create_namespace('minifiles')

  local extend_preview_lines = function(args)
    local buf = args.data.buf_id
    local path, stat = buf_get_path(buf)
    if not stat or stat.type == 'directory' then return end
    local extm_id = 1
    local error = function(msg)
      local hl = 'Text'
      vim.treesitter.stop(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
      vim.api.nvim_buf_set_extmark(buf, files_preview_ns, 0, 0, {
        id = extm_id,
        virt_text_pos = 'overlay',
        virt_text = { { msg, hl } },
      })
    end
    local warn = function(msg)
      local hl = 'WarningMsg'
      vim.api.nvim_buf_set_extmark(buf, files_preview_ns, 0, 0, {
        id = extm_id,
        virt_text_pos = 'right_align',
        virt_text = { { msg, hl } },
      })
    end
    local no_access, is_binary = validate_file(path)
    local format_msg = function(msg)
      msg = ' '
        .. msg
        .. string.rep(' ', MiniFiles.config.windows.width_preview)
      return string.gsub(msg, ' ', '-')
    end
    if no_access then
      error(format_msg('No access'))
      return
    end
    if is_binary then
      error(format_msg('Non text file'))
      return
    end
    if stat.size > 512 * 1024 then
      warn('Large file detected (>512KB)')
      return
    end
    local read_ok, read_lines = pcall(vim.fn.readfile, path, '')
    if read_ok then
      local lines = vim.split(table.concat(read_lines, '\n'), '\n')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
  end

  -- Extend `mini.files` preview lines; adjust preview error display
  Config.new_autocmd(
    'User',
    'MiniFilesBufferUpdate',
    extend_preview_lines,
    'Extend preview lines'
  )
end)

-- Miscellaneous small but useful functions. Example usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
-- - `<Leader>or` - resize window to its "editable width"
-- - `:lua put_text(vim.lsp.get_clients())` - put output of a function below
--   cursor in current buffer. Useful for a detailed exploration.
-- - `:lua put(MiniMisc.stat_summary(MiniMisc.bench_time(f, 100)))` - run
--   function `f` 100 times and report statistical summary of execution times
now_if_args(function()
  -- Makes `:h MiniMisc.put()` and `:h MiniMisc.put_text()` public
  require('mini.misc').setup()

  -- Change current working directory based on the current file path. It
  -- searches up the file tree until the first root marker ('.git' or 'Makefile')
  -- and sets their parent directory as a current directory.
  -- This is helpful when simultaneously dealing with files from several projects.
  MiniMisc.setup_auto_root()

  -- Restore latest cursor position on file open
  MiniMisc.setup_restore_cursor()

  -- Synchronize terminal emulator background with Neovim's background to remove
  -- possibly different color padding around Neovim instance
  MiniMisc.setup_termbg_sync()
end)

-- Step two ===================================================================

-- Extra 'mini.nvim' functionality.
--
-- See also:
-- - `:h MiniExtra.pickers` - pickers. Most are mapped in `<Leader>f` group.
--   Calling `setup()` makes 'mini.pick' respect 'mini.extra' pickers.
-- - `:h MiniExtra.gen_ai_spec` - 'mini.ai' textobject specifications
-- - `:h MiniExtra.gen_highlighter` - 'mini.hipatterns' highlighters
later(function() require('mini.extra').setup() end)

-- Extend and create a/i textobjects, like `:h a(`, `:h a'`, and more).
-- Contains not only `a` and `i` type of textobjects, but also their "next" and
-- "last" variants that will explicitly search for textobjects after and before
-- cursor. Example usage:
-- - `ci)` - *c*hange *i*inside parenthesis (`)`)
-- - `di(` - *d*elete *i*inside padded parenthesis (`(`)
-- - `yaq` - *y*ank *a*round *q*uote (any of "", '', or ``)
-- - `vif` - *v*isually select *i*inside *f*unction call
-- - `cina` - *c*hange *i*nside *n*ext *a*rgument
-- - `valaala` - *v*isually select *a*round *l*ast (i.e. previous) *a*rgument
--   and then again reselect *a*round new *l*ast *a*rgument
--
-- See also:
-- - `:h text-objects` - general info about what textobjects are
-- - `:h MiniAi-builtin-textobjects` - list of all supported textobjects
-- - `:h MiniAi-textobject-specification` - examples of custom textobjects
later(function()
  local ai = require('mini.ai')
  ai.setup({
    -- 'mini.ai' can be extended with custom textobjects
    custom_textobjects = {
      -- Make `aB` / `iB` act on around/inside whole *b*uffer
      B = MiniExtra.gen_ai_spec.buffer(),
      -- For more complicated textobjects that require structural awareness,
      -- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
      -- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
      F = ai.gen_spec.treesitter({
        a = '@function.outer',
        i = '@function.inner',
      }),
    },

    -- 'mini.ai' by default mostly mimics built-in search behavior: first try
    -- to find textobject covering cursor, then try to find to the right.
    -- Although this works in most cases, some are confusing. It is more robust to
    -- always try to search only covering textobject and explicitly ask to search
    -- for next (`an`/`in`) or last (`al`/`il`).
    -- Try this. If you don't like it - delete next line and this comment.
    search_method = 'cover',
  })

  local find_textobject = function(ai_type, spec, opts)
    opts = vim.tbl_extend('keep', opts or {}, { silent = true })
    local snap_config = vim.deepcopy(MiniAi.config)
    local tmp_id = '_'
    MiniAi.config =
      { custom_textobjects = { [tmp_id] = spec }, silent = opts.silent }
    local reg = MiniAi.find_textobject(ai_type, tmp_id, opts)
    MiniAi.config = snap_config
    return reg
  end

  local buf_get_text = function(reg)
    local from, to = reg.from, reg.to
    return vim.api.nvim_buf_get_text(
      0,
      from.line - 1,
      from.col - 1,
      to.line - 1,
      to.col,
      {}
    )
  end

  local buf_set_text = function(reg, buf_text, follow)
    local from, to = reg.from, reg.to
    vim.api.nvim_buf_set_text(
      0,
      from.line - 1,
      from.col - 1,
      to.line - 1,
      to.col,
      buf_text
    )
    if follow then
      vim.api.nvim_win_set_cursor(0, { from.line, from.col - 1 })
    end
  end

  local function escape_lua_pattern(s)
    return (s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
  end

  local function unescape_lua_pattern(s)
    return (s:gsub("%%(.)", "%1"))
  end

  local function get_config()
    local config = {}
    vim.list_extend(config, vim.b.cycle_config or {})
    vim.list_extend(config, vim.g.cycle_config or {})
    for i, conf in ipairs(config) do
      conf = vim.tbl_extend(
        'keep',
        conf,
        { words = {}, cycle = true, pat = '%f[%w]()%f[%W]' }
      )
      conf._patterns = vim.tbl_map(function(word)
        local pat = conf.pat
        local word_pat = pat:gsub('%(%)', escape_lua_pattern(word))
        return word_pat
      end, conf.words)
      config[i] = conf
    end
    return config
  end

  local cycle_word = function()
    local config = get_config()
    local match_pattern = {}
    for _, conf in ipairs(config) do
      for i, word in ipairs(conf.words) do
        if word ~= '' then table.insert(match_pattern, conf._patterns[i]) end
      end
    end
    local match_reg = find_textobject('a', { match_pattern }, {
      search_method = 'cover_or_next',
      n_lines = 0,
      n_times = vim.v.count1,
    })
    if not match_reg then
      vim.notify(
        '[mini.cycle] No matches found in the current line',
        vim.log.levels.WARN
      )
      return
    end
    local find_longest_cover = function(conf, ref_reg)
      local item_list = {}
      for i, word in ipairs(conf.words) do
        if word ~= '' then
          table.insert(
            item_list,
            { i = i, word = word, pat = conf._patterns[i] }
          )
        end
      end
      table.sort(item_list, function(a, b) return #a.word >= #b.word end)
      for _, item in ipairs(item_list) do
        local cover_reg = find_textobject('a', { item.pat }, {
          search_method = 'cover',
          n_lines = 0,
          n_times = 1,
          reference_region = { from = ref_reg },
        })
        if cover_reg then return cover_reg, item.i end
      end
    end
    local match_text = buf_get_text(match_reg)[1]
    for _, conf in ipairs(config) do
      if vim.list_contains(conf.words, escape_lua_pattern(match_text)) then
        local cover_reg, i = find_longest_cover(conf, match_reg.from)
        if cover_reg then
          local next_index = conf.cycle and (i % #conf.words + 1)
            or math.min(i + 1, #conf.words)
          local next_word = unescape_lua_pattern(conf.words[next_index])
          local cover_text = buf_get_text(cover_reg)[1]

          if next_word ~= cover_text then
            buf_set_text(cover_reg, { next_word }, true)
          end
          return
        end
      end
    end
  end

  -- stylua: ignore
  vim.keymap.set("n", "<Leader>c", function() cycle_word() end, { desc = "Cycle" })
end)

-- Align text interactively. Example usage:
-- - `gaip,` - `ga` (align operator) *i*nside *p*aragraph by comma
-- - `gAip` - start interactive alignment on the paragraph. Choose how to
--   split, justify, and merge string parts. Press `<CR>` to make it permanent,
--   press `<Esc>` to go back to initial state.
--
-- See also:
-- - `:h MiniAlign-example` - hands-on list of examples to practice aligning
-- - `:h MiniAlign.gen_step` - list of support step customizations
-- - `:h MiniAlign-algorithm` - how alignment is done on algorithmic level
later(function() require('mini.align').setup() end)

-- Animate common Neovim actions. Like cursor movement, scroll, window resize,
-- window open, window close. Animations are done based on Neovim events and
-- don't require custom mappings.
--
-- It is not enabled by default because its effects are a matter of taste.
-- Also scroll and resize have some unwanted side effects (see `:h mini.animate`).
-- Uncomment next line (use `gcc`) to enable.
-- later(function() require('mini.animate').setup() end)

-- Go forward/backward with square brackets. Implements consistent sets of mappings
-- for selected targets (like buffers, diagnostic, quickfix list entries, etc.).
-- Example usage:
-- - `]b` - go to next buffer
-- - `[j` - go to previous jump inside current buffer
-- - `[Q` - go to first entry of quickfix list
-- - `]X` - go to last conflict marker in a buffer
--
-- See also:
-- - `:h MiniBracketed` - overall mapping design and list of targets
later(function() require('mini.bracketed').setup() end)

-- Remove buffers. Opened files occupy space in tabline and buffer picker.
-- When not needed, they can be removed. Example usage:
-- - `<Leader>bw` - completely wipeout current buffer (see `:h :bwipeout`)
-- - `<Leader>bW` - completely wipeout current buffer even if it has changes
-- - `<Leader>bd` - delete current buffer (see `:h :bdelete`)
later(function() require('mini.bufremove').setup() end)

-- Show next key clues in a bottom right window. Requires explicit opt-in for
-- keys that act as clue trigger. Example usage:
-- - Press `<Leader>` and wait for 1 second. A window with information about
--   next available keys should appear.
-- - Press one of the listed keys. Window updates immediately to show information
--   about new next available keys. You can press `<BS>` to go back in key sequence.
-- - Press keys until they resolve into some mapping.
--
-- Note: it is designed to work in buffers for normal files. It doesn't work in
-- special buffers (like for 'mini.starter' or 'mini.files') to not conflict
-- with its local mappings.
--
-- See also:
-- - `:h MiniClue-examples` - examples of common setups
-- - `:h MiniClue.ensure_buf_triggers()` - use it to enable triggers in buffer
-- - `:h MiniClue.set_mapping_desc()` - change mapping description not from config
later(function()
  local miniclue = require('mini.clue')
  -- stylua: ignore
  miniclue.setup({
    -- Define which clues to show. By default shows only clues for custom mappings
    -- (uses `desc` field from the mapping; takes precedence over custom clue).
    clues = {
      -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      -- This creates a submode for window resize mappings. Try the following:
      -- - Press `<C-w>s` to make a window split.
      -- - Press `<C-w>+` to increase height. Clue window still shows clues as if
      --   `<C-w>` is pressed again. Keep pressing just `+` to increase height.
      --   Try pressing `-` to decrease height.
      -- - Stop submode either by `<Esc>` or by any key that is not in submode.
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    -- Explicitly opt-in for set of common keys to trigger clue window
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leader triggers
      { mode =   'n',        keys = '\\' },       -- mini.basics
      { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },    -- Built-in completion
      { mode = { 'n', 'x' }, keys = 'g' },        -- `g` key
      { mode = { 'n', 'x' }, keys = "'" },        -- Marks
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },        -- Registers
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },    -- Window commands
      { mode = { 'n', 'x' }, keys = 's' },        -- `s` key (mini.surround, etc.)
      { mode = { 'n', 'x' }, keys = 'z' },        -- `z` key
    },
    window = {
      config = {
        width = 'auto'
      }
    }
  })
end)

-- Command line tweaks. Improves command line editing with:
-- - Autocompletion. Basically an automated `:h cmdline-completion`.
-- - Autocorrection of words as-you-type. Like `:W`->`:w`, `:lau`->`:lua`, etc.
-- - Autopeek command range (like line number at the start) as-you-type.
-- later(function() require('mini.cmdline').setup() end)

-- Tweak and save any color scheme. Contains utility functions to work with
-- color spaces and color schemes. Example usage:
-- - `:Colorscheme default` - switch with animation to the default color scheme
--
-- See also:
-- - `:h MiniColors.interactive()` - interactively tweak color scheme
-- - `:h MiniColors-recipes` - common recipes to use during interactive tweaking
-- - `:h MiniColors.convert()` - convert between color spaces
-- - `:h MiniColors-color-spaces` - list of supported color sapces
--
-- It is not enabled by default because it is not really needed on a daily basis.
-- Uncomment next line (use `gcc`) to enable.
-- later(function() require('mini.colors').setup() end)

-- Comment lines. Provides functionality to work with commented lines.
-- Uses `:h 'commentstring'` option to infer comment structure.
-- Example usage:
-- - `gcip` - toggle comment (`gc`) *i*inside *p*aragraph
-- - `vapgc` - *v*isually select *a*round *p*aragraph and toggle comment (`gc`)
-- - `gcgc` - uncomment (`gc`, operator) comment block at cursor (`gc`, textobject)
--
-- The built-in `:h commenting` is based on 'mini.comment'. Yet this module is
-- still enabled as it provides more customization opportunities.
later(function() require('mini.comment').setup() end)

-- Autohighlight word under cursor with a customizable delay.
-- Word boundaries are defined based on `:h 'iskeyword'` option.
--
-- It is not enabled by default because its effects are a matter of taste.
-- Uncomment next line (use `gcc`) to enable.
-- later(function() require('mini.cursorword').setup() end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
-- Example usage:
-- - `ghip` - apply hunks (`gh`) within *i*nside *p*aragraph
-- - `gHG` - reset hunks (`gH`) from cursor until end of buffer (`G`)
-- - `ghgh` - apply (`gh`) hunk at cursor (`gh`)
-- - `gHgh` - reset (`gH`) hunk at cursor (`gh`)
-- - `<Leader>go` - toggle overlay
--
-- See also:
-- - `:h MiniDiff-overview` - overview of how module works
-- - `:h MiniDiff-diff-summary` - available summary information
-- - `:h MiniDiff.gen_source` - available built-in sources
later(
  function()
    require('mini.diff').setup({
      view = {
        style = 'sign',
        signs = { add = '▍', change = '▍', delete = '▍' },
      },
    })
  end
)

-- Git integration for more straightforward Git actions based on Neovim's state.
-- It is not meant as a fully featured Git client, only to provide helpers that
-- integrate better with Neovim. Example usage:
-- - `<Leader>gs` - show information at cursor
-- - `<Leader>gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>gL` - show Git log of current file
-- - `:Git help git` - show output of `git help git` inside Neovim
--
-- See also:
-- - `:h MiniGit-examples` - examples of common setups
-- - `:h :Git` - more details about `:Git` user command
-- - `:h MiniGit.show_at_cursor()` - what information at cursor is shown
later(function()
  require('mini.git').setup()

  vim.cmd.cnoreabbrev('G', 'Git')
  vim.cmd.cnoreabbrev('Gc', 'Git checkout')
  vim.cmd.cnoreabbrev('Gca', 'Git commit --amend')

  -- Git blame

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniGitCommandSplit',
    group = vim.api.nvim_create_augroup('mini_gitblame', { clear = true }),
    desc = 'Enhance `Git blame`: colorize buffer and set width for vertical split',
    callback = function(e)
      if e.data.git_subcommand ~= 'blame' then return end
      local win_src = e.data.win_source
      local buf = e.buf
      local win = e.data.win_stdout
      vim.bo[buf].modifiable = false
      vim.wo[win].wrap = false
      vim.wo[win].cursorline = true
      vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
      vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })
      vim.wo[win].scrollbind, vim.wo[win_src].scrollbind = true, true
      vim.wo[win].cursorbind, vim.wo[win_src].cursorbind = true, true
      if string.match(e.data.cmd_input.mods, 'vertical') then
        local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
        local width = vim.iter(lines):fold(-1, function(acc, ln)
          local stat = string.match(ln, '^[%w%p]+ %b()')
          return math.max(acc, vim.fn.strwidth(stat))
        end)
        width = width + vim.fn.getwininfo(win)[1].textoff
        vim.api.nvim_win_set_width(win, width)
      end
      local leftmost = [[^.\{-}\zs]]
      -- stylua: ignore start
      --[[ ^hash  ]] vim.fn.matchadd("Tag", [[^^\w\+]])
      --[[ hash   ]] vim.fn.matchadd("Identifier", [[^\w\+]])
      --[[ author ]] vim.fn.matchadd("String", leftmost .. [[(\zs.\{-} \ze\d\{4}-]])
      --[[ date   ]] vim.fn.matchadd("Comment", leftmost .. [[[0-9-]\{10} [0-9:]\{8} [+-]\d\+]])
    end,
  })

  vim.api.nvim_create_user_command('GitBlame', function()
    local git_wins = vim
      .iter(vim.api.nvim_tabpage_list_wins(0))
      :filter(function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        return vim.bo[buf].ft == 'git_blame'
      end)
      :totable()
    if not vim.tbl_isempty(git_wins) then
      vim
        .iter(git_wins)
        :each(function(win) vim.api.nvim_win_close(win, true) end)
    else
      local open = function()
        vim.cmd([[vert above Git blame -- %]])
        vim.bo.ft = 'git_blame'
      end
      if not pcall(open) then
        vim.notify(
          '[mini.git] Unable to open `:GitBlame` for the file',
          vim.log.levels.WARN
        )
      end
    end
  end, {})
end)

-- Highlight patterns in text. Like `TODO`/`NOTE` or color hex codes.
-- Example usage:
-- - `:Pick hipatterns` - pick among all highlighted patterns
--
-- See also:
-- - `:h MiniHipatterns-examples` - examples of common setups
later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words

  local perf_bg = vim.api.nvim_get_hl(0, { name = '@keyword', link = false }).fg
  vim.api.nvim_set_hl(
    0,
    'HipatternsPerf',
    { bold = true, fg = 'black', bg = perf_bg }
  )

  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      fix = hi_words({ 'FIX', 'FIXME', 'BUG' }, 'MiniHipatternsFixme'),
      note = hi_words({ 'NOTE' }, 'MiniHipatternsNote'),
      todo = hi_words({ 'TODO', 'FEAT' }, 'MiniHipatternsTodo'),
      hack = hi_words({ 'WARN', 'WARNING', 'HACK' }, 'MiniHipatternsHack'),
      perf = hi_words({ 'PERF' }, 'HipatternsPerf'),
      -- Highlight hex color string (#aabbcc)
      hex_color = hipatterns.gen_highlighter.hex_color(),
      -- Highlight short hex color string (#000)
      hex_color_short = {
        pattern = '()#%x%x%x()%f[^%x%w]',
        group = function(_, _, data)
          local match = data.full_match
          local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
          local hex_color = '#' .. r .. r .. g .. g .. b .. b
          return MiniHipatterns.compute_hex_color_group(hex_color, 'bg')
        end,
      },
      -- * { color: hsl(80, 80%, 50%) }
      hsl_color = {
        -- NOTE: Partial support for CSS hsl()
        pattern = 'hsl%(%d+[, ] ?%d+%%?[, ] ?%d+%%?%)',
        group = function(_, m, _)
          -- https://www.w3.org/TR/css-color-3/#hsl-color
          local function hsl_to_rgb(h, s, l)
            h, s, l = h % 360, s / 100, l / 100
            if h < 0 then h = h + 360 end
            local function f(n)
              local k = (n + h / 30) % 12
              local a = s * math.min(l, 1 - l)
              return l - a * math.max(-1, math.min(k - 3, 9 - k, 1))
            end
            return f(0) * 255, f(8) * 255, f(4) * 255
          end
          local h, s, l = m:match('(%d+)[, ] ?(%d+)%%?[, ] ?(%d+)%%?')
          local r, g, b = hsl_to_rgb(h, s, l)
          local hex = string.format('#%02x%02x%02x', r, g, b)
          return MiniHipatterns.compute_hex_color_group(hex, 'bg')
        end,
      },
    },
  })
end)

-- Visualize and work with indent scope. It visualizes indent scope "at cursor"
-- with animated vertical line. Provides relevant motions and textobjects.
-- Example usage:
-- - `cii` - *c*hange *i*nside *i*ndent scope
-- - `Vaiai` - *V*isually select *a*round *i*ndent scope and then again
--   reselect *a*round new *i*indent scope
-- - `[i` / `]i` - navigate to scope's top / bottom
--
-- See also:
-- - `:h MiniIndentscope.gen_animation` - available animation rules
later(function() require('mini.indentscope').setup() end)

-- Jump to next/previous single character. It implements "smarter `fFtT` keys"
-- (see `:h f`) that work across multiple lines, start "jumping mode", and
-- highlight all target matches. Example usage:
-- - `fxff` - move *f*orward onto next character "x", then next, and next again
-- - `dt)` - *d*elete *t*ill next closing parenthesis (`)`)
-- later(function()
--   require('mini.jump').setup({
--     mappings = {
--       forward = 'f',
--       backward = 'F',
--       forward_till = 't',
--       backward_till = 'T',
--     },
--   })
--
--   local custom_jump = function(backward, till)
--     return function()
--       local target = vim.fn.getcharstr()
--       MiniJump.jump(target, backward, till)
--     end
--   end
--   vim.keymap.set('n', 'f', custom_jump(false, false))
--   vim.keymap.set('n', 'F', custom_jump(true, false))
--   vim.keymap.set('n', 't', custom_jump(false, true))
--   vim.keymap.set('n', 'T', custom_jump(true, true))
--
--   -- Why? Because I had a use case:
--   -- { mode = 'n', keys = '<Leader>b',  desc = '+Buffer' },
--   --            this 'd' was my target  ↑  in a macro
--   --            to reach it, I decided on using $F'F'Fd
--   --            which would've worked great without mini.jump but since I'm
--   --            using mini.jump, F would go to the previous '
--   --            To tackle this, I thought that since we have ; as a repeat jump
--   --            keybind, there was no real need to have smart jump on fFtT
--   --            And here we are, with my personalized flow that works for me.
--   --            For the people who think they would've instead used $F'FhFd,
--   --            instead of tinkering with the plugin setup, you might be more
--   --            intelligent than me.
-- end)

-- Jump within visible lines to pre-defined spots via iterative label filtering.
-- Spots are computed by a configurable spotter function. Example usage:
-- - Lock eyes on desired location to jump
-- - `<CR>` - start jumping; this shows character labels over target spots
-- - Type character that appears over desired location; number of target spots
--   should be reduced
-- - Keep typing labels until target spot is unique to perform the jump
--
-- See also:
-- - `:h MiniJump2d.gen_spotter` - list of available spotters
later(function()
  local jump2d = require('mini.jump2d')
  jump2d.setup({
    labels = 'abfhijklnoprsvw',
    spotter = jump2d.gen_spotter.union(
      jump2d.builtin_opts.line_start.spotter,
      jump2d.builtin_opts.word_start.spotter
    ),
    view = {
      dim = true,
      n_steps_ahead = 3,
    },
    mappings = {
      start_jumping = 'sj',
    },
  })
end)

-- Special key mappings. Provides helpers to map:
-- - Multi-step actions. Apply action 1 if condition is met; else apply
--   action 2 if condition is met; etc.
-- - Combos. Sequence of keys where each acts immediately plus execute extra
--   action if all are typed fast enough. Useful for Insert mode mappings to not
--   introduce delay when typing mapping keys without intention to execute action.
--
-- See also:
-- - `:h MiniKeymap-examples` - examples of common setups
-- - `:h MiniKeymap.map_multistep()` - map multi-step action
-- - `:h MiniKeymap.map_combo()` - map combo
-- later(function()
--   require('mini.keymap').setup()
--   -- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
--   MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
--   MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
--   -- On `<CR>` try to accept current completion item, fall back to accounting
--   -- for pairs from 'mini.pairs'
--   MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
--   -- On `<BS>` just try to account for pairs from 'mini.pairs'
--   MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
-- end)

-- Move any selection in any direction. Example usage in Normal mode:
-- - `<M-j>`/`<M-k>` - move current line down / up
-- - `<M-h>`/`<M-l>` - decrease / increase indent of current line
--
-- Example usage in Visual mode:
-- - `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` - move selection left/down/up/right
later(function() require('mini.move').setup() end)

-- Text edit operators. All operators have mappings for:
-- - Regular operator (waits for motion/textobject to use)
-- - Current line action (repeat second character of operator to activate)
-- - Act on visual selection (type operator in Visual mode)
--
-- Example usage:
-- - `griw` - replace (`gr`) *i*inside *w*ord
-- - `gmm` - multiple/duplicate (`gm`) current line (extra `m`)
-- - `vipgs` - *v*isually select *i*nside *p*aragraph and sort it (`gs`)
-- - `gxiww.` - exchange (`gx`) *i*nside *w*ord with next word (`w` to navigate
--   to it and `.` to repeat exchange operator)
-- - `g==` - execute current line as Lua code and replace with its output.
--   For example, typing `g==` over line `vim.lsp.get_clients()` shows
--   information about all available LSP clients.
--
-- See also:
-- - `:h MiniOperators-mappings` - overview of how mappings are created
-- - `:h MiniOperators-overview` - overview of present operators
later(function()
  require('mini.operators').setup()

  -- Create mappings for swapping adjacent arguments. Notes:
  -- - Relies on `a` argument textobject from 'mini.ai'.
  -- - It is not 100% reliable, but mostly works.
  -- - It overrides `:h (` and `:h )`.
  -- Explanation: `gx`-`ia`-`gx`-`ila` <=> exchange current and last argument
  -- Usage: when on `a` in `(aa, bb)` press `)` followed by `(`.
  vim.keymap.set(
    'n',
    '(',
    'gxiagxila',
    { remap = true, desc = 'Swap arg left' }
  )
  vim.keymap.set(
    'n',
    ')',
    'gxiagxina',
    { remap = true, desc = 'Swap arg right' }
  )
end)

-- Autopairs functionality. Insert pair when typing opening character and go over
-- right character if it is already to cursor's right. Also provides mappings for
-- `<CR>` and `<BS>` to perform extra actions when inside pair.
-- Example usage in Insert mode:
-- - `(` - insert "()" and put cursor between them
-- - `)` when there is ")" to the right - jump over ")" without inserting new one
-- - `<C-v>(` - always insert a single "(" literally. This is useful since
--   'mini.pairs' doesn't provide particularly smart behavior, like auto balancing
later(function()
  -- Create pairs not only in Insert, but also in Command line mode
  require('mini.pairs').setup({
    modes = { command = true },
    mappings = {
      ['('] = { neigh_pattern = '[^\\][%s>)%]},:]' },
      ['['] = { neigh_pattern = '[^\\][%s>)%]},:]' },
      ['{'] = { neigh_pattern = '[^\\][%s>)%]},:]' },
      ['"'] = { neigh_pattern = '[%s<(%[{][%s>)%]},:]' },
      ["'"] = { neigh_pattern = '[%s<(%[{][%s>)%]},:]' },
      ['`'] = { neigh_pattern = '[%s<(%[{][%s>)%]},:]' },
      ['<'] = {
        action = 'open',
        pair = '<>',
        neigh_pattern = '[\r%w"\'`].',
        register = { cr = false },
      },
      ['>'] = { action = 'close', pair = '<>', register = { cr = false } },
    },
  })
end)

-- Pick anything with single window layout and fast matching. This is one of
-- the main usability improvements as it powers a lot of "find things quickly"
-- workflows. How to use a picker:
-- - Start picker, usually with `:Pick <picker-name>` command. Like `:Pick files`.
--   It shows a single window in the bottom left corner filled with possible items
--   to choose from. Current item has special full line highlighting.
--   At the top there is a current query used to filter+sort items.
-- - Type characters (appear at top) to narrow down items. There is fuzzy matching:
--   characters may not match one-by-one, but they should be in correct order.
-- - Navigate down/up with `<C-n>`/`<C-p>`.
-- - Press `<Tab>` to show item's preview. `<Tab>` again goes back to items.
-- - Press `<S-Tab>` to show picker's info. `<S-Tab>` again goes back to items.
-- - Press `<CR>` to choose an item. The exact action depends on the picker: `files`
--   picker opens a selected file, `help` picker opens help page on selected tag.
--   To close picker without choosing an item, press `<Esc>`.
--
-- Example usage:
-- - `<Leader>ff` - *f*ind *f*iles; for best performance requires `ripgrep`
-- - `<Leader>fg` - *f*ind inside files (a.k.a. "to *g*rep"); requires `ripgrep`
-- - `<Leader>fh` - *f*ind *h*elp tag
-- - `<Leader>fr` - *r*esume latest picker
-- - `:h vim.ui.select()` - implemented with 'mini.pick'
--
-- See also:
-- - `:h MiniPick-overview` - overview of picker functionality
-- - `:h MiniPick-examples` - examples of common setups
-- - `:h MiniPick.builtin` and `:h MiniExtra.pickers` - available pickers;
--   Execute one either with Lua function, `:Pick <picker-name>` command, or
--   one of `<Leader>f` mappings defined in 'plugin/20_keymaps.lua'
later(function()
  local preview = (function()
    local config = { orientation = 'horizontal', ratio = 0.6 }
    local state =
      { win_id = nil, buf_id = nil, last_item = nil, is_hidden = false }
    local cache = { win_config = {} }
    local scroll_map =
      { up = '<C-b>', down = '<C-f>', left = 'zH', right = 'zL' }

    local function reset()
      state.win_id = nil
      state.buf_id = nil
      state.last_item = nil
      state.is_hidden = false
      cache.win_config = {}
    end

    local function has_win()
      return state.win_id ~= nil and vim.api.nvim_win_is_valid(state.win_id)
    end

    local function create_buf()
      state.buf_id = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(
        state.buf_id,
        'minipick://' .. state.buf_id .. '/preview'
      )
      vim.bo[state.buf_id].bufhidden = 'wipe'
      vim.bo[state.buf_id].matchpairs = ''
      vim.b[state.buf_id].minicursorword_disable = true
      vim.b[state.buf_id].miniindentscope_disable = true
    end

    local function create_win(win_config)
      win_config.style = 'minimal'
      state.win_id = vim.api.nvim_open_win(state.buf_id, false, win_config)
      vim.wo[state.win_id].foldenable = false
      vim.wo[state.win_id].foldmethod = 'manual'
      vim.wo[state.win_id].linebreak = true
      vim.wo[state.win_id].scrolloff = 0
      vim.wo[state.win_id].winhighlight =
        'NormalFloat:MiniPickNormal,FloatBorder:MiniPickBorder'
      vim.wo[state.win_id].wrap = true
    end

    local function close_buf()
      pcall(vim.api.nvim_buf_delete, state.buf_id, { force = true })
      state.buf_id = nil
    end

    local function close_win()
      if has_win() then pcall(vim.api.nvim_win_close, state.win_id, true) end
      state.win_id = nil
    end

    local function close()
      close_win()
      close_buf()
      state.last_item = nil
    end

    ---@param item table | nil
    local function show_preview(item)
      if item ~= nil then
        local preview_func = MiniPick.get_picker_opts().source.preview
        pcall(preview_func, state.buf_id, item)
      else
        vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, {})
      end
    end

    local function compute_border_size(border)
      local n = type(border) == 'table' and #border or 0
      if n == 0 then
        return 2
      elseif config.orientation == 'vertical' then
        return (
          (border[3 % n + 1] == '' and 0 or 1)
          + (border[7 % n + 1] == '' and 0 or 1)
        )
      else
        return (
          (border[1 % n + 1] == '' and 0 or 1)
          + (border[5 % n + 1] == '' and 0 or 1)
        )
      end
    end

    local function compute_layout(window_config, preview_config)
      local preview_ratio = config.ratio
      local border_size = compute_border_size(window_config.border)

      if config.orientation == 'vertical' then
        local preview_size =
          math.floor(preview_ratio * (window_config.width + border_size))
        local preview_width = math.max(1, preview_size - border_size)
        local main_width =
          math.max(1, window_config.width - preview_width - border_size)
        window_config.width = main_width
        preview_config.width = preview_width
        preview_config.col = window_config.col + (main_width + border_size)
      else
        local preview_size =
          math.floor(preview_ratio * (window_config.height + border_size))
        local preview_height = math.max(1, preview_size - border_size)
        local main_height =
          math.max(1, window_config.height - preview_height - border_size)
        window_config.height = main_height
        preview_config.height = preview_height
        if window_config.anchor == 'SW' then
          window_config.row = window_config.row - (preview_height + border_size)
        else
          preview_config.row = window_config.row + (main_height + border_size)
        end
      end
    end

    local function setup(opts)
      config = vim.tbl_deep_extend('force', config, opts or {})
    end

    local function scroll(direction)
      if not has_win() then return end
      local keys =
        vim.api.nvim_replace_termcodes(scroll_map[direction], true, true, true)
      vim.api.nvim_win_call(
        state.win_id,
        function() vim.cmd('normal! ' .. keys) end
      )
    end

    local function cache_win_config()
      local picker_state = MiniPick.get_picker_state()
      if
        not (
          picker_state
          and picker_state.windows
          and picker_state.windows.main
        )
      then
        return
      end
      local window_config =
        vim.api.nvim_win_get_config(picker_state.windows.main)
      local keys = {
        'anchor',
        'border',
        'col',
        'height',
        'relative',
        'row',
        'width',
        'zindex',
      }
      for _, key in ipairs(keys) do
        cache.win_config[key] = window_config[key]
      end
    end

    local function update()
      if state.is_hidden then
        close()
        return
      end

      local picker_state = MiniPick.get_picker_state()
      if
        not (
          picker_state
          and picker_state.windows
          and picker_state.windows.main
        )
      then
        return
      end

      local window_config = vim.deepcopy(cache.win_config)
      local preview_config = vim.deepcopy(cache.win_config)
      compute_layout(window_config, preview_config)

      vim.api.nvim_win_set_config(picker_state.windows.main, window_config)

      if not has_win() then
        create_buf()
        create_win(preview_config)
      else
        vim.api.nvim_win_set_config(state.win_id, preview_config)
      end

      local current_item = MiniPick.get_picker_matches().current
      if current_item ~= state.last_item then
        state.last_item = current_item
        create_buf()
        vim.api.nvim_win_set_buf(state.win_id, state.buf_id)
        show_preview(current_item)
      end

      vim.schedule(vim.cmd.redraw) -- For previewrs that output the result instantly, like file previews with fast treesitter parsers
      -- For previewers that take their sweet time, like `git diff`
      vim.defer_fn(function() vim.schedule(vim.cmd.redraw) end, 200)
    end

    local function toggle()
      MiniPick.refresh()
      state.is_hidden = not state.is_hidden
      update()
    end

    local function stop()
      close()
      reset()
    end

    -- Update preview on picker refresh
    local mini_pick = require('mini.pick')
    local mini_pick_refresh = mini_pick.refresh

    ---@diagnostic disable-next-line: duplicate-set-field
    mini_pick.refresh = function()
      mini_pick_refresh()
      if mini_pick.is_picker_active() then
        cache_win_config()
        vim.schedule(update)
      end
    end

    return {
      setup = setup,
      scroll = scroll,
      cache_win_config = cache_win_config,
      update = update,
      toggle = toggle,
      stop = stop,
    }
  end)()

  local group = vim.api.nvim_create_augroup('UserMiniPick', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniPickStart',
    group = group,
    callback = function()
      preview.cache_win_config()
      preview.update()
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniPickMatch',
    group = group,
    callback = function() vim.schedule(preview.update) end,
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniPickStop',
    group = group,
    callback = preview.stop,
  })

  ---@param keys string
  local function feedkeys(keys)
    keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
    vim.api.nvim_feedkeys(keys, 'n', true)
  end

  require('mini.pick').setup({
    mappings = {
      stop = '<C-q>',
      move_down_arrow = {
        char = '<Down>',
        func = function()
          feedkeys('<C-n>')
          vim.schedule(preview.update)
        end,
      },
      move_up_arrow = {
        char = '<Up>',
        func = function()
          feedkeys('<C-p>')
          vim.schedule(preview.update)
        end,
      },
      scroll_down = '<A-j>', --| These don't matter, used in feedkeys
      scroll_up = '<A-k>', ----|
      scroll_down_custom = {
        char = '<C-S-j>',
        func = function()
          feedkeys('<A-j>')
          vim.schedule(preview.update)
        end,
      },
      scroll_up_custom = {
        char = '<C-S-k>',
        func = function()
          feedkeys('<A-k>')
          vim.schedule(preview.update)
        end,
      },
      scroll_side_preview_down = {
        char = '<C-f>',
        func = function() preview.scroll('down') end,
      },
      scroll_side_preview_up = {
        char = '<C-b>',
        func = function() preview.scroll('up') end,
      },
      toggle_preview = '',
      toggle_side_preview = { char = '<Tab>', func = preview.toggle },
    },
    window = {
      config = function()
        local height = math.floor(0.8 * vim.o.lines)
        local width = math.floor(0.8 * vim.o.columns)
        return { height = height, width = width }
      end,
    },
  })

  MiniPick.registry.grep_todo = function(local_opts, opts)
    local grep_words = {
      'FIX',
      'FIXME',
      'BUG',
      'NOTE',
      'TODO',
      'FEAT',
      'WARN',
      'WARNING',
      'HACK',
      'PERF',
    }
    local pattern = '(' .. table.concat(grep_words, '|') .. ')[ :]'
    local_opts = vim.tbl_extend('keep', local_opts or {}, { pattern = pattern })
    return MiniPick.registry.grep(local_opts, opts)
  end
end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
--
-- How to manage snippets:
-- - 'mini.snippets' itself doesn't come with preconfigured snippets. Instead there
--   is a flexible system of how snippets are prepared before expanding.
--   They can come from pre-defined path on disk, 'snippets/' directories inside
--   config or plugins, defined inside `setup()` call directly.
-- - This config, however, does come with snippet configuration:
--     - 'snippets/global.json' is a file with global snippets that will be
--       available in any buffer
--     - 'after/snippets/lua.json' defines personal snippets for Lua language
--     - 'friendly-snippets' plugin configured in 'plugin/40_plugins.lua' provides
--       a collection of language snippets
--
-- How to expand a snippet in Insert mode:
-- - If you know snippet's prefix, type it as a word and press `<C-j>`. Snippet's
--   body should be inserted instead of the prefix.
-- - If you don't remember snippet's prefix, type only part of it (or none at all)
--   and press `<C-j>`. It should show picker with all snippets that have prefixes
--   matching typed characters (or all snippets if none was typed).
--   Choose one and its body should be inserted instead of previously typed text.
--
-- How to navigate during snippet session:
-- - Snippets can contain tabstops - places for user to interactively adjust text.
--   Each tabstop is highlighted depending on session progression - whether tabstop
--   is current, was or was not visited. If tabstop doesn't yet have text, it is
--   visualized with special "ghost" inline text: • and ∎ by default.
-- - Type necessary text at current tabstop and navigate to next/previous one
--   by pressing `<C-l>` / `<C-h>`.
-- - Repeat previous step until you reach special final tabstop, usually denoted
--   by ∎ symbol. If you spotted a mistake in an earlier tabstop, navigate to it
--   and return back to the final tabstop.
-- - To end a snippet session when at final tabstop, keep typing or go into
--   Normal mode. To force end snippet session, press `<C-c>`.
--
-- See also:
-- - `:h MiniSnippets-overview` - overview of how module works
-- - `:h MiniSnippets-examples` - examples of common setups
-- - `:h MiniSnippets-session` - details about snippet session
-- - `:h MiniSnippets.gen_loader` - list of available loaders
later(function()
  -- Define language patterns to work better with 'friendly-snippets'
  local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- Recognize special injected language of markdown tree-sitter parser
    markdown_inline = { 'markdown.json' },
  }

  local snippets = require('mini.snippets')
  local config_path = vim.fn.stdpath('config')
  snippets.setup({
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })

  -- By default snippets available at cursor are not shown as candidates in
  -- 'mini.completion' menu. This requires a dedicated in-process LSP server
  -- that will provide them. To have that, uncomment next line (use `gcc`).
  -- MiniSnippets.start_lsp_server()
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
-- Each action can be configured with hooks (like add/remove trailing comma).
-- Example usage:
-- - `gS` - toggle between joined (all in one line) and split (each on a separate
--   line and indented) arguments. It is dot-repeatable (see `:h .`).
--
-- See also:
-- - `:h MiniSplitjoin.gen_hook` - list of available hooks
later(function() require('mini.splitjoin').setup() end)

-- Surround actions: add/delete/replace/find/highlight. Working with surroundings
-- is surprisingly common: surround word with quotes, replace `)` with `]`, etc.
-- This module comes with many built-in surroundings, each identified by a single
-- character. It searches only for surrounding that covers cursor and comes with
-- a special "next" / "last" versions of actions to search forward or backward
-- (just like 'mini.ai'). All text editing actions are dot-repeatable (see `:h .`).
--
-- Example usage (this may feel intimidating at first, but after practice it
-- becomes second nature during text editing):
-- - `saiw)` - *s*urround *a*dd for *i*nside *w*ord parenthesis (`)`)
-- - `sdf`   - *s*urround *d*elete *f*unction call (like `f(var)` -> `var`)
-- - `srb[`  - *s*urround *r*eplace *b*racket (any of [], (), {}) with padded `[`
-- - `sf*`   - *s*urround *f*ind right part of `*` pair (like bold in markdown)
-- - `shf`   - *s*urround *h*ighlight current *f*unction call
-- - `srn{{` - *s*urround *r*eplace *n*ext curly bracket `{` with padded `{`
-- - `sdl'`  - *s*urround *d*elete *l*ast quote pair (`'`)
-- - `vaWsa<Space>` - *v*isually select *a*round *W*ORD and *s*urround *a*dd
--                    spaces (`<Space>`)
--
-- See also:
-- - `:h MiniSurround-builtin-surroundings` - list of all supported surroundings
-- - `:h MiniSurround-surrounding-specification` - examples of custom surroundings
-- - `:h MiniSurround-vim-surround-config` - alternative set of action mappings
later(function() require('mini.surround').setup() end)

-- Highlight and remove trailspace. Temporarily stops highlighting in Insert mode
-- to reduce noise when typing. Example usage:
-- - `<Leader>ot` - trim all trailing whitespace in a buffer
later(function() require('mini.trailspace').setup() end)

-- Track and reuse file system visits. Every file/directory visit is persistently
-- tracked on disk to later reuse: show in special frecency order, etc. It also
-- supports adding labels to visited paths to quickly navigate between them.
-- Example usage:
-- - `<Leader>fv` - find across all visits
-- - `<Leader>vv` / `<Leader>vV` - add/remove special "core" label to current file
-- - `<Leader>vc` / `<Leader>vC` - show files with "core" label; all or added within
--   current working directory
--
-- See also:
-- - `:h MiniVisits-overview` - overview of how module works
-- - `:h MiniVisits-examples` - examples of common setups
later(function() require('mini.visits').setup() end)

-- Not mentioned here, but can be useful:
-- - 'mini.doc' - needed only for plugin developers.
-- - 'mini.fuzzy' - not really needed on a daily basis.
-- - 'mini.test' - needed only for plugin developers.

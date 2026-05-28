local now = Config.now

-- Set theme = Tokyonight ======================================================
now(function()
  vim.pack.add({ 'https://github.com/folke/tokyonight.nvim' })
  require('tokyonight').setup()
  vim.cmd.colorscheme('tokyonight-night')
end)

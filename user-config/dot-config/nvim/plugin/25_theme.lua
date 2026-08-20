local now = Config.now

-- Set theme = Tokyonight ======================================================
now(function()
  vim.pack.add({ 'https://github.com/WTFox/luna.nvim' })
  vim.cmd.colorscheme('luna')
  vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "FlashCurrent" })
end)

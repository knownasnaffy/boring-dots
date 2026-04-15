config.load_autoconfig()

c.auto_save.session = True
c.session.lazy_restore = True

c.colors.tabs.odd.bg = "black"
c.colors.tabs.even.bg = "black"
c.colors.tabs.selected.even.bg = "#444444"
c.colors.tabs.selected.odd.bg = "#444444"

c.fonts.statusbar = "12pt default_family"
c.fonts.tabs.selected = "10pt default_family"
c.fonts.tabs.unselected = "10pt default_family"

c.hints.chars = "asdfjkl;wevnio"
c.colors.webpage.preferred_color_scheme = "dark"
c.content.javascript.clipboard = "access"

c.editor.command = ["ghostty", "-e", "nvim", "{file}"]

c.scrolling.smooth = True
c.tabs.mode_on_change = "restore"
c.tabs.last_close = "startpage"

c.url.default_page = "https://start.barinr.xyz"
c.url.start_pages = "https://start.barinr.xyz"
c.url.searchengines["DEFAULT"] = "https://duckduckgo.com/?q={}"
c.url.searchengines["p"] = "https://www.perplexity.ai/?q={}"
c.url.searchengines["y"] = "https://www.youtube.com/results?search_query={}"
c.url.searchengines["c"] = "https://chatgpt.com/?prompt={}"

c.window.hide_decoration = True

config.unbind("H")
config.unbind("K")
config.unbind("J")
config.unbind("L")

config.bind("J", "scroll-page 0 0.5")  # Instead of "C-d"
config.bind("K", "scroll-page 0 -0.5")  # Instead of "C-i"

config.bind("<Alt-o>", "back")  # Instead of "H"
config.bind("<Alt-i>", "forward")  # Instead of "L"
config.bind("<Alt-.>", "tab-next")  # Instead of "J"
config.bind("<Alt-,>", "tab-prev")  # Instead of "K"
config.bind("<Alt-.>", "tab-next", mode="insert")  # Instead of "J"
config.bind("<Alt-,>", "tab-prev", mode="insert")  # Instead of "K"

config.bind("<Alt-c>", "fake-key <Ctrl+c>", mode="normal")
config.bind("<Alt-c>", "fake-key <Ctrl+c>", mode="insert")
config.bind("<Alt-c>", "fake-key <Ctrl+c>", mode="caret")

config.bind("<Alt-v>", "fake-key <Ctrl+v>", mode="insert")
config.bind("<Alt-v>", "fake-key <Ctrl+v>", mode="normal")

config.bind("<Alt-q>", "mode-enter normal", mode="insert")
config.bind("<Alt-q>", "mode-enter normal", mode="caret")
config.bind("<Alt-q>", "mode-enter normal", mode="passthrough")

config.bind("td", "config-cycle -u *://{url:host}/* colors.webpage.darkmode.enabled ;; reload", mode="normal")

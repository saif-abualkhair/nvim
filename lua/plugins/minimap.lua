  return {
    'wfxr/minimap.vim',
    build = "cargo install --locked code-minimap",
    config = function()
      vim.cmd("let g:minimap_width = 20")
      vim.cmd("let g:minimap_auto_start = 1")
      vim.cmd("let g:minimap_auto_start_win_enter = 1")
      -- vim.cmd("Minimap")
    end,
  }

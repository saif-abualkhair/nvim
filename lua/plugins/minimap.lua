-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "wfxr/minimap.vim",
  build = "cargo install --locked code-minimap",
  config = function()
    vim.cmd "let g:minimap_width = 20"
    vim.cmd "let g:minimap_auto_start = 1"
    vim.cmd "let g:minimap_auto_start_win_enter = 1"

    -- Define an autocmd to run Minimap when a buffer is entered
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        -- Check if the Minimap command is available
        if vim.fn.exists ":Minimap" == 2 then vim.cmd "Minimap" end
      end,
    })

    -- Define an autocmd to close Minimap when a buffer is left
    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "*",
      callback = function()
        -- Check if Neovim is still running and the Minimap command is available
        if vim.fn.exists ":MinimapClose" == 2 and vim.fn.exists ":q" == 2 then vim.cmd "MinimapClose" end
      end,
    })
  end,
}

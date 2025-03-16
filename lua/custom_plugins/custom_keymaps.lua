local M = {}

function M.go_run_current_file()
  -- Check if the file has a name (i.e., it's saved)
  local file_path = vim.fn.expand "%"
  if file_path == "" then return end

  -- Save the current file
  vim.cmd "w"

  -- Open a horizontal split and run `go run` in it
  vim.cmd("split | terminal go run " .. file_path)
end

-- Map F6 to the function
vim.api.nvim_set_keymap("n", "<F6>", "", {
  noremap = true,
  silent = true,
  callback = M.go_run_current_file,
})

return M

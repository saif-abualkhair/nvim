local M = {};
-- Fundamental Vim keybinds
local fundamental_keys = {
  -- "i",  -- Enter Insert mode
  "a",  -- Enter Insert mode after the cursor
  "o",  -- Open a new line below and enter Insert mode
  "O",  -- Open a new line above and enter Insert mode
  "s",  -- Delete character under cursor and enter Insert mode
  "S",  -- Delete entire line and enter Insert mode
  "c",  -- Change (operator, requires a motion)
  "C",  -- Change to the end of the line
  "r",  -- Replace a single character
  "R",  -- Enter Replace mode
  -- "v",  -- Enter Visual mode
  "V",  -- Enter Visual Line mode
  "<C-v>", -- Enter Visual Block mode
  "x",  -- Delete character under cursor
  "X",  -- Delete character before cursor
  -- "d",  -- Delete (operator, requires a motion)
  -- "y",  -- Yank (operator, requires a motion)
  -- "p",  -- Paste after cursor
  "P",  -- Paste before cursor
  -- "u",  -- Undo
  -- "<C-r>", -- Redo
  -- ":",  -- Enter command-line mode
}

-- Motion keys (excluding fundamental_keys)
local motion_keys = {
  -- "h",  -- Move left
  -- "j",  -- Move down
  -- "k",  -- Move up
  -- "l",  -- Move right
  "w",  -- Move to the start of the next word
  "b",  -- Move to the start of the previous word
  "e",  -- Move to the end of the current word
  "0",  -- Move to the beginning of the line
  "$",  -- Move to the end of the line
  "gg", -- Move to the beginning of the file
  "G",  -- Move to the end of the file
  "<C-f>", -- Move forward one page
  "<C-b>", -- Move backward one page
  "f",  -- Move to the next occurrence of a character on the current line
  "F",  -- Move to the previous occurrence of a character on the current line
  "t",  -- Move just before the next occurrence of a character on the current line
  "T",  -- Move just after the previous occurrence of a character on the current line
  -- "/",  -- Search forward
  -- "?",  -- Search backward
  -- "n",  -- Repeat the last search in the same direction
  "N",  -- Repeat the last search in the opposite direction
  -- "iw", -- Inner word (text object)
  "aw", -- A word (text object, including surrounding whitespace)
  -- 'i"', -- Inner quoted text (inside `"`)
  'a"', -- A quoted text (including the quotes)
  -- "i(", -- Inner parentheses (text object)
  "a(", -- A parentheses (including the parentheses)
  -- "i{", -- Inner curly braces (text object)
  "a{", -- A curly braces (including the braces)
  -- "i[", -- Inner square brackets (text object)
  "a[", -- A square brackets (including the brackets)
  "%",  -- Move to the matching parenthesis, bracket, or brace
  "*",  -- Search for the word under the cursor forward
  "#",  -- Search for the word under the cursor backward
}

function M.disable_unwanted_keybinds()
  -- Disable fundamental keys
  for _, key in ipairs(fundamental_keys) do
    vim.keymap.set("n", key, "<Nop>", { noremap = true, silent = true })
    vim.keymap.set("v", key, "<Nop>", { noremap = true, silent = true })
  end

  -- Disable motion keys
  for _, key in ipairs(motion_keys) do
    vim.keymap.set("n", key, "<Nop>", { noremap = true, silent = true })
    vim.keymap.set("v", key, "<Nop>", { noremap = true, silent = true })
  end

end

return M;

require("gitsigns-config")
require("clangd-config")
require("flatten-config")

function toggle_netrw(path)
  local buf_name = vim.api.nvim_buf_get_name(0)
  
  if type(path) == "nil"
    and vim.bo.buftype == ""
    and buf_name ~= ""
  then
    path = vim.fs.dirname(buf_name)
  else
    path = "."
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local tab_wins = vim.api.nvim_tabpage_list_wins(tab)
  for _, win in ipairs(tab_wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
          vim.api.nvim_buf_delete(buf, {})
        return
    end
  end

  if #tab_wins == 1 and buf_name ~= "" then
    vim.api.nvim_open_win(0, false, { split = "right"})
  end

  local win = vim.api.nvim_get_current_win()
  vim.cmd(string.format("edit %s", path))
end

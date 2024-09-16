require("gitsigns-config")
require("clangd-config")
require("flatten-config")

function toggle_newtr(path)
  if type(path) == "nil" then
    local buf = vim.api.nvim_get_current_buf()
    vim.print(vim.fn.getbufinfo(buf))
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local tab_wins = vim.api.nvim_tabpage_list_wins(tab)
  for _, win in ipairs(tab_wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.fn.getbufinfo(buf)[1].variables.automatically_created then
        vim.api.nvim_buf_delete(buf, {})
        return
    end
  end

  vim.api.nvim_open_win(0, false, { split = "right"})
  local win = vim.api.nvim_get_current_win()
  vim.cmd(string.format("edit %s", path))
  
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_buf_set_var(buf, "automatically_created", true)
end

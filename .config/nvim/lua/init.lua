require("gitsigns-config")
require("clangd-config")
require("flatten-config")
require("oil-config")
require("cyberdream-config")

local oil = require("oil")

local function run_shell_command(cmd)
  local output = {}
  local function collect_output(jobid, data)
    output = data
    output[#output] = nil
  end

  local jobid = vim.fn.jobstart(cmd, {
    stdout_buffered=true,
    on_stdout=collect_output,
  })

  local code = vim.fn.jobwait({jobid}, 1000)[1]
  if code < 0 then
    error(("'%s' did not exit properly (code %i)"):format(cmd, code))
  end

  if #output > 1 then
    error((
      "'%s' output must not contain more than 1 line. \
       Actual output: \
       %s"
    ):format(cmd, vim.inspect(output)))
  end

  return (output[1] ~= nil) and output[1] or ""
end

local function get_buffer_directory(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

  if filetype == "netrw" then
    return vim.api.nvim_buf_get_var(buf, "netrw_curdir")
  end

  if filetype == "oil" then
    return oil.get_current_dir(buf)
  end

  if buftype == "" and bufname ~= "" then
    return vim.fn.expand("%:p:h")
  end

  if buftype == "terminal" then
    local jobid = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
    local pid = vim.fn.jobpid(jobid)
    local cmdout = run_shell_command(("pwdx %i"):format(pid))
    local path = cmdout:match("^%d+: (.*)$")
    return (path ~= nil) and path or "."
  end

  return "."
end

local function find_buffer_from_name(bufname)
  local buf = vim.fn.bufnr("^" .. bufname .. "$")
  return buf ~= -1 and buf or nil
end

function browse(relpath)
  if type(relpath) == "nil" then
    relpath = "."
  end

  if type(relpath) ~= "string" then
    error(("'relpath' is a '%s' value, expected 'string'"):format(type(pattern)))
  end

  local current_dir = get_buffer_directory(0)
  local abspath = current_dir .. "/" .. relpath

  vim.cmd(("edit %s"):format(abspath))

  if vim.api.nvim_buf_get_name(0) == "" then
    local browsing_dir = vim.api.nvim_buf_get_var(0, "netrw_curdir")
    local badbuf = vim.fn.bufnr(browsing_dir)
    vim.api.nvim_buf_delete(badbuf, {force = true})
    vim.api.nvim_buf_set_name(0, browsing_dir)
  end
end

function quickfind(pattern, path)
  if type(path) == "nil" then
    path = vim.fn.getcwd()
  end

  return deepfind(pattern, vim.fn.getcwd(), true, false)
end

function quickfindclose(pattern, path)
  if type(path) == "nil" then
    path = vim.fn.getcwd()
  end

  return deepfind(pattern, path, true, true)
end

function deepfindclose(pattern, path)
  return deepfind(pattern, path, false, true)
end

function deepfind(pattern, path, file_only, close_on_failure)
  if type(pattern) == "nil" then
    pattern = vim.fn.getreg("/"):match("^\\<(.*)\\>$")
  end

  if type(path) == "nil" then
    path = "."
  end

  if type(close_on_failure) == "nil" then
    close_on_failure = false
  end

  if type(file_only) == "nil" then
    file_only = false
  end

  if type(pattern) ~= "string" then
    error(("'pattern' is a '%s' value, expected 'string'"):format(type(pattern)))
  end

  if type(path) ~= "string" then
    error(("'path' is a '%s' value, expected 'string'"):format(type(path)))
  end

  if type(file_only) ~= "boolean" then
    error(("'file_only' is a '%s' value, expected 'boolean'"):format(type(file_path)))
  end

  local abspath = (path:match("^/.*$"))
    and path
    or get_buffer_directory(0) .. "/" .. path
  local newbuf = vim.api.nvim_create_buf(false, true)
  local oldbuf = vim.api.nvim_win_get_buf(0)

  vim.api.nvim_buf_set_var(newbuf, "termimal_custom_name", ("Fuzzy search for '%s'"):format(pattern))
  vim.api.nvim_win_set_buf(0, newbuf)

  local function edit_choosen_file(jobid, code, event)
    if code ~= 0 and close_on_failure then
      vim.api.nvim_buf_delete(newbuf, {force=true})
      return
    end

    if code ~= 0 then
      vim.api.nvim_win_set_buf(0, oldbuf)
      vim.api.nvim_buf_delete(newbuf, {force=true})
      return
    end

    local line_count = vim.api.nvim_buf_line_count(newbuf)
    local user_choice = table.concat(vim.api.nvim_buf_get_lines(newbuf, 0, line_count - 1, true))
    local filename, linenumber = user_choice:match("^(.+)@(%d+)$")
    vim.cmd(("edit +%i %s"):format(linenumber, filename))
    vim.api.nvim_buf_delete(newbuf, {force=true})
  end

  vim.fn.termopen(("deepfind %s --path %s %s"):format(pattern, abspath, file_only and "--file-only" or ""), {
    on_exit=edit_choosen_file,
  })
  newbuf = vim.fn.bufnr("%")
  vim.cmd("startinsert")
end

function shell(relpath, close_on_success)
  
  if type(close_on_success) == "nil" then
    close_on_success = true
  end

  if type(close_on_success) ~= "boolean" then
    error(("'file_only' is a '%s' value, expected 'boolean'"):format(type(file_path)))
  end

  local buf = nil
  local function exit_shell(jobid, code, event)
    if code == 0 and close_on_success and buf ~= nil then
      vim.api.nvim_buf_delete(buf, {force=true})
      return
    end
  end

  if type(relpath) == "nil" then
    relpath = "."
  end

  if type(relpath) ~= "string" then
    error(("'relpath' is a '%s' value, expected 'string'"):format(type(pattern)))
  end

  local abspath = get_buffer_directory(0) .. "/" .. relpath
  local newbuf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_var(newbuf, "custom_term_flag", nil)
  vim.api.nvim_win_set_buf(0, newbuf)
  vim.fn.termopen({"fish"}, {
    cwd = abspath,
    on_exit = exit_shell
  })
  buf = vim.api.nvim_win_get_buf(0)
end

function open(path)
  if type(path) ~= "string" then
    error(("'path' is a '%s' value, expected 'string'"):format(type(path)))
  end

  p, row, col = path:gmatch("(/.*):([0-9]+):([0-9]+):")()
  if p then
    path = p
  end

  p, row = path:gmatch("(/.*):([0-9]+)")()
  if p then
    path = p
  end

  if not row then
    row = 0
  end

  if path:match("^[<\"].*[>\"]$") then
    path = path:sub(2, -2)
  end

  local abspath = (path:match("^/.*$"))
    and path
    or get_buffer_directory(0) .. "/" .. path

  vim.cmd.vsplit()
  if vim.fn.filereadable(abspath) == 1 then
    vim.cmd(("edit +%i %s"):format(row, abspath))
  else
    quickfindclose(path)
  end
end

vim.api.nvim_create_autocmd({"VimEnter"}, {
  pattern = "*",
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("tabnew")
      vim.cmd("terminal")
      vim.cmd("tabprevious")
    end
  end,
})

vim.api.nvim_create_autocmd({"TermOpen", "TermLeave"}, {
  pattern = "*",
  callback = function(ev)
    local buf = ev.buf
    local success, jobid = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")

    -- Check if a process is still attached to the terminal
    -- If not, we bail
    if not success then
      return
    end

    local success, pid = pcall(vim.fn.jobpid, jobid)

    -- Same...
    if not success then
      return
    end

    local success, custom_name = pcall(vim.api.nvim_buf_get_var, buf, "termimal_custom_name")
    local term_name = success and custom_name or vim.fn.simplify(get_buffer_directory(0))
    vim.api.nvim_buf_set_name(buf, ("%i|%s"):format(pid, term_name))
  end,
})


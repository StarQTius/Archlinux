function start()
    vim.lsp.start({
        name = "clangd",
        cmd = {"/home/paulin/.config/nvim/lsp/clangd.fish"},
        root_dir = vim.fs.dirname(vim.fs.find({"build/compile_commands.json"}, { upward = true })[1])
    })
end

vim.api.nvim_create_autocmd(
    "FileType",
    {
        pattern = "cpp,hpp",
        callback = start
    }
)

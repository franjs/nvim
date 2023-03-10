return {
	"jose-elias-alvarez/null-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		null_ls.setup({
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr })
						end,
					})
				end
				vim.api.nvim_set_keymap("n", "ff", ":lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })
			end,
			sources = {
				null_ls.builtins.formatting.prettier.with({
					prefer_local = "node_modules/.bin",
				}),
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.code_actions.gitsigns,
			},
		})
	end,
}

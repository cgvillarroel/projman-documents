-- I couldn't get registers to work in vim.cmd
-- This function allows us to do what `<c-r>"` does
_G.DumpContents = function()
		vim.cmd('norm wwyt["_d$')
		vim.cmd("read src/" .. vim.fn.getreg('"'))
		vim.cmd("norm kdd")
	end

vim.fn.delete("output/wiki.adoc")
vim.cmd("e output/wiki.adoc")
vim.cmd("read src/wiki.adoc")
vim.cmd("norm kdd")
vim.cmd("%g/^include::/lua DumpContents()")
vim.cmd("w")

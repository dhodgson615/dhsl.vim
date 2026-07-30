if vim.g.loaded_dhsl then return end

vim.g.loaded_dhsl = 1

require('dhsl').setup()

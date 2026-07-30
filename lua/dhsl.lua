local M = {}

function M.get_git_branch()
    return vim.b.dhsl_git_branch or ''
end

function M.update_branch()
    local dir = vim.fn.expand('%:p:h')

    if vim.fn.empty(dir) == 1 or vim.fn.isdirectory(dir) == 0 then return end

    local bufnr = vim.api.nvim_get_current_buf()
    local branch_output = ''

    vim.fn.jobstart({ 'git', '-C', dir, 'branch', '--show-current' }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                branch_output = vim.trim(table.concat(data, '\n'))
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                local branch = vim.trim(branch_output)
                pcall(vim.api.nvim_buf_set_var, bufnr, 'dhsl_git_branch',
                    #branch > 0 and '  ' .. branch .. ' ' or '')
            else
                pcall(vim.api.nvim_buf_set_var, bufnr, 'dhsl_git_branch', '')
            end
            vim.schedule(function() vim.cmd('redrawstatus') end)
        end,
    })
end

function M.get_ale_status()
    if not vim.g.loaded_ale then return '' end

    local counts = vim.fn['ale#statusline#Count'](vim.fn.bufnr(''))

    if counts.total == 0 then return '' end

    local res = ''

    if counts.error > 0 or counts.style_error > 0 then
        res = res .. ' %#ErrorMsg# E:' .. (counts.error + counts.style_error) .. ' %*'
    end

    if counts.warning > 0 or counts.style_warning > 0 then
        res = res .. ' %#WarningMsg# W:' .. (counts.warning + counts.style_warning) .. ' %*'
    end

    return res
end

function M.get_char_info()
    local col_num = vim.fn.charcol('.')
    local line_str = vim.fn.getline('.')

    if vim.fn.empty(line_str) == 1 or col_num > vim.fn.strchars(line_str) then
        return 'd=0 0x0 000'
    end

    local char_val = vim.fn.char2nr(vim.fn.strcharpart(line_str, col_num - 1, 1))
    return string.format('d=%-2d 0x%-2X 0%-2o', char_val, char_val, char_val)
end

function M.set_statusline()
    if vim.g.dhsl_disabled then return end

    local win_w = vim.fn.winwidth(0)
    local sl = '%* %<'

    sl = sl .. " %{&modified ? '[+] ' : ''}"
    sl = sl .. "%{&ff} > %{strlen(&fenc) ? &fenc : '(none)'}"

    if win_w > 60 then sl = sl .. ' %* %.20{&filetype} %*' end

    sl = sl .. ' %{dhsl#GetGitBranch()}'
    sl = sl .. '%{dhsl#GetAleStatus()}'
    sl = sl .. '%='

    if win_w > 80 then sl = sl .. ' %{dhsl#GetCharInfo()}' end
    if vim.o.ruler then sl = sl .. vim.o.rulerformat end

    vim.wo.statusline = sl
end

function M.setup()
    -- Expose autoload-compatible wrappers so statusline %{} expressions work
    vim.cmd([[
        function! dhsl#GetGitBranch()
            return luaeval('require("dhsl").get_git_branch()')
        endfunction
        function! dhsl#UpdateBranch()
            lua require('dhsl').update_branch()
        endfunction
        function! dhsl#GetAleStatus()
            return luaeval('require("dhsl").get_ale_status()')
        endfunction
        function! dhsl#GetCharInfo()
            return luaeval('require("dhsl").get_char_info()')
        endfunction
        function! dhsl#SetStatusLine()
            lua require('dhsl').set_statusline()
        endfunction
    ]])

    local r_fmt = "%100(%=%*%) Byte %o/%{getfsize(expand(@%))}, Line %l/%L, Col %c%V, Pg %{winheight(0) ? line('.') / winheight(0) + 1 : 0}/%{winheight(0) ? line('$') / winheight(0) + 1 : 0}, %{wordcount().words} Words %5.P %*"
    vim.o.rulerformat = r_fmt

    local augroup = vim.api.nvim_create_augroup('DhslUpdate', { clear = true })

    vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter', 'WinEnter' }, {
        pattern = '*',
        group = augroup,
        callback = function() M.set_statusline() end,
    })

    vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '*:*',
        group = augroup,
        callback = function() M.set_statusline() end,
    })

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufEnter' }, {
        pattern = '*',
        group = augroup,
        callback = function() M.update_branch() end,
    })

    vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'ruler',
        group = augroup,
        callback = function() M.set_statusline() end,
    })

    vim.api.nvim_create_autocmd('User', {
        pattern = 'ALELintPost',
        group = augroup,
        callback = function() M.set_statusline() end,
    })

    vim.api.nvim_create_user_command('DhslToggle', function()
        vim.g.dhsl_disabled = not (vim.g.dhsl_disabled or false)

        if vim.g.dhsl_disabled then
            vim.cmd('set statusline&')
            print('DHSL Disabled')
        else
            M.set_statusline()
            print('DHSL Enabled')
        end
    end, {})

    M.set_statusline()
    M.update_branch()
end

return M

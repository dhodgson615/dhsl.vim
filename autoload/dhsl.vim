vim9script

export def GetGitBranch(): string
    return get(b:, 'dhsl_git_branch', '')
enddef

export def UpdateBranch()
    var branch = trim(system("git -C " .. shellescape(expand('%:p:h')) .. " branch --show-current 2>/dev/null"))
    b:dhsl_git_branch = empty(branch) ? "" : "  " .. branch .. " "
enddef

export def GetCharInfo(): string
    var col_num = charcol('.')
    var line_str = getline('.')

    if empty(line_str) || col_num > strchars(line_str)
        return 'd=0 0x0 000'
    endif

    var char_val = char2nr(strcharpart(line_str, col_num - 1, 1))
    return printf('d=%-2d 0x%-2X 0%-2o', char_val, char_val, char_val)
enddef

export def SetStatusLine()
    if exists('g:dhsl_disabled') && g:dhsl_disabled | return | endif

    var win_w = winwidth(0)
    var sl = "%* %<"

    sl ..= " %{&ff} > %{strlen(&fenc) ? &fenc : '(none)'}"

    if win_w > 60 | sl ..= " %* %.20{&filetype} %*" | endif

    sl ..= "%#Directory#%{dhsl#GetGitBranch()}%*"
    sl ..= "%="

    if win_w > 80 | sl ..= " %{dhsl#GetCharInfo()}" | endif
    if &ruler | sl ..= &rulerformat | endif

    &l:statusline = sl
enddef

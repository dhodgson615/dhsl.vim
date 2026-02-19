vim9script

# Helper function for character info
export def GetCharInfo(): string
    var col_num = charcol('.')
    var line_str = getline('.')
    if empty(line_str) || col_num > strchars(line_str)
        return 'd=0 0x0 000'
    endif
    var char_val = char2nr(strcharpart(line_str, col_num - 1, 1))
    return printf('d=%-2d 0x%-2X 0%-2o', char_val, char_val, char_val)
enddef

# The core statusline builder
export def SetStatusLine()
    if exists('g:dhsl_disabled') && g:dhsl_disabled
        return
    endif

    var sl = "%* %<" 
    sl ..= " %{&ff} > %{strlen(&fenc) ? &fenc : '(none)'}"
    sl ..= " %* %.20{&filetype} %*"
    sl ..= " %{dhsl#GetCharInfo()}"
    sl ..= "%* %="
    
    if &ruler 
        sl ..= &rulerformat 
    endif
    &statusline = sl
enddef

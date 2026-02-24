vim9script

if exists('g:loaded_dhsl') | finish | endif
g:loaded_dhsl = 1

import autoload 'dhsl.vim'

# Default Ruler Format
var r_fmt = "%100(%=%*%)"
r_fmt ..= " Byte %o/%{getfsize(expand(@%))},"
r_fmt ..= " Line %l/%L,"
r_fmt ..= " Col %c%V,"
r_fmt ..= " Pg %{winheight(0) ? line('.') / winheight(0) + 1 : 0}"
r_fmt ..= "/%{winheight(0) ? line('$') / winheight(0) + 1 : 0},"
r_fmt ..= " %{wordcount().words} Words %5.P %*"
&rulerformat = r_fmt

augroup DhslUpdate
    autocmd!
    autocmd VimEnter,BufEnter,WinEnter,ModeChanged *:* dhsl#SetStatusLine()
    autocmd FocusGained,BufReadPost,BufWritePost * dhsl#UpdateBranch()
    autocmd OptionSet ruler dhsl#SetStatusLine()

    if exists('#User#ALEPost')
        autocmd User ALEPost dhsl#SetStatusLine()
    endif
augroup END

command! DhslToggle {
    if !exists('g:dhsl_disabled') | g:dhsl_disabled = false | endif

    g:dhsl_disabled = !g:dhsl_disabled

    if g:dhsl_disabled
        set statusline&
        echo "DHSL Disabled"
    else
        dhsl#SetStatusLine()
        echo "DHSL Enabled"
    endif
}

dhsl#UpdateBranch()
dhsl#SetStatusLine()

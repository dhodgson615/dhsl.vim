vim9script

if exists('g:loaded_dhsl') | finish | endif

g:loaded_dhsl = 1

import autoload 'dhsl.vim'

var r_fmt = "%100(%=%*%) Byte %o/%{getfsize(expand(@%))}, Line %l/%L, Col %c%V, Pg %{winheight(0) ? line('.') / winheight(0) + 1 : 0}/%{winheight(0) ? line('$') / winheight(0) + 1 : 0}, %{wordcount().words} Words %5.P %*"
&rulerformat = r_fmt

augroup DhslUpdate
    autocmd!
    autocmd VimEnter,BufEnter,WinEnter,ModeChanged *:* dhsl#SetStatusLine()
    autocmd BufReadPost,BufWritePost,BufEnter * dhsl#UpdateBranch()
    autocmd OptionSet ruler dhsl#SetStatusLine()
    autocmd User ALELintPost dhsl#SetStatusLine()
augroup END

command! DhslToggle {
    g:dhsl_disabled = !get(g:, 'dhsl_disabled', false)

    if g:dhsl_disabled
        set statusline&
        echo "DHSL Disabled"
    else
        dhsl#SetStatusLine()
        echo "DHSL Enabled"
    endif
}

dhsl#SetStatusLine()
dhsl#UpdateBranch()

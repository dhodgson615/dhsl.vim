vim9script

if exists('g:loaded_dhsl')
    finish
endif
g:loaded_dhsl = 1

# Default Ruler Format
var r_fmt = "%100(%=%*%)"
r_fmt ..= " Byte %o/%{getfsize(expand(@%))},"
r_fmt ..= " Line %l/%L,"
r_fmt ..= " Col %c%V,"
r_fmt ..= " Pg %{winheight(0) ? line('.') / winheight(0) + 1 : 0}"
r_fmt ..= "/%{winheight(0) ? line('$') / winheight(0) + 1 : 0},"
r_fmt ..= " %{wordcount().words} Words %5.P %*"

&rulerformat = r_fmt

# Initialize the bar
import autoload 'dhsl.vim'
dhsl.SetStatusLine()

# Update logic
augroup DhslUpdate
    autocmd!
    autocmd OptionSet ruler dhsl.SetStatusLine()
    # Ensure it stays active even if other plugins try to overwrite it on startup
    autocmd VimEnter * dhsl.SetStatusLine()
augroup END

# Command to toggle the bar manually
command! DhslToggle {
    if !exists('g:dhsl_disabled') | g:dhsl_disabled = false | endif
    g:dhsl_disabled = !g:dhsl_disabled
    if g:dhsl_disabled
        set statusline&
        echo "DHSL Disabled"
    else
        dhsl.SetStatusLine()
        echo "DHSL Enabled"
    endif
}

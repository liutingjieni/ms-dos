" Vim filetype plugin file
" Language:         X resources files like ~/.Xdefaults (xrdb)
" Maintainer:       Nikolai Weibull <now@bitwi.se>
" Latest Revision:  2006-04-19

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:undo_ftplugin = "setl com< cms< inc< fo<"

setlocal comments=s1:/*,mb:*,ex:*/,:! commentstring& inc&
setlocal formatoptions-=t formatoptions+=croql

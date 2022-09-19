" Title:       Shakyo.vim
" Description: A plugin to help you memorise texts exactly character by
"              character.
" Last Change: 19 September 2022
" Maintainer:  NI57721 <https://github.com/NI57721>

if exists("g:loaded_example-plugin")
"  finish
endif
let g:loaded_shakyo = 1

command! -nargs=0 ShakyoRun call shakyo#Run()
command! -nargs=0 ShakyoClue call shakyo#Clue()


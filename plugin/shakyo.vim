" Title:       Shakyo.vim
" Description: A plugin to help you memorise texts exactly character by
"              character.
" Last Change: 23 September 2022
" Maintainer:  NI57721 <https://github.com/NI57721>

if exists("g:loaded_example-plugin")
  finish
endif
let g:loaded_shakyo = 1

nnoremap <Plug>(shakyo-run)        <Cmd>call shakyo#run()<CR>
nnoremap <Plug>(shakyo-quit)       <Cmd>call shakyo#quit()<CR>
nnoremap <Plug>(shakyo-clue)       <Cmd>call shakyo#clue()<CR>
nnoremap <Plug>(shakyo-force-quit) <Cmd>call shakyo#force-quit()<CR>


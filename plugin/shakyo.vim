if exists("g:loaded_example-plugin")
  finish
endif
let g:loaded_shakyo = v:true

nnoremap <Plug>(shakyo-run)        <Cmd>call shakyo#run()<CR>
nnoremap <Plug>(shakyo-quit)       <Cmd>call shakyo#quit()<CR>
nnoremap <Plug>(shakyo-clue)       <Cmd>call shakyo#clue()<CR>
nnoremap <Plug>(shakyo-force-quit) <Cmd>call shakyo#force-quit()<CR>


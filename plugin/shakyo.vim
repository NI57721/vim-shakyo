if exists('g:loaded_shakyo') && g:loaded_shakyo
  finish
endif
let g:loaded_shakyo = v:true

nnoremap <Plug>(shakyo-run)  <Cmd>call shakyo#run()<CR>
nnoremap <Plug>(shakyo-quit) <Cmd>call shakyo#quit()<CR>
nnoremap <Plug>(shakyo-clue) <Cmd>set operatorfunc=shakyo#clue \| execute 'normal! ' .. v:count1 .. 'g@l'<CR>


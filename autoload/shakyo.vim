
let s:shakyo_mode_prefix = '[shakyo]'
let g:shakyo_done = v:false

" Hide the current buffer, open its partial copy, and then start the shakyo
" mode.
function! shakyo#run() abort
  if g:shakyo_done
    echohl ErrorMsg
    echo "Cannot enter shakyo mode, because you are already in shakyo mode.\n" .
      \  "Call Quit() once, if you want to continue."
    echohl None
    return
  end
  let s:origin_bufnr = bufnr('%')
  let s:origin_syntax = exists('b:current_syntax') ? b:current_syntax : ''
  let s:origin_bufname = bufname()
  let s:origin_line_count = len(getbufline(s:origin_bufnr, 1, '$'))

  call s:openDuplicatedBuffer()
  let g:shakyo_done = v:true
  echohl ModeMsg
  echom 'In SHAKYO mode'
  echohl None
  augroup shakyo
    autocmd! TextChangedI,TextChangedP,CursorMoved,CursorMovedI *
    \   if s:winid ==# win_getid()
    \ |   call s:highlightDifference()
    \ | endif
  augroup END
endfunction

" Display the first of characters in the current line which are different
" from the example one.
function! shakyo#clue() abort
  let l:current_line_data = s:getCurrentLineData()
  if l:current_line_data.line_no > s:origin_line_count
    return
  endif
  let l:differentCharIndex = s:getDifferentCharIndex(
  \   l:current_line_data.current_line,
  \   l:current_line_data.origin_line
  \ )
  if l:differentCharIndex == -1
    return
  endif
  let l:clueCharacter = nr2char(
  \   strgetchar(
  \     l:current_line_data.origin_line,
  \     l:differentCharIndex
  \   )
  \ )
  if l:clueCharacter ==# "\xff"
    let l:clueCharacter = "\x0a"
  endif
  call s:insertCharacer(l:differentCharIndex, l:clueCharacter)
endfunction

" Close shakyo mode window and its buffer, and then open and focus on the
" example buffer instead.
function! shakyo#quit() abort
  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout!' s:bufnr
  execute 'buffer' s:origin_bufnr
  let g:shakyo_done = v:false
endfunction

function! shakyo#force-quit()
  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout!' s:bufnr
  execute 'buffer' s:origin_bufnr
  let g:shakyo_done = v:false
endfunction

" Create and open a new buffer which has the copied texts of the current
" buffer from the first line to the previous line of the current line.
" Hide the current buffer until calling Quit().
function! s:openDuplicatedBuffer() abort
  let l:view = winsaveview()
  let l:filetype = &filetype
  let l:line_no = line('.')
  if line_no > 1
    silent execute '1,' . (line_no - 1) . '%y'
  endif

  silent execute 'tabnew' s:shakyo_mode_prefix . s:origin_bufname
  tabprevious
  hide
  let s:bufnr = bufnr('%')
  let s:winid = win_getid()
  if l:filetype !=# ''
    execute  'setfiletype' l:filetype
  endif
  if line_no > 1
    silent 0put
  endif
  call winrestview(l:view)
endfunction

" Highlight the difference between the current line and the corresponding
" line of the origin, if any.
function! s:highlightDifference() abort
  let l:current_line_data = s:getCurrentLineData()
  if l:current_line_data.line_no > s:origin_line_count
    return
  endif

  let l:differentCharIndex = s:getDifferentCharIndex(
  \   l:current_line_data.current_line,
  \   l:current_line_data.origin_line
  \ )
  if l:differentCharIndex == -1
    match TODO /\%.l$/
    return
  endif
  execute 'match ErrorMsg /\%.l^.\{' . l:differentCharIndex . '}\zs.*/'
endfunction

function! s:insertCharacer(index, char) abort
  if a:index == 0
    let l:insert = 'i'
  elseif a:index == 1
    let l:insert = 'a'
  else
    let l:insert = (a:index - 1) . 'la'
  endif
  execute 'normal! 0' . l:insert . a:char
endfunction

function! s:getCurrentLineData() abort
  let l:data = {}
  let l:data.line_no = line('.')
  let l:data.current_line = getline(l:data.line_no)
  let l:data.origin_line = join(getbufline(s:origin_bufnr, l:data.line_no))
  return l:data
endfunction

" Compare two lines from the first character to the end. Then return the
" lowest index where the two lines have different characters. The index
" corresponds with the value charcol().
" If the two lines are exactly the same, then return -1.
function! s:getDifferentCharIndex(line1, line2) abort
  for l:i in range(0, strchars(a:line1) - 1)
    if strgetchar(a:line1, l:i) ==# strgetchar(a:line2, l:i)
      continue
    endif
    return l:i
  endfor
  if strchars(a:line1) < strchars(a:line2)
    return strchars(a:line1)
  endif
  return -1
endfunction


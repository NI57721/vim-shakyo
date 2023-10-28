
let s:shakyo_mode_prefix = '[shakyo]'
let g:shakyo_running = v:false

" Hide the current buffer, open its partial copy, and then start the shakyo
" mode.
function! shakyo#run() abort
  if g:shakyo_running
    echoerr "Cannot enter shakyo mode, because you are already in shakyo mode.\n" ..
      \   "Call Quit() once, if you want to continue."
    return
  end
  let s:origin_bufnr = bufnr('%')
  let s:origin_syntax = exists('b:current_syntax') ? b:current_syntax : ''
  let s:origin_bufname = bufname()
  let s:origin_line_count = len(getbufline(s:origin_bufnr, 1, '$'))

  call s:openDuplicatedBuffer()
  let g:shakyo_running = v:true
  let b:keymap_name="Shakyo"
  augroup shakyo
    autocmd! TextChangedI,TextChangedP,CursorMoved,CursorMovedI *
      \   if has('s:winid') && s:winid ==# win_getid() |
      \     call s:highlightDifference() |
      \   endif
  augroup END
endfunction

" Display the first of characters in the current line which are different
" from the example one.
function! shakyo#clue() abort
  let current_line_data = s:getCurrentLineData()
  if current_line_data.line_no > s:origin_line_count
    return
  endif
  let differentCharIndex = s:getDifferentCharIndex(
  \   current_line_data.current_line,
  \   current_line_data.origin_line
  \ )
  if differentCharIndex == -1
    return
  endif
  let clueCharacter = nr2char(
  \   strgetchar(
  \     current_line_data.origin_line,
  \     differentCharIndex
  \   )
  \ )
  if clueCharacter ==# "\xff"
    let clueCharacter = "\x0a"
  endif
  call s:insertCharacer(differentCharIndex, clueCharacter)
endfunction

" Close shakyo mode window and its buffer, and then open and focus on the
" example buffer instead.
function! shakyo#quit() abort
  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout!' s:bufnr
  execute 'buffer' s:origin_bufnr
  let g:shakyo_running = v:false
endfunction

function! shakyo#force_quit()
  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout!' s:bufnr
  execute 'buffer' s:origin_bufnr
  let g:shakyo_running = v:false
endfunction

" Create and open a new buffer which has the copied texts of the current
" buffer from the first line to the previous line of the current line.
" Hide the current buffer until calling Quit().
function! s:openDuplicatedBuffer() abort
  let view = winsaveview()
  let filetype = &filetype
  let line_no = line('.')
  if line_no > 1
    silent execute '1,' .. (line_no - 1) .. '%y'
  endif

  silent execute 'tabnew' s:shakyo_mode_prefix .. s:origin_bufname
  tabprevious
  hide
  let s:bufnr = bufnr('%')
  let s:winid = win_getid()
  if filetype !=# ''
    execute  'setfiletype' filetype
  endif
  if line_no > 1
    silent 0put
  endif
  call winrestview(view)
endfunction

" Highlight the difference between the current line and the corresponding
" line of the origin, if any.
function! s:highlightDifference() abort
  let current_line_data = s:getCurrentLineData()
  if current_line_data.line_no > s:origin_line_count
    return
  endif

  let differentCharIndex = s:getDifferentCharIndex(
  \   current_line_data.current_line,
  \   current_line_data.origin_line
  \ )
  if differentCharIndex == -1
    match TODO /\%.l$/
    return
  endif
  execute 'match ErrorMsg /\%.l^.\{' .. differentCharIndex .. '}\zs.*/'
endfunction

function! s:insertCharacer(index, char) abort
  if a:index == 0
    let insert = 'i'
  elseif a:index == 1
    let insert = 'a'
  else
    let insert = (a:index - 1) .. 'la'
  endif
  execute 'normal! 0' .. insert .. a:char
endfunction

function! s:getCurrentLineData() abort
  let data = {}
  let data.line_no = line('.')
  let data.current_line = getline(data.line_no)
  let data.origin_line = join(getbufline(s:origin_bufnr, data.line_no))
  return data
endfunction

" Compare two lines from the first character to the end. Then return the
" lowest index where the two lines have different characters. The index
" corresponds with the value charcol().
" If the two lines are exactly the same, then return -1.
function! s:getDifferentCharIndex(line1, line2) abort
  for i in range(0, strchars(a:line1) - 1)
    if strgetchar(a:line1, i) ==# strgetchar(a:line2, i)
      continue
    endif
    return i
  endfor
  if strchars(a:line1) < strchars(a:line2)
    return strchars(a:line1)
  endif
  return -1
endfunction


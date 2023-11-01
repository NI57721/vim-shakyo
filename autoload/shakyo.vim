let s:shakyo_mode_prefix = '[Shakyo]'
let s:shakyo_running = v:false

" Hide the current buffer, open its partial copy, and then start the Shakyo
" mode.
function! shakyo#run() abort
  if s:shakyo_running
    echoerr "Shakyo mode is already running. You need to quit it before running another."
    return
  end
  let s:origin_bufnr = bufnr('%')
  let s:origin_syntax = exists('b:current_syntax') ? b:current_syntax : ''
  let s:origin_bufname = bufname()
  let s:origin_line_count = len(getbufline(s:origin_bufnr, 1, '$'))

  call s:duplicateBuffer(s:origin_buffer.name)
  let g:shakyo_running = v:true
  let b:keymap_name="Shakyo"
  augroup Shakyo
    autocmd! TextChangedI,TextChangedP,CursorMoved,CursorMovedI *
      \   if exists('s:winid') && s:winid ==# win_getid() |
      \     execute s:getHighlightCommand() |
      \   endif
  augroup END
endfunction

" Display the first of characters in the current line which are different
" from the origin.
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

" Close Shakyo mode window and its buffer, and then open and focus on the
" origin buffer.
function! shakyo#quit() abort
  if !s:shakyo_running
    echoerr "Shakyo mode is not running."
    return
  end

  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout! ' .. s:bufnr
  execute 'buffer ' .. s:origin_buffer.nr
  let s:shakyo_running = v:false
endfunction

function! shakyo#force_to_quit()
  call win_gotoid(s:winid)
  tabnew
  execute 'bwipeout! ' .. s:bufnr
  execute 'buffer ' .. s:origin_buffer.nr
  let s:shakyo_running = v:false
endfunction

" Create and open a new buffer which has the copied texts of the current
" buffer from the first line to the previous line of the current line.
" Hide the current buffer until calling Quit().
function! s:duplicateBuffer(name) abort
  let view = winsaveview()
  let filetype = &filetype
  let whole_text = getline(1, line('.') - 1)

  silent execute 'tabnew ' .. s:shakyo_mode_prefix .. a:name
  let s:bufnr = bufnr('%')
  let s:winid = win_getid()
  tabprevious
  hide

  if filetype !=# ''
    execute  'setfiletype ' .. filetype
  endif
  call append(1, whole_text)
  normal! ggddGo

  call winrestview(view)
endfunction

function! s:getHighlightCommand() abort
  let current_line = s:getLineData('.')
  echom('c.no: ' .. current_line.no .. ', o.cnt: ' .. s:origin_buffer.line_count)
  if current_line.no > s:origin_buffer.line_count
    return ''
  endif

  let differentCharIndex = s:getDifferentCharIndex(
  \   current_line.body,
  \   current_line.origin
  \ )
  if differentCharIndex == -1
    return 'match TODO /\%.l$/'
  else
    return 'match ErrorMsg /\%.l^.\{' .. differentCharIndex .. '}\zs.*/'
  endif
endfunction

function! s:insertString(index, str) abort
  if a:index == 0
    let insert = 'i'
  elseif a:index == 1
    let insert = 'a'
  else
    let insert = (a:index - 1) .. 'la'
  endif
  execute 'normal! 0' .. insert .. a:str
endfunction

function! s:getLineData(expr) abort
  let data = {}
  let data.no = line(a:expr)
  let data.body = getline(data.no)
  let data.origin = getbufline(s:origin_buffer.nr, data.no) ->join()
  return data
endfunction

function! s:getBufferData(buf) abort
  let data = {}
  let data.nr = bufnr(a:buf)
  let data.name = bufname()
  let data.line_count = getbufline(data.nr, 1, '$') ->len()
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


let s:shakyo_mode_prefix = '[Shakyo]'
let s:shakyo_running = v:false

" The origin buffer data to memorize
let s:origin_buffer = ''
" The ID of the window in Shakyo mode
let s:winid = ''
" The number of the buffer in Shakyo mode
let s:bufnr = ''

" Hide the current buffer, open its partial copy, and then start the Shakyo
" mode.
function! shakyo#run() abort
  if s:shakyo_running
    throw 'Shakyo mode is already running. You need to quit it before running another.'
  end
  let s:origin_buffer = s:getBufferData('%')

  call s:duplicateBuffer(s:origin_buffer.name)
  let s:bufnr = bufnr('%')
  let s:winid = win_getid()
  let s:shakyo_running = v:true
  augroup Shakyo
    autocmd! TextChangedI,TextChangedP,CursorMoved,CursorMovedI *
      \   if exists('s:winid') && s:winid ==# win_getid() |
      \     execute s:getHighlightCommand() |
      \   endif
  augroup END
endfunction

" Display the first of characters in the current line which are different
" from the origin.
" TODO: Take a number as an argument, and then return the strings whose
" length is the number instead of a character.
function! shakyo#clue() abort
  if !s:shakyo_running
    throw 'Shakyo mode is not running yet.'
  end

  let current_line = s:getLineData('.')
  if current_line.no > s:origin_buffer.line_count
    return
  endif
  let differentCharIndex = s:getDifferentCharIndex(
  \   current_line.body,
  \   current_line.origin,
  \ )
  if differentCharIndex == -1
    return
  endif
  let clueCharacter = strgetchar(current_line.origin, differentCharIndex)
    \   ->nr2char()
  if clueCharacter ==# "\xff"
    let clueCharacter = "\x0a"
  endif
  call s:insertString(differentCharIndex, clueCharacter)
endfunction

" Close Shakyo mode window and its buffer, and then open and focus on the
" origin buffer.
function! shakyo#quit() abort
  if !s:shakyo_running
    throw 'Shakyo mode is not running yet.'
  end

  call win_gotoid(s:winid)
  execute 'buffer! ' .. s:origin_buffer.nr
  execute 'bwipeout! ' .. s:bufnr

  let s:origin_buffer = ''
  let s:origin_winid = ''
  let s:winid = ''
  let s:bufnr = ''
  let s:shakyo_running = v:false
endfunction

" Hide the current buffer and create a new buffer, in which the texts of the
" current buffer are copied from the first line to the line just before the
" current line.
" TODO: take an argument. s:duplicateBufferUpTo(line)
function! s:duplicateBuffer(name) abort
  let view = winsaveview()
  let filetype = &filetype
  let whole_text = getline(1, line('.') - 1)

  silent execute 'hide edit ' .. s:shakyo_mode_prefix .. a:name
  if filetype != ''
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


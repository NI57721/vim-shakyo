
" let g:shakyo_ignore
" let s:origin_bufnr
" let s:origin_syntax

function! Run() abort
" function! shakyo#Run() abort
  let s:origin_bufnr = bufnr('%')
  let s:origin_syntax = b:current_syntax

  call s:openDuplicatedBuffer()
  augroup shakyo
    autocmd! TextChanged,TextChangedI,TextChangedP,CursorMoved *
      \ call s:highlightDifference()
  augroup END
endfunction

function! Quit() abort
  autocmd! shakyo CursorMoved *
  tabnew
  execute 'bwipeout!' s:bufnr
  execute 'buffer' s:origin_bufnr
endfunction

" Create and open a new buffer which has the copied texts of the current
" buffer from the first line to the previous line of the current line.
function! s:openDuplicatedBuffer() abort
  let l:view = winsaveview()
  let l:filetype = &filetype
  let l:line_no = line('.')
  execute '1,' . (line_no - 1) . '%y'

  tabnew
  tabprevious
  hide
  let s:bufnr = bufnr('%')
  execute  'setfiletype' l:filetype
  0put
  call winrestview(l:view)
endfunction

" Highlight the difference between the current line and the corresponding
" line of the example, if any.
function! s:highlightDifference() abort
  let l:line_no = line('.')
  let l:current_line = getline(l:line_no)
  let l:example_line = getbufline(s:origin_bufnr, l:line_no)[0]
  let l:differentCharIndex = s:getDifferentCharIndex(
    \l:current_line,
    \l:example_line
  \)

  if l:differentCharIndex == -1
    match TODO /\%.l$/
    return
  endif
  execute 'match ErrorMsg /\%.l^.\{' . l:differentCharIndex . '}\zs.*/'
endfunction

" iinnasdfiojn
" iiihiraganakl
" hogenfugan
" aiueoあいうえお
" かっきくえこ

" Compare two lines from the first character to the end. Then return the
" lowest index where the two lines have different characters. If the two
" lines are exactly the same, then return -1.
function! s:getDifferentCharIndex(line1, line2) abort
  for l:i in range(0, len(a:line1) - 1)
    if a:line1[l:i] ==# a:line2[l:i]
      continue
    endif
    return l:i
  endfor
  if len(a:line1) < len(a:line2)
    return len(a:line1)
  endif
  return -1
endfunction

" Clue()
" Quit()
" Run(line_no, file)

call Run()

" TODO ignore some characters
" TODO turn off in different tabs



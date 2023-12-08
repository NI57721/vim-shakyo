let s:suite  = themis#suite('Test for vim-shakyo')
let s:assert = themis#helper('assert')
let s:scope  = themis#helper('scope')
let s:funcs  = s:scope.funcs('autoload/shakyo.vim')
let s:vars   = s:scope.vars('autoload/shakyo.vim')
call themis#helper('command')

function s:createBufferWith(name, lines) abort
  execute 'new ' .. a:name
  call append(0, a:lines)
  $delete
  call setcursorcharpos(1, 1)
endfunction

function s:cleanBuffer() abort
  let in_first_buffer = v:false
  for bufnr in range(1, bufnr('$'))
    if buflisted(bufnr)
      execute bufnr .. '+,$bwipeout!'
      break
    endif
  endfor
endfunction

function s:logAllBuffers(prefix = '') abort
  if !empty(a:prefix)
    call themis#log(a:prefix)
  endif

  for bufnr in range(1, bufnr('$'))
    if !buflisted(bufnr)
      continue
    endif

    call themis#log(bufnr .. ': ' .. bufname(bufnr))
    call themis#log(getbufline(bufnr, 1, '$'))
  endfor
endfunction

function s:suite.shakyoHighlightConfig() abort
  call s:cleanBuffer()
  let config = s:vars.config

  let want = #{completed: 'WildMenu', wrong: 'ErrorMsg'}
  let get = config.highlight
  call s:assert.equals(get, want)

  call shakyo#config(#{highlight: #{completed: 'Foo'}})
  let want = #{completed: 'Foo', wrong: 'ErrorMsg'}
  let get = config.highlight
  call s:assert.equals(get, want)

  call shakyo#config(#{highlight: #{wrong: 'Bar'}})
  let want = #{completed: 'Foo', wrong: 'Bar'}
  let get = config.highlight
  call s:assert.equals(get, want)

  call shakyo#config(#{highlight: #{completed: 'WildMenu', wrong: 'ErrorMsg'}})
endfunction

function s:suite.shakyoClueDotRepeat() abort
  call s:cleanBuffer()
  let lines = ['sample text', '1', '0123456789', '3', '4', '5', '6', '7', '8', '9']
  call s:createBufferWith('foo', lines)
  call setcursorcharpos(3, 1)

  try
    call shakyo#run()
    nnoremap <buffer> <Space>c <Plug>(shakyo-clue)

    normal 1 c
    normal! .
    let want = ['sample text', '1', '01']
    let get = getbufline('%', 1, '$')
    call s:assert.equals(get, want)

    normal! 3.
    let want = ['sample text', '1', '01234']
    let get = getbufline('%', 1, '$')
    call s:assert.equals(get, want)

    normal 4 c
    let want = ['sample text', '1', '012345678']
    let get = getbufline('%', 1, '$')
    call s:assert.equals(get, want)
  finally
    call shakyo#quit()
  endtry
endfunction

function s:suite.useShakyo() abort
  call s:cleanBuffer()
  let bufname_prefix = '[Test]'
  let lines = ['sample text', '1', '0123456789', '3', '4', '5', '6', '7', '8', '9']
  let bufname = 'bufname'
  let s:vars.shakyo_mode_prefix = bufname_prefix
  call s:createBufferWith(bufname, lines)
  call setcursorcharpos(3, 1)

  Throws /^Shakyo mode is not running yet\.$/ shakyo#_clue()
  Throws /^Shakyo mode is not running yet\.$/ shakyo#quit()

  try
    call shakyo#run()
    let want = bufname_prefix .. bufname
    let get = bufname('%')
    call s:assert.equals(get, want)

    call shakyo#_clue()
    let want = ['sample text', '1', '0']
    let get = getbufline('%', 1, '$')
    call s:assert.equals(get, want)

    call shakyo#_clue(7)
    let want = ['sample text', '1', '01234567']
    let get = getbufline('%', 1, '$')
    call s:assert.equals(get, want)
  finally
    call shakyo#quit()
  endtry

    let want = bufname
    let get = bufname('%')
    call s:assert.equals(get, want)
endfunction

function s:suite.duplicateBuffer() abort
  call s:cleanBuffer()
  let lines = ['sample text', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  let bufname_prefix = '[Test]'
  let current_line_no = 7
  let bufname = 'foobar'
  call s:createBufferWith(bufname, lines)
  call setcursorcharpos(current_line_no, 1)

  let s:vars.shakyo_mode_prefix = bufname_prefix
  call s:funcs.duplicateBuffer(bufname)
  let bufnr = bufnr('%')

  let want = bufname_prefix .. 'foobar'
  let get = bufname(s:vars.bufnr)
  call s:assert.equals(get, want)

  let want = add(lines[:current_line_no - 2], '')
  let get = getline(1, '$')
  call s:assert.equals(get, want)
endfunction

function s:suite.applyHighlight() abort
  call s:cleanBuffer()
  let match_ids = s:vars.match_ids
  call s:createBufferWith('origin bufname', ['sample text', 'the second line'])
  let s:vars.origin_buffer = s:funcs.getBufferData('%')
  call s:createBufferWith('shakyo bufname', ['sample text', 'the 2nd line', '', ''])

  let want = []
  let get = keys(match_ids)
  call s:assert.equals(get, want)

  call setcursorcharpos(1, 1)
  call s:funcs.applyHighlight()
  let want = ['1']
  let get = keys(match_ids)
  call s:assert.equals(get, want)

  call s:funcs.applyHighlight()
  let want = ['1']
  let get = keys(match_ids)
  call s:assert.equals(get, want)

  call setcursorcharpos(2, 1)
  call s:funcs.applyHighlight()
  let want = ['1', '2']
  let get = keys(match_ids)
  call s:assert.equals(get, want)


  call setcursorcharpos(10, 1)
  call s:funcs.applyHighlight()
  let want = ['1', '2']
  let get = keys(match_ids)
  call s:assert.equals(get, want)
endfunction

function s:suite.getHighlightPattern() abort
  call s:cleanBuffer()
  call s:createBufferWith('origin bufname', ['sample text', 'the second line'])
  let s:vars.origin_buffer = s:funcs.getBufferData('%')
  call s:createBufferWith('shakyo bufname', ['sample text', 'the 2nd line', ''])

  call setcursorcharpos(1, 1)
  let want = ['WildMenu', '\%.l$']
  let get = s:funcs.getHighlightPattern()
  call s:assert.equals(get, want)

  call setcursorcharpos(2, 1)
  let want = ['ErrorMsg', '\v%.l^.{4}\zs.*']
  let get = s:funcs.getHighlightPattern()
  call s:assert.equals(get, want)

  call setcursorcharpos(3, 1)
  let want = ['', '']
  let get = s:funcs.getHighlightPattern()
  call s:assert.equals(get, want)
endfunction

function s:suite.insertString() abort
  call s:cleanBuffer()
  call s:createBufferWith('', ['sample text', 'the second line'])

  call s:funcs.insertString(0, 'foo')
  call setcursorcharpos(1, 1)
  let target = '.'
  let want = 'foosample text'
  let get = getline('.')
  call s:assert.equals(get, want)

  call s:funcs.insertString(1, 'bar')
  call setcursorcharpos(1, 1)
  let target = '.'
  let want = 'fbaroosample text'
  let get = getline('.')
  call s:assert.equals(get, want)

  call s:funcs.insertString(13, 'baz')
  call setcursorcharpos(1, 1)
  let target = '.'
  let want = 'fbaroosample baztext'
  let get = getline('.')
  call s:assert.equals(get, want)
endfunction

function s:suite.getLineData() abort
  call s:cleanBuffer()
  call s:createBufferWith('origin bufname', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
  let s:vars.origin_buffer = s:funcs.getBufferData('%')
  call s:createBufferWith('shakyo bufname', [0, 1, 2, 3, 4, 5, 6, 777, 8, 9])
  call setcursorcharpos(8, 1)

  let target = '.'
  let want = #{
    \   no: 8,
    \   body: '777',
    \   origin: getbufline(s:vars.origin_buffer.nr, 8) ->join(),
    \ }
  let get = s:funcs.getLineData(target)
  call s:assert.equals(get, want)
endfunction

function s:suite.getBufferData() abort
  call s:cleanBuffer()
  call s:createBufferWith('sample buffer', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

  let target = '%'
  let want = #{
   "\   nr: <any number>,
    \   name: 'sample buffer',
    \   line_count: 10,
    \ }
  let get = s:funcs.getBufferData(target)
  call s:assert.equals(get.name, want.name)
  call s:assert.equals(get.line_count, want.line_count)
endfunction

function s:suite.getDifferentCharIndex() abort
  call s:cleanBuffer()

  let target = [
    \   '',
    \   '',
    \ ]
  let want = -1
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)

  let target = [
    \   '',
    \   'foo',
    \ ]
  let want = 0
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)

  let target = [
    \   'foo',
    \   '',
    \ ]
  let want = 0
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)

  let target = [
    \   'foobarbaz',
    \   'foobazbar',
    \ ]
  let want = 5
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)

  let target = [
    \   'foobazbar',
    \   'foobarbaz',
    \ ]
  let want = 5
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)

  let target = [
    \   'foo１２３４５６',
    \   'foo１２３456',
    \ ]
  let want = 6
  let get = s:funcs.getDifferentCharIndex(target[0], target[1])
  call s:assert.equals(get, want)
endfunction


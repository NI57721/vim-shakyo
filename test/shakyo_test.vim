let s:suite  = themis#suite('Test for vim-shakyo')
let s:assert = themis#helper('assert')
let s:scope  = themis#helper('scope')
1
2
let s:funcs  = s:scope.funcs('autoload/shakyo.vim')
let s:vars   = s:scope.vars('autoload/shakyo.vim')

function s:createBufferWith(name, lines) abort
  execute 'new ' .. a:name
  call append(0, a:lines)
  $delete
  normal! 1G
endfunction

function s:cleanBuffer() abort
  1buffer!
  2,$bwipeout!
endfunction

function s:suite.duplicateBuffer() abort
  let lines = ['sample text', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  let bufname_prefix = '[Text]'
  let current_line_no = 7
  let bufname = 'foobar'
  call s:createBufferWith(bufname, lines)
  execute 'normal! ' .. current_line_no .. 'G'

  let s:vars.shakyo_mode_prefix = bufname_prefix
  call s:funcs.duplicateBuffer(bufname)
  let bufnr = bufnr('%')

  let want = bufname_prefix .. 'foobar'
  let get = bufname(s:vars.bufnr)
  call s:assert.equals(get, want)

  let want = add(lines[:current_line_no - 2], '')
  let get = getline(1, '$')
  call s:assert.equals(get, want)

  call s:cleanBuffer()
endfunction

function s:suite.getHighlightCommand() abort
  call s:createBufferWith('origin bufname', ['sample text', 'the second line'])
  let s:vars.origin_buffer = s:funcs.getBufferData('%')
  call s:createBufferWith('shakyo bufname', ['sample text', 'the 2nd line', ''])

  normal! 1G
  let want = 'match TODO /\%.l$/'
  let get = s:funcs.getHighlightCommand()
  call s:assert.equals(get, want)

  normal! 2G
  let want = 'match ErrorMsg /\%.l^.\{4}\zs.*/'
  let get = s:funcs.getHighlightCommand()
  call s:assert.equals(get, want)

  normal! 3G
  let want = ''
  let get = s:funcs.getHighlightCommand()
  call s:assert.equals(get, want)

  call s:cleanBuffer()
endfunction

function s:suite.insertString() abort
  call s:createBufferWith('', ['sample text', 'the second line'])

  call s:funcs.insertString(0, 'foo')
  normal! 1G
  let target = '.'
  let want = 'foosample text'
  let get = getline('.')
  call s:assert.equals(get, want)

  call s:funcs.insertString(1, 'bar')
  normal! 1G
  let target = '.'
  let want = 'fbaroosample text'
  let get = getline('.')
  call s:assert.equals(get, want)

  call s:funcs.insertString(13, 'baz')
  normal! 1G
  let target = '.'
  let want = 'fbaroosample baztext'
  let get = getline('.')
  call s:assert.equals(get, want)

  call s:cleanBuffer()
endfunction

function s:suite.getLineData() abort
  call s:createBufferWith('origin bufname', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
  let s:vars.origin_buffer = s:funcs.getBufferData('%')
  call s:createBufferWith('shakyo bufname', [0, 1, 2, 3, 4, 5, 6, 777, 8, 9])
  normal! 8G

  let target = '.'
  let want = #{
    \   no: 8,
    \   body: '777',
    \   origin: getbufline(s:vars.origin_buffer.nr, 8) ->join(),
    \ }
  let get = s:funcs.getLineData(target)
  call s:assert.equals(get, want)

  call s:cleanBuffer()
endfunction

function s:suite.getBufferData() abort
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

  call s:cleanBuffer()
endfunction

function s:suite.getDifferentCharIndex() abort
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


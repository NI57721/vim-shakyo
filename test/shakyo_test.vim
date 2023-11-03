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
  normal! 1G
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

function s:suite.use_shakyo() abort
  call s:cleanBuffer()
  let bufname_prefix = '[Test]'
  let lines = ['sample text', '1', '0123456789', '3', '4', '5', '6', '7', '8', '9']
  let bufname = 'bufname'
  let s:vars.shakyo_mode_prefix = bufname_prefix
  call s:createBufferWith(bufname, lines)
  normal! 3G

  Throws /^Shakyo mode is not running yet\.$/ shakyo#clue()
  Throws /^Shakyo mode is not running yet\.$/ shakyo#quit()

  call shakyo#run()
  let want = bufname_prefix .. bufname
  let get = bufname('%')
  call s:assert.equals(get, want)

  call shakyo#clue()
  let want = ['sample text', '1', '0']
  let get = getbufline('%', 1, '$')
  call s:assert.equals(get, want)

  call shakyo#clue(7)
  let want = ['sample text', '1', '01234567']
  let get = getbufline('%', 1, '$')
  call s:assert.equals(get, want)

  call shakyo#quit()
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
endfunction

function s:suite.getHighlightCommand() abort
  call s:cleanBuffer()
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
endfunction

function s:suite.insertString() abort
  call s:cleanBuffer()
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
endfunction

function s:suite.getLineData() abort
  call s:cleanBuffer()
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


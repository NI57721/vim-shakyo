# vim-shakyo
![Test](./../../actions/workflows/test.yml/badge.svg)  
Do you like to memorise text verbatim?  
Yes! This plugin helps you.
![screenshot](https://raw.githubusercontent.com/NI57721/vim-shakyo/assets/screenshot.gif)

## Installation
You can use your preferred plugin manager.
```vim
" dein.vim
call dein#add('NI57721/vim-socrates')

" vim-plug
Plug 'NI57721/vim-socrates'

" neobundle
NeoBundle 'NI57721/vim-socrates'

" jetpack
Jetpack 'NI57721/vim-socrates'

" packer
packer.startup(function() use 'NI57721/vim-socrates' end)
```

## Usage
By adding the key mappings below you can run/quit Shakyo mode, and get a
```vim
" Examples of settings
nnoremap <leader>r <Plug>(shakyo-run)
nnoremap <leader>q <Plug>(shakyo-quit)
nnoremap <leader>c <Plug>(shakyo-clue)
```
### Run
Once you start Shakyo mode, a new buffer is created which has the whole text
from the beginning of the buffer to the line on the cursor. In this new
buffer you are supposed to write the following text, depending only on your
memory. The lines you have written up correctly are highlighted at the ends
of the lines to let you know that you have made it. On the other hand, when
you write a wrong text, the part is highlighted for you to know that you have
mistaken. See Config to learn how to change the highlight groups.

### Quit
When you quit Shakyo mode, you return to the original buffer as it was when
you start Shakyo mode.

### Clue
If you get stuck, you can get a clue whenever you like. The next letter shows
up.

### Config
You can specify some attributes by calling shakyo#config().

#### Highlight
The ends of correctly written lines are highlighted by highlight.completed,
whose default value is 'WildMenu'.
Wrongly written characters are highlighted by highlight.wrong, whose default
value is 'ErrorMsg'.
```vim
    call shakyo#config(#{
      \   highlight: #{
      \     completed: 'WildMenu',
      \     wrong: 'ErrorMsg'
      \   }
      \ })
```

## Variables
- g:shakyo_ignore
    You can set a string to this variable. It allows you to omit each
    character in the string.
```vim
    " Example
    let g:shakyo_ignore = ',.;:!?'
```

- g:shakyo_inconsistencies
    You can set a list which elements are a list of strings to this variable.
    It allows you to select either of the spelling inconsistencies of a word.
    In the example below, you can write "color" in stead of "colour", and
    vice versa.
```vim
    " Example
    let g:shakyo_inconsistencies = [
      \   ['colour', 'color'],
      \   ['grey', 'gray'],
      \   ['centre', 'center'],
      \ ]
```

## Licence
MIT Licence


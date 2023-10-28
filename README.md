# vim-shakyo
Do you like to memorise text verbatim?  
Yes! This plugin helps you.
![screenshot](https://raw.githubusercontent.com/NI57721/vim-shakyo/assets/screenshot.gif)

## Installation
- [vim-plug](https://github.com/junegunn/vim-plug): Add the line below to your .vimrc.  
```
Plug 'NI57721/vim-shakyo'
```

- [dein](https://github.com/Shougo/dein.vim): Add the line below to your dein_lazy.toml.  
```
[[plugins]]
repo = 'NI57721/vim-shakyo'
```

## Usage
```
" Mapping examples
nnoremap <leader>r <Plug>(shakyo-run)
nnoremap <leader>q <Plug>(shakyo-quit)
nnoremap <leader>c <Plug>(shakyo-clue)
```
### shakyo-run
Enter into shakyo mode, which helps you memorise the text on the current buffer.  
In the mode a new buffer is created. You can edit text there. Characters you write wrongly are highlighted. If you write up a full line correctly, the end of the line is highlighted.

### shakyo-quit
You can always quit shakyo mode.

### shakyo-clue
You can always get clues. This displays the first letter of characters in the current line which are different from the example text.

## Author
[@NI57721](https://twitter.com/NI57721)

## Licence
MIT Licence


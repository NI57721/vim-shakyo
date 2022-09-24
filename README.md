# shakyo.vim
Do you like to memorise text verbatim?  
Yes! This plugin helps you.
![screenshot](https://raw.githubusercontent.com/NI57721/shakyo.vim/assets/screenshot.gif)

## Installation
- [vim-plug](https://github.com/junegunn/vim-plug): Add the line below to your .vimrc.  
```
Plug 'NI57721/shakyo.vim'
```

- [dein](https://github.com/Shougo/dein.vim): Add the line below to your dein_lazy.toml.  
```
[[plugins]]  
repo = 'NI57721/shakyo.vim'
```

## Usage
### ShakyoRun
Enter in shakyo mode, which helps you memorise the text on the current buffer.  
In the mode a new buffer is created. You can edit text there. Characters you write wrongly are highlighted. If you write up a full line correctly, the end of the line is highlighted.

### ShakyoQuit
You can always quit shakyo mode.

### ShakyoClue
You can always get clues. This displays the first letter of characters in the current line which are different from the example text.

## Author
[@NI57721](https://twitter.com/NI57721)

## Licence
MIT Licence

---
#### TODO
 - Add an option to ignore some characters.  
 Where g:shakyo_ignore = ',.;:!?', you're allowed to write too much the characters or omit them.
 - Add compatibility option between dialects.  
 In English, let's say, it would be allowed to write 'colour' instead of 'color.' That kind of thing.
 - Use a test framework.  
 cf. [thinca/vim-themis](https://github.com/thinca/vim-themis)


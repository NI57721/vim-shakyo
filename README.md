# shakyo.vim
Do you like to memorise text verbatim? Yes! Then, this plugin helps you.
[]()


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
### shakyo#run()
Start shakyo mode, which helps you memorise the text on the current buffer.  
In the mode a new buffer is created, where you can edit text. Characters you write wrongly are highlighted. If you can manage to write a full line correctly, the end of the line is highlighted.

### shakyo#quit()
You can always quit shakyo mode.

### shakyo#clue()
You can always get clues. This function displays the first letter of characters in the current line which are different from the example text.


## Author
[@NI57721](https://twitter.com/NI57721)

## Licence
MIT Licence

---
##### TODO
 - Add an option to ignore some characters.  
 Let's say, where g:shakyo_ignore = ',.;:!?', then you can write too much the characters or omit them.
  - Add compatibility option between dialects.  
  When it comes to English, it could be allowed to write 'colour' instead of 'color.' That kind of thing.
   - Use a test framework.  
   cf. [thinca/vim-themis](https://github.com/thinca/vim-themis)

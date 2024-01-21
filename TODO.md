<div align="center">

# Marknav TODO

</div>

## Integration with vim/neovim features

Utilize buffers, windows and tabs.

- [ ] Open link side-by-side - window split
- [ ] Open link in a new tab (similar to "Shift+Enter" in browser)
- [ ] Customizable keymapping
- [ ] Autocommands on file-open or save
- [ ] Better filetype detect and make plugin usable only in markdown files

- [ ] ? Vim signs to visually mark lines that contain links
- [ ] ? Customize the appearance of links: highlighting? underscoring? shrink link to name similar to vimwiki?
    * use Neovim highlight groups for that so highlighting would be consistent with user's colorscheme
- [ ] ? Remove error message when any key is pressed

## Location/QuickFix lists

Populate Location or QuickFix lists with links in the current buffer either on file-open or keybind.
Similar functionality to "Ctrl-F" in browser. Addition: window that shows list of links.

- All links can be viewed with `:lopen` (for location) or `:copen` (for QuickFix).
- Links can be examined one by one with `:lnext` / `:lprevious` or `:cnext` / `:cprevious` (similar to "Ctrl-F" in browser)
- History can be examined with `:lnewer` / `:lolder` or `:cnewer` / `:colder`

## Windows Support

Right now just Unix-like paths are supported.

- Look into `fnamemodify`

## Enhanced Buffer Management

Retain buffer history or delete the buffer on buffer-change?
Implement cache in lua or with built-in neo(vim) features?

- make buffer stack local for each window/buffer. Otherwise it'll be a mess with multiple tabs / split windows.

## Minor

- [ ] Red error message

- [ ] ? Autosave on `:MarknavJump` and `:MarknavBack`
- [ ] ? Consider using `fnamemodify()` for path concatenation. Should be platform-indepent and more robust
- [ ] ? Add bullet list and numbered list characters to pattern ("*", "-", "10.")
- [ ] ? Consider `gf` and `goto` built-in commands
- [ ] ? Consider `isfname`

- [x] Disable `:MarknavJump` to the same file
- [x] Support absolute paths and paths relative to the directory the file is in
- [x] `:MarknavJump` recognize different links on the same line

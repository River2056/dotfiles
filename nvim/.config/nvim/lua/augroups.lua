local u = require("utils")

-- reset tab related by different files
u.create_augroup({
    { "FileType", "typescript", "set", "tabstop=2", "softtabstop=2", "shiftwidth=2" },
}, "set_ts_tab_width")
u.create_augroup({
    { "FileType", "javascript", "set", "tabstop=2", "softtabstop=2", "shiftwidth=2" },
}, "set_ts_tab_width")
u.create_augroup({
    { "FileType", "dosbatch", "set", "tabstop=2", "softtabstop=2", "shiftwidth=2" },
}, "set_dos_batch_width")
u.create_augroup({
    { "FileType", "html", "set", "tabstop=2", "softtabstop=2", "shiftwidth=2" },
}, "set_html_width")

-- call Black to format python files
--[[ u.create_augroup({
    { 'BufWritePre', '*.py', 'Black' }
}, 'black_on_save') ]]

u.create_augroup({
    { "BufWinLeave", "*.*", "mkview" },
    { "BufWinEnter", "*.*", "silent! loadview" },
}, "remember_folds")

require("oil").setup({
    default_file_explorer = true,
    -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
    delete_to_trash = true,
    -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
    skip_confirm_for_simple_edits = true,
    -- Configuration for the file preview window
    preview_win = {
        -- Whether the preview window is automatically updated when the cursor is moved
        update_on_cursor_moved = true,
        -- How to open the preview window "load"|"scratch"|"fast_scratch"
        preview_method = "fast_scratch",
    },
    keymaps = {
        ["<c-d>"] = { "actions.preview_scroll_down" },
        ["<c-u>"] = { "actions.preview_scroll_up" },
    },
})
-- copy filepath keymap
vim.keymap.set("n", "yp", function()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()
    if entry then
        local dir = oil.get_current_dir()
        vim.fn.setreg("+", dir .. entry.name)
    end
end, { buffer = true, desc = "Yank file path" })

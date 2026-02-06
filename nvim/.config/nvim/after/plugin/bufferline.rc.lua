local bufferline = require("bufferline")
local bufdelete = require("bufdelete")
local closeCommand = function(bufnum)
    bufdelete.bufdelete(bufnum, true)
end
bufferline.setup({
    options = {
        mode = "buffers",                         -- set to "tabs" to only show tabpages instead
        style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
        themable = true,                          -- allows highlight groups to be overriden i.e. sets highlights as default
        numbers = "ordinal",                      -- | function({ ordinal, id, lower, raise }): string,
        close_command = closeCommand(bufnum),     -- can be a string | function, | false see "Mouse actions"
        right_mouse_command = closeCommand(bufnum), -- can be a string | function | false, see "Mouse actions"
        left_mouse_command = "buffer %d",         -- can be a string | function, | false see "Mouse actions"
        middle_mouse_command = nil,               -- can be a string | function, | false see "Mouse actions"
        indicator = {
            -- icon = "▎", -- this should be omitted if indicator style is not 'icon'
            style = "icon",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "● ",
        close_icon = " ",
        left_trunc_marker = " ",
        right_trunc_marker = " ",
        --- name_formatter can be used to change the buffer's label in the bufferline.
        --- Please note some names can/will break the
        --- bufferline so use this at your discretion knowing that it has
        --- some limitations that will *NOT* be fixed.
        -- name_formatter = function(buf) -- buf contains:
        -- name                | str        | the basename of the active file
        -- path                | str        | the full path of the active file
        -- bufnr               | int        | the number of the active buffer
        -- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
        -- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
        -- end,
        max_name_length = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        truncate_names = true, -- whether or not tab names should be truncated
        tab_size = 18,
        diagnostics = false,
        diagnostics_update_in_insert = false, -- only applies to coc
        diagnostics_update_on_event = true, -- use nvim's diagnostic handler
        -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "(" .. count .. ")"
        end,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer", -- | function ,
                text_align = "left",
                separator = true,
            },
        },
        color_icons = true, -- whether or not to add the filetype icon highlights
        get_element_icon = function(element)
            -- element consists of {filetype: string, path: string, extension: string, directory: string}
            -- This can be used to change how bufferline fetches the icon
            -- for an element e.g. a buffer or a tab.
            -- e.g.
            local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
            return icon, hl
        end,
        show_buffer_icons = true, -- disable filetype icons for buffers
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
        duplicates_across_groups = true, -- whether to consider duplicate paths in different groups as duplicates
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        separator_style = "slant",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,
        hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
        },
        sort_by = "insert_after_current",
    },
})

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map("n", "≤", "<cmd>BufferLineCyclePrev<CR>", opts)
map("n", "≥", "<cmd>BufferLineCycleNext<CR>", opts)
map("n", "“", "<cmd>BufferLineMovePrev<CR>", opts)
map("n", "‘", "<cmd>BufferLineMoveNext<CR>", opts)

map("n", "¡", "<cmd>BufferLineGoToBuffer 1<CR>", opts)
map("n", "™", "<cmd>BufferLineGoToBuffer 2<CR>", opts)
map("n", "£", "<cmd>BufferLineGoToBuffer 3<CR>", opts)
map("n", "¢", "<cmd>BufferLineGoToBuffer 4<CR>", opts)
map("n", "∞", "<cmd>BufferLineGoToBuffer 5<CR>", opts)
map("n", "§", "<cmd>BufferLineGoToBuffer 6<CR>", opts)
map("n", "¶", "<cmd>BufferLineGoToBuffer 7<CR>", opts)
map("n", "•", "<cmd>BufferLineGoToBuffer 8<CR>", opts)
map("n", "ª", "<cmd>BufferLineGoToBuffer 9<CR>", opts)
map("n", "Ω", "<cmd>BufferLinePick<CR>", opts)

-- close tabs
map("n", "√", "<cmd>BufferLinePickClose<CR>", opts)
map("n", "ç", ":bd!<CR>", opts)
map("n", "å", "<cmd>BufferLineCloseOthers<CR>", opts)
map("n", "≈", "<cmd>BufferLineCloseRight<CR>", opts)

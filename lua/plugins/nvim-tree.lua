return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local function on_attach(bufnr)
            local api = require("nvim-tree.api")

            local function opts(desc)
                return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            local git_add = function()
                local node = api.tree.get_node_under_cursor()
                local gs = node.git_status.file

                -- If the current node is a directory get children status
                if gs == nil then
                    gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
                        or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
                end

                -- If the file is untracked, unstaged or partially staged, we stage it
                if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
                    vim.cmd("silent !git add " .. node.absolute_path)

                    -- If the file is staged, we unstage
                elseif gs == "M " or gs == "A " then
                    vim.cmd("silent !git restore --staged " .. node.absolute_path)
                end

                api.tree.reload()
            end

            local function edit_or_open()
                local node = api.tree.get_node_under_cursor()

                if node.nodes ~= nil then
                    -- expand or collapse folder
                    api.node.open.edit()
                else
                    -- open file
                    api.node.open.edit()
                    -- Close the tree if file was opened
                    api.tree.close()
                end
            end

            -- open as vsplit on current node
            local function vsplit_preview()
                local node = api.tree.get_node_under_cursor()

                if node.nodes ~= nil then
                    -- expand or collapse folder
                    api.node.open.edit()
                else
                    -- open file as vsplit
                    api.node.open.vertical()
                end

                -- Finally refocus on tree if it was lost
                api.tree.focus()
            end

            local function copy_file_to(node)
                local file_src = node["absolute_path"]
                -- The args of input are {prompt}, {default}, {completion}
                -- Read in the new file path using the existing file's path as the baseline.
                local file_out = vim.fn.input("COPY TO: ", file_src, "file")
                -- Create any parent dirs as required
                local dir = vim.fn.fnamemodify(file_out, ":h")
                vim.fn.system({ "mkdir", "-p", dir })
                -- Copy the file
                vim.fn.system({ "cp", "-R", file_src, file_out })
            end

            -- Default mappings. Feel free to modify or remove as you wish.
            --
            -- BEGIN_DEFAULT_ON_ATTACH
            vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
            vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
            vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
            vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
            vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
            vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
            vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
            vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
            vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
            vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
            vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
            vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
            vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
            vim.keymap.set("n", "a", api.fs.create, opts("Create"))
            vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
            vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
            vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
            vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
            vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
            vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
            vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
            vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
            vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
            vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
            vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
            vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
            vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
            vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
            vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
            vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
            vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
            vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
            vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
            vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
            vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
            vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
            vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
            vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
            vim.keymap.set("n", "q", api.tree.close, opts("Close"))
            vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
            vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
            vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
            vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
            vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
            vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
            vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
            vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
            vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
            vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
            -- END_DEFAULT_ON_ATTACH

            vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
            vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
            vim.keymap.set("n", "h", api.tree.close, opts("Close"))
            vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
            vim.keymap.set("n", "ga", git_add, opts("Git Add"))
            vim.keymap.set("n", "c", copy_file_to, opts("Copy File To"))
        end

        -- Automatically open file upon creation
        local api = require("nvim-tree.api")
        api.events.subscribe(api.events.Event.FileCreated, function(file)
            vim.cmd("edit " .. file.fname)
        end)

        require("nvim-tree").setup({
            on_attach = on_attach,
            live_filter = {
                prefix = "[FILTER]: ",
                always_show_folders = false, -- Turn into false from true by default
            },
            disable_netrw = false,
            hijack_netrw = true,
            open_on_tab = false,
            hijack_cursor = false,
            update_cwd = false,
            renderer = {
                add_trailing = false,
                group_empty = false,
                highlight_git = false,
                highlight_opened_files = "none",
                root_folder_modifier = ":~",
                indent_markers = {
                    enable = false,
                    icons = {
                        corner = "└ ",
                        edge = "│ ",
                        none = "  ",
                    },
                },
                icons = {
                    webdev_colors = true,
                    git_placement = "before",
                    padding = " ",
                    symlink_arrow = " ➛ ",
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = false,
                        git = true,
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "✗",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = {
                    hint = "",
                    info = "",
                    warning = "",
                    error = "",
                },
            },
            update_focused_file = {
                enable = true,
                update_cwd = false,
                ignore_list = {},
            },
            system_open = {
                cmd = nil,
                args = {},
            },
            view = {
                adaptive_size = true,
            },
            filters = {
                dotfiles = false,
                git_ignored = true,
                custom = { "^.git$", "^.yarn$", "^.next$" },
                exclude = { ".env", ".env.local", ".env.development.local", ".env.test.local", ".env.production.local" }
            },
        })

        vim.api.nvim_set_keymap("n", "<Leader>e", ":NvimTreeToggle<CR>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<Leader>R", ":NvimTreeRefresh<CR>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<Leader>F", ":NvimTreeFindFile<CR>", { noremap = true })
    end,
}

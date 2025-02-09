lua << EOF

--require('dap').setup()
local dap = require('dap')
-- dap.adapters.cppdbg = {
--   id = 'cppdbg',
--   type = 'executable',
--   command = '/home/dmitrii/.config/nvim/bin/extension/debugAdapters/bin/OpenDebugAD7',
-- }
-- 
-- dap.configurations.cpp = {
--   {
--     name = "Launch file",
--     type = "cppdbg",
--     request = "launch",
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopAtEntry = true,
--   },
--   {
--     name = 'Attach to gdbserver :1234',
--     type = 'cppdbg',
--     request = 'launch',
--     MIMode = 'gdb',
--     miDebuggerServerAddress = 'localhost:1234',
--     miDebuggerPath = '/usr/bin/gdb',
--     cwd = '${workspaceFolder}',
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--   },
-- }
-- dap.configurations.rust = {
--   {
--     name = "Launch file",
--     type = "cppdbg",
--     request = "launch",
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopAtEntry = true,
--   },
--   {
--     name = 'Attach to gdbserver :1234',
--     type = 'cppdbg',
--     request = 'launch',
--     MIMode = 'gdb',
--     miDebuggerServerAddress = 'localhost:1234',
--     miDebuggerPath = '/usr/bin/gdb',
--     cwd = '${workspaceFolder}',
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--   },
-- }
dap.adapters.lldb = {
  type = 'executable',
  --command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  command = 'lldb-dap', -- adjust as needed, must be absolute path
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}
dap.configurations.rust = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    initCommands = function()
      -- Find out where to look for the pretty printer Python module
      local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

      local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
      local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

      local commands = {}
      local file = io.open(commands_file, 'r')
      if file then
        for line in file:lines() do
          table.insert(commands, line)
        end
        file:close()
      end
      table.insert(commands, 1, script_import)

      return commands
    end,

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}

--require("nvim-dap-virtual-text").setup {
--    enabled = true,                        -- enable this plugin (the default)
--    enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
--    highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
--    highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
--    show_stop_reason = true,               -- show stop reason when stopped for exceptions
--    commented = false,                     -- prefix virtual text with comment string
--    only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
--    all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
--    clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
--    --- A callback that determines how a variable is displayed or whether it should be omitted
--    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
--    --- @param buf number
--    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
--    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
--    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
--    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
--    display_callback = function(variable, buf, stackframe, node, options)
--      if options.virt_text_pos == 'inline' then
--        return ' = ' .. variable.value
--      else
--        return variable.name .. ' = ' .. variable.value
--      end
--    end,
--    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
--    virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
--
--    -- experimental features:
--    all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
--    virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
--    virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
--                                           -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
--}

require("dapui").setup()
local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<Leader>dt", ':DapToggleBreakpoint<CR>')
vim.keymap.set("n", "<Leader>dx", ':DapTerminate<CR>')
vim.keymap.set("n", "<Leader>do", ':DapStepOver<CR>')

EOF

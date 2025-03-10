--require('leap').create_default_mappings()
vim.keymap.set('n',        's', '<Plug>(leap)')
vim.keymap.set('n',        '<leader>s', '<Plug>(leap)')
vim.keymap.set('n',        'S', '<Plug>(leap-from-window)')
vim.keymap.set({'x', 'o'}, 's', '<Plug>(leap-forward)')
vim.keymap.set({'x', 'o'}, 'S', '<Plug>(leap-backward)')

-- Define equivalence classes for brackets and quotes, in addition to
-- the default whitespace group.
require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

-- Use the traversal keys to repeat the previous motion without explicitly
-- invoking Leap.
require('leap.user').set_repeat_keys('<enter>', '<backspace>')

vim.api.nvim_set_keymap("n", "<leader>v", "<cmd>CHADopen<cr>", { noremap = true, silent = true}) 

-- local chadtree_settings = { 
--   options = {
--     mimetypes = {
--       allow_exts = {".ts", ".png", ".gif", ".jpg", ".jpeg", "image/jpeg"},
--       warn = {"audio", "font",  "video"},
--     }
--   }
-- }
local chadtree_settings = { 
  ["options.mimetypes.allow_exts"] = {".jpeg", ".png", ".jpg", "jpg", "jpeg", "image/jpeg"},
  ["options.mimetypes.warn"] = {"video", "audio", "font"},
}

vim.api.nvim_set_var("chadtree_settings", chadtree_settings)

--##### `chadtree_settings.options.mimetypes.allow_exts`
--
--Skip warning for these extensions
--
--**default:**
--
--```json
--[".ts"]
--```

-- chadtree_settings.options.mimetypes.allow_exts

-- nnoremap <leader>v <cmd>CHADopen<cr>
-- 
-- "let g:chadtree_settings = {
-- "  'chadtree_settings.keymap.tertiary' : 'T'
-- "}
-- let g:chadtree_settings = { 
-- }

require('gen').setup({
  -- model = "zephyr",
  -- model = "deepseek-coder:6.7b-instruct-q6_K",
  model = "deepseek-coder:33b-instruct-q4_K_M",
  command = "curl --silent --no-buffer -X POST http://10.252.1.6:11434/api/generate -d $body",
  display_mode = "split", -- The display mode. Can be "float" or "split".
  show_prompt = true, -- Shows the Prompt submitted to Ollama.
  show_model = true, -- Displays which model you are using at the beginning of your chat session.
  no_auto_close = true, -- Never closes the window automatically.
})

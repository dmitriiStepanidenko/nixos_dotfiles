require("codesnap").setup({
  -- The save_path must be ends with .png, unless when you specified a directory path,
  -- CodeSnap will append an auto-generated filename to the specified directory path
  -- For example:
  -- save_path = "~/Pictures"
  -- parsed: "~/Pictures/CodeSnap_y-m-d_at_h:m:s.png"
  -- save_path = "~/Pictures/foo.png"
  -- parsed: "~/Pictures/foo.png"
  save_path = "~",
  watermark = "",
  bg_theme = "sea",
  bg_x_padding = 58,
  bg_y_padding = 39,
  bg_padding = nil,
  has_line_number = true,
  has_breadcrumbs = true,
})

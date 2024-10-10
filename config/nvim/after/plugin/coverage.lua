require("coverage").setup({
  auto_reload = true,
  auto_reload_timeout_ms = 1000,
  lcov_file = "./target/coverage/tests.lcov"
})


test_message <- "import_ohlc() only supports a single symbol"
expect_error(import_ohlc(sym_yahoo(c("AAPL", "NFLX"))),
    pattern = sub("\\(|\\)", ".", test_message),
    info = test_message)

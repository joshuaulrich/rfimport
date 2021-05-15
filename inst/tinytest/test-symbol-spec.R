suppressMessages(library(fimvisr))

sym1 <- sym_yahoo(c("AAPL", "NFLX"))
expect_inherits(sym1, "symbol_spec")


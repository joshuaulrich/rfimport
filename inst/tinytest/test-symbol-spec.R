suppressMessages(library(rfimport))

sym1 <- sym_yahoo(c("AAPL", "NFLX"))
expect_inherits(sym1, "symbol_spec")

sym2 <- sym_yahoo("FB", foo = "bar")
expect_warning(c(sym1, sym2), ".*found different source attributes.*")

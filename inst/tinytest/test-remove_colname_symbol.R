suppressMessages(library(rfimport))

data("sample_matrix", package = "xts")

x <- as.xts(sample_matrix)
ohlc_colnames <- colnames(x)

# Test column name "AAPL.Open" -> "Open", etc.
colnames(x) <- paste("AAPL", ohlc_colnames, sep = ".")
y <- rfimport:::.remove_colname_symbol(x)
expect_equal(colnames(y), ohlc_colnames)

# Test column name "BRK.A.Open" -> "Open", etc.
colnames(x) <- paste("BRK.A", ohlc_colnames, sep = ".")
y <- rfimport:::.remove_colname_symbol(x)
expect_equal(colnames(y), ohlc_colnames)

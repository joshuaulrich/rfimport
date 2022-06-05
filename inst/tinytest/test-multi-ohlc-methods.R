test_message <- "c.multiple_ohlc() returns object with names"
x <- structure(list(
    ABC = structure(c(422.59, 423.11, 422.78, 423.21, 421.19, 420.32, 422.19, 422.28, 51555000, 47134300, 416.71, 416.79),
        class = c("xts", "zoo"),
        src = "yahoo",
        updated = structure(1654442753.21245, class = c("POSIXct", "POSIXt")),
        index = structure(c(1623024000, 1623110400), tzone = "UTC", tclass = "Date"),
        dim = c(2L, 6L),
        dimnames = list(NULL, c("Open", "High", "Low", "Close", "Volume", "Adjusted")))
), class = "multiple_ohlc")

y <- structure(list(
    DEF = structure(c(227.89, 231.21, 230.78, 233.48, 227.25, 229.98, 230.45, 232.89, 24049857, 27770308, 228.2556, 230.6723),
        class = c("xts", "zoo"),
        src = "tiingo",
        updated = structure(1654442752.52916, class = c("POSIXct", "POSIXt")),
        index = structure(c(1623024000, 1623110400), tzone = "UTC", tclass = "Date"),
        dim = c(2L, 6L),
        dimnames = list(NULL, c("Open", "High", "Low", "Close", "Volume", "Adjusted")))
), class = "multiple_ohlc")

z <- c(x, y)
expect_identical(names(z), c("ABC", "DEF"), test_message)

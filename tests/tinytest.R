# run package unit tests
if (requireNamespace("tinytest", quietly = TRUE)) {
    suppressPackageStartupMessages(library("rfimport"))
    use_color <- as.logical(Sys.getenv("_MY_TINYTEST_COLOR_", FALSE))
    verbosity <- as.integer(Sys.getenv("_MY_TINYTEST_VERBOSE_", 2))
    cat("tinytest colored output:", use_color,
        "\ntinytest verbosity:", verbosity, "\n")
    tinytest::test_package("rfimport", color = use_color, verbose = verbosity)
}


# vim: tabstop=4 shiftwidth=4 expandtab
#
#  fimvisr: Financial Market Data Import & Visualization
#
#  Copyright (C) 2020 Joshua M. Ulrich
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

.remove_colname_symbol <-
function(object, remove_prefix = TRUE)
{
    if (remove_prefix) {
        look_ahead_for_anything_followed_by_period <- "(?!(.|\n)*\\.)"

        group_of_everything_before_first_period <- "(.*)\\."
        group_of_everything_after_last_period <-
            paste0("(", look_ahead_for_anything_followed_by_period,
                   ".*$)")

        pattern <-
            paste0(group_of_everything_before_first_period,
                   group_of_everything_after_last_period)

        # set colnames to everything after last period
        colnames(object) <- gsub(pattern, "\\2", colnames(object), perl = TRUE)
    }
    return(object)
}

# import intraday quotes
import_quote <-
function(symbol_spec, ...)
{
    UseMethod("import_quote", symbol_spec)
}

import_quote.symbol_spec <-
function(symbol_spec, ...)
{
    NextMethod(object = symbol_spec)
}

import_quote.default <-
function(symbol_spec, ...)
{
    stop("not implemented")
}

#' Import OHLC(VA) data from one or more sources
#'
#' This function imports data that has columns with open, high, low, close,
#' and possibly volume and/or adjusted close (if the data source returns it).
#'
#' @param symbol_spec A symbol specification object.
#' @param \dots Additional parameters passed to methods.
#'
#' @return An object of class \code{multiple_ohlc}.
#'
#' @author Joshua Ulrich
#' @keywords IO connection
#' @examples
#'
#' tickers <- sym_yahoo(c("AAPL", "NFLX"))
#' ohlc <- import_ohlc(tickers)
#'
import_ohlc <-
function(symbol_spec, ...)
{
    UseMethod("import_ohlc", symbol_spec)
}

import_ohlc.default <-
function(symbol_spec, ...)
{
    stop("not implemented")
}

import_ohlc.symbol_spec <-
function(symbol_spec, ...)
{
    symbols_by_source <- split(symbol_spec, names(symbol_spec))

    for (sym in names(symbols_by_source)) {
        method_function <- getS3method("import_ohlc", sym)

        src_spec <- symbols_by_source[[sym]]
        attr(src_spec, "src_attr") <- .get_src_attr(symbol_spec)[[sym]]

        if (exists("results")) {
            results <- c(results, method_function(src_spec, ...))
        } else {
            results <- method_function(src_spec, ...)
        }
    }

    symbol_names <- gsub("\\^", "", symbol_spec)
    results <- results[symbol_names]

    return(results)
}

#' Import univariate series from one or more sources
#'
#' This function imports data where each column represents a different series.
#'
#' @param symbol_spec A symbol specification object.
#' @param \dots Additional parameters passed to methods.
#'
#' @return An object of class \code{xts} with one column per series.
#'
#' @author Joshua Ulrich
#' @keywords IO connection
#' @examples
#'
#' series_symbols <- sym_fred(c("DGS10", "DGS5"))
#' treasury_rates <- import_series(series_symbols)
#'
import_series <-
function(symbol_spec, ...)
{
    UseMethod("import_series", symbol_spec)
}

import_series.symbol_spec <-
function(symbol_spec, ...)
{
    symbols_by_source <- split(symbol_spec, names(symbol_spec))

    for (sym in names(symbols_by_source)) {
        method_function <- getS3method("import_series", sym)

        src_spec <- symbols_by_source[[sym]]
        attr(src_spec, "src_attr") <- .get_src_attr(symbol_spec)[[sym]]

        if (exists("results")) {
            results <- c(results, method_function(src_spec, ...))
        } else {
            results <- method_function(src_spec, ...)
        }
    }

    symbol_names <- gsub("\\^", "", symbol_spec)
    results <- results[, symbol_names]

    return(results)
}

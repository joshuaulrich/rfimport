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

    return(results)
}

# A univariate series from one or more sources
import_series <-
function(symbol_spec, ...)
{
    UseMethod("import_series", symbol_spec)
}

import_series.symbol_spec <-
function(symbol_spec, ...)
{
    NextMethod(object = symbol_spec)
}


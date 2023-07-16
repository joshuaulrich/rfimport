# vim: tabstop=4 shiftwidth=4 expandtab
#
#  rfimport: Import Financial Market Data
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

#' Import a collection of OHLC data from one or more sources
#'
#' This function imports data that has columns with open, high, low, close,
#' and possibly volume and/or adjusted close (if the data source returns it).
#'
#' @param symbol_spec A symbol specification object.
#' @param dates An ISO-8601 string specifying the start and/or end dates.
#' @param \dots Additional parameters passed to methods.
#'
#' @return An object of class \code{ohlc_collection}.
#'
#' @author Joshua Ulrich
#' @keywords IO connection
#' @examples
#'
#' \dontrun{
#' tickers <- sym_yahoo(c("AAPL", "NFLX"))
#' collection <- import_ohlc_collection(tickers)
#' }
#'
import_ohlc_collection <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    UseMethod("import_ohlc_collection", symbol_spec)
}

import_ohlc_collection.default <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    stop("not implemented")
}

import_ohlc_collection.symbol_spec <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    symbols_by_source <- split(symbol_spec, names(symbol_spec))

    for (sym in names(symbols_by_source)) {
        method_function <- getS3method("import_collection", sym)

        src_spec <- symbols_by_source[[sym]]
        attr(src_spec, "src_attr") <- .get_src_attr(symbol_spec)[[sym]]

        if (exists("results")) {
            results <- c(results, method_function(src_spec, dates, ...))
        } else {
            results <- method_function(src_spec, dates, ...)
        }
    }

    symbol_names <- gsub("\\^", "", symbol_spec)
    results <- results[symbol_names]

    return(results)
}

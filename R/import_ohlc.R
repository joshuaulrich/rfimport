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

#' Import a single OHLC(VA) series as an xts object
#'
#' This function imports data that has columns with open, high, low, close,
#' and possibly volume and/or adjusted close (if the data source returns it).
#'
#' @param symbol_spec A symbol specification object with one symbol.
#' @param dates An ISO-8601 string specifying the start and/or end dates.
#' @param \dots Additional parameters passed to methods.
#'
#' @return An object of class \code{xts}.
#'
#' @author Joshua Ulrich
#' @keywords IO connection
#' @examples
#'
#' ticker <- sym_yahoo("AAPL")
#' ohlc <- import_ohlc(ticker)
#'
import_ohlc <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    UseMethod("import_ohlc", symbol_spec)
}

import_ohlc.default <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    stop("not implemented")
}

import_ohlc.symbol_spec <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    if (length(symbol_spec) > 1L) {
        stop("import_ohlc() only supports a single symbol.")
    }

    method_function <- getS3method("import_ohlc_collection", names(symbol_spec))

    src_spec <- symbol_spec
    attr(src_spec, "src_attr") <- .get_src_attr(symbol_spec)

    results <- method_function(src_spec, dates, ...)[[1L]]

    return(results)
}



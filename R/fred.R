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

#' Symbol specification for FRED
#'
#' @param symbols Series symbols to import.
#' @param \dots Additional source attributes.
#' @param curl_options Options passed to \pkg{curl} functions.
#'
#' @return An object of class \code{symbol_spec}. The object contains a
#'     \code{src_attr} attribute that stores any additional details that need
#'     to be used for the connection to the data source.
#'
#' @references \url{https://fred.stlouisfed.org/}
#'
#' @author Joshua Ulrich
#'
#' @rdname fred
#' @keywords IO connection
#'
#' @examples
#'
#' series_symbols <- sym_fred(c("DGS10", "DGS5"))
#'
#' \dontrun{
#' # one symbol
#' treasury_10y <- import_series(sym_fred("DGS10"))
#'
#' # multiple symbols (one wide xts object)
#' treasury_rates <- import_series(series_symbols)
#' }
#'
sym_fred <-
function(symbols, ..., curl_options = list())
{
    src_name <- "fred"
    src_attr <- list(curl_options = curl_options,
                     ...)

    create_sym_spec(symbols, src_name = src_name, src_attr = src_attr)
}

#' Import data from FRED
#'
#' Imports data from FRED for each symbol in \code{symbol_spec}. This method
#' should not be called directly. Use \code{import_series} with one FRED
#' \code{symbol_spec}.
#'
#' @aliases import_series.fred
#'
#' @param symbol_spec A \code{symbol_spec} object, with one element for each
#'    symbol that will be imported.
#' @param dates An ISO-8601 string specifying the start and/or end dates.
#' @param \dots Arguments passed to other functions (not currently used).
#'
#' @return A \code{xts} object, with all the columns for each
#'    \code{symbol_spec}.
#'
#' @rdname fred
#' @keywords IO
#'
import_series.fred <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    env <- new.env()
    getSymbols(syms, src = "FRED", env = env, ...)

    lenv <- as.list(env)

    result <- do.call("merge", lenv)
    return(result)
}

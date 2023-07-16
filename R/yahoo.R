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

#' Symbol specification for Yahoo Finance
#'
#' @param symbols Ticker symbols to import.
#' @param \dots Additional source attributes.
#' @param curl_options Options passed to \pkg{curl} functions.
#'
#' @return An object of class \code{symbol_spec}. The object contains a
#'     \code{src_attr} attribute that stores any additional details that need
#'     to be used for the connection to the data source.
#'
#' @references \url{https://finance.yahoo.com/}
#'
#' @author Joshua Ulrich
#'
#' @rdname yahoo
#' @keywords IO connection
#' @examples
#'
#' tickers <- sym_yahoo(c("AAPL", "NFLX"))
#'
#' \dontrun{
#' # one symbol
#' spy <- import_ohlc(sym_yahoo("SPY"))
#'
#' # multiple symbols
#' ohlc <- import_ohlc_collection(tickers)
#' }
#'
sym_yahoo <-
function(symbols, ..., curl_options = list())
{
    src_name <- "yahoo"
    src_attr <- list(curl_options = curl_options,
                     ...)

    create_sym_spec(symbols, src_name = src_name, src_attr = src_attr)
}

#' Import data from Yahoo Finance
#'
#' Imports data from Yahoo Finance for each symbol in \code{symbol_spec}. This
#' method should not be called directly. Use \code{import_ohlc_collection} with
#' one or more Yahoo Finance \code{symbol_spec} objects.
#'
#' @aliases import_ohlc.yahoo import_ohlc_collection.yahoo
#'
#' @param symbol_spec A \code{symbol_spec} object, with one element for each
#'    symbol that will be imported.
#' @param dates An ISO-8601 string specifying the start and/or end dates.
#' @param \dots Arguments passed to other functions (not currently used).
#'
#' @return A \code{ohlc_collection} object, with one element for each
#'    \code{symbol_spec}.
#'
#' @rdname yahoo
#' @keywords IO
#'
#' @examples
#'
#'  ### Note: you must have a working internet
#'  ### connection for these examples to work!
#'  if (interactive()) {
#'      sym_spec <- sym_yahoo(c("IBM", "CSCO"))
#'      yahoo_data <- import_ohlc_collection(sym_spec)
#'  }
#'
import_ohlc_collection.yahoo <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    from_to <- .api$parse_iso8601_interval(dates)

    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    curl_opt <- attr(symbol_spec, "curl_options")

    if (!hasArg("periodicity")) {
        periodicity <- "daily"
    }

    env <- new.env()
    getSymbols(syms, src = "yahoo", from = from_to$start, to = from_to$end, ...,
               periodicity = periodicity, env = env, curl_options = curl_opt)

    env <- eapply(env, .remove_colname_symbol)
    structure(env, class = "ohlc_collection")
}

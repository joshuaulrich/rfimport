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

#' Symbol specification for Tiingo OHLC data
#'
#' @param symbols Ticker symbols to import.
#' @param \dots Additional source attributes.
#' @param curl_options Options passed to \pkg{curl} functions.
#' @param api_key Your Tiingo API key (available for free).
#'
#' @return An object of class \code{symbol_spec}. The object contains a
#'     \code{src_attr} attribute that stores any additional details that need
#'     to be used for the connection to the data source.
#'
#' @references \url{https://www.tiingo.com/}, \url{https://api.tiingo.com/}
#'
#' @author Joshua Ulrich
#'
#' @rdname tiingo
#' @keywords IO connection
#' @examples
#'
#' tickers <- sym_tiingo(c("AAPL", "NFLX"), api_key = "*****")
#'
#' \dontrun{
#' # one symbol
#' spy <- import_ohlc(sym_tiingo("SPY"))
#'
#' # multiple symbols
#' ohlc <- import_ohlc_collection(tickers)
#' }
#'
sym_tiingo <-
function(symbols, ..., curl_options = list(), api_key = NULL)
{
    config_file <- "~/.R/quantmod-config.json"
    if (file.exists(config_file)) {
        api_key <- jsonlite::fromJSON(config_file)[["tiingo"]][["api_key"]]
    } else if (is.null(api_key)) {
        # url to where they can get a free api key
        stop("you need an api key to import Tiingo data")
    }

    src_name <- "tiingo"
    src_attr <- list(curl_options = curl_options,
                     api_key = api_key,
                     ...)

    create_sym_spec(symbols, src_name = src_name, src_attr = src_attr)
}

#' Import OHLC data from Tiingo
#'
#' Imports OHLC data from Tiingo for each symbol in \code{symbol_spec}. This method
#' should not be called directly. Use \code{import_ohlc_collection} with one or
#' more Tiingo \code{symbol_spec}, or \code{import_ohlc} to import one symbol.
#'
#' @aliases import_ohlc.tiingo import_ohlc_collection.tiingo
#'
#' @param symbol_spec A \code{symbol_spec} object, with one element for each
#'    symbol that will be imported.
#' @param dates An ISO-8601 string specifying the start and/or end dates.
#' @param \dots Arguments passed to other functions (not currently used).
#'
#' @return A \code{ohlc_collection} object, with one element for each
#'    \code{symbol_spec}.
#'
#' @rdname tiingo
#' @keywords IO
#'
import_ohlc_collection.tiingo <-
function(symbol_spec,
         dates = NULL,
         ...)
{
    config_file <- "~/.R/quantmod-config.json"
    if (file.exists(config_file)) {
        api_key <- jsonlite::fromJSON(config_file)[["tiingo"]][["api_key"]]
    } else {
        api_key <- .get_src_attr(symbol_spec)[["api_key"]]
    }
    if (is.null(api_key)) {
        stop("you need an api key to use Tiingo data")
    }

    from_to <- .api$parse_iso8601_interval(dates)
    from_to <- lapply(from_to, trunc, units = "days")

    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    env <- new.env()
    getSymbols(syms, src = "tiingo", from = from_to$start, to = from_to$end,
               ..., env = env, api.key = api_key)

    env <- eapply(env, .remove_colname_symbol)
    structure(env, class = "ohlc_collection")
}

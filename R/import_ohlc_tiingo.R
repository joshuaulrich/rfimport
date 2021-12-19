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

#' Import data from Tiingo
#' 
#' Imports data from Tiingo for each symbol in \code{symbol_spec}. This method
#' should not be called directly. Use \code{import_ohlc} with one or more
#' Tiingo \code{symbol_spec}.
#' 
#' @aliases import_ohlc.tiingo import_ohlc_tiingo
#' 
#' @param symbol_spec A \code{symbol_spec} object, with one element for each
#'    symbol that will be imported.
#' @param \dots Arguments passed to other functions (not currently used).
#' @param from A date/time that specifies the first possible date of the
#'    imported data (default: \code{Sys.Date() - 365}).
#' @param to A date/time that specifies the last possible date of the
#'    imported data (default: \code{Sys.Date()}).
#' 
#' @return A \code{multiple_ohlc} object, with one element for each
#'    \code{symbol_spec}.
#' 
#' @keywords IO connection
#' 
#' @examples
#' 
#'  ### Note: you must have a working internet
#'  ### connection for these examples to work!
#'  if (interactive()) {
#'      sym_spec <- sym_tiingo(c("IBM", "CSCO"), api_key = "[your_api_key]")
#'      tiingo_data <- import_ohlc(sym_spec)
#'  }
#' 

import_ohlc.tiingo <-
function(symbol_spec, ..., from = NULL, to = NULL)
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
    if (is.null(from)) {
        from <- Sys.Date() - 365
    }
    if (is.null(to)) {
        to <- Sys.Date()
    }

    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    env <- new.env()
    getSymbols(syms, src = "tiingo", from = from, to = to, ..., env = env,
               api.key = api_key)

    env <- eapply(env, .remove_colname_symbol)
    structure(env, class = "multiple_ohlc")
}

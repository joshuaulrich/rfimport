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

### generic constructor for symbol_spec connection objects
create_sym_spec <-
function(symbols,
         src_name = NULL,
         src_attr = NULL)
{
    if (is.null(src_name)) {
        stop("'src_name' cannot be NULL")
    }

    src_attr <- setNames(list(src_attr), src_name)
    src_names <- rep(src_name, length(symbols))
    structure(setNames(symbols, src_names),
              class = "symbol_spec",
              src_attr = src_attr)
}

### symbol_spec connection objects

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
#' @keywords IO connection
#' @examples
#'
#' tickers <- sym_yahoo(c("AAPL", "NFLX"))
#' \dontrun{
#'     ohlc <- import_ohlc(tickers)
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

#' Symbol specification for Tiingo
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
#' @references \url{https://www.tiingo.com/}
#'
#' @author Joshua Ulrich
#' @keywords IO connection
#' @examples
#'
#' \dontrun{
#'     tickers <- sym_tiingo(c("AAPL", "NFLX"), api_key = "*****")
#'     ohlc <- import_ohlc(tickers)
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
#' @keywords IO connection
#' @examples
#'
#' series_symbols <- sym_fred(c("DGS10", "DGS5"))
#'
#' \dontrun{
#'     treasury_rates <- import_series(series_symbols)
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

.get_src_attr <-
function(symbol_spec)
{
    # helper to avoid getting NULL by misspelling 'src_attr'
    attr(symbol_spec, "src_attr")
}

.combine_src_attr <-
function(...)
{
    new_attr <- src_attr_x <- NULL
    objs <- list(...)

    for (o in objs) {
        src_attr_y <- .get_src_attr(o)

        same_src <- identical(names(src_attr_x), names(src_attr_y))
        diff_attr <- !isTRUE(all.equal(src_attr_x, src_attr_y))

        if (same_src && diff_attr) {
            warning("found different source attributes for ",
                    names(src_attr_x), "\n  using ", src_attr_x,
                    call. = FALSE, immediate. = TRUE)
            new_attr <- src_attr_x
        } else {
            new_attr <- c(src_attr_x, src_attr_y)
        }
        src_attr_x <- src_attr_y
    }
    return(new_attr)
}

c.symbol_spec <-
function(...)
{
    objs <- list(...)
    if (length(objs) > 1) {
        src_attr <- .combine_src_attr(...)

        result <- NextMethod()
        result <-
            structure(result,
                      class = "symbol_spec",
                      src_attr = src_attr)
    } else {
        result <- objs[[1]]
    }
    return(result)
}

print.symbol_spec <-
function(x, ..., quote = FALSE)
{
    y <- x
    attr(y, "src_attr") <- NULL
    class(y) <- NULL

    print(y, ..., quote = quote)
    invisible(x)
}

str.symbol_spec <-
function(object, ...)
{
    src_attr_names <- names(attr(object, "src_attr"))

    for (nm in src_attr_names) {
        this_api_key <- attr(object, "src_attr")[[nm]][["api_key"]]
        if (!is.null(this_api_key)) {
            attr(object, "src_attr")[[nm]][["api_key"]] <- "<redacted>"
        }
    }
    NextMethod(.Generic)
}

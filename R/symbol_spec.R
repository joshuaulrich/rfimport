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

### symbol_spec connection objects
sym_yahoo <-
function(symbols, ...)
{
    structure(symbols,
              #         url = "...",
              #         adjust = TRUE,
              return_class = "xts",
              curl_options = list(),
              class = c("symbol_spec", "yahoo"))
}

sym_tiingo <-
function(symbols, api_key = NULL, ...)
{
    if (is.null(api_key)) {
        # url to where they can get a free api key
        stop("you need an api key to import Tiingo data")
    }
    structure(symbols,
              #         url = "...",
              #         adjust = TRUE,
              api_key = api_key,
              return_class = "xts",
              curl_options = list(),
              class = c("symbol_spec", "tiingo"))
}

sym_fred <-
function(symbols, ...)
{
    structure(symbols,
              #         url = "...",
              #         adjust = TRUE,
              return_class = "xts",
              class = c("symbol_spec", "fred"))
}

c.symbol_spec <-
function(...)
{
    # I don't like this. It should always return the same type of object
    # But otherwise I don't know how to have a list of specs to different
    # sources.
    objects <- list(...)
    if (length(objects) > 1) {
        result <- structure(list(...), class = "symbol_spec_list")
    }
    return(result)
}

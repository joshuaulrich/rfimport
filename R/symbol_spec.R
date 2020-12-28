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

# TODO: try turning these into lists

### symbol_spec connection objects
sym_yahoo <-
function(symbols, ...)
{
    # TODO: check `...` for curl_options
    src_spec <- lapply(symbols, structure, class = "yahoo")
    sym_spec <- structure(src_spec,
                          curl_options = list(),
                          class = "symbol_spec")
    setNames(sym_spec, symbols)
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
              spec_class = "tiingo",
              class = c("symbol_spec", "tiingo"))
}

sym_fred <-
function(symbols, ...)
{
    src_spec <- lapply(symbols, structure, class = "fred")
    sym_spec <- structure(src_spec, class = "symbol_spec")
    setNames(sym_spec, symbols)
}

print.symbol_spec <-
function(x, ..., quote = FALSE)
{
    n <- sapply(x, class)
    y <- unlist(x, recursive = FALSE, use.names = FALSE)
    p <- setNames(n, y)
    print(p, ..., quote = quote)
    invisible(p)
}

c.symbol_spec <-
function(...)
{
    specs <- unlist(list(...), recursive = FALSE, use.names = TRUE)
    structure(specs, class = "symbol_spec")
}

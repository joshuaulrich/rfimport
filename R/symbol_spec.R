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
function(symbols,
         ...,
         curl_options = list(),
         return_class = "xts")
{
    tickers <- structure(symbols,
                         curl_options = curl_options,
                         return_class = return_class,
                         ...,
                         class = "yahoo")

    structure(list(yahoo = tickers), class = "symbol_spec")
}

sym_tiingo <-
function(symbols,
         ...,
         api_key = NULL,
         curl_options = list(),
         return_class = "xts")
{
    if (is.null(api_key)) {
        # url to where they can get a free api key
        stop("you need an api key to import Tiingo data")
    }

    tickers <- structure(symbols,
                         curl_options = curl_options,
                         return_class = return_class,
                         api_key = api_key,
                         ...,
                         class = "tiingo")

    structure(list(tiingo = tickers), class = "symbol_spec")
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
    print(p, ..., quote = quote)
    invisible(p)
}

c.symbol_spec <-
function(...)
{
    # Combine common sources from each argument
    arglist <- pairlist(...)

    specs <- list()
    for (i in seq_along(arglist)) {
        spec_i <- arglist[[i]]
        spec_src <- names(spec_i)
        spec_attr <- attributes(spec_i[[1]])

        # Should we check attributes on specs for the same source?
        specs[[spec_src]] <- c(specs[[spec_src]], spec_i[[1L]])
        # c() drops attributes, so add them back
        attributes(specs[[spec_src]]) <- spec_attr
    }

    # Warn if the same ticker is requested from more than one source?
    # Probably, because the purpose is to return a set of data independent
    # of the source

    structure(specs, class = "symbol_spec")
}

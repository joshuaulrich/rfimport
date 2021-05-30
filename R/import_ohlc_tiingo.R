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

import_ohlc.tiingo <-
function(symbol_spec, ..., from = NULL, to = NULL)
{
    api_key <- .get_src_attr(symbol_spec)[["api_key"]]
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
    structure(as.list(env), class = "multiple_ohlc")
}

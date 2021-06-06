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

import_ohlc.yahoo <-
function(symbol_spec, ..., from = NULL, to = NULL)
{
    if (is.null(from)) {
        from <- Sys.Date() - 365
    }
    if (is.null(to)) {
        to <- Sys.Date()
    }

    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    curl_opt <- attr(symbol_spec, "curl_options")

    if (!hasArg("periodicity")) {
        periodicity <- "daily"
    }

    env <- new.env()
    getSymbols(syms, src = "yahoo", from = from, to = to, ...,
               periodicity = periodicity, env = env, curl_options = curl_opt)

    env <- eapply(env, .adjust_colnames)
    structure(env, class = "multiple_ohlc")
}

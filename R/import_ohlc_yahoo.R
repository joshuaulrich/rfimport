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

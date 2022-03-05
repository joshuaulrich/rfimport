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

import_series.fred <-
function(symbol_spec, ...)
{
    # drop attributes
    syms <- .drop_attributes(symbol_spec)

    rtype <- attr(symbol_spec, "return_type")

    env <- new.env()
    getSymbols(syms, src = "FRED", env = env, return.type = rtype, ...)

    lenv <- as.list(env)

    result <- do.call("merge", lenv)
    return(result)
}

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

# import intraday quotes
import_quote <-
function(symbol_spec, ...)
{
    UseMethod("import_quote", symbol_spec)
}

import_quote.symbol_spec <-
function(symbol_spec, ...)
{
    NextMethod(object = symbol_spec)
}

import_quote.default <-
function(symbol_spec, ...)
{
    stop("not implemented")
}

# OHLC(VA) data from one or more sources
import_ohlc <-
function(symbol_spec, ...)
{
    UseMethod("import_ohlc", symbol_spec)
}

import_ohlc.default <-
function(symbol_spec, ...)
{
    stop("not implemented")
}

import_ohlc.symbol_spec <-
function(symbol_spec, ...)
{
    NextMethod(object = symbol_spec)
}

# A univariate series from one or more sources
import_series <-
function(symbol_spec, ...)
{
    UseMethod("import_series", symbol_spec)
}

import_series.symbol_spec <-
function(symbol_spec, ...)
{
    NextMethod(object = symbol_spec)
}


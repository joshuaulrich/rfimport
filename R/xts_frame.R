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

#' Make an xts object from a multiple_ohlc object
#'
#' This function extracts a single column from each symbol in a multiple_ohlc
#' object.
#'
#' @param multi_ohlc A \code{multiple_ohlc} object.
#' @param column Column to extract for each symbol.
#' @param \dots Not currently used.
#'
#' @return An object of class \code{xts}.
#'
#' @author Joshua Ulrich
#' @examples
#'
#' \dontrun{
#'     tickers <- sym_yahoo(c("AAPL", "NFLX"))
#'     ohlc <- import_ohlc(tickers)
#'     prices <- make_xts_frame(ohlc, "close")
#' }
#'
make_xts_frame <-
function(multi_ohlc, column = "close", ...)
{
    # TODO: this should be more general, so users can extract any column from
    #   any type of multi-symbol object. But that means we need something like
    #   a multi-symbol class.
    get_price <-
        switch(column,
               "open"     = quantmod::Op,
               "high"     = quantmod::Hi,
               "low"      = quantmod::Lo,
               "close"    = quantmod::Cl,
               "adjusted" = quantmod::Ad,
               "volume"   = quantmod::Vo
               )

    result <- do.call("merge", lapply(multi_ohlc, get_price))
    colnames(result) <- names(multi_ohlc)

    return(result)
}

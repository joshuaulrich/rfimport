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

`[.ohlc_collection` <-
function(x, i)
{
    result <- NextMethod(.Generic)
    structure(result, class = "ohlc_collection")
}

c.ohlc_collection <-
function(...)
{
    # TODO: check for the same symbols in '...'
    result <- unlist(list(...), recursive = FALSE, use.names = TRUE)
    structure(result, class = "ohlc_collection")
}

print.ohlc_collection <-
function(x, ..., n = 5)
{
    for (nm in names(x)) {
        y <- x[[nm]]
        nry <- NROW(y)
        ncy <- NCOL(y)
        ibeg <- seq.int(1L, n, 1L)
        iend <- seq.int(nry-n+1L, nry, 1L)

        if (nry > (n*2+1)) {
            index_str <- as.character(index(y))
            index_str <- c(index_str[ibeg],
                           "...",
                           index_str[iend])

            ybeg <- y[ibeg,]
            yend <- y[iend,]
            out <- rbind(data.frame(ybeg),
                         matrix(NA, 1L, ncy, dimnames = list("...", colnames(y))),
                         data.frame(yend))

            out <- data.frame(` ` = rownames(out), out, check.names = FALSE)
            out <- capture.output(print(out, row.names = FALSE))
            # n+2 to account for column names in first element
            out[n+2] <- gsub("NA", "  ", out[n+2], fixed = TRUE)
            # remove leading space to match print.xts()
            out <- sub("^ ", "", out)
        } else {
            out <- capture.output(print(data.frame(y)))
        }

        cat(nm, "\n")
        write(out, "")
        cat("\n")
    }
    invisible(x)
}

head.ohlc_collection <-
function(x, n = 6, ...)
{
    lapply(x, function(.) head(., n = n))
}

tail.ohlc_collection <-
function(x, n = 6, ...)
{
    lapply(x, function(.) tail(., n = n))
}

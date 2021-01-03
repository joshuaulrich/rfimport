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

print.multiple_ohlc <-
function(x, ..., n = 5)
{
    for (y in x) {
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

        write(out, "")
        cat("\n")
    }
}

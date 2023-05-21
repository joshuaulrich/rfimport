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

# external API for creating new import methods
.api <- new.env()

local({

    ### FIXME: add argument to control whether the result should be a date or datetime
    parse_iso8601_interval <-
    function(datetime)
    {
        if (is.null(datetime)) {
            result <- list(start = Sys.Date() - 365,
                           end = Sys.Date())
        } else {
            result <- xts::.parseISO8601(datetime)
            result <- setNames(lapply(result, as.Date), c("start", "end"))
        }

        if (is.na(result$start)) {
            result$start <- as.Date("1900-01-01")
        }

        if (is.na(result$end)) {
            result$end <- as.Date("2299-12-31")
        }

        return(result)
    }

    parse_period <-
    function(period = NULL)
    {
        if (is.null(period)) {
            return(NULL)
        }

        period <- trimws(period)[1L]

        if (grepl("^[[:digit:]]", period)) {
            # starts with a digit; may or may not have a space
            pattern <- "^([[:digit:]]+)[[:space:]]*([[:alpha:]]+)*$"

            n <- gsub(pattern, "\\1", period)
            n <- as.numeric(n)

            unit <- gsub(pattern, "\\2", period)
            if (nchar(unit) < 1) {
                stop("could not determine units of period (", period, ")")
            }
        } else {
            n <- 1
            unit <- period
        }

        # special cases and abbreviations
        unit <-
            switch(unit,
                   ns = "nanoseconds",
                   us = "microseconds",
                   ms = "milliseconds",
                   secs = "seconds",
                   mins = "minutes",
                   hourly = "hours",
                   daily = "days",
                   monthly = "months",
                   quarterly = "quarters",
                   yearly = "years",
                   unit)

        valid_units <-
            c("ticks",
              "nanoseconds",
              "microseconds",
              "milliseconds",
              "seconds",
              "minutes",
              "hours",
              "days",
              "weeks",
              "months",
              "quarters",
              "years")

        unit_n <- pmatch(unit, valid_units, 0)
        if (unit_n < 1) {
            stop("\nperiod units should be one of:\n    ",
                 paste(valid_units, collapse = ", "))
        }
        std_unit <- valid_units[unit_n]

        list(n = n, units = std_unit)
    }

    match_periodicity <-
    function(periodicity, values)
    {
        value <- parse_period(periodicity)
    }

}, envir = .api)

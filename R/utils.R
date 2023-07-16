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

.drop_attributes <-
function(x)
{
    attributes(x) <- NULL
    x
}

.remove_colname_symbol <-
function(object, remove_prefix = TRUE)
{
    if (remove_prefix) {
        look_ahead_for_anything_followed_by_period <- "(?!(.|\n)*\\.)"

        group_of_everything_before_first_period <- "(.*)\\."
        group_of_everything_after_last_period <-
            paste0("(", look_ahead_for_anything_followed_by_period,
                   ".*$)")

        pattern <-
            paste0(group_of_everything_before_first_period,
                   group_of_everything_after_last_period)

        # set colnames to everything after last period
        colnames(object) <- gsub(pattern, "\\2", colnames(object), perl = TRUE)
    }
    return(object)
}

# local copy of function
parse_period <- rfimport:::.api$parse_period

make_case <- function(n, u) { list(n = n, units = u) }

run_test_cases <-
function(test_cases)
{
    for (case_name in names(test_cases)) {
        case <- test_cases[[case_name]]
        p <- parse_period(case_name)
        expect_identical(p, case, info = case_name)

        CASE_NAME <- toupper(case_name)
        P <- parse_period(CASE_NAME)
        expect_identical(p, case, info = CASE_NAME)
    }
    invisible(NULL)
}

###########################################################################
# Ticks

tick_cases <-
  list("tick"  = make_case(1, "ticks"),
       "ticks" = make_case(1, "ticks"))
### TODO: any number with 'ticks' should be an error

###########################################################################
# Nanos

nanosecond_cases <-
  list("nanosecond"    = make_case(1, "nanoseconds"),
       "nanoseconds"   = make_case(1, "nanoseconds"),
       "2 nanosecond"  = make_case(2, "nanoseconds"),
       "2 nanoseconds" = make_case(2, "nanoseconds"),
       "2 nanos"       = make_case(2, "nanoseconds"),
       "2 nano"        = make_case(2, "nanoseconds"),
       "2nanosecond"   = make_case(2, "nanoseconds"),
       "2nanoseconds"  = make_case(2, "nanoseconds"),
       "2nanos"        = make_case(2, "nanoseconds"),
       "2nano"         = make_case(2, "nanoseconds"))

run_test_cases(nanosecond_cases)

###########################################################################
# Micros

microsecond_cases <-
  list("microsecond"    = make_case(1, "microseconds"),
       "microseconds"   = make_case(1, "microseconds"),
       "2 microsecond"  = make_case(2, "microseconds"),
       "2 microseconds" = make_case(2, "microseconds"),
       "2 micros"       = make_case(2, "microseconds"),
       "2 micro"        = make_case(2, "microseconds"),
       "2microsecond"   = make_case(2, "microseconds"),
       "2microseconds"  = make_case(2, "microseconds"),
       "2micros"        = make_case(2, "microseconds"),
       "2micro"         = make_case(2, "microseconds"))

run_test_cases(microsecond_cases)

###########################################################################
# Millis

millisecond_cases <-
  list("millisecond"    = make_case(1, "milliseconds"),
       "milliseconds"   = make_case(1, "milliseconds"),
       "2 millisecond"  = make_case(2, "milliseconds"),
       "2 milliseconds" = make_case(2, "milliseconds"),
       "2 millis"       = make_case(2, "milliseconds"),
       "2 milli"        = make_case(2, "milliseconds"),
       "2millisecond"   = make_case(2, "milliseconds"),
       "2milliseconds"  = make_case(2, "milliseconds"),
       "2millis"        = make_case(2, "milliseconds"),
       "2milli"         = make_case(2, "milliseconds"))

run_test_cases(millisecond_cases)

###########################################################################
# Seconds

second_cases <-
  list("second"    = make_case(1, "seconds"),
       "seconds"   = make_case(1, "seconds"),
       "sec"       = make_case(1, "seconds"),
       "secs"      = make_case(1, "seconds"),
       "2 second"  = make_case(2, "seconds"),
       "2 seconds" = make_case(2, "seconds"),
       "2 s"       = make_case(2, "seconds"),
       "2 sec"     = make_case(2, "seconds"),
       "2 secs"    = make_case(2, "seconds"),
       "2second"   = make_case(2, "seconds"),
       "2seconds"  = make_case(2, "seconds"),
       "2s"        = make_case(2, "seconds"),
       "2sec"      = make_case(2, "seconds"),
       "2secs"     = make_case(2, "seconds"))

run_test_cases(second_cases)

###########################################################################
# Minutes

minute_cases <-
  list("min"       = make_case(1, "minutes"),
       "mins"      = make_case(1, "minutes"),
       "minute"    = make_case(1, "minutes"),
       "minutes"   = make_case(1, "minutes"),
       "2 min"     = make_case(2, "minutes"),
       "2 minute"  = make_case(2, "minutes"),
       "2 minutes" = make_case(2, "minutes"),
       "2min"      = make_case(2, "minutes"),
       "2mins"     = make_case(2, "minutes"),
       "2minute"   = make_case(2, "minutes"),
       "2minutes"  = make_case(2, "minutes"))

run_test_cases(minute_cases)

###########################################################################
# Hours

hour_cases <-
  list("hour"    = make_case(1, "hours"),
       "hours"   = make_case(1, "hours"),
       "hr"      = make_case(1, "hours"),
       "hrs"     = make_case(1, "hours"),
       "2 hour"  = make_case(2, "hours"),
       "2 hours" = make_case(2, "hours"),
       "2 h"     = make_case(2, "hours"),
       "2hour"   = make_case(2, "hours"),
       "2hours"  = make_case(2, "hours"),
       "2hr"     = make_case(2, "hours"),
       "2hrs"    = make_case(2, "hours"),
       "2h"      = make_case(2, "hours"))

run_test_cases(hour_cases)

###########################################################################
# Days

day_cases <-
  list("day"    = make_case(1, "days"),
       "days"   = make_case(1, "days"),
       "5 day"  = make_case(5, "days"),
       "5 days" = make_case(5, "days"),
       "5 d"    = make_case(5, "days"),
       "5day"   = make_case(5, "days"),
       "5days"  = make_case(5, "days"),
       "5d"     = make_case(5, "days"))

run_test_cases(day_cases)

###########################################################################
# Weeks

week_cases <-
  list("week"    = make_case(1, "weeks"),
       "weeks"   = make_case(1, "weeks"),
       "wks"     = make_case(1, "weeks"),
       "1wk"     = make_case(1, "weeks"),
       "4 week"  = make_case(4, "weeks"),
       "4 weeks" = make_case(4, "weeks"),
       "4 wks"   = make_case(4, "weeks"),
       "4 w"     = make_case(4, "weeks"),
       "4week"   = make_case(4, "weeks"),
       "4weeks"  = make_case(4, "weeks"),
       "4wks"    = make_case(4, "weeks"),
       "4w"      = make_case(4, "weeks"))

run_test_cases(week_cases)

###########################################################################
# Months

month_cases <-
  list("month"    = make_case(1, "months"),
       "months"   = make_case(1, "months"),
       "mons"     = make_case(1, "months"),
       "mos"      = make_case(1, "months"),
       "3 month"  = make_case(3, "months"),
       "3 months" = make_case(3, "months"),
       "3 mons"   = make_case(3, "months"),
       "3 mon"    = make_case(3, "months"),
       "3 mos"    = make_case(3, "months"),
       "3 mo"     = make_case(3, "months"),
       "3month"   = make_case(3, "months"),
       "3months"  = make_case(3, "months"),
       "3mons"    = make_case(3, "months"),
       "3mon"     = make_case(3, "months"),
       "3mos"     = make_case(3, "months"),
       "3mo"      = make_case(3, "months"))

run_test_cases(month_cases)

###########################################################################
# Quarters

quarter_cases <-
  list("quarter"    = make_case(1, "quarters"),
       "quarters"   = make_case(1, "quarters"),
       "qtrs"       = make_case(1, "quarters"),
       "qtr"        = make_case(1, "quarters"),
       "4 quarter"  = make_case(4, "quarters"),
       "4 quarters" = make_case(4, "quarters"),
       "4 qtrs"     = make_case(4, "quarters"),
       "4 qtr"     = make_case(4, "quarters"),
       "4 q"        = make_case(4, "quarters"),
       "4quarter"   = make_case(4, "quarters"),
       "4quarters"  = make_case(4, "quarters"),
       "4qtrs"      = make_case(4, "quarters"),
       "4qtr"      = make_case(4, "quarters"),
       "4q"         = make_case(4, "quarters"))

run_test_cases(quarter_cases)

###########################################################################
# Years

year_cases <-
  list("year"     = make_case(1, "years"),
       "years"    = make_case(1, "years"),
       "yrs"      = make_case(1, "years"),
       "yr"       = make_case(1, "years"),
       "annually" = make_case(1, "years"),
       "5 year"   = make_case(5, "years"),
       "5 years"  = make_case(5, "years"),
       "5 yrs"    = make_case(5, "years"),
       "5 yr"     = make_case(5, "years"),
       "5 y"      = make_case(5, "years"),
       "5year"    = make_case(5, "years"),
       "5years"   = make_case(5, "years"),
       "5yrs"     = make_case(5, "years"),
       "5yr"      = make_case(5, "years"),
       "5y"       = make_case(5, "years"))

run_test_cases(year_cases)

###########################################################################
# Special cases

# "ly" suffixes
ly_cases <-
  list("hourly"    = make_case(1, "hours"),
       "daily"     = make_case(1, "days"),
       "weekly"    = make_case(1, "weeks"),
       "monthly"   = make_case(1, "months"),
       "quarterly" = make_case(1, "quarters"),
       "yearly"    = make_case(1, "years"))

run_test_cases(ly_cases)

# Errors for 'm', 'mi'
expect_error(parse_period("m"), pattern = "'m' is ambiguous")
expect_error(parse_period("mi"), pattern = "'mi' is ambiguous")

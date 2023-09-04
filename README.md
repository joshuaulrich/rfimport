---
title: "rfimport: getSymbols Rebooted"
author: Joshua Ulrich
date: March 03, 2023
geometry: "left=2cm,right=2cm,top=2cm,bottom=2cm"
output: pdf_document
---

# Background and Motivation

The quantmod package has been a core part of the R/Finance ecosystem for over 15 years. It's awesome that the package is so popular, but that also comes with responsibility to maintain backward compatibility. Breaking changes may break code used for making business decision, research, blog posts, books, courses, answers on [stackoverflow](https://stackoverflow.com), and much more. We take this responsibility seriously, and do our best to keep functions backward compatible. Sometimes breaking changes are necessary (e.g. bug fixes, changes to external data sources, etc.), but we do our best to make them carefully, with plenty of warning and lead time for users to adjust their code.

There are things in quantmod that we want to change, but they would certainly break existing code. No matter how much we'd like to make those changes, we can't justify breaking a large portion of the code our community has written in the past 15+ years.

Introducing the "rfimport" package. It is a place to work on new implementations that improve on the pieces in `getSymbols()` that we would like to change. This code is *extremely alpha*. This is the time to provide feedback, suggestions, feature requests, etc. Know that we will break things, maybe without warning. You should consider the API unstable until the 1.0.0 release.

## How the Old `getSymbols()` Works

By default `getSymbols()` creates objects for each `Symbol` in the environment it's called from, and it returns the value of the `Symbol` argument. It's generally good practice for functions to avoid changing anything in the user's environment (this is called having side-effects). It's better for functions to only return a value, like `getSymbols(..., auto.assign = FALSE)` does. `getSymbols()` does not support `auto.assign = FALSE` for more than one symbol.

`getSymbols()` also uses functionality that was formerly provided by the archived [Defaults](https://cran.r-project.org/package=Defaults) package. This functionality to allow users to set default values for `getSymbols()` source method arguments. This is also a side-effect because it makes `getSymbols()` depend on something other than its argument values.

`getSymbols()` specifies the data sources via its `src` argument. Then `getSymbols()` uses the `src` argument to determine which source method to use (e.g. `getSymbols("SPY", src = "yahoo")` will call `getSymbols.yahoo("SPY")` behind the scenes. This is essentially method dispatch, but done manually rather than using R's built-in S3 functionality.


# What We've Learned

* We should avoid the side-effect of creating objects in the calling environment.
* We can use S3 method dispatch instead of creating `getSymbols()` source methods.
* Stock ticker symbology is a pain and we need a better way to handle it.
* We need a way to provide functionality like the Defaults package did, but without side-effects.

## Automatically Creating Objects

`getSymbols()` creates an object for every value in the `Symbols` argument. This isn't an issue for a few symbols, but it clutters the environment when there are several hundred symbols. You can load all the symbols into a separate environment, but that's not a pattern most users are familiar with.

We wanted to remove the ability to load objects into the calling environment, and even created a warning about changing `auto.assign = FALSE` as the default for `getSymbols()` and recommending users replace their `getSymbols()` call with the `loadSymbols()` function that already existed. But we ultimately decided breaking the community's code wasn't worth it.

Automatically creating objects makes it cumbersome to put prices for all symbols into one object. This is a common use case and there are several steps. It should be possible with one or two function calls. Here's an example.

```r
symbols <- c("SPY", "AAPL")
getSymbols(symbols)

# Put all the prices into one xts object,
prices <- do.call(merge, lapply(symbols, get))
# or
prices <- do.call(merge, mget(symbols))

# Extract only the Close prices
close_prices <- Cl(prices)

# Remove ".Close" suffix so close_prices[, "SPY"] works
colnames(close_prices) <- sub(".Close", "", colnames(close_prices))

head(prices[, symbols[1]])
```

Automatically creating objects also makes passing all the data to another function awkward. It causes users to do things like:

* Call `getSymbols()` in any function that needs data, which may mean the same data is imported multiple times.
* Pass the same `symbols` object to `getSymbols()` and the other function. Then the other function searches through environments to find the objects named with those `symbols`.
* Users could put all the data in an environment and use that as an argument to the function, but I haven't seen many people use this pattern.

The lesson: a function that imports data should *return* the data like a normal R function, without using or creating side-effects.

Returning an object means we need a way to return multiple series in one object (e.g. a list). Returning one object also avoids the issue where the symbol is not a valid R object name (e.g. `getSymbols("^DJI")` creates an object named `DJI`). More on that later.

## Source methods

Different `getSymbols()` source methods can (or may need to) have different arguments. Ideally the source methods wouldn't be exported because users shouldn't call them directly, like `getSymbols.yahoo("SPY")`. Not being exported makes it hard to find the help page for them, which means it's hard to know what arguments are available for various source methods.

The source methods are named like S3 methods even though `getSymbols()` isn't a generic function and the source methods aren't actual S3 methods. This has the potential to create odd behavior that would confuse users.

## Ticker Symbology

There are two major issues with ticker symbols.

1. Exchanges and data providers sometimes use different ticker symbols for the same security.
1. Some ticker symbols are not valid R object names.

Another issue is when the ticker symbol is similar to the name of one of the price columns. This has come up several times with Lowe's (LOW). The `Lo()` and `OHLC()` functions think all of the columns with the ticker symbol in the column name are the low price for the period.

### Same Security, Different Ticker

This isn't `getSymbols()`'s fault and it's out of our control, but it needs to be handled better. Exchange and data source symbology is awful. Identifiers for the same series are often different across exchanges and data providers. For example: the symbol for Berkshire Hathaway B-class shares is "BRK-B" for Yahoo Finance, "BRK/B" for the SIP (Securities Information Processor), "BRK B" for ICE, and probably "BRK.B" somewhere else.

### Invalid R Object Names

`getSymbols()` tries to create objects with valid R names, but only does so for *some* symbols that aren't valid R object names. For example, `BRK-B`, `BRK B`, and `BRK/B` aren't valid R objects names because valid names start with a letter or a dot (period), and can only contain letters, numbers, a dot, or an underscore.

Here are some common examples of ticker symbology woes:

`^DJI` isn't a valid R object name because it starts with `^`. So `getSymbols()` creates an object with the `^` removed. But then you can't use the code below to put all the prices into one object. Also notice that `getSymbols()` *returns* `"^DJI"` even though it creates an object with a different name.

```r
symbols <- c("^DJI", "BRK-B")
getSymbols(symbols)
## [1] "^DJI" "BRK-B"

prices <- do.call(merge, mget(symbols))
## Error: value for '^DJI' not found
```

You have to remove the leading `^` manually. And you have to set `fixed = TRUE` in the call to `sub()` because `^` is a special character in regular expressions. *Sigh*.

```r
prices <- do.call(merge, mget(sub("^", "", symbols, fixed = TRUE)))
```

Recall that `BRK-B` also isn't a valid R name because of the `-`. But it wasn't an issue in the code above because `getSymbols()` made an object named `BRK-B`, not an object with a valid R name. This is confusing for users because they can't easily access that object (i.e. `head(BRK-B)` is an error). This is a pervasive issue for several foreign exchanges with tickers that begin with numbers (e.g. `000001.SZ`).

Another issue with symbols that aren't valid R object names is that many R functions will convert column names into valid R object names, including `merge.xts()`. So you can't use the input symbol to subset the resulting xts object. Here's an example:

```r
# Extract the close prices and remove ".Close" suffix
close_prices <- Cl(prices)
colnames(close_prices) <- sub(".Close", "", colnames(close_prices))

# Extract the close price for "BRK-B"
close_prices[, "BRK-B"]
## Error in `[.xts`(close_prices, , "BRK-B") : subscript out of bounds
colnames(close_prices)
## [1] "DJI"   "BRK.B"
```

`setSymbolLookup()` exists to help with things like this, but it's another function users have to learn to use and my experience is that most users don't know about `setSymbolLookup()`. I just had to look at the source to figure out how to use it to make `getSymbols()` return a valid R object for `"BRK-B"`.

```r
setSymbolLookup(BRK.B = list(name = "BRK-B", src = "yahoo"))
```

If I have to look at the source code to figure out how to do this, users don't have a chance. You may think, "but you could document how to do this", but writing documentation isn't fun. And who reads the documentation anyway? ;-)

## Defaults Functionality

The "Defaults" functionality in quantmod comes from the archived Defaults package. This functionality allows users to set new default argument values to any `getSymbols()` source function. This is helpful because it makes importing easier. But it means `getSymbols()` relies on something other than its parameter values, and it's good practice to avoid side-effects like this.

This gave users the ability to set preferences like return class, periodicity (e.g. hourly, daily, monthly), connection settings (e.g. credentials, API keys).

# 'rfimport' Design and Features

The design of 'rfimport' is influenced by the [`DBI`](https://cran.r-project.org/web/packages/DBI/index.html) package, which provides a set of generic 'database interface' functions. Users create connection objects by creating a 'driver' object for the specific database and passing that to `dbConnect()`. Then you pass that connection object to the other `DBI` functions. For example, to query an execute a statement for a PostgreSQL database:

```r
library(RPostgreSQL)

driver <- PostgreSQL()
conn <- DBI::dbConnect(driver)
student_count <- DBI::dbGetQuery(conn, "select count(*) from students")

# Add a new student
new_student <- "Robert'); DROP TABLE students;--"
DBI::dbExecute(conn,
    "INSERT INTO students (name) VALUES ('?');",
    params = list(new_student))
```

To import data using 'rfimport':

```r
library(rfimport)

# The sym_* functions are a combination of the
# driver, connection, and query in DBI
syms <- sym_yahoo("SPY")

# Import some data from Yahoo Finance
spy <- import_ohlc(syms)
```

### Symbol Specification

The package introduces a new virtual S3 class `"symbol_spec"` as the basis for creating sub-classes that hold all necessary information to connect to a data source. This virtual class allows users to combine symbols from different data sources into a single vector. For example: `import_ohlc_collection(c(sym_yahoo("SPY"), sym_tiingo("DIA")))` will import data for "SPY" from [Yahoo Finance](https://finance.yahoo.com/) and data for "DIA" from [Tiingo](https://www.tiingo.com/).

Each data source will have its own `symbol_spec` constructor. The constructor will have an argument for the vector of symbols and other arguments for all the other data source connection settings. It will return an object that inherits from the new virtual `symbol_spec` For example `sym_yahoo()` will return a `c("yahoo", "symbol_spec")` class vector.

The help page for the symbol spec constructors can also document the import methods that the data source supports. So `help("sym_yahoo")` would also contain information about `import.yahoo()` and `import_collection.yahoo()`.

#### Ticker Symbology

The package would standardize how index tickers are specified. One possibility is to prefix the ticker with an 'i' or 'i_' (e.g. "iDJI" or "i_DJI").

It would also standardize how to specify share classes, warrants, preferred, etc. One possibility is to use an underscore to identify share classes, a lowercase 'w' for warrants, and a lowercase 'p' for preferred. For example, "BRK_B" for Berkshire Hathaway B shares, "FOOw" for warrants, "BARp" for preferred. We could also include a translation table and/or function.

It could also provide a way to map source symbols to user-defined values. It makes the most sense to do this is the `sym_<source>()` constructor. But how set and store the mapping? Some possibilities:

* `sym_yahoo(BRK.B = list(symbol = "BRK-B"))`
* `sym_yahoo(c(BRK.B = "BRK-B", "DIA"))`
* `sym_yahoo(c("BRK.B", "DIA"), sym_db = list(BRK.B = "BRK-B"))`

### Import Functions

#### Generics

The package will have generic functions `import()` and `import_collection()` to dispatch on `symbol_spec` sub-classes. `import_collection()` will return a list of xts objects for one or more symbols. `import()` only handles a single symbol and returns one xts object. Other generic import functions may be added in the future.

The generics will have a `symbol_spec`, `dates`, `...`, and `periodicity` arguments, in that order. `dates` can be either an ISO 8601 date interval (e.g. `dates = "2021-01-01/2021-12-31"`) or a two-element vector with the start and end dates (e.g. `dates = c("2021-01-01", "2021-12-31")`). The vector can be Date, POSIXct, or a character that is coercible to one of those two classes.

For example:

```r
spy <- import(sym_yahoo("SPY"), dates = "2021/2022")
str(spy)

stocks <- sym_tiingo(c("AAPL", "NFLX")) |>
    import_collection(dates = "2021-03-01/2022-11-31")
str(stocks)
```

The package may also include generic `import` functions that return specific types of data. Particularly `import_ohlc()` for open, high, low, close, (adjusted, volume), and `import_bbo()` for best bid and offer.

#### Periodicity

The `periodicity` argument specifies the interval between data points (e.g. daily, monthly, 15-minute). The data source determines the possible periodicity values, so they're responsible for ensuring the requested periodicity value is available from the data source. 'rfimport' will provide a standard way to specify the periodicity values. Then the source methods can translate those values into the value source needs. For example, one data source may use "monthly" for monthly data and another may use "months". Users would set `periodicity = "months"` for either source and the source method would translate the value to "monthly", if necessary.

#### Source Methods

Each data source will have a S3 method for the relevant import generics, rather than a `src` argument like `getSymbols()`. Calling `import(sym_yahoo("SPY"))` will call the corresponding `import.yahoo()` method to import data from Yahoo Finance.

#### Returned Data

The built-in `import()` methods will automatically include dividends and splits (when available) when importing daily OHLCV data. They will be included as attributes on the returned OHLCV object. This will allow users to switch between adjusted and unadjusted prices without having to re-download the data.

They also will not include the series symbol in the OHLCV column names like `getSymbols()` currently does. It may make sense to include an attribute with the "source symbol" (e.g. "^DJI") and the "R symbol" (e.g. "DJI") on the returned xts object. Then that attribute can be used later if it makes sense as (part of) a column name.

### Providing "Defaults" Functionality

Though we want to avoid side-effects, we probably want to provide a way to set credentials so they do not have to be provided for every import call.

We could provide this functionality in a pure way by creating an `options` object that holds a list of values. Users would create this object once and pass it to the relevant 'rfimport' function (either `sym_<source>()` or `import()`). The default options could be created by a function like `sym_<source>_options()`. This would be similar to the 'control' arguments to many optimization routines (e.g. `DEoptim.control()`).

# Open Questions and Considerations

## How should we specify the class of the returned object? Some possibilities:

* Set it via a `return_class` argument in the `symbol_spec` constructor
    * PRO: each source is likely to have a specific data structure, and it wouldn't require creating a generic `import` function for each return type.
    * CON: allows the potential for one call to an `import_*_collection()` function to return a list of heterogeneous objects.

* Set it via a `return_class` argument in the `import` method
    * PRO: the method would return a list of objects that are all the same class.
    * CON: the generic and/or the default `import` method would need a `return_class` argument.

* Create a new generic `import` functions for each return class
    * PRO: makes it clear what the `import` function returns.
    * CON: namespace clutter, don't want generics for *every* class. Possibly provide generics for most widely used non-xts classes: data.frame, data.table, tibble, tsibble.

* The symbol specification can store a function that controls what data is returned. Not sure I like that because it adds complexity and the user can call that function after the data is returned. For example: `sym_yahoo("SPY", return_func = as.data.table)`.

## How can we make it easier to manipulate results?

It should be easier to manipulate returned data for common use cases.

The most common use case is making a wide xts object with close prices from a list of xts objects. This currently requires several steps that are likely unfamiliar to most users. It should be possible with one or two function calls. We can consider Garrett See's [qmao](https://github.com/gsee/qmao) package for inspiration. For example, use 'price frames' to replace `do.call(merge, list_of_objects_from_getSymbols)`

There are lots of other common manipulations, like aggregating to a higher periodicity or applying a function to many symbols' data. The import functions will return something list-like, so users can use `lapply()` to apply any other function to each series.

## Should we create new data types?
<!-- should this section even be included? -->

Should we create a new package with new classes for financial market data?

It would allow us to use functions like `Cl()`, `OHLC()`, etc. in packages that depend on each other. This is an issue in TTR. It can't use these functions because quantmod depends on TTR (so TTR can't depend on quantmod).

We could also create methods for these classes to do common tasks. For example: create an xts object of close prices from a list of OHLC xts objects, or calculate weighted midpoint from BBO data.

Data for each symbol would be stored separately, so column names wouldn't need to use the "Symbol.Data" pattern.

The `import()` methods could return the new class instead of a plain list. The new class also provides an opportunity to re-consider how the data is stored and how extractor functions (e.g. `Cl()`) work. We could also create some setter functions (e.g. `Cl<-`).


<!--
Feedback to incorporate

-----
Jim


Background and motivation
* Introducing the package needs better transition
     "Because of these things..."

Make it clear that 'alpha' means I'm looking for community feedback. Many sections have several possible solutions to problems and features and I need input in order to make an informed decision.

What we've learned
* Say we're going to cover each bullet in the sections

Automatically Creating Objects
* again, better transition
     "The lesson: we need a new function to import the data..."

Source methods
Give an example of different arguments, e.g. api.key

-----

Ethan:

ES: (currently embedded in the design section, not listed as an issue) the current prefix/suffix stuff is really useful for interactive or "wide" data structures, but very cumbersome for generic functions and "long" data structures. The Cl,Op, etc function help with this, but the run into issues in edge cases (like open or close in the symbol name). Ideally give optionality for callers on this.

JU: Not sure what you mean here. I plan on removing the OHLC suffixes when the xts objects are in a list. Then I'd like to have a function that combines some/all of the columns of the objects in the list into a single 'wide' object. The 'wide' object column names would be the symbols... but I guess that only works for a single column from the list of objects. Maybe we need to keep the suffix if we extract more than one column.

ES:
1. This should get proper treatment in the issues section
2. Agree that long structure should default to no symbol prefix
3. Conversion from long to wide should add a symbol prefix. Maybe allow for special case of removing existing column as the suffix, but I wouldn't make this the default for consistent behavior
4. The data.table `dcast()` and `melt()` functions handle this well

-->


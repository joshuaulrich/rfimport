---
title: "rfimport: getSymbols Rebooted"
author: Joshua Ulrich
date: March 03, 2023
geometry: "left=2cm,right=2cm,top=2cm,bottom=2cm"
output: pdf_document
---

## Background and Motivation

The quantmod package has been a core part of the R/Finance ecosystem for over a decade. It's awesome that the package is so popular, but that also comes with responsibility to maintain backward compatibility. Breaking changes may break code used for production, research, blog posts, examples in books, answers on [stackoverflow](https://stackoverflow.com), and more. We take this responsibility seriously, and do our best to keep functions backward compatible. Sometimes breaking changes are necessary (e.g. bug fixes, changes to external data sources, etc.), but we do our best to make them carefully, with plenty of warning and lead time for users to adjust their code.

There are things in quantmod that we want to change, but they would certainly break existing code. No matter how much we'd like to make those changes, we can't justify breaking a large portion of the code our community has written over 10+ years.

Enter the "rfimport" package. It will be a place to test alternative implementations that improve on the pieces in `getSymbols()` that we would like to change. This code is *extremely alpha*. This is the time to provide feedback, suggestions, feature requests, etc. Know that we will break things, maybe without warning. You should consider the API unstable until the 1.0.0 release.


## Refresher On How `getSymbols()` Works

By default `getSymbols()` creates objects for each `Symbol` in the environment it's called from, and it returns the value of the `Symbol` argument. It's generally good practice for functions to avoid changing anything in the user's environment (this is called having side-effects). It's better for functions to only return a value, like `getSymbols(..., auto.assign = FALSE)` does. `getSymbols()` does not support `auto.assign = FALSE` for more than one symbol.

It also uses "Defaults" functionality to allow users to set default values for `getSymbols()` "method" parameters. This is also a side-effect because it means `getSymbols()` relies on something other than parameter values.

`getSymbols()` specifies the data sources via its `src` argument. Then `getSymbols()` uses the `src` argument to determine which "method" to use (e.g. `getSymbols("SPY", src = "yahoo")` will call `getSymbols.yahoo("SPY")` behind the scenes. This is essentially method dispatch, but done manually rather than using R's built-in S3 functionality.


## Stuff We've Learned

1. Automatically creating objects in the calling environment creates some pain points.

    * Clutters the global environment with an object for every symbol. This isn't an issue for a few symbols, but becomes a problem with several hundred symbols. You can load all the symbols into a separate environment, but that's not a usage pattern most users are familiar with.
    
    * Requires several steps to put prices for all symbols into one object. This is a common use case and there are a lot of steps. It should be possible with one or two function calls.
    
        ```r
            symbols <- c("SPY", "AAPL")
            getSymbols(symbols)
            
            # put all the prices into one xts object
            prices <- do.call(merge, lapply(symbols, get))
            # or
            prices <- do.call(merge, mget(symbols))
            
            # extract only the Close prices
            close_prices <- Cl(prices)
            
            # remove ".Close" suffix so close_prices[, "SPY"] works
            colnames(close_prices) <- sub(".Close", "", colnames(close_prices))
            
            head(prices[, symbols[1]])
        ```

    * Passing all the data to another function isn't straight-forward. It makes users do things like:
        * Call `getSymbols()` in any function that needs data, which may mean the same data is imported multiple times.
        * Pass the same `symbols` object to `getSymbols()` and the other function. Then the other function searches through environments to find the objects with named with those `symbols`.
        * Users could put all the data in an environment and use that as an argument to the function, but I haven't seen users do this in the wild.

We wanted to change this, and even created a warning about changing `auto.assign = FALSE` as the default for `getSymbols()` and suggesting users replace their `getSymbols()` call with the `loadSymbols()` function that already existed. But we ultimately decided breaking the community's code wasn't worth it.
    * The function that imports the data should *return* the data like a normal R function, without side-effects. This means we need a way to return the data for multiple series.
    * This avoids the issue where the symbol is not a valid R object name (e.g. `getSymbols("^DJI") -> DJI`). More on that later.

#### Source "methods"

1. Different `getSymbols()` "methods" can (or may need to) have different arguments. Ideally the "methods" wouldn't be exported because users shouldn't call them directly (like `getSymbols.yahoo("SPY")`). Not being exported makes it hard to find the help page for them, which means it's hard to know what arguments are available for various "methods".

#### Ticker Symbology

1. This isn't `getSymbols()`'s fault, but it needs to be handled better. Exchange and data source symbology sucks. Identifiers for the same series are often different across exchanges and data providers. For example: the symbol for Berkshire Hathaway B-class shares is "BRK-B" for Yahoo Finance, "BRK.B" for the SIP (Securities Information Processor), and "BRK B" for ICE.

    `getSymbols()` tries to create objects with valid R names, but only does so for *some* symbols that aren't valid R object names. For example, `BRK-B` and `BRK B` aren't valid R objects names because valid names start with a letter or a dot (period), and can only contain letters, numbers, a dot, or an underscore.

    `^DJI` also isn't a valid R object name because it starts with `^`.  So `getSymbols()` creates an object with the `^` removed. But then you can't use the code above to put all the prices into one object. Also notice that `getSymbols()` *returns* `"^DJI"` even though it creates an object with a different name.
    
    ```r
        symbols <- c("^DJI", "BRK-B")
        getSymbols(symbols)
        ## [1] "^DJI" "BRK-B"
        
        prices <- do.call(merge, mget(symbols))
        ## Error: value for '^DJI' not found
    ```
    
    You have to remove the leading `^` manually. And you have to set `sub(..., fixed = TRUE)` because `^` is a special character in regular expressions. *Sigh*.
    
    ```r
        prices <- do.call(merge, mget(sub("^", "", symbols, fixed = TRUE)))
    ```
    
    Recall that `BRK-B` also isn't a valid R name because of the `-`. But it wasn't an issue in the code above because `getSymbols()` made an object named `BRK-B`, not an object with a valid R name. This is confusing for users because they can't easily access that object (i.e. `head(BRK-B)` is an error). This is a pervasive issue for several foreign exchanges with tickers that begin with numbers (e.g. `000001.SZ`).
    
    Another issue with symbols that aren't valid R object names is that many R functions will convert column names into valid R object names, including `merge.xts()`. So you can't use the input symbol to subset the resulting xts object.
    
    ```r
        # extract the close prices and remove ".Close" suffix
        close_prices <- Cl(prices)
        colnames(close_prices) <- sub(".Close", "", colnames(close_prices))
        
        # extract the close price for "BRK-B" 
        close_prices[, "BRK-B"]
        ## Error in `[.xts`(close_prices, , "BRK-B") : subscript out of bounds
        colnames(close_prices)
        ## [1] "DJI"   "BRK.B"
    ```
    
    `setSymbolLookup()` exists to help with things like this, but it's another function users have to learn to use and my experience is that most users don't know about `setSymbolLookup()`. I just had to look at the source to figure out how to use `setSymbolLookup()` to make `getSymbols()` return a valid R object for `"BRK-B"`: `setSymbolLookup(BRK.B = list(name = "BRK-B", src = "yahoo"))`. If I have to look at the source code to figure it out, users don't have a chance. You may think, "but you could document how to do this", but writing documentation isn't fun. And who reads the documentation anyway? ;-)
    
    ```r
        symbols <- c("SPY", "AAPL")
        getSymbols(symbols)
        
        # put all the prices into one xts object
        prices <- do.call(merge, lapply(symbols, get))
        # or
        prices <- do.call(merge, mget(symbols)
        
        # extract only the Close prices
        close_prices <- Cl(prices)
        
        # remove ".Close" suffix so close_prices[, "SPY"] works
        colnames(close_prices) <- sub(".Close", "", colnames(close_prices))
        
        head(prices[, symbols[1]])
        
        raw_symbols <- c("SPY", "AAPL", "^DJI", "BRK-B")
        getSymbols(raw_symbols)
        
        # you have to remove the "^" from DJI because "^DJI" isn't a valid R name
        # and getSymbols() removes it automatically
        symbols <- sub("^", "", raw_symbols, fixed = TRUE)
        
        getSymbols(symbols)
        
        # oops, BRK-B also isn't a valid R name, but getSymbols() didn't it for you,
        # so we have to change it to BRK.B to make it easier to use
        symbols <- sub("-", ".", symbols, fixed = TRUE)
        
        # get the close from each object and put it into a single object
        prices <- Cl(do.call(merge, lapply(symbols, get)))
        
        colnames(prices) <-  sub("-", ".", colnames(prices), fixed = TRUE)
        
        # remove the ".Close" from each column name...
        colnames(prices) <- sub(".Close", "", colnames(prices), fixed = TRUE)
        
        # ... so we can index the columns using `symbols`
        head(prices[, symbols[1]])
    ```

But there are several gotcha's:


### Package Design and Features

1. The 'rfimport' package will not have side-effects like:
    * Loading data into the global environment
    * 'Defaults' functionality: `setDefaults()`, `getDefaults()`, `importDefaults()`, `unsetDefaults()` allows users to set new default argument values to any `getSymbols()` "method". How do we achieve similar functionality in a pure way?
    * `setSymbolLookup()` maps symbols to specific sources, return class, data periodicity, start and end dates, and allow you to map the source symbol to a user defined symbol (e.g. map "BRK-B" to "BRK.B"). Try to make this more 'functional' and 'pure' with fewer side-effects. 

1. The package will also make it easier to manipulate returned data for common use cases.
    * Put all close prices into one object, similar to `do.call(merge, lapply(e, Cl))`. This is a common use case and there are a lot of steps to remember. It should be possible with one or two function calls.
    * We should consider Garrett See's [qmao](https://github.com/gsee/qmao) package for inspiration.
    * For example, use 'price frames' to replace `do.call(merge, list_of_objects_from_getSymbols)`

1. It will add a new virtual S3 class (`"symbol_spec"`, symbol specification) as the basis for creating sub-classes that hold all necessary information to connect to a data source.
    * Each data source will have its own `symbol_spec` constructor. The constructor will create a vector of symbols with all the connection information for the data source, and will return an object that inherits from the new virtual `symbol_spec` (symbol specification) class. For example `sym_yahoo()` will return a vector with class `c("yahoo", "symbol_spec")`.

    * This virtual class allows users to combine symbols from different data sources into a single vector. For example: `import_ohlc_collection(c(sym_yahoo("SPY"), sym_tiingo("DIA")))` will import data for SPY from Yahoo Finance and data for DIA from Tiingo.

    * The `symbol_spec` constructor is where users can specify options like:
        * periodicity (e.g. 5 minute, hourly, daily),
        * default values for each symbol requested. For example, you can change "BRK-B" to "BRK.B" via `sym_yahoo(BRK.B = list(symbol = "BRK-B"))`.

1. It will have generic functions `import()` and `import_collection()` to dispatch on `symbol_spec` sub-classes.
    * `import_collection()` will return data for multiple symbols as a list of xts objects. `import()` will return data for a single symbol as a xts object.
    * The generics will have a `symbol_spec` and a `dates` argument. `dates` can be either an ISO 8601 date interval (e.g. `dates = "2021-01-01/2021-12-31"`) or a two-element vector with the start and end dates (e.g. `dates = c("2021-01-01", "2021-12-31")`).
    * Example: `x <- import_collection(sym_yahoo("SPY", "DIA"), dates = "2021/2022")`
    * Other generic import functions may be added in the future.
    * Calling `import(sym_yahoo("SPY"))` will then call the corresponding `import.yahoo()` method. The symbol specification functions are also where you can set default values for each symbol requested. For example, you can change "BRK-B" to "BRK.B" via `sym_yahoo(BRK.B = list(symbol = "BRK-B"))`.
    * Create generic `import` methods for returning single objects and lists of objects:
        * single objects:
            * `import()` any type of data
            * `import_ohlc()` for open, high, low, close, (adjusted, volume)
            * `import_bbo()` for best bid and offer
        * lists of objects, one element per symbol:
            * `import_collection()`
            * `import_ohlc_collection()`
            * `import_bbo_collection()`

* It will use true S3-methods for each data source. `getSymbols()` specifies the data sources via its `src` argument. Then `getSymbols()` uses the `src` argument to determine which "method" to use (e.g. `getSymbols("SPY", src = "yahoo")` will call `getSymbols.yahoo("SPY")` behind the scenes. That's essentially method dispatch, but done manually rather than using R's S3 methods.

* The built-in `import()` methods will automatically include dividends and splits (when available) when importing daily OHLCV data. They will be included as attributes on the returned OHLCV object.

### Open Questions and Considerations

* Should the returned object type should be specified by the `import` functions or by their respective `symbol_spec`?
    * Specifying in `symbol_spec` constructor:
        * Appealing because each source is likely to have a specific data structure, and it wouldn't require creating a generic `import` function for each return type.
        * Allows the potential for one call to an `import_*_collection()` function to return a list of heterogeneous objects, which isn't desirable.
    * Specifying in `import` method:
        * Appealing because the method would return a list of objects that are all the same class.
        * The generic and/or the default `import` method would need a `return_class` argument.
    * Creating new generic `import` functions for each return class.
        * Con: namespace clutter.

* Should the periodicity of the returned object(s) be specified by the `import` method of the `symbol_spec`, or the `symbol_spec` constructor?

* Can the symbol specification control which method is dispatched without requiring a different symbol specification function for every source/periodicity combination?
    * `sym_tiingo("SPY", return_class = "data.table")` dispatches to `import_ohlc.tiingo_data_table()`.
    * The symbol specification can store a function that controls what data is returned. Not sure I like that because it adds complexity and the user can call that function after the data is returned.
    * It makes sense to set the periodicity in the symbol specification output, because different periodicities are often different tables/endpoints, and one `import` method can handle those. We currently warn if a symbol specification function tries to set an attribute to more than one value.

* Should there be a new package with new classes for financial market data?
    * Would allow us to use functions like `Cl()`, `OHLC()`, etc. in packages that depend on each other. This is an issue in TTR. It can't use these functions because quantmod depends on TTR (so TTR can't depend on quantmod).
    * We could create methods for these classes to do common tasks. For example: create an xts object of close prices from a list of OHLC xts objects, or calculate weighted midpoint from BBO data.
    * Data for each symbol could be stored separately, so column names wouldn't need to use the "Symbol.Data" pattern.
    * The `import()` methods could return the new class instead of a plain list. The new class also provides an opportunity to re-consider how the data is stored and how extractor functions (e.g. `Cl()`) work. We could also create some setter functions (e.g. `Cl<-`).

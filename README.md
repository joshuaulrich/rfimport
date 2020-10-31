### About

This is an [R](https://www.r-project.org) package that provides similar functionality to [quantmod](https://cran.r-project.org/package=quantmod), particularly `getSymbols()`.

### Motivation

The quantmod package has been a core part of the R/Finance ecosystem for over a decade. It's awesome that the package is so popular, but that also comes with responsibility to maintain backward compatibility. Breaking changes may break code used for production, research, blog posts, examples in books, answers on [stackoverflow](https://stackoverflow.com), and more. We take this responsibility seriously, and do our best to keep functions backward compatible. Sometimes breaking changes are necessary, and we try to do them carefully, with plenty of warning and lead time for users to adjust.

There are things in quantmod that we want to change, but they would certainly break existing code. No matter how much we'd like to change the code, we can't justify breaking a large portion of the code created over 10+ years that our community has written.

This package is a place to test alternative implementations that improve on the pieces in quantmod that we would like to update. This code is *extremely alpha*. This is the time to provide feedback, suggestions, feature requests, etc. Know that we will break things. Without warning. Or remorse. :D The API will be unstable until the 1.0.0 release.

### Changes

* `getSymbols()` should not load the data into an environment, including the user's global environment. We wanted to change this, and even created a warning about changing `auto.assign = FALSE` as the default for `getSymbols()` and suggesting users replace their `getSymbols()` call with the `loadSymbols()` function that already existed. But we ultimately decided breaking the community's code wasn't worth it.
    * The function that imports the data should *return* the data like a normal R function, without side-effects. This means we need a way to return the data for multiple series.
    * This avoids the issue where the symbol is not a valid R object name (e.g. `getSymbols("^DJI") -> DJI`)

* Returning multiple series from `getSymbols()` may require a new class of data. The new class(es) gives us opportunity to re-consider how the data is stored and how extractor functions (e.g. `Cl()`) work. We could also create some setter functions (e.g. `Cl<-`).

* Consider making a new class / package to hold financial market data, so we can use `Cl()`, `OHLC()`, etc. in packages that depend on each other (e.g. quantmod depends on TTR, so TTR can't use `Cl()` from quantmod).

* We should consider using Garrett See's [qmao](https://github.com/gsee/qmao) for inspiration and suggestions of things to consider.
    * For example, use 'price frames' to replace `do.call(merge, list_of_objects_from_getSymbols)`





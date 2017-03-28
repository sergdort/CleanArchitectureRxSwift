## Welcome to the PEGTL

[![Release](https://img.shields.io/github/release/ColinH/PEGTL.svg)](https://github.com/ColinH/PEGTL/releases/latest)
[![License](https://img.shields.io/github/license/ColinH/PEGTL.svg)](#license)
[![TravisCI](https://travis-ci.org/ColinH/PEGTL.svg)](https://travis-ci.org/ColinH/PEGTL)
[![Coverage](https://img.shields.io/coveralls/ColinH/PEGTL.svg)](https://coveralls.io/github/ColinH/PEGTL)
[![Issues](https://img.shields.io/github/issues/ColinH/PEGTL.svg)](https://github.com/ColinH/PEGTL/issues)

The Parsing Expression Grammar Template Library (PEGTL) is a zero-dependency C++11 header-only library for creating parsers according to a [Parsing Expression Grammar](http://en.wikipedia.org/wiki/Parsing_expression_grammar) (PEG).

#### Introduction

Grammars are written as regular C++ code, created with template programming (not template meta programming), i.e. nested template instantiations that naturally correspond to the inductive definition of PEGs or other parser combinator approaches.

A comprehensive set of parser rules that can be combined and extended by the user is included, as are mechanisms for debugging grammars and attaching user-defined actions to grammar rules.
Here is an example of how a PEG grammar rule is implemented as C++ class with the PEGTL.

```c++
  // PEG rule for integers consisting of a non-empty
  // sequence of digits with an optional sign:

  // integer ::= ( '+' / '-' )? digit+

  // The same parsing rule implemented with the PEGTL:

  struct integer
     : pegtl::seq< pegtl::opt< pegtl::one< '+', '-' > >,
                   pegtl::plus< pegtl::digit > > {};
```

PEGs are superficially similar to Context-Free Grammars (CFGs), however the more deterministic nature of PEGs gives rise to some very important differences.
The included [grammar analysis](https://github.com/ColinH/PEGTL/wiki/Grammar-Analysis) finds several typical errors in PEGs, including left recursion.

#### Design

The PEGTL is mostly concerned with parsing combinators and grammar rules, and with giving the user control over what else happens during a parsing run.

The PEGTL is designed to be "lean and mean".
The actual core library has about 3000 lines of code.
Emphasis is on simplicity and efficiency but without adding any large constructions for optimising parsers.

Whether and which actions are taken, and which data structures are created during a parsing run, is entirely up to the user of the library, however we provide some [examples](https://github.com/ColinH/PEGTL/wiki/Contrib-and-Examples#examples) for typical situation like unescaping escape sequences in strings, building a generic [JSON](http://www.json.org/) data structure, and on-the-fly evaluation of arithmetic expressions.

Through the use of template programming and template specialisations it is possible to write a grammar once, and use it in multiple ways with different (semantic) actions in different (or the same) parsing runs.

Unlike [Antlr](http://www.antlr.org/) and Yacc/[Bison](http://www.gnu.org/software/bison/), the grammar is expressed in C++ and is part of the C++ source code.
Also, with the PEG formalism the separation into lexer and parser stages is usually dropped -- everything is done in a single grammar.

Unlike [Spirit](http://boost-spirit.com/), the grammar is implemented with compile-time template instantiations rather than run-time operator calls.
This leads to slightly increased compile times as the C++ compiler is given the task of optimising PEGTL grammars.

#### Status

The master branch of the PEGTL is stable in the sense that all known bugs are fixed and all unit tests run without errors. Each commit is automatically tested with multiple operating systems, compilers and versions thereof, namely

* Linux, GCC (4.8, 4.9, 5) with libstdc++
* Linux, Clang (3.4, 3.5, 3.6, 3.7) with libstdc++
* MacOS X, XCode (6, 7) with libc++

(Visual Studio 2015 on Windows is *not* automatically tested, *yet*)

The coverage is also automatically measured and our tests cover 100% of the code, excluding examples.

Releases are not stable in the sense that incompatible API changes can happen between major versions.
[Releases](https://github.com/ColinH/PEGTL/releases) are done in accordance with [Semantic Versioning](http://semver.org/).

## Documentation

* [Getting Started](https://github.com/ColinH/PEGTL/wiki/Getting-Started)
  * [Hello, world!](https://github.com/ColinH/PEGTL/wiki/Getting-Started#hello-world)
  * [Requirements](https://github.com/ColinH/PEGTL/wiki/Getting-Started#requirements)
  * [Compilation](https://github.com/ColinH/PEGTL/wiki/Getting-Started#compilation)
  * [Limitations](https://github.com/ColinH/PEGTL/wiki/Getting-Started#limitations)
* [Rules and Grammars](https://github.com/ColinH/PEGTL/wiki/Rules-and-Grammars)
  * [Combining Existing Rules](https://github.com/ColinH/PEGTL/wiki/Rules-and-Grammars#combining-existing-rules)
* [Actions and States](https://github.com/ColinH/PEGTL/wiki/Actions-and-States)
  * [Actions](https://github.com/ColinH/PEGTL/wiki/Actions-and-States#actions)
  * [States](https://github.com/ColinH/PEGTL/wiki/Actions-and-States#states)
  * [Action Specialisation](https://github.com/ColinH/PEGTL/wiki/Actions-and-States#action-specialisation)
  * [Changing Actions](https://github.com/ColinH/PEGTL/wiki/Actions-and-States#changing-actions)
* [Errors and Exceptions](https://github.com/ColinH/PEGTL/wiki/Errors-and-Exceptions)
  * [Failure](https://github.com/ColinH/PEGTL/wiki/Errors-and-Exceptions#failure)
  * [Error Messages](https://github.com/ColinH/PEGTL/wiki/Errors-and-Exceptions#error-messages)
* [Rule Reference](https://github.com/ColinH/PEGTL/wiki/Rule-Reference)
  * [Meta Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#meta-rules)
  * [Combinators](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#combinators)
  * [Convenience](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#convenience)
  * [Atomic Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#atomic-rules)
  * [ASCII Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#ascii-rules)
  * [UTF-8 Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#utf-8-rules)
  * [UTF-16 Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#utf-16-rules)
  * [UTF-32 Rules](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#utf-32-rules)
  * [Full Index](https://github.com/ColinH/PEGTL/wiki/Rule-Reference#full-index)
* [Parser Reference](https://github.com/ColinH/PEGTL/wiki/Parser-Reference)
  * [Input and Errors](https://github.com/ColinH/PEGTL/wiki/Parser-Reference#input-and-errors)
  * [Parser Functions](https://github.com/ColinH/PEGTL/wiki/Parser-Reference#parser-functions)
  * [Tracer Functions](https://github.com/ColinH/PEGTL/wiki/Parser-Reference#tracer-functions)
  * [Parser Classes](https://github.com/ColinH/PEGTL/wiki/Parser-Reference#parser-classes)
* [Contrib and Examples](https://github.com/ColinH/PEGTL/wiki/Contrib-and-Examples)
  * [Contrib](https://github.com/ColinH/PEGTL/wiki/Contrib-and-Examples#contrib)
  * [Examples](https://github.com/ColinH/PEGTL/wiki/Contrib-and-Examples#examples)
* [Control Hooks](https://github.com/ColinH/PEGTL/wiki/Control-Hooks)
  * [Normal Control](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#normal-control)
  * [Debug Functions](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#debug-functions)
  * [Exception Throwing](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#exception-throwing)
  * [Debugging and Tracing](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#debugging-and-tracing)
  * [Advanced Control](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#advanced-control)
  * [Changing Control](https://github.com/ColinH/PEGTL/wiki/Control-Hooks#changing-control)
* [Advanced Rules](https://github.com/ColinH/PEGTL/wiki/Advanced-Rules)
  * [Simple Rules](https://github.com/ColinH/PEGTL/wiki/Advanced-Rules#simple-rules)
  * [Complex Rules](https://github.com/ColinH/PEGTL/wiki/Advanced-Rules#complex-rules)
* [Switching Style](https://github.com/ColinH/PEGTL/wiki/Switching-Style)
* [Grammar Analysis](https://github.com/ColinH/PEGTL/wiki/Grammar-Analysis)
* [Calculator Example](https://github.com/ColinH/PEGTL/wiki/Calculator-Example)
* [Changelog](https://github.com/ColinH/PEGTL/wiki/Changelog)
* [2014 Refactoring](https://github.com/ColinH/PEGTL/wiki/2014-Refactoring)

#### Thank You

* Christopher Diggins and the YARD parser for the general idea.
* Stephan Beal for the bug reports, suggestions and discussions.
* Johannes Overmann for his invaluable [`streplace`](https://code.google.com/p/streplace/) command-line tool.
* Sam Hocevar for contributing Visual Studio 2015 compatibility.
* George Makrydakis for the [inspiration](https://github.com/irrequietus/typestring) to `pegtl_string_t`.
* Kenneth Geisshirt for Android compatibility.

## License

<a href="http://www.opensource.org/"><img height="100" align="right" src="http://wiki.opensource.org/bin/download/OSI+Operations/Marketing+%26+Promotional+Collateral/OSI_certified_logo_vector.svg"></a>

The PEGTL is certified [Open Source](http://www.opensource.org/docs/definition.html) software. It may be used for any purpose, including commercial purposes, at absolutely no cost. It is distributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.html) reproduced here.

> Copyright (c) 2014-2016 Dr. Colin Hirsch and Daniel Frey
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This site and software is not affiliated with or endorsed by the Open Source Initiative. For questions and suggestions about the PEGTL please contact the authors at `pegtl(at)colin-hirsch.net`.

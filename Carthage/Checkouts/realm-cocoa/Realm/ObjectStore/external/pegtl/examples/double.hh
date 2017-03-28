// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_EXAMPLES_DOUBLE_HH
#define PEGTL_EXAMPLES_DOUBLE_HH

#include <pegtl.hh>

namespace double_
{
   // A grammar for doubles suitable for std::stod without locale support.
   // See also: http://en.cppreference.com/w/cpp/string/basic_string/stof

   struct plus_minus : pegtl::opt< pegtl::one< '+', '-' > > {};
   struct dot : pegtl::one< '.' > {};

   struct inf : pegtl::seq< pegtl::istring< 'i', 'n', 'f' >,
                            pegtl::opt< pegtl::istring< 'i', 'n', 'i', 't', 'y' > > > {};

   struct nan : pegtl::seq< pegtl::istring< 'n', 'a', 'n' >,
                            pegtl::opt< pegtl::one< '(' >,
                                        pegtl::plus< pegtl::alnum >,
                                        pegtl::one< ')' > > > {};

   template< typename D >
   struct number : pegtl::if_then_else< dot,
                                        pegtl::plus< D >,
                                        pegtl::seq< pegtl::plus< D >, dot, pegtl::star< D > > > {};

   struct e : pegtl::one< 'e', 'E' > {};
   struct p : pegtl::one< 'p', 'P' > {};
   struct exponent : pegtl::seq< plus_minus, pegtl::plus< pegtl::digit > > {};

   struct decimal : pegtl::seq< number< pegtl::digit >, pegtl::opt< e, exponent > > {};
   struct binary : pegtl::seq< pegtl::one< '0' >, pegtl::one< 'x', 'X' >, number< pegtl::xdigit >, pegtl::opt< p, exponent > > {};

   struct grammar : pegtl::seq< plus_minus, pegtl::sor< decimal, binary, inf, nan > > {};

} // double_

#endif

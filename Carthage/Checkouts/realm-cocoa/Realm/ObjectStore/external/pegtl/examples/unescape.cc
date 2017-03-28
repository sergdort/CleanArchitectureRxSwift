// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <iostream>

#include <pegtl.hh>

#include <pegtl/contrib/unescape.hh>

namespace unescape
{
   // Grammar for string literals with some escape sequences from the C language:
   // - \x followed by two hex-digits to insert any byte value.
   // - \u followed by four hex-digits to insert a Unicode code point.
   // - \U followed by eight hex-digits to insert any Unicdoe code points.
   // - A backslash followed by one of the characters listed in the grammar below.

   struct escaped_x : pegtl::seq< pegtl::one< 'x' >, pegtl::rep< 2, pegtl::must< pegtl::xdigit > > > {};
   struct escaped_u : pegtl::seq< pegtl::one< 'u' >, pegtl::rep< 4, pegtl::must< pegtl::xdigit > > > {};
   struct escaped_U : pegtl::seq< pegtl::one< 'U' >, pegtl::rep< 8, pegtl::must< pegtl::xdigit > > > {};
   struct escaped_c : pegtl::one< '\'', '"', '?', '\\', 'a', 'b', 'f', 'n', 'r', 't', 'v' > {};

   struct escaped : pegtl::sor< escaped_x,
                                escaped_u,
                                escaped_U,
                                escaped_c > {};

   struct character : pegtl::if_must_else< pegtl::one< '\\' >, escaped, pegtl::utf8::range< 0x20, 0x10FFFF > > {};
   struct literal : pegtl::if_must< pegtl::one< '"' >, pegtl::until< pegtl::one< '"' >, character > > {};

   struct padded : pegtl::must< pegtl::pad< literal, pegtl::blank >, pegtl::eof > {};

   // Action class that uses the actions from pegtl/contrib/unescape.hh to
   // produce a UTF-8 encoded result string where all escape sequences are
   // replaced with their intended meaning.

   template< typename Rule > struct action : pegtl::nothing< Rule > {};

   template<> struct action< pegtl::utf8::range< 0x20, 0x10FFFF > > : pegtl::unescape::append_all {};
   template<> struct action< escaped_x > : pegtl::unescape::unescape_x {};
   template<> struct action< escaped_u > : pegtl::unescape::unescape_u {};
   template<> struct action< escaped_U > : pegtl::unescape::unescape_u {};
   template<> struct action< escaped_c > : pegtl::unescape::unescape_c< escaped_c, '\'', '"', '?', '\\', '\a', '\b', '\f', '\n', '\r', '\t', '\v' > {};

} // unescape

int main( int argc, char ** argv )
{
   for ( int i = 1; i < argc; ++i ) {
      pegtl::unescape::state s;
      pegtl::parse< unescape::padded, unescape::action >( i, argv, s );
      std::cout << "argv[ " << i << " ] = " << s.unescaped << std::endl;
   }
   return 0;
}

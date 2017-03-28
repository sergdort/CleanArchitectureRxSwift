// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <string>
#include <iostream>

#include <pegtl.hh>

#include "double.hh"

namespace sum
{
   struct padded_double
         : pegtl::pad< double_::grammar, pegtl::space > {};

   struct double_list
         : pegtl::list< padded_double, pegtl::one< ',' > > {};

   struct grammar
         : pegtl::seq< double_list, pegtl::eof > {};

   template< typename Rule >
   struct action
         : pegtl::nothing< Rule > {};

   template<> struct action< double_::grammar >
   {
      static void apply( const pegtl::input & in, double & sum )
      {
         // assume all values will fit into a C++ double
         sum += std::stod( in.string() );
      }
   };

} // sum

int main()
{
   std::cout << "Give me a comma separated list of numbers.\n";
   std::cout << "The numbers are added using the PEGTL.\n";
   std::cout << "Type [q or Q] to quit\n\n";

   std::string str;
   while ( std::getline( std::cin, str ) ) {
      if ( str.empty() || str[ 0 ] == 'q' || str[ 0 ] == 'Q' ) {
         break;
      }

      double d = 0.0;
      if ( pegtl::parse< sum::grammar, sum::action >( str, "std::cin", d ) ) {
         std::cout << "parsing OK; sum = " << d << std::endl;
      }
      else {
         std::cout << "parsing failed" << std::endl;
      }
   }
}

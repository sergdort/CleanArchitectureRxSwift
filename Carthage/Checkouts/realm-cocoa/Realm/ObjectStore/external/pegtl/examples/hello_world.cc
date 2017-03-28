// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <string>
#include <iostream>

#include <pegtl.hh>

namespace hello
{
   struct prefix
         : pegtl::string< 'H', 'e', 'l', 'l', 'o', ',', ' ' > {};

   struct name
         : pegtl::plus< pegtl::alpha > {};

   struct grammar
         : pegtl::must< prefix, name, pegtl::one< '!' >, pegtl::eof > {};

   template< typename Rule >
   struct action
         : pegtl::nothing< Rule > {};

   template<> struct action< name >
   {
      static void apply( const pegtl::input & in, std::string & name )
      {
         name = in.string();
      }
   };

} // hello

int main( int argc, char ** argv )
{
   if ( argc > 1 ) {
      std::string name;
      pegtl::parse< hello::grammar, hello::action >( 1, argv, name );
      std::cout << "Good bye, " << name << "!" << std::endl;
   }
}

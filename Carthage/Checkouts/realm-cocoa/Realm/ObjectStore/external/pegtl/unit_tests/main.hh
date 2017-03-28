// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_MAIN_HH
#define PEGTL_UNIT_TESTS_MAIN_HH

#include <cstdlib>

int main( int, char ** argv )
{
   pegtl::unit_test();

   if ( pegtl::failed ) {
      std::cerr << "pegtl: unit test " << argv[ 0 ] << " failed " << pegtl::failed << std::endl;
   }
   return ( pegtl::failed == 0 ) ? EXIT_SUCCESS : EXIT_FAILURE;
}

#endif

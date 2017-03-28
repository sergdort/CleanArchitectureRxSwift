// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "json_errors.hh"

using grammar = pegtl::must< pegtl::json::text, pegtl::eof >;

int main( int argc, char ** argv )
{
   for ( int i = 1; i < argc; ++i ) {
      pegtl::parse< grammar, pegtl::nothing, examples::errors >( i, argv );
   }
   return 0;
}

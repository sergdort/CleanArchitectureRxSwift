// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      try {
         internal::file_mapper( "pegtl" );
         std::cerr << "pegtl: unit test failed for [ internal::file_mapper ] " << std::endl;
         ++failed;
      }
      catch ( const std::exception & ) {
      }
   }

} // pegtl

#include "main.hh"

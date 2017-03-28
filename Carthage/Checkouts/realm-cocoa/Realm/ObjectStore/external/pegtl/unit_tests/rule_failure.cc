// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< failure >( __LINE__, __FILE__, true, false );  // "Success implies consumption" is true because "success" never happens.

      verify_rule< failure >( __LINE__, __FILE__,  "", result_type::LOCAL_FAILURE, 0 );

      for ( char i = 1; i < 127; ++i ) {
         verify_char< failure >( __LINE__, __FILE__, i, result_type::LOCAL_FAILURE );
      }
   }

} // pegtl

#include "main.hh"

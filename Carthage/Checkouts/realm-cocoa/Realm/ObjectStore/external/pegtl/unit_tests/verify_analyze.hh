// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_ANALYZE_HH
#define PEGTL_UNIT_TESTS_VERIFY_ANALYZE_HH

#include <pegtl/analyze.hh>

#include "test_failed.hh"

namespace pegtl
{
   template< typename Rule >
   void verify_analyze( const unsigned line, const char * file, const bool expect_consume, const bool expect_problems )
   {
      analysis::analyze_cycles< Rule > a( true );

      const bool has_problems = ( a.problems() != 0 );
      const bool does_consume = a.template consumes< Rule >();

      if ( has_problems != expect_problems ) {
         TEST_FAILED( "analyze -- problems received/expected [ " << has_problems << " / " << expect_problems << " ]" );
      }
      if ( does_consume != expect_consume ) {
         TEST_FAILED( "analyze -- consumes received/expected [ " << does_consume << " / " << expect_consume << " ]" );
      }
   }

} // pegtl

#endif

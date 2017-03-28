// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_FAIL_HH
#define PEGTL_UNIT_TESTS_VERIFY_FAIL_HH

#include <cassert>
#include <iostream>

#include <pegtl.hh>

#include "test_failed.hh"

namespace pegtl
{
   template< typename Rule, template< typename > class Action = nothing, typename ... States >
   void verify_fail( const std::size_t line, const char * file, const std::string & s, States && ... st )
   {
      try {
         parse< Rule, Action >( s, "expect_exception", st ... );
         TEST_FAILED( "expected exception" );
      }
      catch ( ... ) {
      }
   }

} // pegtl

#endif

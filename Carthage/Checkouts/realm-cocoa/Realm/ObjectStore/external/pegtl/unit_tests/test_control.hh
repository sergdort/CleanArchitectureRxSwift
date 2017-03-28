// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_TEST_CONTROL_HH
#define PEGTL_UNIT_TESTS_TEST_CONTROL_HH

#include <utility>

#include <pegtl/internal/demangle.hh>

namespace pegtl
{
   template< typename Rule >
   struct test_control
   {
      template< typename Input >
      static void apply( const Input & in )
      {
         applied.push_back( std::make_pair( internal::demangle< Rule >(), in.string() ) );
      }
   };

} // pegtl

#endif

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_TEST_ACTION_HH
#define PEGTL_UNIT_TESTS_TEST_ACTION_HH

#include <utility>

#include <pegtl/internal/demangle.hh>

namespace pegtl
{
   template< typename Rule >
   struct test_action
   {
      template< typename Input >
      static void apply( const Input & in )
      {
         applied.push_back( std::make_pair( internal::demangle< Rule >(), in.string() ) );
      }
   };

} // pegtl

#endif

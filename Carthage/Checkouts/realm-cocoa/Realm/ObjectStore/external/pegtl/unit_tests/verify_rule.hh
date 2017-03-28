// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_RULE_HH
#define PEGTL_UNIT_TESTS_VERIFY_RULE_HH

#include <string>
#include <cstdlib>

#include "result_type.hh"
#include "verify_impl.hh"

namespace pegtl
{
   template< typename Rule >
   void verify_rule( const std::size_t line, const char * file, const std::string & data, const result_type result, const std::size_t remain )
   {
      verify_impl< Rule >( line, file, data, result, remain );
   }

} // pegtl

#endif

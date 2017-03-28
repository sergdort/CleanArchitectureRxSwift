// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_CHAR_HH
#define PEGTL_UNIT_TESTS_VERIFY_CHAR_HH

#include <string>
#include <cstdlib>

#include "result_type.hh"
#include "verify_rule.hh"

namespace pegtl
{
   template< typename Rule >
   void verify_char( const std::size_t line, const char * file, const char data, const result_type result )
   {
      verify_rule< Rule >( line, file, std::string( std::size_t( 1 ), data ), result, ( result == result_type::SUCCESS ) ? 0 : 1 );
   }

   template< typename Rule >
   void verify_char( const std::size_t line, const char * file, const char data, const bool result )
   {
      verify_char< Rule >( line, file, data, result ? result_type::SUCCESS : result_type::LOCAL_FAILURE );
   }

} // pegtl

#endif

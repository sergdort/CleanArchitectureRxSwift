// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_IFMT_HH
#define PEGTL_UNIT_TESTS_VERIFY_IFMT_HH

#include <pegtl.hh>

#include "verify_rule.hh"
#include "verify_analyze.hh"

namespace pegtl
{
   template< template< typename, typename, typename > class S >
   void verify_ifmt( const result_type failure = result_type::LOCAL_FAILURE )
   {
      verify_analyze< S< eof, eof, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< eof, eof, any > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< eof, any, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< eof, any, any > >( __LINE__, __FILE__, true, false );
      verify_analyze< S< any, eof, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< any, eof, any > >( __LINE__, __FILE__, true, false );
      verify_analyze< S< any, any, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< any, any, any > >( __LINE__, __FILE__, true, false );

      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__,  "", failure, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__,  "b", failure, 1 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__,  "c", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__,  "ab", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__,  "ac", failure, 2 );
   }

} // pegtl

#endif

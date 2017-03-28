// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_SEQS_HH
#define PEGTL_UNIT_TESTS_VERIFY_SEQS_HH

#include <pegtl.hh>

#include "verify_rule.hh"
#include "verify_analyze.hh"

namespace pegtl
{
   template< template< typename ... > class S >
   void verify_seqs( const result_type failure = result_type::LOCAL_FAILURE )
   {
      verify_analyze< S< any > >( __LINE__, __FILE__, true, false );
      verify_analyze< S< eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< S< any, eof > >( __LINE__, __FILE__, true, false );
      verify_analyze< S< opt< any >, eof > >( __LINE__, __FILE__, false, false );

      verify_rule< S<> >( __LINE__, __FILE__, "", result_type::SUCCESS, 0 );
      verify_rule< S<> >( __LINE__, __FILE__, "a", result_type::SUCCESS, 1 );

      verify_rule< S< eof > >( __LINE__, __FILE__, "", result_type::SUCCESS, 0 );
      verify_rule< S< eof > >( __LINE__, __FILE__, "a", failure, 1 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "", failure, 0 );
      verify_rule< S< one< 'c' >, eof > >( __LINE__, __FILE__, "", failure, 0 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "c", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "a", failure, 1 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "b", failure, 1 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "cc", result_type::SUCCESS, 1 );
      verify_rule< S< one< 'c' > > >( __LINE__, __FILE__, "bc", failure, 2 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "", failure, 0 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "a", failure, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "b", failure, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "c", failure, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "ab", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "aba", result_type::SUCCESS, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "abb", result_type::SUCCESS, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "abc", result_type::SUCCESS, 1 );
      verify_rule< S< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__, "abab", result_type::SUCCESS, 2 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__, "", failure, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__, "a", failure, 1 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__, "ab", failure, 2 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__, "abc", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' >, eof > >( __LINE__, __FILE__, "abc", result_type::SUCCESS, 0 );
      verify_rule< S< one< 'a' >, one< 'b' >, one< 'c' > > >( __LINE__, __FILE__, "abcd", result_type::SUCCESS, 1 );
   }

} // pegtl

#endif

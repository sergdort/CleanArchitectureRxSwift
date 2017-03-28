// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< opt< any > >( __LINE__, __FILE__, false, false );
      verify_analyze< opt< eof > >( __LINE__, __FILE__, false, false );

      verify_rule< opt< one< 'a' > > >( __LINE__, __FILE__,  "", result_type::SUCCESS, 0 );
      verify_rule< opt< one< 'a' > > >( __LINE__, __FILE__,  "a", result_type::SUCCESS, 0 );
      verify_rule< opt< one< 'a' > > >( __LINE__, __FILE__,  "aa", result_type::SUCCESS, 1 );
      verify_rule< opt< one< 'a' > > >( __LINE__, __FILE__,  "ab", result_type::SUCCESS, 1 );
      verify_rule< opt< one< 'a' > > >( __LINE__, __FILE__,  "ba", result_type::SUCCESS, 2 );

      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "", result_type::SUCCESS, 0 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "a", result_type::SUCCESS, 1 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "ab", result_type::SUCCESS, 0 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "aba", result_type::SUCCESS, 1 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "abab", result_type::SUCCESS, 2 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "bab", result_type::SUCCESS, 3 );
      verify_rule< opt< one< 'a' >, one< 'b' > > >( __LINE__, __FILE__,  "cb", result_type::SUCCESS, 2 );
   }

} // pegtl

#include "main.hh"

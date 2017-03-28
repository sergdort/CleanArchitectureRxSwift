// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   template< typename Rule >
   void test_matches_lf()
   {
      static const std::string s1 = "\n";

      input i1( 1, 0, s1.data(), s1.data() + s1.size(), __FUNCTION__ );

      TEST_ASSERT( parse_input< Rule >( i1 ) );
      TEST_ASSERT( i1.line() == 2 );
      TEST_ASSERT( i1.column() == 0 );
   }

   template< typename Rule >
   void test_matches_other( const std::string & s2 )
   {
      TEST_ASSERT( s2.size() == 1 );

      input i2( 1, 0, s2.data(), s2.data() + s2.size(), __FUNCTION__ );

      TEST_ASSERT( parse_input< Rule >( i2 ) );
      TEST_ASSERT( i2.line() == 1 );
      TEST_ASSERT( i2.column() == 1 );
   }

   template< typename Rule >
   void test_mismatch( const std::string & s3 )
   {
      TEST_ASSERT( s3.size() == 1 );

      input i3( 1, 0, s3.data(), s3.data() + s3.size(), __FUNCTION__ );

      TEST_ASSERT( ! parse_input< Rule >( i3 ) );
      TEST_ASSERT( i3.line() == 1 );
      TEST_ASSERT( i3.column() == 0 );
   }

   void unit_test()
   {
      test_matches_lf< any >();
      test_matches_other< any >( " " );

      test_matches_lf< one< '\n' > >();
      test_mismatch< one< '\n' > >( " " );

      test_matches_lf< one< ' ', '\n' > >();
      test_matches_other< one< ' ', '\n' > >( " " );

      test_matches_lf< one< ' ', '\n', 'b' > >();
      test_matches_other< one< ' ', '\n', 'b' > >( " " );

      test_matches_lf< string< '\n' > >();
      test_mismatch< string< '\n' > >( " " );

      test_matches_other< string< ' ' > >( " " );
      test_mismatch< string< ' ' > >( "\n" );

      test_matches_lf< range< 8, 33 > >();
      test_matches_other< range< 8, 33 > >( " " );

      test_mismatch< range< 11, 30 > >( "\n" );
      test_mismatch< range< 11, 30 > >( " " );

      test_matches_lf< not_range< 20, 30 > >();
      test_matches_other< not_range< 20, 30 > >( " " );

      test_mismatch< not_range< 5, 35 > >( "\n" );
      test_mismatch< not_range< 5, 35 > >( " " );

      test_matches_lf< ranges< 'a', 'z', 8, 33, 'A', 'Z' > >();
      test_matches_other< ranges< 'a', 'z', 8, 33, 'A', 'Z' > >( "N" );
      test_mismatch< ranges< 'a', 'z', 8, 33, 'A', 'Z' > >( "9" );

      test_matches_lf< ranges< 'a', 'z', 'A', 'Z', '\n' > >();
      test_matches_other< ranges< 'a', 'z', 'A', 'Z', '\n' > >( "P" );
      test_mismatch< ranges< 'a', 'z', 'A', 'Z', '\n' > >( "8" );
   }

} // pegtl

#include "main.hh"

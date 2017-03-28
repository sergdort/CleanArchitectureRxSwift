// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   namespace test1
   {
      struct fiz : if_must< at< one< 'a' > >, two< 'a' > > {};
      struct foo : sor< fiz, one< 'b' > > {};
      struct bar : until< eof, foo > {};

      void test_result()
      {
         TEST_ASSERT( applied.size() == 10 );

         TEST_ASSERT( applied[ 0 ].first == internal::demangle< one< 'b' > >() );
         TEST_ASSERT( applied[ 1 ].first == internal::demangle< foo >() );
         TEST_ASSERT( applied[ 2 ].first == internal::demangle< at< one< 'a' > > >() );
         TEST_ASSERT( applied[ 3 ].first == internal::demangle< two< 'a' > >() );
         TEST_ASSERT( applied[ 4 ].first == internal::demangle< fiz >() );
         TEST_ASSERT( applied[ 5 ].first == internal::demangle< foo >() );
         TEST_ASSERT( applied[ 6 ].first == internal::demangle< one< 'b' > >() );
         TEST_ASSERT( applied[ 7 ].first == internal::demangle< foo >() );
         TEST_ASSERT( applied[ 8 ].first == internal::demangle< eof >() );
         TEST_ASSERT( applied[ 9 ].first == internal::demangle< bar >() );

         TEST_ASSERT( applied[ 0 ].second == "b" );
         TEST_ASSERT( applied[ 1 ].second == "b" );
         TEST_ASSERT( applied[ 2 ].second == "" );
         TEST_ASSERT( applied[ 3 ].second == "aa" );
         TEST_ASSERT( applied[ 4 ].second == "aa" );
         TEST_ASSERT( applied[ 5 ].second == "aa" );
         TEST_ASSERT( applied[ 6 ].second == "b" );
         TEST_ASSERT( applied[ 7 ].second == "b" );
         TEST_ASSERT( applied[ 8 ].second == "" );
         TEST_ASSERT( applied[ 9 ].second == "baab" );
      }

      struct state1
      {
         char c;

         template< typename Input >
         state1( const Input &, std::string & )
         { }

         template< typename Input >
         void success( const Input &, std::string & s ) const
         {
            s += c;
         }
      };

      struct fobble : sor< state< state1, alpha >, digit > {};
      struct fibble : until< eof, fobble > {};

      template< typename Rule > struct action1 : nothing< Rule > {};

      template<>
      struct action1< alpha >
      {
         static void apply( const input & in, state1 & s )
         {
            assert( in.size() == 1 );
            s.c = 0[ in.begin() ];
         }
      };

      void state_test()
      {
         std::string result;
         parse< fibble, action1 >( "dk41sk41xk3", __FILE__, result );
         TEST_ASSERT( result == "dkskxk" );
      }

   } // test1

   void unit_test()
   {
      parse< disable< test1::bar >, test_action >( "baab", __FILE__ );

      TEST_ASSERT( applied.size() == 1 );

      TEST_ASSERT( applied[ 0 ].first == internal::demangle< disable< test1::bar > >() );
      TEST_ASSERT( applied[ 0 ].second == "baab" );

      applied.clear();

      parse< at< action< test_action, test1::bar > > >( "baab", __FILE__ );

      TEST_ASSERT( applied.empty() );

      applied.clear();

      parse< test1::bar, test_action >( "baab", __FILE__ );

      test1::test_result();

      applied.clear();

      parse< action< test_action, test1::bar > >( "baab", __FILE__ );

      test1::test_result();

      applied.clear();

      parse< disable< enable< action< test_action, test1::bar > > > >( "baab", __FILE__ );

      test1::test_result();

      test1::state_test();
   }

} // pegtl

#include "main.hh"

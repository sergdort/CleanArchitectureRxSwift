// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_FILE_HH
#define PEGTL_UNIT_TESTS_VERIFY_FILE_HH

#include <pegtl.hh>

namespace pegtl
{
   struct file_content : pegtl_string_t( "dummy content\n" ) {};
   struct file_grammar : seq< rep_min_max< 11, 11, file_content >, eof > {};

   template< typename Rule > struct file_action : nothing< Rule > {};

   template<> struct file_action< eof >
   {
      static void apply( const input &, bool & flag )
      {
         flag = true;
      }
   };

   template< typename Rule > struct file_control : normal< Rule > {};

   template<> struct file_control< eof > : normal< eof >
   {
      static void success( const input &, bool & flag )
      {
         flag = true;
      }
   };

   template< typename T >
   void verify_file()
   {
      {
         const std::string f{ "unit_tests/no_such_file.txt" };
         try {
           T p{ f };
           TEST_ASSERT( !"no error on opening non-existing file" );
         }
         catch( const input_error& e ) {
         }
      } {
         const std::string f{ "unit_tests/file_data.txt" };
         T p{ f };
         TEST_ASSERT( p.source() == f );
         TEST_ASSERT( p.template parse< file_grammar >() );
         TEST_ASSERT( p.source() == f );
      } {
         const std::string f{ "unit_tests/file_data.txt" };
         T p{ f };
         bool flag = true;
         TEST_ASSERT( p.source() == f );
         TEST_ASSERT( p.template parse< file_grammar >( flag ) );
         TEST_ASSERT( flag == true );
      } {
         const std::string f{ "unit_tests/file_data.txt" };
         T p{ f };
         bool flag = false;
         TEST_ASSERT( p.source() == f );
         TEST_ASSERT( p.template parse< file_grammar >( flag ) );
         TEST_ASSERT( flag == false );
      } {
         const std::string f{ "unit_tests/file_data.txt" };
         T p{ f };
         bool flag = false;
         TEST_ASSERT( p.source() == f );
         const bool result = p.template parse< file_grammar, file_action >( flag );
         TEST_ASSERT( result );
         TEST_ASSERT( flag == true );
      } {
         const std::string f{ "unit_tests/file_data.txt" };
         T p{ f };
         bool flag = false;
         TEST_ASSERT( p.source() == f );
         const bool result = p.template parse< file_grammar, nothing, file_control >( flag );
         TEST_ASSERT( result );
         TEST_ASSERT( flag == true );
      }
   }

} // pegtl

#endif

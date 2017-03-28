// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

#include <pegtl/contrib/raw_string.hh>

namespace pegtl
{
   std::string content;

   using rstring = raw_string< '[', '=', ']' >;

   template< typename Rule > struct rsaction : nothing< Rule > {};

   template<> struct rsaction< rstring::content >
   {
      template< typename ... States >
      static void apply( const input & in, const States & ... )
      {
         content.assign( in.begin(), in.end() );
      }
   };

   struct rgrammar : must< rstring, eof > {};

   template< typename Rule, unsigned M, unsigned N >
   void verify_data( const std::size_t line, const char * file, const char ( & m )[ M ], const char ( & n )[ N ] )
   {
      content.clear();
      input i( line, 0, m, m + M - 1, file );
      const auto r = parse_input< Rule, rsaction >( i );
      if ( ( ! r ) || ( content != std::string( n, N - 1 ) ) ) {
         TEST_FAILED( "input data [ '" << m << "' ] expected success with [ '" << n << "' ] but got [ '" << content << "' ] result [ " << r << " ]" );
      }
   }

   void unit_test()
   {
      verify_data< rgrammar >( __LINE__, __FILE__, "[[]]", "" );
      verify_data< rgrammar >( __LINE__, __FILE__, "[[foo]]", "foo" );
      verify_data< rgrammar >( __LINE__, __FILE__, "[===[foo]===]", "foo" );
      verify_data< rgrammar >( __LINE__, __FILE__, "[===[\nfoo]===]", "foo" );
      verify_data< rgrammar >( __LINE__, __FILE__, "[===[\0\0\0]===]", "\0\0\0" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[=" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[=[" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[=[]=" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[=[]]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[[]] " );
      verify_fail< rgrammar >( __LINE__, __FILE__, " [[]]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[=[]-]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[-[]=]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[-[]-]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[===[]====]" );
      verify_fail< rgrammar >( __LINE__, __FILE__, "[====[]===]" );
   }

} // pegtl

#include "main.hh"

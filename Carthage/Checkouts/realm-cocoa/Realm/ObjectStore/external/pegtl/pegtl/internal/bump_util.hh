// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_BUMP_UTIL_HH
#define PEGTL_INTERNAL_BUMP_UTIL_HH

#include <type_traits>

#include "result_on_found.hh"

namespace pegtl
{
   namespace internal
   {
      template< bool > struct bump_impl;

      template<> struct bump_impl< true >
      {
         template< typename Input >
         static void bump( Input & in, const size_t count )
         {
            in.bump( count );
         }
      };

      template<> struct bump_impl< false >
      {
         template< typename Input >
         static void bump( Input & in, const size_t count )
         {
            in.bump_in_line( count );
         }
      };

      template< bool ... > struct bool_list {};

      template< typename Char, Char ... Cs > using no_lf = std::is_same< bool_list< ( Cs != '\n' ) ... >, bool_list< ( Cs || true ) ... > >;

      template< result_on_found R, typename Input, typename Char, Char ... Cs >
      void bump( Input & in, const size_t count )
      {
         bump_impl< no_lf< Char, Cs ... >::value != bool( R ) >::bump( in, count );
      }

   } // internal

} // pegtl

#endif

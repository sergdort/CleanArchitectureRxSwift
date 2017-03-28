// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_PEEK_UTF16_HH
#define PEGTL_INTERNAL_PEEK_UTF16_HH

#include <type_traits>

#include "input_pair.hh"

namespace pegtl
{
   namespace internal
   {
      struct peek_utf16
      {
         using data_t = char32_t;
         using pair_t = input_pair< char32_t >;

         using short_t = std::make_unsigned< char16_t >::type;

         static_assert( sizeof( short_t ) == 2, "expected size 2 for 16bit value" );
         static_assert( sizeof( char16_t ) == 2, "expected size 2 for 16bit value" );

         template< typename Input >
         static pair_t peek( Input & in )
         {
            const std::size_t s = in.size();
            if ( s >= 2 ) {
               const char32_t t = * reinterpret_cast< const short_t * >( in.begin() );
               if ( ( t < 0xd800 ) || ( t > 0xdbff ) || ( s < 4 ) ) {
                  return { t, 2 };
               }
               const char32_t u = * reinterpret_cast< const short_t * >( in.begin() + 2 );
               if ( ( u < 0xdc00 ) || ( u > 0xdfff ) ) {
                  return { t, 2 };
               }
               return { ( ( ( t & 0x03ff ) << 10 ) | ( u & 0x03ff ) ) + 0x10000, 4 };
            }
            return { 0, 0 };
         }
      };

   } // internal

} // pegtl

#endif

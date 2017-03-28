// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_PEEK_UTF8_HH
#define PEGTL_INTERNAL_PEEK_UTF8_HH

#include "input_pair.hh"

namespace pegtl
{
   namespace internal
   {
      struct peek_utf8
      {
         using data_t = char32_t;
         using pair_t = input_pair< char32_t >;

         template< typename Input >
         static pair_t peek( Input & in )
         {
            char32_t c0 = in.peek_byte();

            if ( ( c0 & 0x80 ) == 0 ) {
               return { c0, 1 };
            }
            else if ( ( c0 & 0xE0 ) == 0xC0 ) {
               if ( in.size() >= 2 ) {
                  const char32_t c1 = in.peek_byte( 1 );
                  if ( ( c1 & 0xC0 ) == 0x80 ) {
                     c0 &= 0x1F;
                     c0 <<= 6;
                     c0 |= ( c1 & 0x3F );
                     if ( c0 >= 0x80 ) {
                        return { c0, 2 };
                     }
                  }
               }
            }
            else if ( ( c0 & 0xF0 ) == 0xE0 ) {
               if ( in.size() >= 3 ) {
                  const char32_t c1 = in.peek_byte( 1 );
                  const char32_t c2 = in.peek_byte( 2 );
                  if( ( ( c1 & 0xC0 ) == 0x80 ) && ( ( c2 & 0xC0 ) == 0x80 ) ) {
                     c0 &= 0x0F;
                     c0 <<= 6;
                     c0 |= ( c1 & 0x3F );
                     c0 <<= 6;
                     c0 |= ( c2 & 0x3F );
                     if ( c0 >= 0x800 ) {
                        return { c0, 3 };
                     }
                  }
               }
            }
            else if ( ( c0 & 0xF8 ) == 0xF0 ) {
               if ( in.size() >= 4 ) {
                  const char32_t c1 = in.peek_byte( 1 );
                  const char32_t c2 = in.peek_byte( 2 );
                  const char32_t c3 = in.peek_byte( 3 );
                  if ( ( ( c1 & 0xC0 ) == 0x80 ) && ( ( c2 & 0xC0 ) == 0x80 ) && ( ( c3 & 0xC0 ) == 0x80 ) ) {
                     c0 &= 0x07;
                     c0 <<= 6;
                     c0 |= ( c1 & 0x3F );
                     c0 <<= 6;
                     c0 |= ( c2 & 0x3F );
                     c0 <<= 6;
                     c0 |= ( c3 & 0x3F );
                     if ( c0 >= 0x10000 && c0 <= 0x10FFFF ) {
                        return { c0, 4 };
                     }
                  }
               }
            }
            return { 0, 0 };
         }
      };

   } // internal

} // pegtl

#endif

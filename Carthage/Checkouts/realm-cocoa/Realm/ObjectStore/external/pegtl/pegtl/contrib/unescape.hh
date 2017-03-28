// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_CONTRIB_UNESCAPE_HH
#define PEGTL_CONTRIB_UNESCAPE_HH

#include <string>
#include <cassert>

#include <pegtl/ascii.hh>
#include <pegtl/parse_error.hh>

namespace pegtl
{
   namespace unescape
   {
      struct state
      {
         std::string unescaped;
      };

      // Utility functions for the unescape actions.

      inline bool utf8_append_utf32( std::string & string, const unsigned utf32 )
      {
         if ( utf32 <= 0x7f ) {
            string += char( utf32 & 0xff );
            return true;
         }
         else if ( utf32 <= 0x7ff ) {
            char tmp[] = { char( ( ( utf32 & 0x7c0 ) >> 6 ) | 0xc0 ),
                           char( ( ( utf32 & 0x03f )      ) | 0x80 ) };
            string.append( tmp, sizeof( tmp ) );
            return true;
         }
         else if ( utf32 <= 0xffff ) {
            char tmp[] = { char( ( ( utf32 & 0xf000 ) >> 12 ) | 0xe0 ),
                           char( ( ( utf32 & 0x0fc0 ) >> 6  ) | 0x80 ),
                           char( ( ( utf32 & 0x003f )       ) | 0x80 ) };
            string.append( tmp, sizeof( tmp ) );
            return true;
         }
         else if ( utf32 <= 0x10ffff ) {
            char tmp[] = { char( ( ( utf32 & 0x1c0000 ) >> 18 ) | 0xf0 ),
                           char( ( ( utf32 & 0x03f000 ) >> 12 ) | 0x80 ),
                           char( ( ( utf32 & 0x000fc0 ) >> 6  ) | 0x80 ),
                           char( ( ( utf32 & 0x00003f )       ) | 0x80 ) };
            string.append( tmp, sizeof( tmp ) );
            return true;
         }
         return false;
      }

      // This function MUST only be called for characters matching pegtl::ascii::xdigit!
      template< typename I >
      I unhex_char( const char c )
      {
         switch ( c ) {
            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
               return I( c - '0' );
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
               return I( c - 'a' + 10 );
            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
               return I( c - 'A' + 10 );
         }
         assert( false );  // LCOV_EXCL_LINE
      }

      template< typename I >
      I unhex_string( const char * begin, const char * const end )
      {
         I r = 0;
         while ( begin != end ) {
            r <<= 4;
            r += unhex_char< I >( *begin++ );
         }
         return r;
      }

      // Actions for common unescape situations.

      struct append_all
      {
         template< typename Input, typename State >
         static void apply( const Input & in, State & st )
         {
            st.unescaped.append( in.begin(), in.size() );
         }
      };

      // This function MUST be called for a character matching T which must be pegtl::one< ... >.
      template< typename T, char ... Rs >
      struct unescape_c
      {
         template< typename Input, typename State >
         static void apply( const Input & in, State & st )
         {
            assert( in.size() == 1 );
            st.unescaped += apply_one( * in.begin(), static_cast< const T * >( nullptr ) );
         }

         template< char ... Qs >
         static char apply_one( const char c, const one< Qs ... > * )
         {
            static_assert( sizeof ... ( Qs ) == sizeof ... ( Rs ), "size mismatch between escaped characters and their mappings" );
            return apply_two( c, { Qs ... }, { Rs ... } );
         }

         static char apply_two( const char c, const std::initializer_list< char > & q, const std::initializer_list< char > & r )
         {
            for ( std::size_t i = 0; i < q.size(); ++i ) {
               if ( * ( q.begin() + i ) == c ) {
                  return * ( r.begin() + i );
               }
            }
            assert( false );  // LCOV_EXCL_LINE
         }
      };

      // See examples/unescape.cc to see why the following two actions
      // have the convenience of skipping the first input character...

      struct unescape_u
      {
         template< typename Input, typename State >
         static void apply( const Input & in, State & st )
         {
            assert( ! in.empty() );  // First character MUST be present, usually 'u' or 'U'.
            if ( ! utf8_append_utf32( st.unescaped, unhex_string< unsigned >( in.begin() + 1, in.end() ) ) ) {
               throw parse_error( "invalid escaped unicode code point", in );
            }
         }
      };

      struct unescape_x
      {
         template< typename Input, typename State >
         static void apply( const Input & in, State & st )
         {
            assert( ! in.empty() );  // First character MUST be present, usually 'x'.
            st.unescaped += unhex_string< char >( in.begin() + 1, in.end() );
         }
      };

      // Like unescape_u, but (a) assumes 4 hexdigits per code point,
      // and (b) accepts multiple consecutive escaped 16-bit values.
      // It encodes UTF-16 surrogate pairs as single UTF-8 sequence
      // as required for JSON by RFC 7159.

      struct unescape_j
      {
         template< typename Input, typename State >
         static void apply( const Input & in, State & st )
         {
            assert( ( ( in.size() + 1 ) % 6 ) == 0 );  // Expects multiple "\\u1234" with the first backslash already skipped.
            for ( const char * b = in.begin() + 1; b < in.end(); b += 6 ) {
               const auto c = unhex_string< unsigned >( b, b + 4 );
               if ( ( 0xd800 <= c ) && ( c <= 0xdbff ) && ( b + 6 < in.end() ) ) {
                  const auto d = unhex_string< unsigned >( b + 6, b + 10 );
                  if ( ( 0xdc00 <= d ) && ( d <= 0xdfff ) ) {
                     b += 6;
                     utf8_append_utf32( st.unescaped, ( ( ( c & 0x03ff ) << 10 ) | ( d & 0x03ff ) ) + 0x10000 );
                     continue;
                  }
               }
               utf8_append_utf32( st.unescaped, c );
            }
         }
      };

   } // unescape

} // pegtl

#endif

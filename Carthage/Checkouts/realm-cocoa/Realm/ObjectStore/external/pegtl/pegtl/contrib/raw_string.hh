// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_CONTRIB_RAW_STRING_HH
#define PEGTL_CONTRIB_RAW_STRING_HH

#include "../apply_mode.hh"
#include "../nothing.hh"

#include "../internal/must.hh"
#include "../internal/until.hh"
#include "../internal/state.hh"
#include "../internal/skip_control.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< char Open, char Intermediate, char Close >
      struct raw_string_tag
      { };

      template< typename Tag >
      struct raw_string_state
      {
         template< typename Input, typename ... States >
         raw_string_state( const Input & in, States && ... )
               : line( in.line() ),
                 column( in.column() ),
                 size( in.size() )
         { }

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         typename std::enable_if< ( ( A == apply_mode::ACTION ) && ( ! is_nothing< Action, Tag >::value ) ) >::type
         success( const Input & in, States && ... st ) const
         {
            Input content( line, column, in.begin() - ( size - in.size() ), in.begin() - count, in.source() );
            const bool skip = ( content.peek_char( count ) == '\n' );
            content.bump( count + skip );
            Action< Tag >::apply( const_cast< const Input & >( content ), st ... );
         }

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         typename std::enable_if< ! ( ( A == apply_mode::ACTION ) && ( ! is_nothing< Action, Tag >::value ) ) >::type
         success( const Input &, States && ... ) const
         { }

         raw_string_state( const raw_string_state & ) = delete;
         void operator= ( const raw_string_state & ) = delete;

         std::size_t line;
         std::size_t column;
         std::size_t size;
         std::size_t count = 0;
      };

      template< typename Tag, char Open, char Intermediate >
      struct raw_string_open
      {
         using analyze_t = analysis::generic< analysis::rule_type::ANY >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input >
         static bool match( Input & in, raw_string_state< Tag > & ls )
         {
            if ( in.empty() || ( in.peek_char( 0 ) != Open ) ) {
               return false;
            }
            for ( std::size_t i = 1; i < in.size(); ++i ) {
               switch ( const auto c = in.peek_char( i ) ) {
                  case Open:
                     ls.count = i + 1;
                     in.bump( ls.count );
                     return true;
                  case Intermediate:
                     break;
                  default:
                     return false;
               }
            }
            return false;
         }
      };

      template< typename Tag, char Intermediate, char Close >
      struct raw_string_close
      {
         using analyze_t = analysis::generic< analysis::rule_type::ANY >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input >
         static bool match( Input & in, const raw_string_state< Tag > & ls )
         {
            if ( in.size() < ls.count ) {
               return false;
            }
            if ( in.peek_char( 0 ) != Close ) {
               return false;
            }
            if ( in.peek_char( ls.count - 1 ) != Close ) {
               return false;
            }
            for ( std::size_t i = 0; i < ls.count - 2; ++i ) {
               if ( in.peek_char( i + 1 ) != Intermediate ) {
                  return false;
               }
            }
            in.bump( ls.count );
            return true;
         }
      };

      template< typename Tag, char Open, char Intermediate >
      struct skip_control< raw_string_open< Tag, Open, Intermediate > > : std::true_type {};

      template< typename Tag, char Intermediate, char Close >
      struct skip_control< raw_string_close< Tag, Intermediate, Close > > : std::true_type {};

   } // internal

   // raw_string matches Lua-style long literals.
   //
   // The following description was taken from the Lua documentation
   // (see http://www.lua.org/docs.html):
   //
   // - An "opening long bracket of level n" is defined as an opening square
   //   bracket followed by n equal signs followed by another opening square
   //   bracket. So, an opening long bracket of level 0 is written as `[[`,
   //   an opening long bracket of level 1 is written as `[=[`, and so on.
   // - A "closing long bracket" is defined similarly; for instance, a closing
   //   long bracket of level 4 is written as `]====]`.
   // - A "long literal" starts with an opening long bracket of any level and
   //   ends at the first closing long bracket of the same level. It can
   //   contain any text except a closing bracket of the same level.
   // - Literals in this bracketed form can run for several lines, do not
   //   interpret any escape sequences, and ignore long brackets of any other
   //   level.
   // - For convenience, when the opening long bracket is immediately followed
   //   by a newline, the newline is not included in the string.
   //
   // Note that unlike Lua's long literal, a raw_string is customizable to use
   // other characters than `[`, `=` and `]` for matching. Also note that Lua
   // introduced newline-specific replacements in Lua 5.2, which we do not
   // support on the grammar level.

   template< char Open, char Intermediate, char Close, typename Tag = internal::raw_string_tag< Open, Intermediate, Close > >
   struct raw_string : state< internal::raw_string_state< Tag >,
                              internal::raw_string_open< Tag, Open, Intermediate >,
                              internal::must< internal::until< internal::raw_string_close< Tag, Intermediate, Close > > > >
   {
      // This is used to bind an action to the content
      using content = Tag;

      // This is used for error-reporting when a raw string is not closed properly
      using close = internal::until< internal::raw_string_close< Tag, Intermediate, Close > >;
   };

} // pegtl

#endif

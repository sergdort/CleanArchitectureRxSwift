// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_NORMAL_HH
#define PEGTL_NORMAL_HH

#include "apply_mode.hh"
#include "parse_error.hh"

#include "internal/demangle.hh"
#include "internal/rule_match_one.hh"

namespace pegtl
{
   template< typename Rule >
   struct normal
   {
      template< typename Input, typename ... States >
      static void start( const Input &, States && ... )
      { }

      template< typename Input, typename ... States >
      static void success( const Input &, States && ... )
      { }

      template< typename Input, typename ... States >
      static void failure( const Input &, States && ... )
      { }

      template< typename Input, typename ... States >
      static void raise( const Input & in, States && ... )
      {
         throw pegtl::parse_error( "parse error matching " + internal::demangle< Rule >(), in );
      }

      template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
      static bool match( Input & in, States && ... st )
      {
         return internal::rule_match_one< Rule, A, Action, Control >::match( in, st ... );
      }
   };

} // pegtl

#endif

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_RULE_MATCH_TWO_HH
#define PEGTL_INTERNAL_RULE_MATCH_TWO_HH

#include "../apply_mode.hh"
#include "../nothing.hh"

#include "rule_match_three.hh"

namespace pegtl
{
   namespace internal
   {
      // The purpose of rule_match_two is to call all necessary debug hooks of
      // the control class and, if applicable, also call the action class'
      // apply()-method. The latter can be disabled either explicitly (via
      // disable<>) or implicitly by at<> or not_at<>.

      template< typename Rule,
                apply_mode A,
                template< typename ... > class Action,
                template< typename ... > class Control,
                bool apply_here = ( ( A == apply_mode::ACTION ) && ( ! is_nothing< Action, Rule >::value ) ) >
      struct rule_match_two;

      template< typename Rule, apply_mode A, template< typename ... > class Action, template< typename ... > class Control >
      struct rule_match_two< Rule, A, Action, Control, false >
      {
         template< typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            Control< Rule >::start( const_cast< const Input & >( in ), st ... );

            if ( rule_match_three< Rule, A, Action, Control >::match( in, st ... ) ) {
               Control< Rule >::success( const_cast< const Input & >( in ), st ... );
               return true;
            }
            Control< Rule >::failure( const_cast< const Input & >( in ), st ... );
            return false;
         }
      };

      template< typename Rule, apply_mode A, template< typename ... > class Action, template< typename ... > class Control >
      struct rule_match_two< Rule, A, Action, Control, true >
      {
         template< typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            auto m = in.mark();

            if ( rule_match_two< Rule, A, Action, Control, false >::match( in, st ... ) ) {
               Action< Rule >::apply( Input( in.data(), m ), st ... );
               return m( true );
            }
            return false;
         }
      };

   } // internal

} // pegtl

#endif

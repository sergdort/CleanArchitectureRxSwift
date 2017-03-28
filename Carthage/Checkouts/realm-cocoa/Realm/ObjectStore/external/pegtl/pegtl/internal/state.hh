// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_STATE_HH
#define PEGTL_INTERNAL_STATE_HH

#include "seq.hh"
#include "rule_match_three.hh"
#include "skip_control.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename State, typename ... Rules >
      struct state
      {
         using analyze_t = analysis::generic< analysis::rule_type::SEQ, Rules ... >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static auto success( State & s, const Input & in, States && ... st ) -> decltype( s.template success< A, Action, Control >( in, st ... ), void() )
         {
            s.template success< A, Action, Control >( in, st ... );
         }

         // NOTE: The additional "int = 0" is a work-around for missing expression SFINAE in VS2015.

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States, int = 0 >
         static auto success( State & s, const Input & in, States && ... st ) -> decltype( s.success( in, st ... ), void() )
         {
            s.success( in, st ... );
         }

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            State s( const_cast< const Input & >( in ), st ... );
            if ( rule_match_three< seq< Rules ... >, A, Action, Control >::match( in, s ) ) {
               success< A, Action, Control >( s, in, st ... );
               return true;
            }
            return false;
         }
      };

      template< typename State, typename ... Rules >
      struct skip_control< state< State, Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

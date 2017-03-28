// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_ACTION_HH
#define PEGTL_INTERNAL_ACTION_HH

#include "skip_control.hh"
#include "seq.hh"
#include "rule_match_three.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< template< typename ... > class Action, typename ... Rules >
      struct action
      {
         using analyze_t = analysis::generic< analysis::rule_type::SEQ, Rules ... >;

         template< apply_mode A, template< typename ... > class, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            return rule_match_three< seq< Rules ... >, A, Action, Control >::match( in, st ... );
         }
      };

      template< template< typename ... > class Action, typename ... Rules >
      struct skip_control< action< Action, Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

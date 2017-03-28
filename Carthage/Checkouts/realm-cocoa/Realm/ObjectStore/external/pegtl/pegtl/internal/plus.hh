// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_PLUS_HH
#define PEGTL_INTERNAL_PLUS_HH

#include "seq.hh"
#include "opt.hh"
#include "skip_control.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      // While plus<> could easily be implemented with
      // seq< Rule, Rules ..., star< Rule, Rules ... > > we
      // provide an explicit implementation to optimize away
      // the otherwise created input mark.

      template< typename Rule, typename ... Rules >
      struct plus
      {
         using analyze_t = analysis::generic< analysis::rule_type::SEQ, Rule, Rules ..., opt< plus > >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            return rule_match_three< seq< Rule, Rules ... >, A, Action, Control >::match( in, st ... ) && rule_match_three< star< Rule, Rules ... >, A, Action, Control >::match( in, st ... );
         }
      };

      template< typename Rule, typename ... Rules >
      struct skip_control< plus< Rule, Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

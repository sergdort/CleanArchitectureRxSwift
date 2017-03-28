// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_STAR_HH
#define PEGTL_INTERNAL_STAR_HH

#include "seq.hh"
#include "opt.hh"
#include "skip_control.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename Rule, typename ... Rules >
      struct star
      {
         using analyze_t = analysis::generic< analysis::rule_type::OPT, Rule, Rules ..., star >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            while ( ( ! in.empty() ) && rule_match_three< seq< Rule, Rules ... >, A, Action, Control >::match( in, st ... ) ) {}
            return true;
         }
      };

      template< typename Rule, typename ... Rules >
      struct skip_control< star< Rule, Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

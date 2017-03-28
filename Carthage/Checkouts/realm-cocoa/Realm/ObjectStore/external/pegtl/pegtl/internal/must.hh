// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_MUST_HH
#define PEGTL_INTERNAL_MUST_HH

#include "seq.hh"
#include "raise.hh"
#include "skip_control.hh"

namespace pegtl
{
   namespace internal
   {
      // The general case simply applies must<> to each member of the
      // 'Rules' parameter pack individually, below is the specialization
      // which implements the case for a single rule.

      template< typename ... Rules >
      struct must
            : seq< must< Rules > ... > {};

      // While in theory the implementation for a single rule could
      // be simplified to must< Rule > = sor< Rule, raise< Rule > >, this
      // would result in some unnecessary run-time overhead.

      template< typename Rule >
      struct must< Rule >
      {
         using analyze_t = typename Rule::analyze_t;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            if ( ! Control< Rule >::template match< A, Action, Control >( in, st ... ) ) {
               raise< Rule >::template match< A, Action, Control >( in, st ... );
            }
            return true;
         }
      };

      template< typename ... Rules >
      struct skip_control< must< Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

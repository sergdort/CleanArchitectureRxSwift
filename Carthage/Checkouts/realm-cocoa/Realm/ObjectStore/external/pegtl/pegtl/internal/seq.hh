// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_SEQ_HH
#define PEGTL_INTERNAL_SEQ_HH

#include "trivial.hh"
#include "skip_control.hh"
#include "rule_conjunction.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename ... Rules > struct seq;

      template< typename ... Rules >
      struct skip_control< seq< Rules ... > > : std::true_type {};

      template<>
      struct seq<>
            : trivial< true > {};

      template< typename Rule >
      struct seq< Rule >
      {
         using analyze_t = typename Rule::analyze_t;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            return Control< Rule >::template match< A, Action, Control >( in, st ... );
         }
      };

      template< typename ... Rules >
      struct seq
      {
         using analyze_t = analysis::generic< analysis::rule_type::SEQ, Rules ... >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            auto m = in.mark();
            return m( rule_conjunction< Rules ... >::template match< A, Action, Control >( in, st ... ) );
         }
      };

   } // internal

} // pegtl

#endif

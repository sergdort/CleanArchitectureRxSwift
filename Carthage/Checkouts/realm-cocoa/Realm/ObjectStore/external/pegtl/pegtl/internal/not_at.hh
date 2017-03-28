// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_NOT_AT_HH
#define PEGTL_INTERNAL_NOT_AT_HH

#include "trivial.hh"
#include "skip_control.hh"
#include "rule_conjunction.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename ... Rules > struct not_at;

      template< typename ... Rules >
      struct skip_control< not_at< Rules ... > > : std::true_type {};

      template<>
      struct not_at<>
            : trivial< false > {};

      template< typename ... Rules >
      struct not_at
      {
         using analyze_t = analysis::generic< analysis::rule_type::OPT, Rules ... >;

         template< apply_mode, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
            auto m = in.mark();
            return ! rule_conjunction< Rules ... >::template match< apply_mode::NOTHING, Action, Control >( in, st ... );
         }
      };

   } // internal

} // pegtl

#endif

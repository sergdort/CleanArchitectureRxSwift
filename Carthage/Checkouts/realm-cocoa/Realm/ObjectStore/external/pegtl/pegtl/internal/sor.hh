// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_SOR_HH
#define PEGTL_INTERNAL_SOR_HH

#include "../apply_mode.hh"
#include "skip_control.hh"

#include "../analysis/generic.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename ... Rules >
      struct sor
      {
         using analyze_t = analysis::generic< analysis::rule_type::SOR, Rules ... >;

         template< apply_mode A, template< typename ... > class Action, template< typename ... > class Control, typename Input, typename ... States >
         static bool match( Input & in, States && ... st )
         {
#ifdef __cpp_fold_expressions
            return ( Control< Rules >::template match< A, Action, Control >( in, st ... ) || ... );
#else
            bool result = false;
            using swallow = bool[];
            (void)swallow{ result = result || Control< Rules >::template match< A, Action, Control >( in, st ... ) ..., true };
            return result;
#endif
         }
      };

      template< typename ... Rules >
      struct skip_control< sor< Rules ... > > : std::true_type {};

   } // internal

} // pegtl

#endif

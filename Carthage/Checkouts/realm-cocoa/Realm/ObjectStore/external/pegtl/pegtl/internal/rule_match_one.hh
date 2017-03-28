// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_RULE_MATCH_ONE_HH
#define PEGTL_INTERNAL_RULE_MATCH_ONE_HH

#include "../apply_mode.hh"

#include "skip_control.hh"
#include "rule_match_two.hh"
#include "rule_match_three.hh"

namespace pegtl
{
   namespace internal
   {
      // Forward to rule_match_two<> for all user-defined / -visible rules,
      // but skip rule_match_two<> (which calls the control class' callbacks)
      // and forward directly to rule_match_three<> when a rule is marked as
      // an internal rule by skip_control<>.

      template< typename Rule,
                apply_mode A,
                template< typename ... > class Action,
                template< typename ... > class Control,
                bool = skip_control< Rule >::value >
      struct rule_match_one;

      template< typename Rule, apply_mode A, template< typename ... > class Action, template< typename ... > class Control >
      struct rule_match_one< Rule, A, Action, Control, false >
            : rule_match_two< Rule, A, Action, Control >
      { };

      template< typename Rule, apply_mode A, template< typename ... > class Action, template< typename ... > class Control >
      struct rule_match_one< Rule, A, Action, Control, true >
            : rule_match_three< Rule, A, Action, Control >
      { };

   } // internal

} // pegtl

#endif

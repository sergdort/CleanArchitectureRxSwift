// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_RULE_MATCH_THREE_HH
#define PEGTL_INTERNAL_RULE_MATCH_THREE_HH

#include "../apply_mode.hh"

namespace pegtl
{
   namespace internal
   {
      // The purpose of rule_match_three<> is to allow for two different
      // signatures of a rule's match()-method. A more complicated but
      // more general version which takes the explicit template parameters
      // for A, Action and Control, and a more simple and limited version
      // which takes the input as its only parameter. The latter is often
      // sufficient and helps to keep the overhead smaller.

      template< typename Rule, apply_mode A, template< typename ... > class Action, template< typename ... > class Control >
      struct rule_match_three
      {
         template< typename Input, typename ... States >
         static auto match( Input & in, States && ... st ) -> decltype( Rule::template match< A, Action, Control >( in, st ... ), true )
         {
            return Rule::template match< A, Action, Control >( in, st ... );
         }

         // NOTE: The additional "int = 0" is a work-around for missing expression SFINAE in VS2015.

         template< typename Input, typename ... States, int = 0 >
         static auto match( Input & in, States && ... ) -> decltype( Rule::match( in ), true )
         {
            return Rule::match( in );
         }
      };

   } // internal

} // pegtl

#endif

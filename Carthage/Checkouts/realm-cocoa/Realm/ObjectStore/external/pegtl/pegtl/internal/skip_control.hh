// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_SKIP_CONTROL_HH
#define PEGTL_INTERNAL_SKIP_CONTROL_HH

#include <type_traits>

namespace pegtl
{
   namespace internal
   {
      // This class is a simple tagging mechanism.
      // By default, skip_control< Rule >::value
      // is 'false'. Each internal (!) rule that should
      // be hidden from the control and action class'
      // callbacks simply specializes skip_control<>
      // to return 'true' for the above expression.
      // This is then used in rule_match_one.hh.

      template< typename Rule >
      struct skip_control : std::false_type {};

   } // internal

} // pegtl

#endif

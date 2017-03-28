// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_ANALYSIS_COUNTED_HH
#define PEGTL_ANALYSIS_COUNTED_HH

#include "generic.hh"

namespace pegtl
{
   namespace analysis
   {
      template< rule_type Type, unsigned Count, typename ... Rules >
      struct counted
            : generic< Count ? Type : rule_type::OPT, Rules ... >
      { };

   } // analysis

} // pegtl

#endif

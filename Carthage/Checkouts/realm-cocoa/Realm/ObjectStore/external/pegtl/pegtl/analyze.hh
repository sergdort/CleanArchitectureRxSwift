// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_ANALYZE_HH
#define PEGTL_ANALYZE_HH

#include "analysis/analyze_cycles.hh"

namespace pegtl
{
   template< typename Rule >
   std::size_t analyze( const bool verbose = true )
   {
      return analysis::analyze_cycles< Rule >( verbose ).problems();
   }

} // pegtl

#endif

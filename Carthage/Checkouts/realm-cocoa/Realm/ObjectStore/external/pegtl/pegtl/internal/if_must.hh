// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_IF_MUST_HH
#define PEGTL_INTERNAL_IF_MUST_HH

#include "seq.hh"
#include "must.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename Cond, typename ... Thens >
      using if_must = seq< Cond, must< Thens ... > >;

   } // internal

} // pegtl

#endif

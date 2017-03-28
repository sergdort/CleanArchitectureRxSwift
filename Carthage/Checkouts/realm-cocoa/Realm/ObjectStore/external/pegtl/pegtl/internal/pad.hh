// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_PAD_HH
#define PEGTL_INTERNAL_PAD_HH

#include "seq.hh"
#include "star.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename Rule, typename Pad1, typename Pad2 = Pad1 >
      using pad = seq< star< Pad1 >, Rule, star< Pad2 > >;

   } // internal

} // pegtl

#endif

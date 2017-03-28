// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_LIST_TAIL_PAD_HH
#define PEGTL_INTERNAL_LIST_TAIL_PAD_HH

#include "seq.hh"
#include "list.hh"
#include "pad.hh"
#include "opt.hh"
#include "star.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename Rule, typename Sep, typename Pad >
      using list_tail_pad = seq< list< Rule, pad< Sep, Pad > >, opt< star< Pad >, Sep > >;

   } // internal

} // pegtl

#endif

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

#include "verify_ifmt.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_ifmt< if_must_else >( result_type::GLOBAL_FAILURE );
   }

} // pegtl

#include "main.hh"

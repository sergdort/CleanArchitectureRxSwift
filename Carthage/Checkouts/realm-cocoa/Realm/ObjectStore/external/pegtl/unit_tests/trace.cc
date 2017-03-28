// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

#include <pegtl/trace.hh>

namespace pegtl
{
   using GRAMMAR = pegtl::sor< pegtl::failure, pegtl::one< 'a' > >;

   void unit_test()
   {
      failed = ! pegtl::trace< GRAMMAR >( "ab", "trace test please ignore" );
   }

} // pegtl

#include "main.hh"

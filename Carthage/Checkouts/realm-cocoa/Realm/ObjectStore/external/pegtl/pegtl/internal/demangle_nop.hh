// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_DEMANGLE_NOP_HH
#define PEGTL_INTERNAL_DEMANGLE_NOP_HH

#include <string>

namespace pegtl
{
   namespace internal
   {
      inline std::string demangle( const char * symbol )
      {
         return symbol;
      }

   } // internal

} // pegtl

#endif

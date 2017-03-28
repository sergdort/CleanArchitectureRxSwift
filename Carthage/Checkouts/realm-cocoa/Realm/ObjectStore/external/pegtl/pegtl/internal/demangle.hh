// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_DEMANGLE_HH
#define PEGTL_INTERNAL_DEMANGLE_HH

#include <string>
#include <typeinfo>

#if defined(__GLIBCXX__)
#include "demangle_cxxabi.hh"
#elif defined(__has_include)
#if __has_include(<cxxabi.h>)
#include "demangle_cxxabi.hh"
#else
#include "demangle_nop.hh"
#endif
#else
#include "demangle_nop.hh"
#endif

namespace pegtl
{
   namespace internal
   {
      template< typename T >
      std::string demangle()
      {
         return demangle( typeid( T ).name() );
      }

   } // internal

} // pegtl

#endif

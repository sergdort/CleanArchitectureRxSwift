// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_TRACE_HH
#define PEGTL_TRACE_HH

#include <utility>
#include <iostream>

#include "parse.hh"
#include "normal.hh"
#include "nothing.hh"
#include "position_info.hh"

#include "internal/demangle.hh"

namespace pegtl
{
   template< typename Rule >
   struct tracer
         : normal< Rule >
   {
      template< typename Input, typename ... States >
      static void start( const Input & in, States && ... )
      {
         std::cerr << pegtl::position_info( in ) << "  start  " << internal::demangle< Rule >() << std::endl;
      }

      template< typename Input, typename ... States >
      static void success( const Input & in, States && ... )
      {
         std::cerr << pegtl::position_info( in ) << " success " << internal::demangle< Rule >() << std::endl;
      }

      template< typename Input, typename ... States >
      static void failure( const Input & in, States && ... )
      {
         std::cerr << pegtl::position_info( in ) << " failure " << internal::demangle< Rule >() << std::endl;
      }
   };

   template< typename Rule, template< typename ... > class Action = nothing, typename Input, typename ... States >
   bool trace_input( Input & in, States && ... st )
   {
      return parse_input< Rule, Action, tracer >( in, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, typename ... Args >
   bool trace( Args && ... args )
   {
      return parse< Rule, Action, tracer >( std::forward< Args >( args ) ... );
   }

} // pegtl

#endif

// Copyright (c) 2014-2016 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_PARSE_HH
#define PEGTL_PARSE_HH

#include <string>
#include <cstring>
#include <sstream>

#include "input.hh"

#include "normal.hh"
#include "nothing.hh"

#include "apply_mode.hh"

namespace pegtl
{
   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename Input, typename ... States >
   bool parse_input( Input & in, States && ... st )
   {
      return Control< Rule >::template match< apply_mode::ACTION, Action, Control >( in, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename ... States >
   bool parse( const int argc, char ** argv, States && ... st )
   {
      std::ostringstream os;
      os << "argv[" << argc << ']';
      const std::string source = os.str();
      input in( 1, 0, argv[ argc ], argv[ argc ] + ::strlen( argv[ argc ] ), source.c_str() );
      return parse_input< Rule, Action, Control >( in, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename ... States >
   bool parse( const char * data, const char * dend, const char * source, States && ... st )
   {
      input in( 1, 0, data, dend, source );
      return parse_input< Rule, Action, Control >( in, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename ... States >
   bool parse( const char * data, const std::size_t size, const char * source, States && ... st )
   {
      return parse< Rule, Action, Control >( data, data + size, source, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename ... States >
   bool parse( const std::string & data, const std::string & source, States && ... st )
   {
      return parse< Rule, Action, Control >( data.data(), data.data() + data.size(), source.c_str(), st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename Input, typename ... States >
   bool parse_nested( const Input & nest, const char * data, const char * dend, const char * source, States && ... st )
   {
      input in( 1, 0, data, dend, source, & nest );
      return parse_input< Rule, Action, Control >( in, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename Input, typename ... States >
   bool parse_nested( const Input & nest, const char * data, const std::size_t size, const char * source, States && ... st )
   {
      return parse_nested< Rule, Action, Control >( nest, data, data + size, source, st ... );
   }

   template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename Input, typename ... States >
   bool parse_nested( const Input & nest, const std::string & data, const std::string & source, States && ... st )
   {
      return parse_nested< Rule, Action, Control >( nest, data.data(), data.data() + data.size(), source.c_str(), st ... );
   }

} // pegtl

#endif

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_EXAMPLES_JSON_UNESCAPE_HH
#define PEGTL_EXAMPLES_JSON_UNESCAPE_HH

#include <string>

#include <pegtl.hh>
#include <pegtl/contrib/json.hh>
#include <pegtl/contrib/unescape.hh>

namespace examples
{
   // State base class to store an unescaped string

   struct unescape_state_base
   {
      unescape_state_base() = default;

      unescape_state_base( const unescape_state_base & ) = delete;
      void operator= ( const unescape_state_base & ) = delete;

      std::string unescaped;
   };

   // Action class for parsing literal strings, uses the PEGTL unescape utilities, cf. unescape.cc.

   template< typename Rule, template< typename ... > class Base = pegtl::nothing >
   struct unescape_action : Base< Rule > {};

   template<> struct unescape_action< pegtl::json::unicode > : pegtl::unescape::unescape_j {};
   template<> struct unescape_action< pegtl::json::escaped_char > : pegtl::unescape::unescape_c< pegtl::json::escaped_char, '"', '\\', '/', '\b', '\f', '\n', '\r', '\t' > {};
   template<> struct unescape_action< pegtl::json::unescaped > : pegtl::unescape::append_all {};

} // examples

#endif

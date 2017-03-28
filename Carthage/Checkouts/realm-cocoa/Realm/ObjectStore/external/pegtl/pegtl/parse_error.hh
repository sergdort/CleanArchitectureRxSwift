// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_PARSE_ERROR_HH
#define PEGTL_PARSE_ERROR_HH

#include <vector>
#include <sstream>
#include <stdexcept>

#include "position_info.hh"

namespace pegtl
{
   namespace internal
   {
      template< typename Input >
      std::vector< position_info > positions( const Input & in )
      {
         std::vector< position_info > result;
         for ( const auto * id = & in.data(); id; id = id->from ) {
            result.push_back( pegtl::position_info( * id ) );
         }
         return result;
      }

      template< typename Input >
      std::string source( const Input & in )
      {
         std::ostringstream oss;
         oss << pegtl::position_info( in.data() );
         return oss.str();
      }

   } // internal

   struct parse_error
         : std::runtime_error
   {
      parse_error( const std::string & message, std::vector< position_info > && positions )
            : std::runtime_error( message ),
              positions( std::move( positions ) )
      { }

      template< typename Input >
      parse_error( const std::string & message, const Input & in )
            : std::runtime_error( internal::source( in ) + ": " + message ),
              positions( internal::positions( in ) )
      { }

      std::vector< position_info > positions;
   };

} // pegtl

#endif

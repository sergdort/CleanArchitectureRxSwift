// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_READ_PARSER_HH
#define PEGTL_READ_PARSER_HH

#include "data_parser.hh"

#include "internal/file_reader.hh"

namespace pegtl
{
   class read_parser
         : public data_parser
   {
   public:
      explicit
      read_parser( const std::string & filename )
            : data_parser( internal::file_reader( filename ).read(), filename )
      { }

      read_parser( const std::string & filename, const pegtl::input & from )
            : data_parser( internal::file_reader( filename ).read(), filename, from )
      { }
   };

} // pegtl

#endif

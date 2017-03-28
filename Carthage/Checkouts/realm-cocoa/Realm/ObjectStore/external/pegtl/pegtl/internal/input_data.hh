// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_INPUT_DATA_HH
#define PEGTL_INTERNAL_INPUT_DATA_HH

#include <cstdlib>

namespace pegtl
{
   namespace internal
   {
      struct input_data
      {
         input_data( const std::size_t line, const std::size_t column, const char * begin, const char * end, const char * source, const input_data * from = 0 )
               : line( line ),
                 column( column ),
                 begin( begin ),
                 end( end ),
                 source( source ),
                 from( from )
         { }

         std::size_t line;
         std::size_t column;

         const char * begin;
         const char * end;
         const char * source;

         const input_data * from;
      };

   } // internal

} // pegtl

#endif

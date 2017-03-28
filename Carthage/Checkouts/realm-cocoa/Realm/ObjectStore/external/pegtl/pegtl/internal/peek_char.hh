// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_PEEK_CHAR_HH
#define PEGTL_INTERNAL_PEEK_CHAR_HH

#include <cstddef>

#include "input_pair.hh"

namespace pegtl
{
   namespace internal
   {
      struct peek_char
      {
         using data_t = char;
         using pair_t = input_pair< char >;

         template< typename Input >
         static pair_t peek( Input & in, const std::size_t o = 0 )
         {
            return { in.peek_char( o ), 1 };
         }
      };

   } // internal

} // pegtl

#endif

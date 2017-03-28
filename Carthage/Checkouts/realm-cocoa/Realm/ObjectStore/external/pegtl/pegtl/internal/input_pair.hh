// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_INPUT_PAIR_HH
#define PEGTL_INTERNAL_INPUT_PAIR_HH

namespace pegtl
{
   namespace internal
   {
      template< typename Data >
      struct input_pair
      {
         Data data;
         unsigned char size;

         using data_t = Data;

         explicit operator bool () const
         {
            return size > 0;
         }
      };

   } // internal

} // pegtl

#endif

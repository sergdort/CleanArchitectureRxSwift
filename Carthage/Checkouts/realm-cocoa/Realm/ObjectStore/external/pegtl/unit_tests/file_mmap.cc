// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <pegtl.hh>

// pegtl.hh makes sure you can test for _POSIX_MAPPED_FILES

#if defined(_POSIX_MAPPED_FILES)

#include "test.hh"

#include "verify_file.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_file< mmap_parser >();
   }

} // pegtl

#include "main.hh"

#else

int main( int, char ** )
{
   return 0;
}

#endif

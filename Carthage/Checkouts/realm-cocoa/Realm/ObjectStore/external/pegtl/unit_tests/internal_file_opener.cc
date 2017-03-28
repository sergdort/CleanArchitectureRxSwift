// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      const internal::file_opener fo( "Makefile" );
      ::close( fo.m_fd );  // Provoke exception, nobody would normally do this.
      try {
         fo.size();
         std::cerr << "pegtl: unit test failed for [ internal::file_opener ] " << std::endl;
         ++failed;
      }
      catch ( const std::exception & ) {
      }
   }

} // pegtl

#include "main.hh"

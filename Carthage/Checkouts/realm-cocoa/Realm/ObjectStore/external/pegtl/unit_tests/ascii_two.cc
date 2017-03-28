// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< two< 'a' > >( __LINE__, __FILE__, true, false );

      verify_rule< two< 'a' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< two< 'a' > >( __LINE__, __FILE__, "a", result_type::LOCAL_FAILURE, 1 );
      verify_rule< two< 'a' > >( __LINE__, __FILE__, "ab", result_type::LOCAL_FAILURE, 2 );
      verify_rule< two< 'a' > >( __LINE__, __FILE__, "aa", result_type::SUCCESS, 0 );
      verify_rule< two< 'a' > >( __LINE__, __FILE__, "aaa", result_type::SUCCESS, 1 );
      verify_rule< two< 'a' > >( __LINE__, __FILE__, "aaaa", result_type::SUCCESS, 2 );
   }

} // pegtl

#include "main.hh"

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_IMPL_HH
#define PEGTL_UNIT_TESTS_VERIFY_IMPL_HH

#include <string>
#include <cstdlib>

#include "test_failed.hh"
#include "verify_help.hh"

namespace pegtl
{
   template< typename Rule >
   void verify_impl( const std::size_t line, const char * file, const std::string & data, const result_type expected, const std::size_t remain )
   {
      pegtl::input i( line, 0, data.data(), data.data() + data.size(), file );

      const result_type received = verify_help< Rule >( i );

      if ( ( received == expected ) && ( ( received == result_type::GLOBAL_FAILURE ) || ( i.size() == remain ) ) ) {
         return;
      }
      TEST_FAILED( "input data [ '" << data << "' ] result received/expected [ " << received << " / " << expected << " ] remain received/expected [ " << i.size() << " / " << remain << " ]" );
   }

} // pegtl

#endif

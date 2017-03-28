// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_VERIFY_HELP_HH
#define PEGTL_UNIT_TESTS_VERIFY_HELP_HH

#include <cassert>

#include "result_type.hh"

namespace pegtl
{
   template< typename Rule, typename Input >
   result_type verify_help( Input & i )
   {
      try {
         if ( normal< Rule >::template match< apply_mode::ACTION, nothing, normal >( i ) ) {
            return result_type::SUCCESS;
         }
         return result_type::LOCAL_FAILURE;
      }
      catch ( const std::exception & ) {
         return result_type::GLOBAL_FAILURE;
      }
      catch ( ... ) {
         assert( false );
      }
   }

} // pegtl

#endif

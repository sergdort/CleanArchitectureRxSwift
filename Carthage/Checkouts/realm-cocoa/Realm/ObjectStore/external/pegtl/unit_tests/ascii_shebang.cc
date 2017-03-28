// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< shebang >( __LINE__, __FILE__, true, false );

      verify_rule< shebang >( __LINE__, __FILE__,  "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#", result_type::LOCAL_FAILURE, 1 );
      verify_rule< shebang >( __LINE__, __FILE__,  "!", result_type::LOCAL_FAILURE, 1 );
      verify_rule< shebang >( __LINE__, __FILE__,  "!#", result_type::LOCAL_FAILURE, 2 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#  ", result_type::LOCAL_FAILURE, 3 );
      verify_rule< shebang >( __LINE__, __FILE__,  "!  ", result_type::LOCAL_FAILURE, 3 );
      verify_rule< shebang >( __LINE__, __FILE__,  "## ", result_type::LOCAL_FAILURE, 3 );
      verify_rule< shebang >( __LINE__, __FILE__,  "!! ", result_type::LOCAL_FAILURE, 3 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!", result_type::SUCCESS, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#! ", result_type::SUCCESS, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!/bin/bash", result_type::SUCCESS, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!/bin/bash\n", result_type::SUCCESS, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!/bin/bash\n#!/b", result_type::SUCCESS, 4 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!\n", result_type::SUCCESS, 0 );
      verify_rule< shebang >( __LINE__, __FILE__,  "#!\n ", result_type::SUCCESS, 1 );
   }

} // pegtl

#include "main.hh"

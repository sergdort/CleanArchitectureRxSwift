// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_ANALYSIS_RULE_INFO_HH
#define PEGTL_ANALYSIS_RULE_INFO_HH

#include <string>
#include <vector>

#include "rule_type.hh"

namespace pegtl
{
   namespace analysis
   {
      struct rule_info
      {
         explicit
         rule_info( const rule_type type )
               : type( type )
         { }

         rule_type type;
         std::vector< std::string > rules;
      };

   } // analysis

} // pegtl

#endif

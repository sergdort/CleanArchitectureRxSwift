// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_ANALYSIS_INSERT_RULES_HH
#define PEGTL_ANALYSIS_INSERT_RULES_HH

#include "rule_info.hh"
#include "grammar_info.hh"

namespace pegtl
{
   namespace analysis
   {
      template< typename ... > struct insert_rules;

      template<>
      struct insert_rules<>
      {
         static void insert( grammar_info &, rule_info & )
         { }
      };

      template< typename Rule, typename ... Rules >
      struct insert_rules< Rule, Rules ... >
      {
         static void insert( grammar_info & g, rule_info & r )
         {
            r.rules.push_back( Rule::analyze_t::template insert< Rule >( g ) );
            insert_rules< Rules ... >::insert( g, r );
         }
      };

   } // analysis

} // pegtl

#endif

// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_TEST_HH
#define PEGTL_UNIT_TESTS_TEST_HH

#include <cstddef>
#include <cassert>
#include <iostream>

#include <pegtl.hh>

namespace pegtl
{
   std::size_t failed = 0;
   std::vector< std::pair< std::string, std::string > > applied;

} // pegtl

#include "test_action.hh"
#include "test_assert.hh"
#include "test_control.hh"
#include "test_failed.hh"

#include "verify_rule.hh"
#include "verify_char.hh"
#include "verify_fail.hh"

#include "verify_analyze.hh"

#endif

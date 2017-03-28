// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UNIT_TESTS_TEST_FAILED_HH
#define PEGTL_UNIT_TESTS_TEST_FAILED_HH

#include <iostream>

#define TEST_FAILED( MeSSaGe )                          \
   do {                                                 \
      std::cerr << "pegtl: unit test failed for [ "     \
                << internal::demangle< Rule >()         \
                << " ] "                                \
                << MeSSaGe                              \
                << " in line [ "                        \
                << line                                 \
                << " ] file [ "                         \
                << file << " ]"                         \
                << std::endl;                           \
      ++failed;                                         \
   } while ( 0 )

#endif

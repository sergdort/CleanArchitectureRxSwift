// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

#include <pegtl/contrib/alphabet.hh>

namespace pegtl
{
   void unit_test()
   {
      TEST_ASSERT( alphabet::a == 'a' );
      TEST_ASSERT( alphabet::b == 'b' );
      TEST_ASSERT( alphabet::c == 'c' );
      TEST_ASSERT( alphabet::d == 'd' );
      TEST_ASSERT( alphabet::e == 'e' );
      TEST_ASSERT( alphabet::f == 'f' );
      TEST_ASSERT( alphabet::g == 'g' );
      TEST_ASSERT( alphabet::h == 'h' );
      TEST_ASSERT( alphabet::i == 'i' );
      TEST_ASSERT( alphabet::j == 'j' );
      TEST_ASSERT( alphabet::k == 'k' );
      TEST_ASSERT( alphabet::l == 'l' );
      TEST_ASSERT( alphabet::m == 'm' );
      TEST_ASSERT( alphabet::n == 'n' );
      TEST_ASSERT( alphabet::o == 'o' );
      TEST_ASSERT( alphabet::p == 'p' );
      TEST_ASSERT( alphabet::q == 'q' );
      TEST_ASSERT( alphabet::r == 'r' );
      TEST_ASSERT( alphabet::s == 's' );
      TEST_ASSERT( alphabet::t == 't' );
      TEST_ASSERT( alphabet::u == 'u' );
      TEST_ASSERT( alphabet::v == 'v' );
      TEST_ASSERT( alphabet::w == 'w' );
      TEST_ASSERT( alphabet::x == 'x' );
      TEST_ASSERT( alphabet::y == 'y' );
      TEST_ASSERT( alphabet::z == 'z' );

      TEST_ASSERT( alphabet::A == 'A' );
      TEST_ASSERT( alphabet::B == 'B' );
      TEST_ASSERT( alphabet::C == 'C' );
      TEST_ASSERT( alphabet::D == 'D' );
      TEST_ASSERT( alphabet::E == 'E' );
      TEST_ASSERT( alphabet::F == 'F' );
      TEST_ASSERT( alphabet::G == 'G' );
      TEST_ASSERT( alphabet::H == 'H' );
      TEST_ASSERT( alphabet::I == 'I' );
      TEST_ASSERT( alphabet::J == 'J' );
      TEST_ASSERT( alphabet::K == 'K' );
      TEST_ASSERT( alphabet::L == 'L' );
      TEST_ASSERT( alphabet::M == 'M' );
      TEST_ASSERT( alphabet::N == 'N' );
      TEST_ASSERT( alphabet::O == 'O' );
      TEST_ASSERT( alphabet::P == 'P' );
      TEST_ASSERT( alphabet::Q == 'Q' );
      TEST_ASSERT( alphabet::R == 'R' );
      TEST_ASSERT( alphabet::S == 'S' );
      TEST_ASSERT( alphabet::T == 'T' );
      TEST_ASSERT( alphabet::U == 'U' );
      TEST_ASSERT( alphabet::V == 'V' );
      TEST_ASSERT( alphabet::W == 'W' );
      TEST_ASSERT( alphabet::X == 'X' );
      TEST_ASSERT( alphabet::Y == 'Y' );
      TEST_ASSERT( alphabet::Z == 'Z' );
   }

} // pegtl

#include "main.hh"

// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_UTF16_HH
#define PEGTL_UTF16_HH

#include "internal/rules.hh"
#include "internal/peek_utf16.hh"
#include "internal/result_on_found.hh"

namespace pegtl
{
   namespace utf16
   {
      struct any : internal::any< internal::peek_utf16 > {};
      template< char32_t ... Cs > struct not_one : internal::one< internal::result_on_found::FAILURE, internal::peek_utf16, Cs ... > {};
      template< char32_t Lo, char32_t Hi > struct not_range : internal::range< internal::result_on_found::FAILURE, internal::peek_utf16, Lo, Hi > {};
      template< char32_t ... Cs > struct one : internal::one< internal::result_on_found::SUCCESS, internal::peek_utf16, Cs ... > {};
      template< char32_t Lo, char32_t Hi > struct range : internal::range< internal::result_on_found::SUCCESS, internal::peek_utf16, Lo, Hi > {};
      template< char32_t ... Cs > struct ranges : internal::ranges< internal::peek_utf16, Cs ... > {};

   } // utf16

} // pegtl

#endif

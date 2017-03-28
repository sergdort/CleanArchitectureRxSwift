// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< alnum >( __LINE__, __FILE__, true, false );
      verify_analyze< alpha >( __LINE__, __FILE__, true, false );
      verify_analyze< any >( __LINE__, __FILE__, true, false );
      verify_analyze< blank >( __LINE__, __FILE__, true, false );
      verify_analyze< digit >( __LINE__, __FILE__, true, false );
      verify_analyze< eol >( __LINE__, __FILE__, true, false );
      verify_analyze< identifier_first >( __LINE__, __FILE__, true, false );
      verify_analyze< identifier_other >( __LINE__, __FILE__, true, false );
      verify_analyze< lower >( __LINE__, __FILE__, true, false );
      verify_analyze< nul >( __LINE__, __FILE__, true, false );
      verify_analyze< print >( __LINE__, __FILE__, true, false );
      verify_analyze< seven >( __LINE__, __FILE__, true, false );
      verify_analyze< space >( __LINE__, __FILE__, true, false );
      verify_analyze< upper >( __LINE__, __FILE__, true, false );
      verify_analyze< xdigit >( __LINE__, __FILE__, true, false );

      verify_analyze< not_one< 'a' > >( __LINE__, __FILE__, true, false );
      verify_analyze< not_one< 'a', 'z' > >( __LINE__, __FILE__, true, false );
      verify_analyze< not_range< 'a', 'z' > >( __LINE__, __FILE__, true, false );
      verify_analyze< one< 'a' > >( __LINE__, __FILE__, true, false );
      verify_analyze< one< 'a', 'z' > >( __LINE__, __FILE__, true, false );
      verify_analyze< range< 'a', 'z' > >( __LINE__, __FILE__, true, false );
      verify_analyze< ranges< 'a', 'z' > >( __LINE__, __FILE__, true, false );
      verify_analyze< ranges< 'a', 'z', '4' > >( __LINE__, __FILE__, true, false );

      verify_rule< alnum >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< alpha >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< any >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< blank >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< digit >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< eol >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< identifier_first >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< identifier_other >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< lower >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< nul >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< print >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< seven >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< space >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< upper >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< xdigit >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );

      verify_rule< not_one< 'a' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< not_one< 'a', 'z' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< not_range< 'a' ,'z' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< one< 'a' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< one< 'a', 'z' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< range< 'a', 'z' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< ranges< 'a', 'z' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< ranges< 'a', 'z', '4' > >( __LINE__, __FILE__, "", result_type::LOCAL_FAILURE, 0 );

      for ( int i = -100; i < 200; ++i ) {
         const bool is_blank = ( i == ' ' ) || ( i == '\t' );
         const bool is_digit = ( '0' <= i ) && ( i <= '9' );
         const bool is_lower = ( 'a' <= i ) && ( i <= 'z' );
         const bool is_print = ( ( ' ' <= i ) && ( i <= 126 ) );
         const bool is_seven = ( ( i >= 0 ) && ( i <= 127 ) );
         const bool is_space = ( i == '\n' ) || ( i == '\r' ) || ( i == '\v' ) || ( i == '\f' );
         const bool is_upper = ( 'A' <= i ) && ( i <= 'Z' );
         const bool is_xalpha = ( ( 'a' <= i ) && ( i <= 'f' ) ) || ( ( 'A' <= i ) && ( i <= 'F' ) );

         const bool is_newline = ( i == '\n' );

         const bool is_ident_first = ( i == '_' ) || is_lower || is_upper;
         const bool is_ident_other = is_ident_first || is_digit;

         verify_char< alnum >( __LINE__, __FILE__, i, is_lower || is_upper || is_digit );
         verify_char< alpha >( __LINE__, __FILE__, i, is_lower || is_upper );
         verify_char< any >( __LINE__, __FILE__, i, true );
         verify_char< blank >( __LINE__, __FILE__, i, is_blank );
         verify_char< digit >( __LINE__, __FILE__, i, is_digit );
         verify_char< eol >( __LINE__, __FILE__, i, is_newline );
         verify_char< identifier_first >( __LINE__, __FILE__, i, is_ident_first );
         verify_char< identifier_other >( __LINE__, __FILE__, i, is_ident_other );
         verify_char< lower >( __LINE__, __FILE__, i, is_lower );
         verify_char< nul >( __LINE__, __FILE__, i, i == 0 );
         verify_char< print >( __LINE__, __FILE__, i, is_print );
         verify_char< seven >( __LINE__, __FILE__, i, is_seven );
         verify_char< space >( __LINE__, __FILE__, i, is_blank || is_space );
         verify_char< upper >( __LINE__, __FILE__, i, is_upper );
         verify_char< xdigit >( __LINE__, __FILE__, i, is_digit || is_xalpha );

         const bool is_one = ( i == '#' ) || ( i == 'a' ) || ( i == ' ' );
         const bool is_range = ( 20 <= i ) && ( i <= 120 );
         const bool is_ranges = is_range || ( i == 3 );

         verify_char< not_one< 'P' > >( __LINE__, __FILE__, i, i != 'P' );
         verify_char< not_one< 'a', '#', ' ' > >( __LINE__, __FILE__, i, ! is_one );
         verify_char< not_range< 20, 120 > >( __LINE__, __FILE__, i, ! is_range );
         verify_char< one< 'T' > >( __LINE__, __FILE__, i, i == 'T' );
         verify_char< one< 'a', '#', ' ' > >( __LINE__, __FILE__, i, is_one );
         verify_char< range< 20, 120 > >( __LINE__, __FILE__, i, is_range );
         verify_char< ranges< 20, 120 > >( __LINE__, __FILE__, i, is_range );
         verify_char< ranges< 20, 120, 3 > >( __LINE__, __FILE__, i, is_ranges );

         verify_char< eolf >( __LINE__, __FILE__, i, is_newline );
      }
   }

} // pegtl

#include "main.hh"

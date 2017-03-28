// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <iostream>

#include <pegtl.hh>
#include <pegtl/analyze.hh>
#include <pegtl/file_parser.hh>

namespace sexpr
{
   using namespace pegtl;

   struct hash_comment
         : until< eolf > {};

   struct list;

   struct list_comment
         : if_must< at< one< '(' > >, disable< list > > {};

   struct read_include
         : seq< one< ' ' >, one< '"' >, plus< not_one< '"' > >, one< '"' > > {};

   struct hash_include
         : if_must< string< 'i', 'n', 'c', 'l', 'u', 'd', 'e' >, read_include > {};

   struct hashed
         : if_must< one< '#' >, sor< hash_include, list_comment, hash_comment > > {};

   struct number
         : plus< digit > {};

   struct symbol
         : identifier {};

   struct atom
         : sor< number, symbol > {};

   struct anything;

   struct list
         : if_must< one< '(' >, until< one< ')' >, anything > > {};

   struct normal
         : sor< atom, list > {};

   struct anything
         : sor< space, hashed, normal > {};

   struct main
         : until< eof, must< anything > > {};

   template< typename Rule > struct action : nothing< Rule > {};

   template<>
   struct action< plus< not_one< '"' > > >
   {
      template< typename Input >
      static void apply( const Input & in, std::string & fn )
      {
         fn = in.string();
      }
   };

   template<>
   struct action< hash_include >
   {
      template< typename Input >
      static void apply( const Input & in, std::string & fn )
      {
         std::string f2;
         // Here f2 is the state argument for the nested parsing
         // run (to store the value of the string literal like in
         // the upper-level parsing run), fn is the value of the
         // last string literal that we use as filename here, and
         // the input is passed on for chained error messages (as
         // in "error in line x file foo included from file bar...)
         file_parser( fn, in ).parse< main, sexpr::action >( f2 );
      }
   };

} // sexpr

int main( int argc, char ** argv )
{
   pegtl::analyze< sexpr::main >();

   for ( int i = 1; i < argc; ++i ) {
      std::string fn;
      pegtl::parse< sexpr::main, sexpr::action >( i, argv, fn );
   }
   return 0;
}

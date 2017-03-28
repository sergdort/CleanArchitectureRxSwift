// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <vector>

#include <pegtl.hh>
#include <pegtl/contrib/json.hh>
#include <pegtl/contrib/changes.hh>

#include "json_errors.hh"
#include "json_classes.hh"
#include "json_unescape.hh"

namespace examples
{
   // State class that stores the result of a JSON parsing run -- a single JSON object.
   // The other members are used temporarily, at the end of a (successful) parsing run
   // they are expected to be empty.

   struct json_state
   {
      std::shared_ptr< json_base > result;
      std::vector< std::string > keys;
      std::vector< std::shared_ptr< array_json > > arrays;
      std::vector< std::shared_ptr< object_json > > objects;
   };

   // Action and Control classes

   template< typename Rule > struct action : unescape_action< Rule > {};  // Inherit from json_unescape.hh.
   template< typename Rule > struct control : errors< Rule > {};  // Inherit from json_errors.hh.

   template<>
   struct action< pegtl::json::null >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.result = std::make_shared< null_json >();
      }
   };

   template<>
   struct action< pegtl::json::true_ >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.result = std::make_shared< boolean_json >( true );
      }
   };

   template<>
   struct action< pegtl::json::false_ >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.result = std::make_shared< boolean_json >( false );
      }
   };

   template<>
   struct action< pegtl::json::number >
   {
      static void apply( const pegtl::input & in, json_state & state )
      {
         state.result = std::make_shared< number_json >( std::stold( in.string() ) );  // NOTE: stold() is not quite correct for JSON but we'll use it for this simple example.
      }
   };

   // To parse a string, we change the state to decouple string parsing/unescaping

   struct string_state
         : public unescape_state_base
   {
      void success( json_state & state )
      {
         state.result = std::make_shared< string_json >( unescaped );
      }
   };

   template<>
   struct control< pegtl::json::string::content > : pegtl::change_state< pegtl::json::string::content, string_state, errors > {};

   template<>
   struct action< pegtl::json::array::begin >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.arrays.push_back( std::make_shared< array_json >() );
      }
   };

   template<>
   struct action< pegtl::json::array::element >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.arrays.back()->data.push_back( std::move( state.result ) );
      }
   };

   template<>
   struct action< pegtl::json::array::end >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.result = std::move( state.arrays.back() );
         state.arrays.pop_back();
      }
   };

   template<>
   struct action< pegtl::json::object::begin >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.objects.push_back( std::make_shared< object_json >() );
      }
   };

   // To parse a key, we change the state to decouple string parsing/unescaping

   struct key_state : unescape_state_base
   {
      void success( json_state & state )
      {
         state.keys.push_back( std::move( unescaped ) );
      }
   };

   template<>
   struct control< pegtl::json::key::content > : pegtl::change_state< pegtl::json::key::content, key_state, errors > {};

   template<>
   struct action< pegtl::json::object::element >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.objects.back()->data[ std::move( state.keys.back() ) ] = std::move( state.result );
         state.keys.pop_back();
      }
   };

   template<>
   struct action< pegtl::json::object::end >
   {
      static void apply( const pegtl::input &, json_state & state )
      {
         state.result = std::move( state.objects.back() );
         state.objects.pop_back();
      }
   };

   using grammar = pegtl::must< pegtl::json::text, pegtl::eof >;
}

int main( int argc, char ** argv )
{
   if ( argc != 2 ) {
     std::cerr << "usage: " << argv[ 0 ] << " <json>";
   }
   else {
      examples::json_state state;
      pegtl::file_parser( argv[ 1 ] ).parse< examples::grammar, examples::action, examples::control >( state );
      assert( state.keys.empty() );
      assert( state.arrays.empty() );
      assert( state.objects.empty() );
      std::cout << state.result << std::endl;
   }
   return 0;
}

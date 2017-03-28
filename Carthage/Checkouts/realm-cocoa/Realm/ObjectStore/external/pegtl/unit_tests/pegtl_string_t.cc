// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <type_traits>

#include <pegtl.hh>
#include <pegtl/contrib/alphabet.hh>

namespace test
{
   // We only need to test that this compiles...

   struct foo : pegtl_string_t( "foo" ) {};
   struct foobar : pegtl::sor< pegtl_string_t( "foo" ), pegtl_string_t( "bar" ) > {};

   static_assert( std::is_same< pegtl_string_t( "Hello" ), pegtl::string< 'H', 'e', 'l', 'l', 'o' > >::value, "pegtl_string_t broken" );
   static_assert( ! std::is_same< pegtl_istring_t( "Hello" ), pegtl::string< 'H', 'e', 'l', 'l', 'o' > >::value, "pegtl_istring_t broken" );
   static_assert( std::is_same< pegtl_istring_t( "Hello" ), pegtl::istring< 'H', 'e', 'l', 'l', 'o' > >::value, "pegtl_istring_t broken" );

   using namespace pegtl::alphabet;

   // The strings currently have a maximum length of 100 characters.

   static_assert( std::is_same< pegtl_string_t( "abcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxy" ),
                  pegtl::string< a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y > >::value, "pegtl_string_t broken" );

} // test

int main()
{
   return 0;
}

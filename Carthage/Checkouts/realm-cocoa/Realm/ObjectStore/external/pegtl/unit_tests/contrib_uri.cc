// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include <cassert>

#include <pegtl.hh>
#include <pegtl/analyze.hh>
#include <pegtl/contrib/uri.hh>

using GRAMMAR = pegtl::must< pegtl::uri::URI, pegtl::eof >;

void test( const std::string& in )
{
   pegtl::parse< GRAMMAR >( in, "test" );
}

void fail( const std::string& in )
{
   try {
      pegtl::parse< GRAMMAR >( in, "expect_exception" );
      std::cerr << "FAILED: " << in << std::endl;
      assert( false );
   }
   catch( ... ) {
   }
}

int main( int, char ** )
{
   // ensure the grammar does not contain any obvious problems
   pegtl::analyze< GRAMMAR >();

   // some unit tests that should work
   test( "http://de.wikipedia.org/wiki/Uniform_Resource_Identifier" );
   test( "ftp://ftp.is.co.za/rfc/rfc1808.txt" );
   test( "file:///C:/Users/Benutzer/Desktop/Uniform%20Resource%20Identifier.html" );
   test( "file:///etc/fstab" );
   test( "geo:48.33,14.122;u=22.5" );
   test( "ldap://[2001:db8::7]/c=GB?objectClass?one" );
   test( "gopher://gopher.floodgap.com" );
   test( "mailto:John.Doe@example.com" );
   test( "sip:911@pbx.mycompany.com" );
   test( "news:comp.infosystems.www.servers.unix" );
   test( "data:text/plain;charset=iso-8859-7,%be%fa%be" );
   test( "tel:+1-816-555-1212" );
   test( "telnet://192.0.2.16:80/" );
   test( "urn:oasis:names:specification:docbook:dtd:xml:4.1.2" );
   test( "git://github.com/rails/rails.git" );
   test( "crid://broadcaster.com/movies/BestActionMovieEver" );
   test( "http://nobody:password@example.org:8080/cgi-bin/script.php?action=submit&pageid=86392001#section_2" );

   // some unit tests that should fail
   fail( "" );
   return 0;
}

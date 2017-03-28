// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_FILE_READER_HH
#define PEGTL_INTERNAL_FILE_READER_HH

#include <cstdio>
#include <memory>

#include "../input_error.hh"

namespace pegtl
{
   namespace internal
   {
      class file_reader
      {
      public:
         explicit
         file_reader( const std::string & filename )
               : m_source( filename ),
                 m_file( open(), & std::fclose )
         { }

         file_reader( const file_reader & ) = delete;
         void operator= ( const file_reader & ) = delete;

         std::size_t size() const
         {
            errno = 0;
            if ( std::fseek( m_file.get(), 0, SEEK_END ) ) {
               PEGTL_THROW_INPUT_ERROR( "unable to fseek() to end of file " << m_source );  // LCOV_EXCL_LINE
            }
            errno = 0;
            const auto s = std::ftell( m_file.get() );
            if ( s < 0 ) {
               PEGTL_THROW_INPUT_ERROR( "unable to ftell() file size of file " << m_source );  // LCOV_EXCL_LINE
            }
            errno = 0;
            if ( std::fseek( m_file.get(), 0, SEEK_SET ) ) {
               PEGTL_THROW_INPUT_ERROR( "unable to fseek() to beginning of file " << m_source );  // LCOV_EXCL_LINE
            }
            return s;
         }

         std::string read() const
         {
            std::string nrv;
            nrv.resize( size() );
            errno = 0;
            if ( nrv.size() && ( std::fread( & nrv[ 0 ], nrv.size(), 1, m_file.get() ) != 1 ) ) {
               PEGTL_THROW_INPUT_ERROR( "unable to fread() file " << m_source << " size " << nrv.size() );  // LCOV_EXCL_LINE
            }
            return nrv;
         }

      private:
         const std::string m_source;
         const std::unique_ptr< std::FILE, decltype( & std::fclose ) > m_file;

         std::FILE * open() const
         {
            errno = 0;
            if ( auto * file = std::fopen( m_source.c_str(), "r" ) ) {
               return file;
            }
            PEGTL_THROW_INPUT_ERROR( "unable to fopen() file " << m_source << " for reading" );
         }
      };

   } // internal

} // pegtl

#endif

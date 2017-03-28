// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_FILE_OPENER_HH
#define PEGTL_INTERNAL_FILE_OPENER_HH

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "../input_error.hh"

namespace pegtl
{
   namespace internal
   {
      struct file_opener
      {
         explicit
         file_opener( const std::string & filename )
               : m_source( filename ),
                 m_fd( open() )
         { }

         ~file_opener()
         {
            ::close( m_fd );
         }

         file_opener( const file_opener & ) = delete;
         void operator= ( const file_opener & ) = delete;

         std::size_t size() const
         {
            struct stat st;
            errno = 0;
            if ( ::fstat( m_fd, & st ) < 0 ) {
               PEGTL_THROW_INPUT_ERROR( "unable to fstat() file " << m_source << " descriptor " << m_fd );
            }
            return std::size_t( st.st_size );
         }

         const std::string m_source;
         const int m_fd;

      private:
         int open() const
         {
            errno = 0;
            const int fd = ::open( m_source.c_str(), O_RDONLY );
            if ( fd >= 0 ) {
               return fd;
            }
            PEGTL_THROW_INPUT_ERROR( "unable to open() file " << m_source << " for reading" );
         }
      };

   } // internal

} // pegtl

#endif

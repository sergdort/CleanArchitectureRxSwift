// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INPUT_HH
#define PEGTL_INPUT_HH

#include <string>
#include <cstddef>

#include "internal/input_data.hh"
#include "internal/input_mark.hh"

namespace pegtl
{
   class input
   {
   public:
      explicit
      input( const internal::input_data & data )
            : m_data( data )
      { }

      input( const internal::input_data & data, const internal::input_mark & mark )
            : m_data( mark.m_line, mark.m_column, mark.m_begin, data.begin, data.source, data.from )
      { }

      input( const std::size_t line, const std::size_t column, const char * begin, const char * end, const char * source, const input * from = nullptr )
            : m_data( line, column, begin, end, source, from ? ( & from->m_data ) : nullptr )
      { }

      bool empty() const
      {
         return m_data.begin == m_data.end;
      }

      std::size_t size() const
      {
         return m_data.end - m_data.begin;
      }

      const char * begin() const
      {
         return m_data.begin;
      }

      const char * end() const
      {
         return m_data.end;
      }

      std::size_t line() const
      {
         return m_data.line;
      }

      std::size_t column() const
      {
         return m_data.column;
      }

      const char * source() const
      {
         return m_data.source;
      }

      std::string string() const
      {
         return std::string( m_data.begin, m_data.end );
      }

      char peek_char( const std::size_t offset = 0 ) const
      {
         return m_data.begin[ offset ];
      }

      unsigned char peek_byte( const std::size_t offset = 0 ) const
      {
         return static_cast< unsigned char >( peek_char( offset ) );
      }

      void bump( const std::size_t count = 1 )
      {
         for ( std::size_t i = 0; i < count; ++i ) {
            bump_unsafe();
         }
      }

      void bump_in_line( const std::size_t count = 1 )
      {
         m_data.begin += count;
         m_data.column += count;
      }

      bool bump_if()
      {
         if ( ! empty() ) {
            bump_unsafe();
            return true;
         }
         return false;
      }

      internal::input_mark mark()
      {
         return internal::input_mark( m_data );
      }

      const internal::input_data & data() const
      {
         return m_data;
      }

   private:
      internal::input_data m_data;

      void bump_unsafe()
      {
         switch ( * m_data.begin ) {
            case '\n':
               ++m_data.line;
               m_data.column = 0;
               break;
            default:
               ++m_data.column;
               break;
         }
         ++m_data.begin;
      }
   };

} // pegtl

#endif

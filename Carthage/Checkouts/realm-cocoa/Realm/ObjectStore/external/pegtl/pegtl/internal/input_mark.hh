// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INTERNAL_INPUT_MARK_HH
#define PEGTL_INTERNAL_INPUT_MARK_HH

#include "input_data.hh"

namespace pegtl
{
   namespace internal
   {
      class input_mark
      {
      public:
         explicit
         input_mark( input_data & i )
               : m_line( i.line ),
                 m_column( i.column ),
                 m_begin( i.begin ),
                 m_input( & i )
         { }

         input_mark( input_mark && i )
               : m_line( i.m_line ),
                 m_column( i.m_column ),
                 m_begin( i.m_begin ),
                 m_input( i.m_input )
         {
            i.m_input = nullptr;
         }

         ~input_mark()
         {
            if ( m_input ) {
               m_input->line = m_line;
               m_input->column = m_column;
               m_input->begin = m_begin;
            }
         }

         input_mark( const input_mark & ) = delete;
         void operator= ( const input_mark & ) = delete;

         bool success()
         {
            m_input = nullptr;
            return true;
         }

         bool failure()
         {
            m_input->line = m_line;
            m_input->column = m_column;
            m_input->begin = m_begin;
            m_input = nullptr;
            return false;
         }

         bool operator() ( const bool result )
         {
            return result ? success() : failure();
         }

      public:
         const std::size_t m_line;
         const std::size_t m_column;
         const char * const m_begin;
         input_data * m_input;
      };

   } // internal

} // pegtl

#endif

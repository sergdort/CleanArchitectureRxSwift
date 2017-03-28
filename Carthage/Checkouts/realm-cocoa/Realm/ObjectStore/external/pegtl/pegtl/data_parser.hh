// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_DATA_PARSER_HH
#define PEGTL_DATA_PARSER_HH

#include <string>
#include <utility>

#include "parse.hh"
#include "input.hh"
#include "normal.hh"
#include "nothing.hh"

namespace pegtl
{
   class data_parser
   {
   public:
      data_parser( std::string data, std::string source, const std::size_t line = 1, const std::size_t column = 0 )
            : m_data( std::move( data ) ),
              m_source( std::move( source ) ),
              m_input( line, column, m_data.data(), m_data.data() + m_data.size(), m_source.c_str() )
      { }

      data_parser( std::string data, std::string source, const pegtl::input & from, const std::size_t line = 1, const std::size_t column = 0 )
            : m_data( std::move( data ) ),
              m_source( std::move( source ) ),
              m_input( line, column, m_data.data(), m_data.data() + m_data.size(), m_source.c_str(), & from )
      { }

      const std::string & source() const
      {
         return m_source;
      }

      const pegtl::input & input() const
      {
         return m_input;
      }

      template< typename Rule, template< typename ... > class Action = nothing, template< typename ... > class Control = normal, typename ... States >
      bool parse( States && ... st )
      {
         return parse_input< Rule, Action, Control >( m_input, st ... );
      }

   private:
      std::string m_data;
      std::string m_source;
      pegtl::input m_input;
   };

} // pegtl

#endif

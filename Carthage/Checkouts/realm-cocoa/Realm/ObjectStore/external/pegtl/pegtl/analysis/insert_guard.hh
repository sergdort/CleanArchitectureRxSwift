// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_ANALYSIS_INSERT_GUARD_HH
#define PEGTL_ANALYSIS_INSERT_GUARD_HH

namespace pegtl
{
   namespace analysis
   {
      template< typename C >
      class insert_guard
      {
      public:
         insert_guard( insert_guard && g )
               : m_i( g.m_i ),
                 m_c( g.m_c )
         {
            g.m_c = 0;
         }

         insert_guard( C & c, const typename C::value_type & t )
               : m_i( c.insert( t ) ),
                 m_c( & c )
         { }

         ~insert_guard()
         {
            if ( m_c && m_i.second ) {
               m_c->erase( m_i.first );
            }
         }

         insert_guard( const insert_guard & ) = delete;
         void operator= ( const insert_guard & ) = delete;

         explicit operator bool () const
         {
            return m_i.second;
         }

      private:
         const std::pair< typename C::iterator, bool > m_i;
         C * m_c;
      };

      template< typename C, typename T >
      insert_guard< C > make_insert_guard( C & c, const T & t )
      {
         return insert_guard< C >( c, t );
      }

   } // analysis

} // pegtl

#endif

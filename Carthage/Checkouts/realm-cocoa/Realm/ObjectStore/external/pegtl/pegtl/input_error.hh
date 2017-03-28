// Copyright (c) 2014-2016 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_INPUT_ERROR_HH
#define PEGTL_INPUT_ERROR_HH

#include <sstream>
#include <stdexcept>
#include <cerrno>

namespace pegtl
{
   struct input_error
         : std::runtime_error
   {
      input_error( const std::string & message, const int errorno )
            : std::runtime_error( message ),
              errorno( errorno )
      { }

      int errorno;
   };

#define PEGTL_THROW_INPUT_ERROR( MESSAGE )                              \
   do {                                                                 \
      const int errorno = errno;                                        \
      std::ostringstream oss;                                           \
      oss << "pegtl: " << MESSAGE << " errno " << errorno;              \
      throw pegtl::input_error( oss.str(), errorno );                   \
   } while ( false )

} // pegtl

#endif

// Copyright (c) 2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_FILE_PARSER_HH
#define PEGTL_FILE_PARSER_HH

#include "read_parser.hh"

#if defined (__unix__) || (defined (__APPLE__) && defined (__MACH__))
#include <unistd.h>  // Required for _POSIX_MAPPED_FILES
#endif

#if defined(_POSIX_MAPPED_FILES)
#include "mmap_parser.hh"
#endif

namespace pegtl
{
#if defined(_POSIX_MAPPED_FILES)
   using file_parser = mmap_parser;
#else
   using file_parser = read_parser;
#endif
} // pegtl

#endif

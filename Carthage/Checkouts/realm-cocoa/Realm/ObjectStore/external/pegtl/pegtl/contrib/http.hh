// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#ifndef PEGTL_CONTRIB_HTTP_HH
#define PEGTL_CONTRIB_HTTP_HH

#include "../rules.hh"
#include "../ascii.hh"
#include "../utf8.hh"
#include "abnf.hh"
#include "uri.hh"

namespace pegtl
{
   namespace http
   {
      // HTTP 1.1 grammar according to RFC 7230.

      // This grammar is a direct PEG translation of the original HTTP grammar.
      // It should be considered experimental -- in case of any issues, in particular
      // missing anchor rules for actions, please contact the developers.

      using namespace abnf;

      using OWS = star< WSP >; // optional whitespace
      using RWS = plus< WSP >; // required whitespace
      using BWS = OWS; // "bad" whitespace

      using obs_text = not_range< 0x00, 0x7F >;
      using obs_fold = seq< CRLF, plus< WSP > >;

      struct tchar : sor< ALPHA, DIGIT, one< '!', '#', '$', '%', '&', '\'', '*', '+', '-', '.', '^', '_', '`', '|', '~' > > {};
      struct token : plus< tchar > {};

      struct field_name : token {};

      struct field_vchar : sor< VCHAR, obs_text > {};
      struct field_content : list< field_vchar, plus< WSP > > {};
      struct field_value : star< sor< field_content, obs_fold > > {};

      struct header_field : seq< field_name, one< ':' >, OWS, field_value, OWS > {};

      struct method : token {};

      struct absolute_path : plus< one< '/' >, uri::segment > {};

      struct origin_form : seq< absolute_path, uri::opt_query >  {};
      struct absolute_form : uri::absolute_URI {};
      struct authority_form : uri::authority {};
      struct asterisk_form : one< '*' > {};

      struct request_target : sor< origin_form, absolute_form, authority_form, asterisk_form > {};

      struct status_code : rep< 3, DIGIT > {};
      struct reason_phrase : star< sor< VCHAR, obs_text, WSP > > {};

      struct HTTP_version : if_must< pegtl_string_t( "HTTP/" ), DIGIT, one< '.' >, DIGIT > {};

      struct request_line : if_must< method, SP, request_target, SP, HTTP_version, CRLF > {};
      struct status_line : if_must< HTTP_version, SP, status_code, SP, reason_phrase, CRLF > {};
      struct start_line : sor< request_line, status_line > {};

      struct message_body : star< OCTET > {};
      struct HTTP_message : seq< start_line, star< header_field, CRLF >, CRLF, opt< message_body > > {};

      struct Content_Length : plus< DIGIT > {};

      struct uri_host : uri::host {};
      struct port : uri::port {};

      struct Host : seq< uri_host, opt< one< ':' >, port > > {};

      // PEG are different from CFGs! (this replaces ctext and qdtext)
      using text = sor< HTAB, range< 0x20, 0x7E >, obs_text >;

      struct quoted_pair : if_must< one< '\\' >, sor< VCHAR, obs_text, WSP > > {};
      struct quoted_string : if_must< DQUOTE, until< DQUOTE, sor< quoted_pair, text > > > {};

      struct transfer_parameter : seq< token, BWS, one< '=' >, BWS, sor< token, quoted_string > > {};
      struct transfer_extension : seq< token, star< OWS, one< ';' >, OWS, transfer_parameter > > {};
      struct transfer_coding : sor< pegtl_istring_t( "chunked" ),
                                    pegtl_istring_t( "compress" ),
                                    pegtl_istring_t( "deflate" ),
                                    pegtl_istring_t( "gzip" ),
                                    transfer_extension > {};

      struct rank : sor< seq< one< '0' >, opt< one< '.' >, rep_opt< 3, DIGIT > > >,
                         seq< one< '1' >, opt< one< '.' >, rep_opt< 3, one< '0' > > > > > {};

      struct t_ranking : seq< OWS, one< ';' >, OWS, one< 'q', 'Q' >, one< '=' >, rank > {};
      struct t_codings : sor< pegtl_istring_t( "trailers" ), seq< transfer_coding, opt< t_ranking > > > {};

      struct TE : opt< sor< one< ',' >, t_codings >, star< OWS, one< ',' >, opt< OWS, t_codings > > > {};

      template< typename T >
      using make_comma_list = seq< star< one< ',' >, OWS >, T, star< OWS, one< ',' >, opt< OWS, T > > >;

      struct connection_option : token {};
      struct Connection : make_comma_list< connection_option > {};

      struct Trailer : make_comma_list< field_name > {};

      struct Transfer_Encoding : make_comma_list< transfer_coding > {};

      struct protocol_name : token {};
      struct protocol_version : token {};
      struct protocol : seq< protocol_name, opt< one< '/' >, protocol_version > > {};
      struct Upgrade : make_comma_list< protocol > {};

      struct pseudonym : token {};

      struct received_protocol : seq< opt< protocol_name, one< '/' > >, protocol_version > {};
      struct received_by : sor< seq< uri_host, opt< one< ':' >, port > >, pseudonym > {};

      struct comment : if_must< one< '(' >, until< one< ')' >, sor< comment, quoted_pair, text > > > {};

      struct Via : make_comma_list< seq< received_protocol, RWS, received_by, opt< RWS, comment > > > {};

      struct http_URI : if_must< pegtl_istring_t( "http://" ), uri::authority, uri::path_abempty, uri::opt_query, uri::opt_fragment > {};
      struct https_URI : if_must< pegtl_istring_t( "https://" ), uri::authority, uri::path_abempty, uri::opt_query, uri::opt_fragment > {};

      struct partial_URI : seq< uri::relative_part, uri::opt_query > {};

      struct chunk_size : plus< HEXDIG > {};

      struct chunk_ext_name : token {};
      struct chunk_ext_val : sor< quoted_string, token > {};
      struct chunk_ext : star< if_must< one< ';' >, chunk_ext_name, if_must< one< '=' >, chunk_ext_val > > > {};

      struct chunk_data : until< at< CRLF >, OCTET > {};

      struct chunk : seq< chunk_size, opt< chunk_ext >, CRLF, chunk_data, CRLF > {};

      struct last_chunk : seq< plus< one< '0' > >, opt< chunk_ext >, CRLF > {};

      struct trailer_part : star< header_field, CRLF > {};

      struct chunked_body : seq< until< last_chunk, chunk >, trailer_part, CRLF > {};

   } // http

} // pegtl

#endif

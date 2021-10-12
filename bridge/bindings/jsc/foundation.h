/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

namespace kraken::binding::jsc {
struct Uri
{
public:
  std::string QueryString, Path, Protocol, Host, Port, Fragment;

  static std::string toString(Uri& uri) {
    return uri.Protocol + "://"
           + uri.Host
           + (uri.Port == "" ? "" : ":" + uri.Port)
           + (uri.Path.find("/") == 0 ? uri.Path : "/" + uri.Path)
           + (uri.QueryString.find("?") == 0 || uri.QueryString == "" ? uri.QueryString : "?" + uri.QueryString)
           + (uri.Fragment.find("#") == 0 || uri.Fragment == "" ? uri.Fragment : "#" + uri.Fragment);
  }

  static Uri Parse(const std::string &uri)
  {
    Uri result;

    typedef std::string::const_iterator iterator_t;

    if (uri.length() == 0)
      return result;

    iterator_t uriEnd = uri.end();

    // Get query start.
    iterator_t queryStart = std::find(uri.begin(), uriEnd, '?');

    // Get protocol.
    iterator_t protocolStart = uri.begin();
    // "://");.
    iterator_t protocolEnd = std::find(protocolStart, uriEnd, ':');

    if (protocolEnd != uriEnd) {
      std::string prot = &*(protocolEnd);
      if ((prot.length() > 3) && (prot.substr(0, 3) == "://")) {
        result.Protocol = std::string(protocolStart, protocolEnd);
        // ://.
        protocolEnd += 3;
      } else {
        // No protocol.
        protocolEnd = uri.begin();
      }
    } else {
      // No protocol.
      protocolEnd = uri.begin();
    }

    // Host.
    iterator_t hostStart = protocolEnd;

    // Get fragment start.
    iterator_t fragmentStart = std::find(hostStart, uriEnd, '#');

    // Get pathStart.
    iterator_t pathStart = std::find(hostStart, fragmentStart, '/');

    // Check for port.
    iterator_t hostEnd = std::find(protocolEnd, (pathStart != uriEnd) ? pathStart : queryStart, ':');

    result.Host = std::string(hostStart, hostEnd);

    // Port.
    if ((hostEnd != uriEnd) && ((&*(hostEnd))[0] == ':')) {
      hostEnd++;
      iterator_t portEnd = (pathStart != uriEnd) ? pathStart : queryStart;
      result.Port = std::string(hostEnd, portEnd);
    }

    // Path.
    if (pathStart != uriEnd) {
      result.Path = std::string(pathStart, queryStart);
    }

    // Query.
    if (queryStart != uriEnd) {
      result.QueryString = std::string(queryStart, fragmentStart);
    }

    // Fragment.
    if (fragmentStart != uriEnd) {
      result.Fragment = std::string(fragmentStart, uri.end());
    }

    return result;

  }
};
}

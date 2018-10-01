module WebServer.Requests

import WebServer.JS

%default total
%access public export

data RequestMethod
  = Delete
  | Get
  | Head
  | Options
  | Post
  | Put

Eq RequestMethod where
  (==) Delete Delete = True
  (==) Get Get = True
  (==) Head Head = True
  (==) Options Options = True
  (==) Post Post = True
  (==) Put Put = True
  (==) _ _ = False

Show RequestMethod where
  show Delete = "DELETE"
  show Get = "GET"
  show Head = "HEAD"
  show Options = "OPTIONS"
  show Post = "POST"
  show Put = "PUT"

Ord RequestMethod where
  compare x y = compare (show x) (show y)

record Request where
  constructor MkRequest
  method : RequestMethod
  path : String
%name Request req

data ContentTypeValue
  = TextHtmlUtf8

data CacheControlValue
  = NoCache

contentType : (filename : String) -> String
contentType filename =
  case reverse (split (== '.') filename) of
    ("asc" :: _) =>
      "application/octet-stream"
    ("css" :: _) =>
      "text/css"
    ("js" :: _) =>
      "application/javascript"
    _ =>
      "text/html; charset=utf-8"

mutual
  data Header
    = Custom String String
    | ContentLengthFor String
    | ContentType ContentTypeValue
    | ContentTypeFor String
    | CacheControl CacheControlValue
    | Location String

  parseHeader : Header -> JS_IO (String, String)
  parseHeader (Custom k v) =
    pure (k, v)
  parseHeader (ContentLengthFor body) =
    pure ("Content-Length", show !(byteLength body))
  parseHeader (ContentTypeFor s) =
    pure ("Content-Type", contentType s)
  parseHeader (ContentType TextHtmlUtf8) =
    pure ("Content-Type", contentType "html")
  parseHeader (CacheControl NoCache) =
    pure ("Cache-Control", "no-cache")
  parseHeader (Location uri) =
    pure ("Location", uri)

data Code
  = OK
  | Created
  | NotFound

Cast Code Int where
  cast OK = 200
  cast Created = 201
  cast NotFound = 404

record Response where
  constructor MkResponse
  code : Code
  body : String
  headers : List Header
%name Response res

requestFromRaw : (meth : String) -> (url : String) -> Request
requestFromRaw "DELETE"  = MkRequest Delete
requestFromRaw "GET"     = MkRequest Get
requestFromRaw "HEAD"    = MkRequest Head
requestFromRaw "OPTIONS" = MkRequest Options
requestFromRaw "POST"    = MkRequest Post
requestFromRaw "PUT"     = MkRequest Put
requestFromRaw _         = MkRequest Head

RequestHandler : Type
RequestHandler = Request -> Response

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

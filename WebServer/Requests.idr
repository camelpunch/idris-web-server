module WebServer.Requests

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

record Response where
  constructor MkResponse
  code : Nat
  body : String
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

module WebServer.Server

%lib Node "http"

public export
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

public export
record Request where
  constructor MkRequest
  method : RequestMethod
  path : String

public export
record Response where
  constructor MkResponse
  code : Nat
  body : String

export
requestFromRaw : (meth : String) -> (url : String) -> Request
requestFromRaw "DELETE"  url = MkRequest Delete url
requestFromRaw "GET"     url = MkRequest Get url
requestFromRaw "HEAD"    url = MkRequest Head url
requestFromRaw "OPTIONS" url = MkRequest Options url
requestFromRaw "POST"    url = MkRequest Post url
requestFromRaw "PUT"     url = MkRequest Put url
requestFromRaw _         url = MkRequest Head url

%inline
js : (fname : String) ->
     (ty : Type) ->
     {auto fty : FTy FFI_JS [] ty} ->
     ty
js = foreign FFI_JS

export
write : (res : Ptr) -> (body : String) -> JS_IO ()
write = js "%0.write(%1)" (Ptr -> String -> JS_IO ())

export
writeHead : (res : Ptr) -> (code : Nat) -> JS_IO ()
writeHead res code = js "%0.writeHead(%1)" (Ptr -> Int -> JS_IO ()) res (cast code)

export
method : (req : Ptr) -> JS_IO String
method = js "%0.method" (Ptr -> JS_IO String)

export
url : (req : Ptr) -> JS_IO String
url = js "%0.url" (Ptr -> JS_IO String)

export
end : (res : Ptr) -> JS_IO ()
end = js "%0.end()" (Ptr -> JS_IO ())

public export
RequestHandler : Type
RequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

public export
RouteTable : Type
RouteTable = List (RequestMethod, String, Response)

export
responseFromRequest : Request -> RouteTable -> Response
responseFromRequest req [] = MkResponse 404 "Not Found\n"
responseFromRequest req@(MkRequest method path) ((routeMethod, routePath, resp) :: routes) =
  if routeMethod == method && routePath == path
  then resp
  else responseFromRequest req routes

RequestProxy : Type
RequestProxy = Ptr -> JsFn (Ptr -> JS_IO ())

export
startServer : (port : Nat) ->
              (onListening: JS_IO ()) ->
              RequestHandler -> JS_IO ()
startServer port onListening onRequest = do
  server <- js "http.createServer()"
               (JS_IO Ptr)
  js "%0.listen(%1)"
     (Ptr -> Int -> JS_IO Ptr)
     server (cast port)
  js "%0.on('request', (req, res) => { %1(req)(res)() })"
     (Ptr -> JsFn RequestProxy -> JS_IO Ptr)
     server (MkJsFn (MkJsFn . onRequest))
  js "%0.on('listening', %1)"
     (Ptr -> JsFn (() -> JS_IO ()) -> JS_IO ())
     server (MkJsFn (\_ => onListening))

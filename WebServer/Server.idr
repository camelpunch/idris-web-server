module WebServer.Server

import public Data.SortedMap

import WebServer.JS
import public WebServer.RequestMethod
import public WebServer.Request
import public WebServer.Response

%lib Node "http"

public export
RequestHandler : Type
RequestHandler = Request -> Response

IORequestHandler : Type
IORequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

public export
RouteTable : Type
RouteTable = SortedMap String (SortedMap RequestMethod RequestHandler)
%name RouteTable routes

pureHandler2IOHandler : RequestHandler -> IORequestHandler
pureHandler2IOHandler f ptrReq ptrRes = do
  let req = requestFromRaw !(method ptrReq) !(url ptrReq)
  let res = f req
  js "%0.setHeader(\"Content-Length\", Buffer.byteLength(%1))"
     SendString ptrRes (body res)
  writeHead ptrRes (code res)
  write ptrRes (body res)
  end ptrRes

pureHandler2TwoArgChain : RequestHandler -> TwoArgChain
pureHandler2TwoArgChain f = MkJsFn $ MkJsFn . pureHandler2IOHandler f

export
startServer : (port : Nat) ->
              (onListening: JS_IO ()) ->
              RequestHandler ->
              JS_IO ()
startServer port onListening onRequest = do
  server <- js "http.createServer()" (JS_IO Ptr)
  js "%0.listen(%1)" SendInt server (cast port)
  js "%0.on('request', (req, res) => { %1(req)(res)() })"
     (Ptr -> TwoArgChain -> JS_IO Ptr)
     server (pureHandler2TwoArgChain onRequest)
  js "%0.on('listening', %1)"
     (Ptr -> JsFn (() -> JS_IO ()) -> JS_IO ())
     server (MkJsFn (\_ => onListening))

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

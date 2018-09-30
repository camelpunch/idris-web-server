module WebServer

import WebServer.JS
import public WebServer.Requests

%lib Node "http"
%default total

IORequestHandler : Type
IORequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

parseHeader : Header -> JS_IO (String, String)
parseHeader (Custom k v) =
  pure (k, v)
parseHeader (ContentLengthFor body) =
  pure ("Content-Length", show !(byteLength body))
parseHeader (ContentType TextHtmlUtf8) =
  pure ("Content-Type", "text/html; charset=utf-8")
parseHeader (CacheControl NoCache) =
  pure ("Cache-Control", "no-cache")
parseHeader (Location uri) =
  pure ("Location", uri)

time : String -> JS_IO ()
time = js "console.time(%0)" (String -> JS_IO ())

timeLog : String -> Code -> JS_IO ()
timeLog label code =
  js "console.timeLog(%0, %1)"
     (String -> Int -> JS_IO ())
     label (cast code)

pureHandler2IOHandler : RequestHandler -> IORequestHandler
pureHandler2IOHandler f ptrReq ptrRes = do
  let req = requestFromRaw !(method ptrReq) !(url ptrReq)
  let res = f req
  let label = show (method req) ++ " " ++ path req
  time label
  setHeaders ptrRes !(parseHeader `traverse` headers res)
  writeHead ptrRes (code res)
  write ptrRes (body res)
  end ptrRes
  timeLog label (code res)

pureHandler2TwoArgChain : RequestHandler -> TwoArgChain
pureHandler2TwoArgChain f = MkJsFn $ MkJsFn . pureHandler2IOHandler f

export
partial
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

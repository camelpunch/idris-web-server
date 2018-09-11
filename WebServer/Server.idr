module WebServer.Server

%lib Node "http"

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
end : (res : Ptr) -> JS_IO ()
end = js "%0.end()" (Ptr -> JS_IO ())

public export
RequestHandler : Type
RequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

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

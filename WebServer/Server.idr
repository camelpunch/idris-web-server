module WebServer.Server

%lib Node "http"

%inline
js : (fname : String) ->
     (ty : Type) ->
     {auto fty : FTy FFI_JS [] ty} ->
     ty
js fname ty = foreign FFI_JS fname ty

export
write : Ptr -> String -> JS_IO ()
write res body = js "%0.write(%1)" (Ptr -> String -> JS_IO ()) res body

export
writeHead : Ptr -> Int -> JS_IO ()
writeHead res code = js "%0.writeHead(%1)" (Ptr -> Int -> JS_IO ()) res code

export
end : Ptr -> JS_IO ()
end res = js "%0.end()" (Ptr -> JS_IO ()) res

public export
RequestHandler : Type
RequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

RequestProxy : Type
RequestProxy = Ptr -> JsFn (Ptr -> JS_IO ())

createRequestProxy : RequestHandler -> RequestProxy
createRequestProxy handler req =
  MkJsFn (\res => handler req res)

export
startServer : (port : Nat) -> RequestHandler -> JS_IO ()
startServer port handler = do
  server <- js "http.createServer()" (JS_IO Ptr)
  js "%0.listen(%1)" (Ptr -> Int -> JS_IO Ptr) server (cast port)
  js """
     %0.on('request', function(req, res) {
       %1(req)(res)()
     })
     """
     (Ptr -> JsFn RequestProxy -> JS_IO Ptr)
     server (MkJsFn (createRequestProxy handler))
  js """
     %0.on('listening', function() {
       console.log({
         timestamp: new Date().getTime(),
         message: "Server running"
       })
     })
     """
     (Ptr -> JS_IO ())
     server

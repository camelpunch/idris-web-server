%lib Node "http"

%inline
js : (fname : String) ->
     (ty : Type) ->
     {auto fty : FTy FFI_JS [] ty} ->
     ty
js fname ty = foreign FFI_JS fname ty

write : Ptr -> String -> JS_IO ()
write res body = js "%0.write(%1)" (Ptr -> String -> JS_IO ()) res body

writeHead : Ptr -> Int -> JS_IO ()
writeHead res code = js "%0.writeHead(%1)" (Ptr -> Int -> JS_IO ()) res code

end : Ptr -> JS_IO ()
end res = js "%0.end()" (Ptr -> JS_IO ()) res

RequestHandler : Type
RequestHandler = (req : Ptr) -> (res : Ptr) -> JS_IO ()

handleRequest : RequestHandler
handleRequest req res = do
  writeHead res 200
  write res "Nice server bro"
  end res

RequestProxy : Type
RequestProxy = Ptr -> JsFn (Ptr -> JS_IO ())

createRequestProxy : RequestHandler -> RequestProxy
createRequestProxy handler req =
  MkJsFn (\res => handleRequest req res)

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

main : JS_IO ()
main = startServer 4000 handleRequest

%lib Node "http"
%lib Node "url"

writeHead : Ptr -> Int -> JS_IO ()
writeHead res code =
  foreign FFI_JS "%0.writeHead(%1)" (Ptr -> Int -> JS_IO ()) res code

end : Ptr -> JS_IO ()
end res =
  foreign FFI_JS "%0.end()" (Ptr -> JS_IO ()) res

handleRequest : Ptr -> Ptr -> JS_IO ()
handleRequest req res = do
  writeHead res 200
  end res
  pure ()

requestProxy : Ptr -> JsFn (Ptr -> JS_IO ())
requestProxy req =
  MkJsFn (\res => handleRequest req res)

main : JS_IO ()
main = do
  server <- foreign FFI_JS "http.createServer()"
            (JS_IO Ptr)
  foreign FFI_JS "%0.listen(%1)"
          (Ptr -> Int -> JS_IO Ptr)
          server
          4000
  foreign FFI_JS """
          %0.on('request', function(req, res) {
            %1(req)(res)()
          })
          """
          (Ptr -> JsFn (Ptr -> (JsFn (Ptr -> JS_IO ()))) -> JS_IO Ptr)
          server
          (MkJsFn requestProxy)
  putStrLn' "Server running"

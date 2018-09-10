%lib Node "http"
%lib Node "url"

handleRequest : Ptr -> JS_IO Int
handleRequest req = do
  foreign FFI_JS "console.log(%0)"
          (Ptr -> JS_IO Ptr)
          req
  pure 201

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
            var statusCode = %1(req)
            res.writeHead(statusCode)
            res.end()
          })
          """
          (Ptr -> JsFn (Ptr -> JS_IO Int) -> JS_IO Ptr)
          server
          (MkJsFn handleRequest)
  putStrLn' "Server running"

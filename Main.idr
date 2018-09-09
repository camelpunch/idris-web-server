%lib Node "http"
%lib Node "url"

MyResponse : Type
MyResponse = () -> Int

somefun : MyResponse
somefun _ = 201

main : JS_IO ()
main = do
  server <- foreign FFI_JS """
            http.createServer(function (request, response) {
              response.writeHead(%0())
              response.end()
            }).listen(%1)
            """
            (JsFn MyResponse -> Int -> JS_IO Ptr)
            (MkJsFn somefun)
            4000
  putStrLn' "Server running"

import WebServer.Server

%default total

handleRequest : RouteTable -> RequestHandler
handleRequest routes req res = do
  let request = requestFromRaw !(method req) !(url req)
  let response = responseFromRequest request routes
  respondWith res response

routes : RouteTable
routes = [
  ( Get, "/"
  , MkResponse 200
    "€cool\n"
  )
]

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handleRequest routes)

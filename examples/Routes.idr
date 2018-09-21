import WebServer.Server

%default total

handler : RouteTable -> Request -> Response
handler [] req = MkResponse 404 "Not Found\n"
handler ((routeMethod, routePath, resp) :: routes) req@(MkRequest method path) =
  if routeMethod == method && routePath == path
  then resp
  else handler routes req

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
              (handler routes)

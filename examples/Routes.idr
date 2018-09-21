import WebServer.Server

%default total

home : RequestHandler
home _ = MkResponse 200 "€cool\n"

wrongMethod : RequestHandler
wrongMethod _ = MkResponse 405 "Wrong Method, Buddy\n"

routes : RouteTable
routes =
  [ (    Get, "/", home )
  , (   Post, "/", wrongMethod )
  , ( Delete, "/", wrongMethod )
  ]

matches : Request -> Route -> Bool
matches (MkRequest method path) (rtMethod, rtPath, _) =
  rtMethod == method && rtPath == path

handler : RouteTable -> Request -> Response
handler [] req = MkResponse 404 "Not Found\n"
handler (route@(_, _, f) :: routes) req =
  if req `matches` route
  then f req
  else handler routes req

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handler routes)

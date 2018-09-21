import WebServer.Server
import WebServer.Routes

%default total

appRoutes : Routes
appRoutes =
  [ Get "/" $ \req =>
    MkResponse 200 $ "I ♥ ur " ++ show (method req) ++ " method\n"

  , Get "/" $ \req =>
    MkResponse 200 $ "Unreachable endpoint\n"

  , Get "/posts" $ \_ =>
    MkResponse 200 "Post a, Post b\n"

  , Post "/posts" $ \_ =>
    MkResponse 201 "I honestly made a post\n"

  , Delete "/posts/:id" $ \_ =>
    MkResponse 500 "We haven't got that far, yet.\n"
  ]

notFound : Response
notFound = MkResponse 404 "Not Found\n"

handler : RouteTable -> Request -> Response
handler routes req = fromMaybe notFound (match req routes)

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handler $ mapRoutes appRoutes)

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

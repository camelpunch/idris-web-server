import WebServer.Server
import WebServer.Routes

%default total

appRoutes : Routes
appRoutes =
  [ get "/" $ \req =>
    MkResponse 200 $
    "I ♥ ur " ++ show (method req) ++ " method\n"

  , get "/" $ \req =>
    MkResponse 200 $
    "Unreachable endpoint\n"

  , get "/posts" $ \_ =>
    MkResponse 200 $
    "Post a, Post b\n"

  , post "/posts" $ \_ =>
    MkResponse 201 $
    "I honestly made a post\n"

  , delete "/posts/:id/foo/:bar" $ \req, id, bar =>
    MkResponse 200 $
    "You passed " ++ id ++ " and " ++ bar ++ "\n"
  ]

notFound : Response
notFound = MkResponse 404 "Not Found\n"

handler : Routes -> Request -> Response
handler routes req = fromMaybe notFound (handle req routes)

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handler appRoutes)

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

import WebServer
import WebServer.Routes

%default total

standardHeaders : (body : String) -> List Header
standardHeaders body =
  [ ContentLengthFor body
  , ContentType TextHtmlUtf8
  , Custom "Foo" "Bar"
  ]

respondWith : (code : Code) -> (body : String) -> Response
respondWith code body =
  MkResponse code body $ standardHeaders body

notFound : Response
notFound =
  respondWith NotFound "Not Found\n"

appRoutes : Routes
appRoutes =
  [ get "/" $ \req =>
    respondWith OK $
    "I ♥ ur " ++ show (method req) ++ " method\n"

  , get "/" $ \req =>
    respondWith OK $
    "Unreachable endpoint\n"

  , get "/posts" $ \_ =>
    respondWith OK $
    "Post a, Post b\n"

  , post "/posts" $ \_ =>
    let body = "I honestly made a post\n" in
      MkResponse
        Created body $
        Location "/posts/thenewpost" :: standardHeaders body

  , delete "/posts/:num.id/foo/:bar/:str.baz" $ \req, id, bar, baz =>
    respondWith OK $
    "You passed " ++ show id ++ " and " ++ bar ++ " and " ++ baz ++ "\n"
  ]

handler : Routes -> Request -> Response
handler routes req =
  fromMaybe notFound (handle req routes)

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

import WebServer
import WebServer.Routes

%default total

standardHeaders : (body : String) -> List Header
standardHeaders body =
  [ ContentLengthFor body
  , ContentType TextHtmlUtf8
  , Custom "Foo" "Bar"
  ]

ok : (body : String) -> Response
ok body =
  MkResponse OK body $ standardHeaders body

created : (uri : String) -> Response
created uri =
  let body = "Location: " ++ uri in
  MkResponse Created body $ Location uri :: standardHeaders body

notFound : Response
notFound =
  let body = "Not Found\n" in
  MkResponse NotFound body $ standardHeaders body

appRoutes : Routes
appRoutes =
  [ get "/" $ \req => ok $
    "I ♥ ur " ++ show (method req) ++ " method\n"

  , get "/" $ \req => ok $
    "Unreachable endpoint\n"

  , get "/posts" $ \_ => ok $
    "Post a, Post b\n"

  , post "/posts" $ \_ => created $
    "/posts/thenewpost"

  , delete "/posts/:num.id/foo/:bar/:str.baz" $ \req, id, bar, baz => ok $
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

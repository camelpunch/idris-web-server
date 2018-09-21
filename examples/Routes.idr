import WebServer.Server
import WebServer.Routes

%default total

notFound : Response
notFound = MkResponse 404 "Not Found\n"

home : RequestHandler
home _ = MkResponse 200 "€cool\n"

listPosts : RequestHandler
listPosts _ = MkResponse 200 "Post a, Post b\n"

createPost : RequestHandler
createPost _ = MkResponse 201 "I honestly made a post\n"

appRoutes : Routes
appRoutes =
  [ ( "/"
    , [ ( Get, home )
      ]
    )
  , ( "/posts"
    , [ ( Get, listPosts )
      , ( Post, createPost )
      ]
    )
  ]

handler : RouteTable -> Request -> Response
handler routes req = fromMaybe notFound (match routes req)

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handler $ routes2Table appRoutes)

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

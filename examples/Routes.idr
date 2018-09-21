import WebServer.Server

%default total

notFound : Response
notFound = MkResponse 404 "Not Found\n"

home : RequestHandler
home _ = MkResponse 200 "€cool\n"

listPosts : RequestHandler
listPosts _ = MkResponse 200 "Post a, Post b\n"

createPost : RequestHandler
createPost _ = MkResponse 201 "I honestly made a post\n"

routes : RouteTable
routes = fromList
  [ ("/", fromList
    [ (Get, home)
    ]
    )
  , ("/posts", fromList
    [ (Get, listPosts)
    , (Post, createPost)
    ]
    )
  ]

match : RouteTable -> Request -> Maybe Response
match routes req = do
  methods <- lookup (path req) routes
  handler <- lookup (method req) methods
  pure $ handler req

handler : RouteTable -> Request -> Response
handler routes req = fromMaybe notFound (match routes req)

partial
main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              (handler routes)

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

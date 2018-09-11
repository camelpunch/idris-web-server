import WebServer.Server

handleRequest : RequestHandler
handleRequest req res = do
  writeHead res 200
  write res $ "Nice " ++ !(method req) ++ " request, bro\n"
  end res

main : JS_IO ()
main = startServer 4000 handleRequest

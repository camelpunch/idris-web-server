import WebServer.Server

handleRequest : RequestHandler
handleRequest req res = do
  writeHead res 200
  write res $ "Nice " ++ !(method req) ++ " request, bro\n"
  end res

main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!")
              handleRequest

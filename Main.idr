import Server

handleRequest : RequestHandler
handleRequest req res = do
  writeHead res 200
  write res "Nice server bro"
  end res

main : JS_IO ()
main = startServer 4000 handleRequest

import WebServer.Server

main : JS_IO ()
main = do
  putStrLn' "Server starting..."
  startServer 4000
              (putStrLn' "The server is ready!") $
              \req =>
                MkResponse 200 $
                  "Nice " ++ show (method req) ++ " request, bro\n"

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

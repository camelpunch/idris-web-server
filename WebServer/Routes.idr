module WebServer.Routes

import WebServer.Requests

%default total

public export
data Route
  = Delete String RequestHandler
  | Get String RequestHandler
  | Head String RequestHandler
  | Options String RequestHandler
  | Post String RequestHandler
  | Put String RequestHandler
%name Route route

public export
Routes : Type
Routes = List Route
%name Routes routes

toTuple : Route -> (RequestMethod, String, RequestHandler)
toTuple (Delete x f) = (Delete, x, f)
toTuple (Get x f) = (Get, x, f)
toTuple (Head x f) = (Head, x, f)
toTuple (Options x f) = (Options, x, f)
toTuple (Post x f) = (Post, x, f)
toTuple (Put x f) = (Put, x, f)

export
match : Request -> Routes -> Maybe Response
match req [] = Nothing
match req@(MkRequest method path) (x :: xs) =
  let (m, p, f) = toTuple x in
  if (method, path) == (m, p)
  then Just (f req)
  else match req xs

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

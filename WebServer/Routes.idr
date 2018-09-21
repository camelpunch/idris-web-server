module WebServer.Routes

import public Data.SortedMap

import WebServer.Requests

%default total

public export
Routes : Type
Routes = List (String, List (RequestMethod, RequestHandler))

public export
RouteTable : Type
RouteTable = SortedMap String (SortedMap RequestMethod RequestHandler)
%name RouteTable routes

export
routes2Table : Routes -> RouteTable
routes2Table =
  foldl (\acc, (path, methodHandlers) =>
    insert path (fromList methodHandlers) acc
  ) empty

export
match : RouteTable -> Request -> Maybe Response
match routes req = do
  methods <- lookup (path req) routes
  handler <- lookup (method req) methods
  pure $ handler req

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

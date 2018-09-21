module WebServer.Routes

import public Data.SortedMap

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

public export
RouteTable : Type
RouteTable = SortedMap String (SortedMap RequestMethod RequestHandler)
%name RouteTable routes

singletonTable : (path : String) ->
                 RequestMethod ->
                 RequestHandler ->
                 RouteTable
singletonTable path m f = fromList [(path, fromList [(m, f)])]

addRoute : (path : String) -> RequestMethod -> RequestHandler -> RouteTable -> RouteTable
addRoute path m f routes =
  mergeWith mergeLeft (singletonTable path m f) routes

export
mapRoutes : Routes -> RouteTable
mapRoutes [] = empty
mapRoutes ((Delete path f) :: routes) = addRoute path Delete f (mapRoutes routes)
mapRoutes ((Get path f) :: routes) = addRoute path Get f (mapRoutes routes)
mapRoutes ((Head path f) :: routes) = addRoute path Head f (mapRoutes routes)
mapRoutes ((Options path f) :: routes) = addRoute path Options f (mapRoutes routes)
mapRoutes ((Post path f) :: routes) = addRoute path Post f (mapRoutes routes)
mapRoutes ((Put path f) :: routes) = addRoute path Put f (mapRoutes routes)

export
match : Request -> RouteTable -> Maybe Response
match req routes = do
  methods <- lookup (path req) routes
  handler <- lookup (method req) methods
  pure $ handler req

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

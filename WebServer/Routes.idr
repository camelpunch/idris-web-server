module WebServer.Routes

import WebServer.Requests

import public WebServer.PathRequestHandler

%default total

public export
record Route where
  constructor MkRoute
  method : RequestMethod
  path : String
  format : Format
  handler : Request -> HandlerType format
%name Route route

public export
delete : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
delete path f = MkRoute Delete path (parseFormat path) f
public export
get : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
get path f = MkRoute Get path (parseFormat path) f
public export
head : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
head path f = MkRoute Head path (parseFormat path) f
public export
options : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
options path f = MkRoute Options path (parseFormat path) f
public export
post : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
post path f = MkRoute Post path (parseFormat path) f
public export
put : (path : String) -> (Request -> HandlerType (parseFormat path)) -> Route
put path f = MkRoute Put path (parseFormat path) f

public export
Routes : Type
Routes = List Route
%name Routes routes

pathMatch : (reqPath : String) -> (routePath : String) -> Maybe (List String)
pathMatch reqPath routePath =
  if reqPath == routePath then
    Just []
  else
    partsMatch [] ((== '/') `split` reqPath) ((== '/') `split` routePath)
  where
  partsMatch : (acc : List String) ->
               (req : List String) ->
               (route : List String) ->
               Maybe (List String)
  partsMatch [] [] [] = Nothing
  partsMatch (arg :: args) [] [] = Just (arg :: args)
  partsMatch acc [] (x :: xs) = Nothing
  partsMatch acc (x :: xs) [] = Nothing
  partsMatch acc (x :: xs) (y :: ys) =
    if x == y then
      partsMatch acc xs ys
    else
      case unpack y of
        (':' :: chars) => partsMatch (acc ++ [x]) xs ys
        _ => Nothing

export
handle : Request -> Routes -> Maybe Response
handle req [] = Nothing
handle req (route :: routes) =
  case (method req == method route, path req `pathMatch` path route) of
    (True, Just args) => Just $ applyHandler route args
    (True, Nothing) => handle req routes
    (False, _) => handle req routes
  where
  applyH : (fmt : Format) ->
           (f : HandlerType fmt) ->
           (args : List String) ->
           Response
  applyH (Str format) f [] = MkResponse 500 "Server Error"
  applyH (Str format) f (arg :: args) = applyH format (f arg) args
  applyH End response _ = response

  applyHandler : (r : Route) ->
                 (args : List String) ->
                 Response
  applyHandler route args =
    applyH (format route) (handler route req) args

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

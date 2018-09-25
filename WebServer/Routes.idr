module WebServer.Routes

import WebServer.Requests
import public WebServer.Format

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
RouteConfig : Type
RouteConfig = (path : String) ->
              (Request -> HandlerType (parseFormat path)) ->
              Route
public export
routeConfig : RequestMethod -> RouteConfig
routeConfig method path = MkRoute method path (parseFormat path)

public export
delete : RouteConfig
delete = routeConfig Delete
public export
get : RouteConfig
get = routeConfig Get
public export
head : RouteConfig
head = routeConfig Head
public export
options : RouteConfig
options = routeConfig Head
public export
post : RouteConfig
post = routeConfig Post
public export
put : RouteConfig
put = routeConfig Put

public export
Routes : Type
Routes = List Route
%name Routes routes

pathMatch : (reqPath : String) -> (routePath : String) -> Maybe (List String)
pathMatch reqPath routePath =
  if reqPath == routePath then
    Just []
  else
    partsMatch [] (divide reqPath) (divide routePath)

  where

  divide : (path : String) -> List String
  divide = split (== '/')

  partsMatch : (acc : List String) ->
               (req : List String) ->
               (route : List String) ->
               Maybe (List String)
  partsMatch [] [] [] = Nothing
  partsMatch (arg :: args) [] [] = Just (arg :: args)
  partsMatch acc [] (x :: xs) = Nothing
  partsMatch acc (x :: xs) [] = Nothing
  partsMatch acc (reqPart :: reqParts) (routePart :: routeParts) =
    if reqPart == routePart then
      partsMatch acc reqParts routeParts
    else
      case unpack routePart of
        (':' :: chars) => partsMatch (acc ++ [reqPart]) reqParts routeParts
        _              => Nothing

export
handle : Request -> Routes -> Maybe Response
handle req [] = Nothing
handle req (route :: routes) =
  case (method req == method route, path req `pathMatch` path route) of
    (True, Just args) =>
      applyHandler (format route) (handler route req) args
    _ =>
      handle req routes

  where

  str2Nat : String -> Maybe Nat
  str2Nat s = all isDigit (unpack s) `toMaybe` cast s

  applyHandler : (fmt : Format) ->
                 (f : HandlerType fmt) ->
                 (args : List String) ->
                 Maybe Response
  applyHandler (Num format) f (arg :: args) =
    applyHandler format (f !(str2Nat arg)) args
  applyHandler (Str format) f (arg :: args) =
    applyHandler format (f arg) args
  applyHandler End f _ =
    Just f
  applyHandler _ f [] =
    Nothing

-- Local Variables:
-- idris-load-packages: ("contrib")
-- End:

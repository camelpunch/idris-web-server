module WebServer.Format

import WebServer.Requests

%default total

%access public export

data Format
  = Str Format
  | End
%name Format format

Eq Format where
  (==) (Str x) (Str y) = x == y
  (==) End End = True
  (==) _ _ = False

HandlerType : Format -> Type
HandlerType (Str fmt) = String -> HandlerType fmt
HandlerType End = Response
%name HandlerType f

parse : (parts : List String) -> Format
parse parts = parse' End parts
  where
  parse' : (acc : Format) -> (parts : List String) -> Format
  parse' acc [] = acc
  parse' acc (part :: parts) =
    case unpack part of
         (':' :: chars) => Str (parse' acc parts)
         _              => parse' acc parts

parseFormat : (routePath : String) -> Format
parseFormat routePath = parse $ (== '/') `split` routePath

module WebServer.Format

import WebServer.Requests

%default total

%access public export

data Format
  = Num Format
  | Str Format
  | End
%name Format format

HandlerType : Format -> Type
HandlerType (Num fmt) = Nat -> HandlerType fmt
HandlerType (Str fmt) = String -> HandlerType fmt
HandlerType End = Response
%name HandlerType f

parse : (acc : Format) -> (parts : List String) -> Format
parse acc [] = acc
parse acc (part :: parts) =
  case unpack part of
       (':' :: 'n' :: 'u' :: 'm' :: '.' :: _) =>
         Num (parse acc parts)
       (':' :: _) =>
         Str (parse acc parts)
       _ =>
         parse acc parts

parseFormat : (routePath : String) -> Format
parseFormat routePath = parse End $ (== '/') `split` routePath

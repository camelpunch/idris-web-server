module WebServer.PathRequestHandler

import WebServer.Requests

%default total

%access public export

data PathArgTypes
  = Str PathArgTypes
  | End
%name PathArgTypes argTypes

HandlerTypeFromArgTypes : (acc : Type) -> PathArgTypes -> Type
HandlerTypeFromArgTypes acc (Str argTypes) = String -> HandlerTypeFromArgTypes acc argTypes
HandlerTypeFromArgTypes acc End = acc

parse : (parts : List String) -> PathArgTypes
parse parts = parse' End parts
  where
  parse' : (acc : PathArgTypes) -> (parts : List String) -> PathArgTypes
  parse' acc [] = acc
  parse' acc (part :: parts) =
    case unpack part of
         (':' :: chars) => Str (parse' acc parts)
         _              => parse' acc parts

PathRequestHandler : (path : String) -> Type
PathRequestHandler path =
  Request -> PlaceholderType Response (split (== '/') path)

  where

  PlaceholderType : Type -> List String -> Type
  PlaceholderType accType [] = accType
  PlaceholderType accType (part :: parts) =
    case unpack part of
      (':' :: chars) => PlaceholderType (String -> accType) parts
      _              => PlaceholderType accType parts

module WebServer.Response

%default total
%access public export

record Response where
  constructor MkResponse
  code : Nat
  body : String
%name Response res

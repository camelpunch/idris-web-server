module WebServer.Request

import WebServer.RequestMethod

%default total
%access public export

record Request where
  constructor MkRequest
  method : RequestMethod
  path : String
%name Request req

export
requestFromRaw : (meth : String) -> (url : String) -> Request
requestFromRaw "DELETE"  = MkRequest Delete
requestFromRaw "GET"     = MkRequest Get
requestFromRaw "HEAD"    = MkRequest Head
requestFromRaw "OPTIONS" = MkRequest Options
requestFromRaw "POST"    = MkRequest Post
requestFromRaw "PUT"     = MkRequest Put
requestFromRaw _         = MkRequest Head

module WebServer.RequestMethod

%default total

public export
data RequestMethod
  = Delete
  | Get
  | Head
  | Options
  | Post
  | Put

export
Eq RequestMethod where
  (==) Delete Delete = True
  (==) Get Get = True
  (==) Head Head = True
  (==) Options Options = True
  (==) Post Post = True
  (==) Put Put = True
  (==) _ _ = False

export
Show RequestMethod where
  show Delete = "DELETE"
  show Get = "GET"
  show Head = "HEAD"
  show Options = "OPTIONS"
  show Post = "POST"
  show Put = "PUT"

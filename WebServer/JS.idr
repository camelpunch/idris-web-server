module JS

%access public export

%inline
js : (fname : String) ->
     (ty : Type) ->
     {auto fty : FTy FFI_JS [] ty} ->
     ty
js = foreign FFI_JS

SetKeyValue : Type
SetKeyValue = Ptr -> (key : String) -> (value : String) -> JS_IO ()

GetString : Type
GetString = Ptr -> JS_IO String

SendString : Type
SendString = Ptr -> String -> JS_IO ()

SendInt : Type
SendInt = Ptr -> Int -> JS_IO ()

Command : Type
Command = Ptr -> JS_IO ()

TwoArgChain : Type
TwoArgChain = JsFn (Ptr -> JsFn (Ptr -> JS_IO ()))

write : SendString
write = js "%0.write(%1)" SendString

writeHead : (res : Ptr) -> (code : Nat) -> JS_IO ()
writeHead res code = js "%0.writeHead(%1)" SendInt res (cast code)

setHeader : SetKeyValue
setHeader = js "%0.setHeader(%1, %2)" SetKeyValue

method : GetString
method = js "%0.method" GetString

url : GetString
url = js "%0.url" GetString

end : Command
end = js "%0.end()" Command

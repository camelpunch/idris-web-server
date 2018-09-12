module JS

%inline
export
js : (fname : String) ->
     (ty : Type) ->
     {auto fty : FTy FFI_JS [] ty} ->
     ty
js = foreign FFI_JS

public export
SetKeyValue : Type
SetKeyValue = Ptr -> (key : String) -> (value : String) -> JS_IO ()

public export
GetString : Type
GetString = Ptr -> JS_IO String

public export
SendString : Type
SendString = Ptr -> String -> JS_IO ()

public export
SendInt : Type
SendInt = Ptr -> Int -> JS_IO ()

public export
Command : Type
Command = Ptr -> JS_IO ()

port module Ports exposing (onSessionChange, storeSession)

-- ELM-LANG MODULES --

import Json.Encode exposing (Value)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg

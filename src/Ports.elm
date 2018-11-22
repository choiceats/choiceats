port module Ports exposing
    ( onSessionChange
    , selectText
    , storeSession
    )

-- ELM-LANG MODULES --

import Json.Encode exposing (Value)



-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg


port selectText : String -> Cmd msg

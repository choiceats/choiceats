port module Ports
    exposing
        ( onSessionChange
        , setDocumentTitle
        , storeSession
        , selectText
        )

-- ELM-LANG MODULES --

import Json.Encode exposing (Value)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg


port setDocumentTitle : String -> Cmd msg


port selectText : String -> Cmd msg

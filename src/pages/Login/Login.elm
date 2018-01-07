port module Login exposing (main)

-- ELM-LANG MODULES
import Html exposing (Html, div, text, label, input, button, h1, form, br, a)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id, href)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (Error, send, post, stringBody)
import Json.Decode as JD exposing (string, field, map4)
import Json.Encode as JE exposing (object, string, encode)
import Regex exposing (regex, caseInsensitive)

-- APP MODULES
import Login.Types as T exposing (..)

main =
  Html.programWithFlags
  { update        = update
  , view          = view
  , init          = init
  , subscriptions = subscriptions
  }

init : T.Flags -> (T.Model, Cmd T.Msg)
init initFlags = 
  ({emailInput     = ""
  , passwordInput  = ""
  , flags          = initFlags
  , loggedIn       = False
  , serverFeedback = ""
  }, Cmd.none )

hasLength : String -> Bool
hasLength str =
  not <| String.isEmpty str

mapStatusCodeToMessage : Int -> String
mapStatusCodeToMessage code =
  case code of
    401 ->
      "Unable to verify username or password."
    403 ->
      "You are not authorized for that."
    404 ->
      "Nothing's there (404)."
    _   ->
      "Unrecognized error code. " ++ toString code

update : T.Msg -> T.Model -> (T.Model, Cmd T.Msg)
update msg model = 
  case msg of

    T.Email str ->
        ({ model | emailInput = str
        }, Cmd.none)

    T.Password str ->
        ({model | passwordInput = str
        }, Cmd.none)

    T.AttemptLogin ->
      (model, requestAccount model)

    T.ReceiveResponse (Ok user)->
      ({model | loggedIn = True, serverFeedback = "" }, recordLogin <| stringifySession user)

    T.ReceiveResponse (Err (Http.BadStatus message)) ->
          ({model | serverFeedback = mapStatusCodeToMessage message.status.code}, Cmd.none)

    T.ReceiveResponse (Err (Http.BadUrl message)) ->
          ({model | serverFeedback = toString message}, Cmd.none)

    T.ReceiveResponse (Err (Http.Timeout)) ->
          ({model | serverFeedback = "Unable to contact server, it took too long to respond"}, Cmd.none)

    T.ReceiveResponse (Err (Http.NetworkError)) ->
          ({model | serverFeedback = "Error in the network"}, Cmd.none)
          -- Happens if server is offline.

    T.ReceiveResponse (Err (Http.BadPayload message response)) ->
          ({model | serverFeedback = toString message}, Cmd.none)



stringifySession : Session -> String
stringifySession session = 
  """ { "userId": """ ++ (toString session.userId) ++ """
  , "email": \"""" ++ session.email ++ """\" 
  , "name": \"""" ++ session.name ++ """\" 
  , "token": \"""" ++ session.token ++ """\" }"""
-- TODO: Find a better way to stringify this object

--  toString <| JE.object
--  [ ("userId", JE.string (toString session.userId))
--  , ("email", JE.string session.email)
--  , ("name", JE.string session.name)
--  , ("token", JE.string session.token)
--  ]

requestAccount : T.Model -> Cmd T.Msg
requestAccount model =
  let body =
  [ ("email", JE.string model.emailInput)
  , ("password", JE.string model.passwordInput)
  ]

  in
  Http.send ReceiveResponse (
    Http.post
      "http://localhost:4000/auth"
      (Http.stringBody
        "application/json; charset=utf-8"
        <| JE.encode 0
        <| JE.object body
      )
      <| sessionDecoder
  )

sessionDecoder : JD.Decoder Session
sessionDecoder =
  map4 Session
    (field "userId" JD.string)
    (field "email" JD.string)
    (field "name" JD.string)
    (field "token" JD.string)

port recordLogin : String -> Cmd msg

subscriptions : T.Model -> Sub T.Msg
subscriptions model =
  Sub.none

notDash : Char -> Bool
notDash char = char /= '-'

notSpace : Char -> Bool
notSpace char = char /= ' '

isIdChar : Char -> Bool
isIdChar char = notDash char && notSpace char

viewInput : String -> T.LabelName -> T.InputAttr -> (String -> T.Msg) -> Html T.Msg
viewInput userInput labelName inputAttr inputType = 
  let
    idName = (String.filter isIdChar labelName)

  in
    div [class "field"]
    [ label [for idName] [text labelName]
    , div [class "ui input"]
      [ input [ type_ inputAttr
              , onInput inputType
              , value userInput
              , id idName
              ] []
      ]
    ]

view : T.Model -> Html T.Msg
view model =
  div
  [style [("height", "calc(100vh - 50px)"), ("overflow", "auto"), ("padding", "20px")]]
  [ div 
    [ style [("max-width", "500px"), ("margin", "auto")] ]
    [ form [class "ui form"]
      [ h1 [ style [("font-family", "Fira Code"), ("font-size", "25px")] ] [ text "Login"]
      , viewInput model.emailInput "Email" "text" T.Email
      , viewInput model.passwordInput "Password" "password" T.Password
      , br [] []
      , div [] [ button
                   [ type_ "submit"
                   , class "ui primary button"
                   , disabled (not (hasLength model.emailInput) || not (hasLength model.passwordInput))
                   , onWithOptions
                     "click"
                     { stopPropagation = True
                     , preventDefault = True
                     }
                     (JD.succeed T.AttemptLogin)
                   ]
                   [text "Login"]]
      , br [] []
      , br [] []
      , a [href "/login/sign-up"]
        [ button
            [ type_ "button"
            , class "ui button"
            --, role "button" TODO: Find out how to assign role attribute
            ]
            [text "Sign up"]
        ]
      ]
    ]
  , div
    [class <| "ui error message " ++ (if hasLength model.serverFeedback then "visible" else "hidden")]
    [text model.serverFeedback]
  ]

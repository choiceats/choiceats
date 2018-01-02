port module Signup exposing (main)

-- ELM-LANG MODULES
import Html exposing (Html, div, text, label, input, button, h1, form, br, a)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id)
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
  , view          = viewSignup
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

setEmail : String -> T.LoginFields -> T.LoginFields
setEmail emailInput fields =
  let
    hasInput = hasLength emailInput

  in
    { fields | email =
      { userInput = emailInput
      , message = ""
      , isValid = hasInput
      }
    }

setPassword : String -> T.LoginFields -> T.LoginFields
setPassword passwordInput fields =
  let
    hasInput = hasLength passwordInput

  in
    {fields | password = { userInput = passwordInput
    , message = message
    , isValid = hasInput
    }}

hasLength : String -> Bool
hasLength str =
  not <| String.isEmpty str

update : T.Msg -> T.Model -> (T.Model, Cmd T.Msg)
update msg model = 
  case msg of

    T.Email str ->
        ({ model | emailInput = str
        }, Cmd.none)

    T.Password str ->
        ({model | passwordInput = str
        }, Cmd.none)

    T.RequestAccount ->
      (model, requestAccount model)

    T.ReceiveResponse (Ok user)->
      ({model | loggedIn = True }, recordLogin <| stringifySession user)

    T.ReceiveResponse (Err err)->
      ({model | serverFeedback = toString err}, Cmd.none)

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
  [ ("email", JE.string model.formFields.email.userInput)
  , ("password", JE.string model.formFields.password.userInput)
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

-- This can replace the current "Bad Password" element.
-- viewError : T.FormField -> Html T.Msg
-- viewError field =
--   div [class <| "ui error message " ++ (if hasLength field.message && (not field.isValid) then "visible" else "hidden")]
--     [ div [class "header"] [text field.message] ]

-- can add ui [class "list"] [li[] [text var]] or p [] [text var] if need secondary error parts

￼    
￼    
￼    
view : T.Model -> Html T.Msg
view model =
  div
  [[style [("height", "calc(100vh - 50px)"), ("overflow", "auto"), ("padding", "20px")]]]
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
                   ]
                   [text "Login"]]
      , br [] []
      , br [] []
      , a [href "/login/sign-up"]
        [ button
            [ type_ "button"
            , class "ui button"
            , role "button"
            ]
            ["Sign up"]
        ]
      ]
    ]
  ]

-- These will be the button options
--       , button
--         [ type_ "submit"
--         , class "ui primary button"
--         , disabled <| 
--         , onWithOptions
--             "click"
--             { stopPropagation = True
--             , preventDefault = True
--             }
--             (JD.succeed RequestAccount)
--         ]
 

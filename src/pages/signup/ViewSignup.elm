port module ViewSignup exposing (main)

-- ELM-LANG MODULES
import Html exposing (Html, div, text, label, input, button, h1, form)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (..)
import Json.Decode exposing (decodeString, int, string, field, bool)
import Json.Encode exposing (..)

main =
  Html.programWithFlags
  { update        = update
  , view          = viewSignup
  , init          = init
  , subscriptions = subscriptions
  }

type Msg
  = Email String
  | FirstName String
  | LastName String
  | Password String
  | PasswordCheck String
  | RequestAccount
  | ReceiveResponse (Result Http.Error Int)

type alias Flags = { token: String }

type alias SignupFields =
  { email: String
  , firstName: String
  , lastName: String
  , password: String
  , passwordCheck: String
  }

type alias ValidationRecord = 
  { isValid: Bool
  , message: String
  }

type alias Model =
  { formFields: SignupFields
  , loggedIn: Bool
  , flags: Flags
  , formFieldsValidation:
    { email: ValidationRecord
    , firstName: ValidationRecord
    , lastName: ValidationRecord
    , password: ValidationRecord
    , passwordCheck: ValidationRecord
    }
  , formFeedback : String
  , buttonEnabled: Bool
  }

initial_validation =
  { isValid = False
  , message = ""
  }

init : Flags -> (Model, Cmd Msg)
init initFlags = 
  ({formFields =
      { email = ""
      , firstName = ""
      , lastName = ""
      , password = ""
      , passwordCheck = ""
      }
    , formFieldsValidation =
      { email = initial_validation
      , firstName = initial_validation
      , lastName = initial_validation
      , password = initial_validation
      , passwordCheck = initial_validation
      }
    , flags = initFlags
    , buttonEnabled = True
    , loggedIn = False
    , formFeedback = ""
  }, Cmd.none)

setEmail : String -> SignupFields -> SignupFields
setEmail str fields =
  {fields | email = str}

setFirstName : String -> SignupFields -> SignupFields
setFirstName str fields =
  {fields | firstName = str}

setLastName : String -> SignupFields -> SignupFields
setLastName str fields =
  {fields | lastName = str}

setPassword : String -> SignupFields -> SignupFields
setPassword str fields =
  {fields | password = str}

setPasswordCheck : String -> SignupFields -> SignupFields
setPasswordCheck str fields =
  {fields | passwordCheck = str}

getCanUpdate : Model -> Bool
getCanUpdate model = True

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of

    Email str ->
      ({model | formFields = setEmail str model.formFields }, Cmd.none)

    FirstName str ->
      ({model | formFields = setFirstName str model.formFields }, Cmd.none)

    LastName str ->
      ({model | formFields = setLastName str model.formFields }, Cmd.none)

    Password str ->
      ({model | formFields = setPassword str model.formFields }, Cmd.none)

    PasswordCheck str ->
      ({model | formFields = setPasswordCheck str model.formFields }, Cmd.none)

    RequestAccount ->
      (model, requestAccount model)

    ReceiveResponse (Ok user)->
      ({model | loggedIn = True }, Cmd.none)

    ReceiveResponse (Err err)->
      ({model | formFeedback = toString err}, Cmd.none)

requestAccount : Model -> Cmd Msg
requestAccount model =
  let body =
  [ ("email", Json.Encode.string model.formFields.email)
  , ("firstName", Json.Encode.string model.formFields.firstName)
  , ("lastName", Json.Encode.string model.formFields.lastName)
  , ("password", Json.Encode.string model.formFields.password)
  ]

  in
  Http.send ReceiveResponse (
    Http.post
      "http://localhost:4000/user"
      (Http.stringBody
        "application/json; charset=utf-8"
        <| Json.Encode.encode 0
        <| Json.Encode.object body
      )
      <| field "user" Json.Decode.int
  )

port recordSignup : String -> Cmd msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

viewSignup : Model -> Html Msg
viewSignup model =
  let
    (f) = model.formFields

  in
    div [style [("max-width", "500px"), ("margin", "auto")]]
    [ 
      form [class "ui form"]
      [ h1
        [ style [("font-family", "Fira Code") , ("font-size", "25px")] ]
        [text "Signup!"]
      , viewInput f.email         "Email"       "text"     Email
      , viewInput f.firstName     "First Name"  "text"     FirstName
      , viewInput f.lastName      "Last Name"   "text"     LastName
      , viewInput f.password      "Password"    "password" Password
      , viewInput f.passwordCheck "Re-Password" "password" PasswordCheck
      , button
        [ type_ "submit"
        , class "ui primary button"
        , disabled <| not model.buttonEnabled
        , onWithOptions
            "click"
            { stopPropagation = True
            , preventDefault = True
            }
            (Json.Decode.succeed RequestAccount)
        ]
        [text "Signup"]
      , div [] [text <| toString model]
      ]
    ]

type alias LabelName = String
type alias InputAttr = String
type alias FormValue = String

notDash : Char -> Bool
notDash char = char /= '-'

notSpace : Char -> Bool
notSpace char = char /= ' '

isIdChar : Char -> Bool
isIdChar char = notDash char && notSpace char

viewInput : FormValue -> LabelName -> InputAttr -> (String -> Msg) -> Html Msg
viewInput formValue labelName inputAttr inputType = 
  let
    idName = (String.filter isIdChar labelName)
  in
    div [class "field"]
    [ label [for idName] [text labelName]
    , div [class "ui input"]
      [
        input [ type_ inputAttr
              , onInput inputType
              , value formValue
              , id idName
              ]
        []
      ]
    ]

-- response body is currently (asof 20171116)
-- {user: 34}

-- but it needs to be:

-- email: "aa@aa.aa"
-- name: "aa aa"
-- token: "6tt5iyzpqo265jq8wjotude7vitkbbe"
-- userId: 3

-- So that login and redirect can work correctly

-- The flow will be - send a signup request.
-- If the signup request is successful,
--    write the request to localStorage
--    redirect the user to home page AFTER localStorage successfully written (it is async, so you'll probably need to send AND receive messages via ports
-- 
-- If the signup fails, tell them why.


-- import { register } from '../../services/users'
--       return <Redirect to={{ pathname: '/' }} />

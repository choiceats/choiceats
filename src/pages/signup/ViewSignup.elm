port module ViewSignup exposing (main)

-- ELM-LANG MODULES
import Html exposing (Html, div, text, label, input, button, h1, form)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (Error, send, post, stringBody)
import Json.Decode as JD exposing (int, string, field, map4)
import Json.Encode as JE exposing (object, string, encode)
import Regex exposing (regex, caseInsensitive)

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
  | ReceiveResponse (Result Http.Error Session)

type alias Session =
  {
    userId: Int,
    email: String,
    name: String,
    token: String
  }

type alias Flags = { token: String }

-- type UserInput = Int | String | Number
-- had problems getting union types to play nicely with things that expected a String. TODO: Make this type work as it generalizes better to different form field types

type alias UserInput = String

type alias FormField =
  { userInput: UserInput
  , isValid: Bool
  , message: String
  }

type alias SignupFields =
  { email: FormField
  , firstName: FormField
  , lastName: FormField
  , password: FormField
  , passwordCheck: FormField
  }

type alias Model =
  { formFields: SignupFields
  , loggedIn: Bool
  , flags: Flags
  , serverFeedback : String
  , canSubmitForm: Bool
  }

emptyUserData =
  { userInput = ""
  , isValid = True
  , message = ""
  }

init : Flags -> (Model, Cmd Msg)
init initFlags = 
  ({formFields =
      { email = emptyUserData
      , firstName = emptyUserData
      , lastName = emptyUserData
      , password = emptyUserData
      , passwordCheck = emptyUserData
      }
    , flags = initFlags
    , canSubmitForm = False
    , loggedIn = False
    , serverFeedback = ""
  }, Cmd.none )

emailRegex = caseInsensitive (regex "^\\S+@\\S+\\.\\S+$")
  
validateEmail : String -> Bool
validateEmail email =
    Regex.contains emailRegex email

setEmail : String -> SignupFields -> SignupFields
setEmail emailInput fields =
  let
    hasInput = not (String.isEmpty emailInput)
    isValidEmail = validateEmail emailInput

    message =

      if not hasInput

        then "Enter an email address."

      else if not isValidEmail

        then "Enter a valid email address."

      else ""

  in
    { fields | email =
      { userInput = emailInput
      , message = message
      , isValid = hasInput && isValidEmail
      }
    }

setFirstName : String -> SignupFields -> SignupFields
setFirstName firstNameInput fields =
  let
    hasInput = not (String.isEmpty firstNameInput)

  in
    { fields | firstName =
      { userInput = firstNameInput
      , message = if hasInput then "" else "Enter a first name."
      , isValid = hasInput
      }
    }

setLastName : String -> SignupFields -> SignupFields
setLastName lastNameInput fields =
  let
    hasInput = not (String.isEmpty lastNameInput)

  in
    { fields | lastName =
      { userInput = lastNameInput
      , message = if hasInput then "" else "Enter a last name."
      , isValid = hasInput
      }
    }

createWordRegex word = caseInsensitive (regex ("^.*" ++ word ++ ".*$"))

passwordRegex = createWordRegex "password"
  
setPassword : String -> SignupFields -> SignupFields
setPassword passwordInput fields =
  let
    hasInput = not (String.isEmpty passwordInput)

    passwordIsPassword = Regex.contains passwordRegex passwordInput

    passwordIsName =
      ( Regex.contains (createWordRegex fields.firstName.userInput) passwordInput
      || Regex.contains (createWordRegex fields.lastName.userInput) passwordInput 
      )

    minimum_password_length = 6

    passwordIsLongEnough = String.length passwordInput >= minimum_password_length

    message =
      if not hasInput
        then "Enter a password."

      else if passwordIsPassword
        then "You can do better than \"password\" for a password."

      else if passwordIsName
        then "You can do better than using your name for a password."

      else if not passwordIsLongEnough
        then "Password must be at least " ++ (toString minimum_password_length) ++ " characters long."

      else ""

  in
    {fields | password = { userInput = passwordInput
    , message = message
    , isValid =
      ( hasInput
      && (not passwordIsPassword)
      && passwordIsLongEnough
      && not passwordIsName
      )
    }}


setPasswordCheck : String -> SignupFields -> SignupFields
setPasswordCheck passwordCheckInput fields =
  let
    isValid = if fields.password.userInput == passwordCheckInput then True else False

  in
    { fields | passwordCheck =
      { userInput = passwordCheckInput
      , message = if isValid then "" else "Passwords must match."
      , isValid = isValid
      }
    }

notEmpty : String -> Bool
notEmpty str =
  not <| String.isEmpty str

getCanSubmitForm : SignupFields -> Bool
getCanSubmitForm f =
     (f.email.isValid         && notEmpty f.email.userInput        )
  && (f.firstName.isValid     && notEmpty f.firstName.userInput    )
  && (f.lastName.isValid      && notEmpty f.lastName.userInput     )
  && (f.password.isValid      && notEmpty f.password.userInput     )
  && (f.passwordCheck.isValid && notEmpty f.passwordCheck.userInput)
 
update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of

    Email str ->
      let
        newFields = setEmail str model.formFields

      in
        ({ model | formFields = newFields
        , canSubmitForm = getCanSubmitForm newFields
        }, Cmd.none)

    FirstName str ->
      let
        newFields = setFirstName str model.formFields
          |> (setPassword model.formFields.password.userInput)

      in
        ({model | formFields = newFields
        , canSubmitForm = getCanSubmitForm newFields
        }, Cmd.none)

    LastName str ->
      let
        newFields = setLastName str model.formFields
          |> (setPassword model.formFields.password.userInput)

      in
        ({model | formFields = newFields
        , canSubmitForm = getCanSubmitForm newFields
        }, Cmd.none)

    Password str ->
      ({model | formFields = setPassword str model.formFields }, Cmd.none)

    PasswordCheck str ->
      ({model | formFields = setPasswordCheck str model.formFields }, Cmd.none)

    RequestAccount ->
      (model, requestAccount model)

    ReceiveResponse (Ok user)->
      ({model | loggedIn = True }, recordSignup <| stringifySession user)

    ReceiveResponse (Err err)->
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

requestAccount : Model -> Cmd Msg
requestAccount model =
  let body =
  [ ("email", JE.string model.formFields.email.userInput)
  , ("firstName", JE.string model.formFields.firstName.userInput)
  , ("lastName", JE.string model.formFields.lastName.userInput)
  , ("password", JE.string model.formFields.password.userInput)
  ]

  in
  Http.send ReceiveResponse (
    Http.post
      "http://localhost:4000/user"
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
    (field "userId" JD.int)
    (field "email" JD.string)
    (field "name" JD.string)
    (field "token" JD.string)

port recordSignup : String -> Cmd msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

viewSignup : Model -> Html Msg
viewSignup model =
  let
    f = model.formFields

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
        , disabled <| not model.canSubmitForm
        , onWithOptions
            "click"
            { stopPropagation = True
            , preventDefault = True
            }
            (JD.succeed RequestAccount)
        ]
        [text "Signup"]
      , div [] [text <| toString model]
      ]
    ]

type alias LabelName = String
type alias InputAttr = String

notDash : Char -> Bool
notDash char = char /= '-'

notSpace : Char -> Bool
notSpace char = char /= ' '

isIdChar : Char -> Bool
isIdChar char = notDash char && notSpace char

viewInput : FormField -> LabelName -> InputAttr -> (String -> Msg) -> Html Msg
viewInput formField labelName inputAttr inputType = 
  let
    idName = (String.filter isIdChar labelName)

  in
    div [class "field"]
    [ label [for idName] [text labelName]
    , div [class "ui input"]
      [
        input [ type_ inputAttr
              , onInput inputType
              , value formField.userInput
              , id idName
              ]
        []
      ]
    , viewError formField
    ]


viewError : FormField -> Html Msg
viewError field =
  div [class <| "ui error message " ++ (if field.isValid then "hidden" else "visible")]
    [ div [class "header"] [text field.message] ]

-- can add ui [class "list"] [li[] [text var]] or p [] [text var] if need secondary error parts

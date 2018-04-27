module Page.Signup exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

-- ELM-LANG MODULES

import Html exposing (Html, div, text, label, input, button, h1, form)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (Error, send, post, stringBody)
import Json.Decode as JD exposing (string, field, map4)
import Json.Encode as JE exposing (object, string, encode)
import Regex exposing (regex, caseInsensitive)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --

import Data.Session exposing (Session)
import Data.User exposing (User, decoder)
import Request.User exposing (storeSession)
import Route exposing (Route)


-- TYPES


type Msg
    = Email String
    | FirstName String
    | LastName String
    | Password String
    | PasswordCheck String
    | RequestAccount
    | ReceiveResponse (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User



-- type UserInput = Int | String | Number
-- had problems getting union types to play nicely with things that expected a String. TODO: Make this type work as it generalizes better to different form field types


type alias FormField =
    { userInput : String
    , isValid : Bool
    , message : String
    }


type alias SignupFields =
    { email : FormField
    , firstName : FormField
    , lastName : FormField
    , password : FormField
    , passwordCheck : FormField
    }


type alias Model =
    { formFields : SignupFields
    , loggedIn : Bool
    , token : String
    , serverFeedback : String
    , canSubmitForm : Bool
    }


emptyUserData =
    { userInput = ""
    , isValid = True
    , message = ""
    }


type alias LabelName =
    String


type alias InputAttr =
    String


initialModel : Model
initialModel =
    { formFields =
        { email = emptyUserData
        , firstName = emptyUserData
        , lastName = emptyUserData
        , password = emptyUserData
        , passwordCheck = emptyUserData
        }
    , token = "dsf"
    , canSubmitForm = False
    , loggedIn = False
    , serverFeedback = ""
    }


emailRegex =
    caseInsensitive (regex "^\\S+@\\S+\\.\\S+$")


validateEmail : String -> Bool
validateEmail email =
    Regex.contains emailRegex email


setEmail : String -> SignupFields -> SignupFields
setEmail emailInput fields =
    let
        hasInput =
            hasLength emailInput

        isValidEmail =
            validateEmail emailInput

        message =
            if not hasInput then
                "Enter an email address."
            else if not isValidEmail then
                "Enter a valid email address."
            else
                ""
    in
        { fields
            | email =
                { userInput = emailInput
                , message = message
                , isValid = hasInput && isValidEmail
                }
        }


setFirstName : String -> SignupFields -> SignupFields
setFirstName firstNameInput fields =
    let
        hasInput =
            hasLength firstNameInput
    in
        { fields
            | firstName =
                { userInput = firstNameInput
                , message =
                    if hasInput then
                        ""
                    else
                        "Enter a first name."
                , isValid = hasInput
                }
        }


setLastName : String -> SignupFields -> SignupFields
setLastName lastNameInput fields =
    let
        hasInput =
            hasLength lastNameInput
    in
        { fields
            | lastName =
                { userInput = lastNameInput
                , message =
                    if hasInput then
                        ""
                    else
                        "Enter a last name."
                , isValid = hasInput
                }
        }


createWordRegex word =
    caseInsensitive (regex ("^.*" ++ word ++ ".*$"))


passwordRegex =
    createWordRegex "password"


setPassword : String -> SignupFields -> SignupFields
setPassword passwordInput fields =
    let
        hasInput =
            hasLength passwordInput

        passwordIsPassword =
            Regex.contains passwordRegex passwordInput

        passwordIsName =
            ((String.length fields.firstName.userInput
                > 0
                && Regex.contains (createWordRegex fields.firstName.userInput) passwordInput
             )
                || (String.length fields.lastName.userInput
                        > 0
                        && Regex.contains (createWordRegex fields.lastName.userInput) passwordInput
                   )
            )

        minimum_password_length =
            6

        passwordIsLongEnough =
            String.length passwordInput >= minimum_password_length

        passwordsMatch =
            fields.passwordCheck.userInput == passwordInput

        passwordCheckHasInput =
            hasLength fields.passwordCheck.userInput

        bothPasswordsHaveInput =
            hasInput && passwordCheckHasInput

        message =
            if False then
                "Enter a password."
            else if passwordIsPassword then
                "You can do better than \"password\" for a password."
            else if passwordIsName then
                "You can do better than using your name for a password."
            else if hasInput && not passwordIsLongEnough then
                "Password must be at least " ++ (toString minimum_password_length) ++ " characters long."
            else if bothPasswordsHaveInput && not passwordsMatch then
                "Passwords must match."
            else
                ""
    in
        { fields
            | password =
                { userInput = passwordInput
                , message = message
                , isValid =
                    (hasInput
                        && (not passwordIsPassword)
                        && passwordIsLongEnough
                        && not passwordIsName
                        && passwordsMatch
                    )
                }
        }


setPasswordCheck : String -> SignupFields -> SignupFields
setPasswordCheck passwordCheckInput fields =
    -- Keep the password checking logic in the setPassword method
    { fields
        | passwordCheck =
            { userInput = passwordCheckInput
            , message = ""
            , isValid = True
            }
    }


hasLength : String -> Bool
hasLength str =
    not <| String.isEmpty str


getCanSubmitForm : SignupFields -> Bool
getCanSubmitForm f =
    (f.email.isValid && hasLength f.email.userInput)
        && (f.firstName.isValid && hasLength f.firstName.userInput)
        && (f.lastName.isValid && hasLength f.lastName.userInput)
        && (f.password.isValid && hasLength f.password.userInput)
        && (f.passwordCheck.isValid && hasLength f.passwordCheck.userInput)


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        Email str ->
            let
                newFields =
                    setEmail str model.formFields
            in
                ( ( { model
                        | formFields = newFields
                        , canSubmitForm = getCanSubmitForm newFields
                    }
                  , Cmd.none
                  )
                , NoOp
                )

        FirstName str ->
            let
                newFields =
                    setFirstName str model.formFields
                        |> (setPassword model.formFields.password.userInput)
                        |> (setPasswordCheck model.formFields.passwordCheck.userInput)
            in
                ( ( { model
                        | formFields = newFields
                        , canSubmitForm = getCanSubmitForm newFields
                    }
                  , Cmd.none
                  )
                , NoOp
                )

        LastName str ->
            let
                newFields =
                    setLastName str model.formFields
                        |> (setPassword model.formFields.password.userInput)
                        |> (setPasswordCheck model.formFields.passwordCheck.userInput)
            in
                ( ( { model
                        | formFields = newFields
                        , canSubmitForm = getCanSubmitForm newFields
                    }
                  , Cmd.none
                  )
                , NoOp
                )

        Password str ->
            let
                newFields =
                    setPassword str model.formFields
                        |> (setPasswordCheck model.formFields.passwordCheck.userInput)
            in
                ( ( { model
                        | formFields = newFields
                        , canSubmitForm = getCanSubmitForm newFields
                    }
                  , Cmd.none
                  )
                , NoOp
                )

        PasswordCheck str ->
            let
                newFields =
                    setPasswordCheck str model.formFields
                        |> (setPassword model.formFields.password.userInput)
            in
                ( ( { model
                        | formFields = newFields
                        , canSubmitForm = getCanSubmitForm newFields
                    }
                  , Cmd.none
                  )
                , NoOp
                )

        RequestAccount ->
            ( ( model, requestAccount model ), NoOp )

        ReceiveResponse (Ok user) ->
            ( ( { model | loggedIn = True }, Cmd.batch [ storeSession user, Route.modifyUrl Route.Recipes ] ), SetUser user )

        ReceiveResponse (Err err) ->
            ( ( { model | serverFeedback = toString err }, Cmd.none ), NoOp )


requestAccount : Model -> Cmd Msg
requestAccount model =
    let
        body =
            [ ( "email", JE.string model.formFields.email.userInput )
            , ( "firstName", JE.string model.formFields.firstName.userInput )
            , ( "lastName", JE.string model.formFields.lastName.userInput )
            , ( "password", JE.string model.formFields.password.userInput )
            ]
    in
        Http.send ReceiveResponse
            (Http.post
                "http://localhost:4000/user"
                (Http.stringBody
                    "application/json; charset=utf-8"
                 <|
                    JE.encode 0 <|
                        JE.object body
                )
             <|
                decoder
            )


view : Session -> Model -> Html Msg
view session model =
    let
        f =
            model.formFields
    in
        div [ class "ui container" ]
            [ form [ class "ui form", style [ ( "max-width", "700px" ), ( "margin", "0 auto" ) ] ]
                [ h1
                    [ class "ui header", style [ ( "font-family", "fira-code" ) ] ]
                    [ text "Signup!" ]
                , viewInput f.email "Email" "text" Email
                , viewInput f.firstName "First Name" "text" FirstName
                , viewInput f.lastName "Last Name" "text" LastName
                , viewInput f.password "Password" "password" Password
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
                    [ text "Signup" ]
                ]
            ]


notDash : Char -> Bool
notDash char =
    char /= '-'


notSpace : Char -> Bool
notSpace char =
    char /= ' '


isIdChar : Char -> Bool
isIdChar char =
    notDash char && notSpace char


viewInput : FormField -> LabelName -> InputAttr -> (String -> Msg) -> Html Msg
viewInput formField labelName inputAttr inputType =
    let
        idName =
            (String.filter isIdChar labelName)
    in
        div [ class "field" ]
            [ label [ for idName ] [ text labelName ]
            , div [ class "ui input" ]
                [ input
                    [ type_ inputAttr
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
    div
        [ class <|
            "ui error message "
                ++ (if hasLength field.message && (not field.isValid) then
                        "visible"
                    else
                        "hidden"
                   )
        ]
        [ div [ class "header" ] [ text field.message ] ]



-- can add ui [class "list"] [li[] [text var]] or p [] [text var] if need secondary error parts

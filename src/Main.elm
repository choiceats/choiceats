module Main exposing (main)

-- ELM-LANG MODULES --
-- THIRD PARTY MODULES --
-- APPLICATION MODULES --
-- import Browser.Navigation exposing (Location, programWithFlags)

import Browser
import Browser.Navigation as Nav
import Data.AuthToken as AuthToken exposing (AuthToken(..))
import Data.Recipe exposing (Slug)
import Data.Session exposing (Session)
import Data.User as User exposing (Name(..), User, UserId(..))
import Html exposing (..)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode
import Menu
import Page.Errored as Errored exposing (PageLoadError)
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Randomizer as Randomizer
import Page.RecipeDetail as RecipeDetail
import Page.RecipeEditor as RecipeEditor
import Page.Recipes as Recipes
import Page.Signup as Signup
import Ports
import Route exposing (Route, routeToTitle)
import Task
import Url
import Views.Page as Page exposing (ActivePage)


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Login Login.Model
    | Signup Signup.Model
    | Randomizer Randomizer.Model
    | RecipeDetail RecipeDetail.Model
    | Recipes Recipes.Model
    | RecipeEditor (Maybe Slug) RecipeEditor.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL --


type alias Model =
    { session : Session
    , pageState : PageState
    , apiUrl : String
    , navKey : Nav.Key
    , url : Url.Url
    }


type alias Flags =
    { apiUrl : String
    , session : User
    }


encodeToken : AuthToken -> Value
encodeToken (AuthToken token) =
    Encode.string token


decodeToken : Decoder AuthToken
decodeToken =
    Decode.string
        |> Decode.map AuthToken


decodeName : Decoder User.Name
decodeName =
    Decode.string
        |> Decode.map User.Name


decodeUserId : Decoder User.UserId
decodeUserId =
    Decode.string
        |> Decode.map User.UserId


flagsDecoder : String -> Result Decode.Error User
flagsDecoder =
    Decode.decodeString
        (Decode.field "session"
            (Decode.map4 User
                (Decode.field "email" Decode.string)
                (Decode.field "token" decodeToken)
                (Decode.field "name" decodeName)
                (Decode.field "userId" decodeUserId)
            )
        )


apiUrlDecoder :
    String
    -> Result Decode.Error String -- Success string is apiUrl
apiUrlDecoder =
    Decode.decodeString (Decode.field "api_url" Decode.string)


init : Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init val url navKey =
    let
        resultStringFlags =
            Decode.decodeValue Decode.string val

        stringifiedFlags =
            case resultStringFlags of
                Ok flags ->
                    flags

                Err _ ->
                    """{"bad": "deal dewd"}"""

        apiUrl =
            case apiUrlDecoder stringifiedFlags of
                Ok decodedApiUrl ->
                    decodedApiUrl

                _ ->
                    "http://localhost:4000"

        session =
            case flagsDecoder stringifiedFlags of
                Ok flags ->
                    { user = Just flags }

                _ ->
                    { user = Nothing }
    in
    setRoute (Route.fromUrl url)
        { pageState = Loaded initialPage
        , session = session
        , apiUrl = apiUrl
        , url = url
        , navKey = navKey
        }


initialPage : Page
initialPage =
    Blank



-- VIEW --


view : Model -> Browser.Document Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page



-- TODO: Do all title setting in this function as data is available rather than on route changes


viewPage : Session -> Bool -> Page -> Browser.Document Msg
viewPage session isLoading page =
    let
        frame =
            Page.frame isLoading session.user
    in
    case page of
        NotFound ->
            frame Page.Other "Page not found" (NotFound.view session)

        Blank ->
            -- for initial page load, while loading data via HTTP
            frame Page.Other "Loading..." (Html.text "")

        Errored subModel ->
            frame Page.Other "Error" (Errored.view session subModel)

        Login subModel ->
            frame Page.Login "Sign in" (Html.map LoginMsg (Login.view session subModel))

        Signup subModel ->
            frame Page.Signup "Sign up" (Html.map SignupMsg (Signup.view session subModel))

        Randomizer subModel ->
            frame Page.Randomizer "Recipe ideas" (Html.map RandomizerMsg (Randomizer.view session subModel))

        Recipes subModel ->
            let
                mappedHtml =
                    Html.map RecipesMsg (Recipes.view session subModel)
            in
            frame Page.Recipes "Recipes" mappedHtml

        RecipeDetail subModel ->
            let
                mappedHtml =
                    Html.map RecipeDetailMsg (RecipeDetail.view session subModel)
            in
            frame Page.Other "Recipe detail" mappedHtml

        RecipeEditor maybeSlug subModel ->
            let
                framePage =
                    if maybeSlug == Nothing then
                        Page.NewRecipe

                    else
                        Page.Other

                title =
                    if maybeSlug == Nothing then
                        "Add recipe"

                    else
                        "Edit recipe"

                mappedHtml =
                    Html.map RecipeEditorMsg (RecipeEditor.view subModel)
            in
            frame framePage title mappedHtml


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SetUser sessionChange
        , Sub.map RecipeEditorMsg (Sub.map RecipeEditor.SetAutocompleteState Menu.subscription)
        ]


sessionChange : Sub (Maybe User)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | SetUser (Maybe User)
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | RandomizerMsg Randomizer.Msg
    | RecipesMsg Recipes.Msg
    | RecipeDetailMsg RecipeDetail.Msg
    | RecipeEditorMsg RecipeEditor.Msg
    | RecipeDetailLoaded (Result PageLoadError RecipeDetail.Model)
    | EditRecipeLoaded Slug (Result PageLoadError RecipeEditor.Model)
    | NewRecipeLoaded (Result PageLoadError RecipeEditor.Model)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt toMsg task
            )

        errored =
            pageErrored model
    in
    case maybeRoute of
        Nothing ->
            ( { model | pageState = Loaded NotFound }, Cmd.none )

        Just Route.NewRecipe ->
            case model.session.user of
                Just user ->
                    transition NewRecipeLoaded (RecipeEditor.initNew model.session model.apiUrl)

                Nothing ->
                    errored Page.NewRecipe "You must be signed in to add a recipe."

        Just (Route.EditRecipe slug) ->
            case model.session.user of
                Just user ->
                    transition (EditRecipeLoaded slug) (RecipeEditor.initEdit model.session slug model.apiUrl)

                Nothing ->
                    errored Page.Other "You must be signed in to edit a recipe."

        Just Route.Root ->
            case model.session.user of
                Just user ->
                    ( model, Route.replaceUrl model.navKey Route.Recipes )

                Nothing ->
                    ( model, Route.replaceUrl model.navKey Route.Login )

        Just Route.Login ->
            ( { model | pageState = Loaded (Login (Login.init model.apiUrl model.navKey)) }
            , Cmd.none
            )

        Just Route.Logout ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | user = Nothing } }
            , Cmd.batch
                [ Ports.storeSession Nothing
                , Route.replaceUrl model.navKey Route.Login
                ]
            )

        Just Route.Signup ->
            ( { model | pageState = Loaded (Signup (Signup.initModel model.apiUrl model.navKey)) }
            , Cmd.none
            )

        Just Route.Randomizer ->
            let
                ( newModel, newMsg ) =
                    Randomizer.init model.session model.apiUrl
            in
            ( { model | pageState = Loaded (Randomizer newModel) }
            , Cmd.map RandomizerMsg newMsg
            )

        Just Route.Recipes ->
            let
                ( newModel, newMsg ) =
                    Recipes.init model.session model.apiUrl
            in
            ( { model | pageState = Loaded (Recipes newModel) }
            , Cmd.map RecipesMsg newMsg
            )

        Just (Route.RecipeDetail slug) ->
            let
                initRecipeDetail =
                    RecipeDetail.init model.session slug model.apiUrl
            in
            transition RecipeDetailLoaded initRecipeDetail


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
    ( { model | pageState = Loaded (Errored error) }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        session =
            model.session

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
            ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

        errored =
            pageErrored model
    in
    case ( msg, page ) of
        ( SetRoute route, _ ) ->
            setRoute route model

        ( EditRecipeLoaded slug (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (RecipeEditor (Just slug) subModel) }
            , Ports.setDocumentTitle (routeToTitle (Route.EditRecipe slug))
            )

        ( EditRecipeLoaded slug (Err error), _ ) ->
            ( { model | pageState = Loaded (Errored error) }
            , Ports.setDocumentTitle (routeToTitle (Route.EditRecipe slug) ++ " Error")
            )

        ( NewRecipeLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (RecipeEditor Nothing subModel) }
            , Ports.setDocumentTitle (routeToTitle Route.NewRecipe)
            )

        ( NewRecipeLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded (Errored error) }
            , Ports.setDocumentTitle (routeToTitle Route.NewRecipe ++ " Error")
            )

        ( SetUser user, _ ) ->
            let
                cmd =
                    -- If just signed out, then redirect to Login
                    if session.user /= Nothing && user == Nothing then
                        Route.replaceUrl model.navKey Route.Login

                    else
                        Cmd.none
            in
            ( { model | session = { session | user = user } }, cmd )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Login.update subMsg subModel model.navKey

                newModel =
                    case msgFromPage of
                        Login.NoOp ->
                            model

                        Login.SetUser user ->
                            { model | session = { user = Just user } }
            in
            ( { newModel | pageState = Loaded (Login pageModel) }, Cmd.map LoginMsg cmd )

        ( SignupMsg subMsg, Signup subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Signup.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Signup.NoOp ->
                            model

                        Signup.SetUser user ->
                            { model | session = { user = Just user } }
            in
            ( { newModel | pageState = Loaded (Signup pageModel) }, Cmd.map SignupMsg cmd )

        ( RandomizerMsg subMsg, Randomizer subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Randomizer.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Randomizer.NoOp ->
                            model
            in
            ( { newModel | pageState = Loaded (Randomizer pageModel) }, Cmd.map RandomizerMsg cmd )

        ( RecipesMsg subMsg, Recipes subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Recipes.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Recipes.NoOp ->
                            model
            in
            ( { newModel | pageState = Loaded (Recipes pageModel) }, Cmd.map RecipesMsg cmd )

        ( RecipeDetailMsg subMsg, RecipeDetail subModel ) ->
            case subMsg of
                RecipeDetail.ReceiveDeleteRecipe res ->
                    ( model, Route.replaceUrl model.navKey Route.Recipes )

                _ ->
                    let
                        ( ( pageModel, cmd ), msgFromPage ) =
                            RecipeDetail.update subMsg subModel

                        newModel =
                            case msgFromPage of
                                RecipeDetail.NoOp ->
                                    model
                    in
                    ( { newModel | pageState = Loaded (RecipeDetail pageModel) }, Cmd.map RecipeDetailMsg cmd )

        ( RecipeDetailLoaded (Ok subModel), _ ) ->
            let
                title =
                    case subModel.mRecipe of
                        Ok r ->
                            r.name

                        Err trumm ->
                            routeToTitle (Route.RecipeDetail (Data.Recipe.Slug ""))
            in
            ( { model | pageState = Loaded (RecipeDetail subModel) }
            , Ports.setDocumentTitle title
            )

        ( RecipeDetailLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded (Errored error) }
            , Ports.setDocumentTitle (routeToTitle (Route.RecipeDetail (Data.Recipe.Slug "")) ++ " Error")
            )

        ( RecipeEditorMsg subMsg, RecipeEditor slug subModel ) ->
            case model.session.user of
                Nothing ->
                    if slug == Nothing then
                        errored Page.NewRecipe
                            "You must be signed in to add recipes."

                    else
                        errored Page.Other
                            "You must be signed in to edit recipes."

                Just user ->
                    case subMsg of
                        RecipeEditor.RecipeSubmitted recipeSubmitResult ->
                            case recipeSubmitResult of
                                Ok recipe ->
                                    ( model, Route.replaceUrl model.navKey (Route.RecipeDetail (Data.Recipe.Slug recipe.id)) )

                                _ ->
                                    toPage (RecipeEditor slug) RecipeEditorMsg RecipeEditor.update subMsg subModel

                        _ ->
                            toPage (RecipeEditor slug) RecipeEditorMsg RecipeEditor.update subMsg subModel

        ( _, NotFound ) ->
            -- Disregard incoming messages when on the NotFound page.
            ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- MAIN --


onUrlChange : Url.Url -> Msg
onUrlChange url =
    SetRoute Nothing


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest _ =
    SetRoute Nothing


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        , subscriptions = subscriptions
        }



--  programWithFlags (Route.fromLocation >> SetRoute)
-- need onUrlChange and onUrlRequest functions
-- And need to press that record to
-- What is the difference between Location and UrlRequest??

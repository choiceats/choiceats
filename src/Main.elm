module Main exposing (main)

-- ELM-LANG MODULES --

import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Task


-- THIRD PARTY MODULES --

import Autocomplete


-- APPLICATION MODULES --

import Data.Recipe exposing (Slug)
import Data.Session exposing (Session)
import Data.User as User exposing (User)
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Randomizer as Randomizer
import Page.RecipeDetail as RecipeDetail
import Page.RecipeEditor as RecipeEditor
import Page.Recipes as Recipes
import Page.Signup as Signup
import Ports
import Route exposing (Route, routeToTitle)
import Views.Page as Page exposing (ActivePage)


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Home Home.Model
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
    }


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = decodeUserFromJson val }
        }


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString User.decoder >> Result.toMaybe)


initialPage : Page
initialPage =
    Blank



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page


viewPage : Session -> Bool -> Page -> Html Msg
viewPage session isLoading page =
    let
        frame =
            Page.frame isLoading session.user
    in
        case page of
            NotFound ->
                NotFound.view session
                    |> frame Page.Other

            Blank ->
                -- for initial page load, while loading data via HTTP
                Html.text ""
                    |> frame Page.Other

            Errored subModel ->
                Errored.view session subModel
                    |> frame Page.Other

            Home subModel ->
                Home.view session subModel
                    |> frame Page.Home
                    |> Html.map HomeMsg

            Login subModel ->
                Login.view session subModel
                    |> frame Page.Login
                    |> Html.map LoginMsg

            Signup subModel ->
                Signup.view session subModel
                    |> frame Page.Signup
                    |> Html.map SignupMsg

            Randomizer subModel ->
                Randomizer.view session subModel
                    |> frame Page.Randomizer
                    |> Html.map RandomizerMsg

            Recipes subModel ->
                Recipes.view session subModel
                    |> frame Page.Recipes
                    |> Html.map RecipesMsg

            RecipeDetail subModel ->
                RecipeDetail.view session subModel
                    |> frame Page.Other
                    |> Html.map RecipeDetailMsg

            RecipeEditor maybeSlug subModel ->
                let
                    framePage =
                        if maybeSlug == Nothing then
                            Page.NewRecipe
                        else
                            Page.Other
                in
                    RecipeEditor.view subModel
                        |> frame framePage
                        |> Html.map RecipeEditorMsg


subscriptions model =
    Sub.batch
        [ Sub.map SetUser sessionChange
        , Sub.map RecipeEditorMsg (Sub.map RecipeEditor.SetAutocompleteState Autocomplete.subscription)
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
    | HomeLoaded (Result PageLoadError Home.Model)
    | HomeMsg Home.Msg
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
            , (Task.attempt toMsg task)
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
                        transition NewRecipeLoaded (RecipeEditor.initNew model.session)

                    Nothing ->
                        errored Page.NewRecipe "You must be signed in to add a recipe."

            Just (Route.EditRecipe slug) ->
                case model.session.user of
                    Just user ->
                        transition (EditRecipeLoaded slug) (RecipeEditor.initEdit model.session slug)

                    Nothing ->
                        errored Page.Other "You must be signed in to edit a recipe."

            Just Route.Home ->
                transition HomeLoaded (Task.succeed (Home.init model.session))

            Just Route.Root ->
                ( model, Route.modifyUrl Route.Home )

            Just Route.Login ->
                ( { model | pageState = Loaded (Login Login.initialModel) }
                , Ports.setDocumentTitle (routeToTitle Route.Login)
                )

            Just Route.Logout ->
                let
                    session =
                        model.session
                in
                    ( { model | session = { session | user = Nothing } }
                    , Cmd.batch
                        [ Ports.storeSession Nothing
                        , Route.modifyUrl Route.Home
                        ]
                    )

            Just Route.Signup ->
                ( { model | pageState = Loaded (Signup Signup.initialModel) }
                , Ports.setDocumentTitle (routeToTitle Route.Signup)
                )

            Just Route.Randomizer ->
                let
                    ( newModel, newMsg ) =
                        (Randomizer.init model.session)
                in
                    ( { model | pageState = Loaded (Randomizer newModel) }
                    , Cmd.batch
                        [ Ports.setDocumentTitle (routeToTitle Route.Randomizer)
                        , Cmd.map RandomizerMsg newMsg
                        ]
                    )

            Just Route.Recipes ->
                let
                    ( newModel, newMsg ) =
                        (Recipes.init model.session)
                in
                    ( { model | pageState = Loaded (Recipes newModel) }
                    , Cmd.batch
                        [ Ports.setDocumentTitle (routeToTitle Route.Recipes)
                        , Cmd.map RecipesMsg newMsg
                        ]
                    )

            Just (Route.RecipeDetail slug) ->
                let
                    init =
                        (RecipeDetail.init model.session slug)
                in
                    transition RecipeDetailLoaded init


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
                , Ports.setDocumentTitle (routeToTitle (Route.NewRecipe))
                )

            ( NewRecipeLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }
                , Ports.setDocumentTitle (routeToTitle (Route.NewRecipe) ++ " Error")
                )

            ( HomeLoaded (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (Home subModel) }
                , Ports.setDocumentTitle (routeToTitle Route.Home)
                )

            ( HomeLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }
                , Ports.setDocumentTitle "Error"
                )

            ( SetUser user, _ ) ->
                let
                    cmd =
                        -- If just signed out, then redirect to Home.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none
                in
                    ( { model | session = { session | user = user } }, cmd )

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update subMsg subModel

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

            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg (Home.update session) subMsg subModel

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
                                        ( model, Route.modifyUrl (Route.RecipeDetail (Data.Recipe.Slug recipe.id)) )

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


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

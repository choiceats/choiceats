module Main exposing (main)

import Data.Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.Login as Login
import Page.Signup as Signup
import Page.Randomizer as Randomizer
import Page.RecipeDetail as RecipeDetail
import Page.Recipes as Recipes
import Page.NotFound as NotFound
import Ports
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)


{- Still missing:
   Settings
   PageLoadError
   Errored
   |
-}
-- Models?


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
                    |> frame Page.Other
                    |> Html.map LoginMsg

            Signup subModel ->
                Signup.view session subModel
                    |> frame Page.Other
                    |> Html.map SignupMsg

            Randomizer subModel ->
                Randomizer.view session subModel
                    |> frame Page.Other
                    |> Html.map RandomizerMsg

            Recipes subModel ->
                Recipes.view session subModel
                    |> frame Page.Other
                    |> Html.map RecipesMsg

            RecipeDetail subModel ->
                RecipeDetail.view session subModel
                    |> frame Page.Other
                    |> Html.map RecipeDetailMsg


subscriptions model =
    Sub.batch
        [ Sub.map SetUser sessionChange
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
    | RecipeDetailLoaded (Result PageLoadError RecipeDetail.Model)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        -- TODO: Make it how it should be
        -- transition toMsg task =
        --     ({ model | pageState = TransitioningFrom (getPage model.pageState) },
        --         Task.attempt toMsg task)
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }, (Task.attempt toMsg task) )

        --
        errored =
            pageErrored model
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            -- TODO: Make it how it should be
            Just Route.Home ->
                transition HomeLoaded (Task.succeed (Home.init model.session))

            Just Route.Root ->
                ( model, Route.modifyUrl Route.Home )

            Just Route.Login ->
                ( { model | pageState = Loaded (Login Login.initialModel) }, Cmd.none )

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
                ( { model | pageState = Loaded (Signup Signup.initialModel) }, Cmd.none )

            Just Route.Randomizer ->
                let
                    ( newModel, newMsg ) =
                        (Randomizer.init model.session)
                in
                    ( { model | pageState = Loaded (Randomizer newModel) }, Cmd.map RandomizerMsg newMsg )

            Just Route.Recipes ->
                let
                    ( newModel, newMsg ) =
                        (Recipes.init model.session)
                in
                    ( { model | pageState = Loaded (Recipes newModel) }, Cmd.map RecipesMsg newMsg )

            Just (Route.RecipeDetail slug) ->
                let
                    init =
                        (RecipeDetail.init model.session slug)
                in
                    transition RecipeDetailLoaded init



-- should be a task for the second argument. A Task.attempt?? That can produce a model??
-- updatePage can call setRoute. setRoute can setRoute, or it can do a task. If the task succeeds, it does some sort of resolving with data (via result??) and triggers the *Loaded message. I think the Loaded message then tells the page it can now display, and sets the model to the form ((model, msg), external msg)
-- After all, setRoute is for when you FIRST come in on the page so it is not expected that you be able to set all the model at once. So it is enough to do a task that gets data. And that is also another reason why you don't go to the page immediately: the data is still loading.
-- And it is if ALL the tasks (i.e. Task.map2) succeed that you must end up with a Home.Model or RecipeDetail.Model or what have you.
-- It does not return a model, but a Task Model. The whole thing is still boxed in task!! Which is why they are using Task.Map
-- the success ask for recipe, gets passed to a function that takes a recipe and returns a model !! :D :D :D :D
--
--
--
--
--                let
--                    ( ( newModel, newMsg ), newExternalMsg ) =
--                        (RecipeDetail.init model.session slug)
--                in
--                    transition RecipeDetailLoaded ( ( newModel, newMsg ), newExternalMsg )
--( { model | pageState = Loaded (RecipeDetail newModel) }, Cmd.map RecipeDetailMsg newMsg )
--            Just (Route.RecipeDetail slug) ->
--                let
--                    ( ( newModel, newMsg ), newExternalMsg ) =
--                        (RecipeDetail.init model.session slug)
--                in
--                    ( { model | pageState = Loaded (RecipeDetail newModel) }, Cmd.map RecipeDetailMsg newMsg )


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

            ( HomeLoaded (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (Home subModel) }, Cmd.none )

            ( HomeLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

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

            ( RecipeDetailLoaded (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (RecipeDetail subModel) }, Cmd.none )

            ( RecipeDetailLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            --                let
            --                    ( ( pageModel, cmd ), msgFromPage ) =
            --                        RecipeDetail.update subMsg subModel
            --
            --                    newModel =
            --                        case msgFromPage of
            --                            RecipeDetail.NoOp ->
            --                                model
            --                in
            --                    ( { newModel | pageState = Loaded (RecipeDetail pageModel) }, Cmd.map RecipeDetailMsg cmd )
            --            ( RecipeDetailMsg subMsg, RecipeDetail subModel ) ->
            --                let
            --                    ( ( pageModel, cmd ), msgFromPage ) =
            --                        RecipeDetail.update subMsg subModel
            --
            --                    newModel =
            --                        case msgFromPage of
            --                            RecipeDetail.NoOp ->
            --                                model
            --                in
            --                    ( { newModel | pageState = Loaded (RecipeDetail pageModel) }, Cmd.map RecipeDetailMsg cmd )
            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg (Home.update session) subMsg subModel

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

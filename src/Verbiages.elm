module Verbiages exposing (errors, titles)


titles =
    { notFound = "Page not found"
    , loading = "Loading..."
    , error = "Error"
    , signIn = "Sign in"
    , signUp = "Sign up"
    , ideas = "Recipe ideas"
    , recipes = "Recipes"
    , defaultRecipeDetail = "Recipe Detail"
    , addRecipe = "Add recipe"
    , editRecipe = "Edit recipe"
    }


errors =
    { signInAdd = "You must be signed in to add a recipe."
    , signInEdit = "You must be signed in as recipe owner to edit a recipe."
    , recipeLoad = "Unable to load recipe."
    , recipeLoadParts = "Failed to load some needed pieces of recipe editor."
    }

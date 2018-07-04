module Marker exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Markdown

main : Program Never Model Msg
main =
  Html.beginnerProgram
    { model = model
    , view = view
    , update = update
    }


-- MODEL

type alias Model =
  { content : String
  }

model : Model
model =
  Model starter


-- UPDATE

type Msg
    = Name String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Name content ->
      { model | content = content }


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "wrapper" ]
    [ textarea [ placeholder "Write something...", onInput Name, class "editor" ] [ text model.content ]
    , Markdown.toHtml [ class "markdown-body" ] model.content
    ]


-- UTIL

starter : String
starter = """# This is Markdown

[Markdown](http://daringfireball.net/projects/markdown/) lets you write content in a really natural way.

  * You can have lists, like this one
  * Make things **bold** or *italic*
  * Embed snippets of `code`
  * Create [links](/)
  * ...

The [elm-markdown][] package parses all this content, allowing you
to easily generate blocks of `Element` or `Html`.

[elm-markdown]: http://package.elm-lang.org/packages/evancz/elm-markdown/latest
"""

# Marker

Simple Markdown Editor That Saves to LocalStorage

### Development

#### Requirements
  - [Elm 0.19](https://guide.elm-lang.org/install.html)
  - [elm-live](https://github.com/architectcodes/elm-live)

#### Build on Change
  - `elm-live src/Marker.elm --open --dir=public -- --output=public/marker.js`

#### Build for Production

  - `elm make src/Marker.elm --output=public/marker.js --optimize`

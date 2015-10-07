import XMonad

main = xmonad $ defaultConfig
    { borderWidth        = 2
    , terminal           = "termite"
    , normalBorderColor  = "#393939"
    , focusedBorderColor = "#ca674a" }

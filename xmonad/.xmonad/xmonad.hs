import XMonad

import qualified Data.Map as M

main = xmonad $ defaultConfig
    { borderWidth        = 2
    , terminal           = "termite"
    , normalBorderColor  = "#393939"
    , focusedBorderColor = "#ca674a"
    , keys               = myKeys
    }

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys c@(XConfig { modMask = modMask }) =
  M.insert
    (modMask, xK_p)
    (spawn "dmenu_run -fn 'Iosevka:14'")
    ((keys defaultConfig) c)

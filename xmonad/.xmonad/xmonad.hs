import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run (spawnPipe)
import XMonad.Hooks.ManageDocks
import System.IO (hPutStrLn)

import qualified Data.Map as M

main = do
  xmproc <- spawnPipe "xmobar"

  xmonad $ defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                  { ppOutput = hPutStrLn xmproc
                  , ppTitle = xmobarColor "green" "" . shorten 50
                  }
    , borderWidth        = 2
    , terminal           = "termite"
    , normalBorderColor  = "#393939"
    , focusedBorderColor = "#ca674a"
    }

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys c@(XConfig { modMask = modMask }) =
  M.insert
    (modMask, xK_p)
    (spawn "dmenu_run -fn 'Iosevka:14'")
    ((keys defaultConfig) c)

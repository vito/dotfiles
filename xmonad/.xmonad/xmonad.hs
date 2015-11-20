import System.IO (hPutStrLn)

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.CustomKeys
import XMonad.Util.Run (spawnPipe)

import qualified Data.Map as M

main = do
  xmproc <- spawnPipe "xmobar"

  xmonad $ defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                  { ppOutput = hPutStrLn xmproc
                  , ppCurrent = xmobarColor "#6eb5f3" ""
                  , ppUrgent = xmobarColor "#000000" "#ca674a"
                  , ppTitle = xmobarColor "#96a967" "" . shorten 100
                  }
    , borderWidth        = 2
    , terminal           = "termite"
    , normalBorderColor  = "#393939"
    , focusedBorderColor = "#ca674a"
    , keys               = customKeys (const []) insKeys
    }

insKeys :: XConfig l -> [((KeyMask, KeySym), X ())]
insKeys conf@(XConfig {modMask = modm}) =
   [ ((modm              , xK_p ), spawn "dmenu_run -fn 'Iosevka:10'")
   , ((modm .|. shiftMask, xK_l ), spawn "slock")
   ]

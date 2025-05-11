
{-# OPTIONS_GHC -Wno-deprecations #-} -- Optional: Suppress deprecation warnings if any arise from dependencies

import Data.Monoid
import System.IO (hPutStrLn) -- For writing to xmobar pipe (kept in case needed later)
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioMute, xF86XK_AudioNext, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioRaiseVolume, xF86XK_AudioStop)
import Data.List (isPrefixOf) -- <<< ADDED: For prefix matching in ManageHook

import XMonad
import XMonad.Util.Run (spawnPipe) -- Kept in case needed later
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.EZConfig (additionalKeysP)

-- Hooks
import XMonad.Hooks.DynamicLog -- Core dynamic log hooks & PP definition
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen) -- For EWMH compliance
import XMonad.ManageHook
import XMonad.Hooks.ManageDocks   -- <<< ADDED: Import for avoidStruts, manageDocks, and docks

-- Layouts & Spacing
import XMonad.Layout.Spacing -- For gaps between windows
import XMonad.Layout.ThreeColumns (ThreeCol(..)) -- For ThreeCol layout

import qualified XMonad.StackSet as W
import qualified XMonad.Layout.LayoutModifier

------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------

-- XMobar configuration
myXmobarPP :: PP
myXmobarPP = def
    { ppCurrent         = xmobarColor "#bc96da" "" . wrap "[" "]"
    , ppVisible         = xmobarColor "#bc96da" "" . wrap "(" ")"
    , ppHidden          = xmobarColor "#3b4252" "" . wrap " " " "
    , ppHiddenNoWindows = xmobarColor "#3b4252" "" . wrap " " " "
    , ppUrgent          = xmobarColor "#bf616a" "" . wrap "!" "!"
    , ppSep             = "  "
    , ppTitle           = xmobarColor "#bc96da" "" . shorten 60
    , ppLayout          = xmobarColor "#bc96da" ""
    }

myTerminal :: String
myTerminal = "wezterm"

myModMask :: KeyMask
myModMask = mod4Mask -- Use Super key as the modifier

-- Gaps configuration
myGapWidth :: Integer
myGapWidth = 5 -- Set the gap width in pixels

-- Define the spacing layout modifier
mySpacing =
  spacingRaw
    False -- smartBorder: False = always show gaps
    (Border 0 0 0 0) -- screenBorder size T/B/R/L
    True -- screenBorderEnabled
    (Border myGapWidth myGapWidth myGapWidth myGapWidth) -- windowBorder size T/B/R/L
    True -- windowBorderEnabled

-- Define Workspace Names
myWorkspaces :: [String]
-- Using escape codes for icons to avoid potential lexical errors
myWorkspaces = [ "\xf0ac web"    -- 
               , "\xf075 chat"   --  (Replaced \t with space)
               , "\xf1b6 steam"  -- 
               , "\xf11b games"  -- 
               , "\xf7d9 printing" -- 
               ]

-- Border colors
myNormalBorderColor :: String
myNormalBorderColor = "#3b4252" -- Nord Polar Night 1

myFocusedBorderColor :: String
myFocusedBorderColor = "#bc96da" -- Custom purple accent

myBorderWidth :: Dimension
myBorderWidth = 2

------------------------------------------------------------------------
-- Layout Hook
------------------------------------------------------------------------

-- Apply spacing to the layouts you want gapped
myLayout =  mySpacing threeCol ||| mySpacing tiled ||| mySpacing (Mirror tiled) ||| Full
  where
    -- Base layout definitions
    threeCol = ThreeColMid nmaster delta ratio
    tiled = Tall nmaster delta ratio
    -- Layout parameters
    nmaster = 1 -- Default number of windows in the master pane
    ratio = 1 / 2 -- Default proportion of screen occupied by master pane
    delta = 3 / 100 -- Percent of screen to increment by when resizing panes

------------------------------------------------------------------------
-- Manage Hook
------------------------------------------------------------------------

-- Define rules for specific applications
-- <<< MODIFIED myManageHook >>>
myManageHook :: ManageHook
myManageHook =
  composeAll
    [ 
     className =? "wezterm" --> doShift (head myWorkspaces)
    , className =? "thorium-browser" --> doShift (head myWorkspaces)
    , className =? "Cursor" --> doShift (head myWorkspaces)  -- Assign Cursor to workspace 0
    -- Assign Discord to workspace 1 (chat), make it float, and prevent it from stealing focus
    , className =? "discord" --> doShift (myWorkspaces !! 1) <+> doFloat <+> doF W.focusDown
    -- Assign Steam client to workspace 2 (steam), make it float, and prevent it from stealing focus
    , (className =? "Steam" <||> className =? "steam") -->
        doShift (myWorkspaces !! 2) <+> doFloat <+> doF W.focusDown
    -- For gamescope or steam_app*, shift to workspace 3 (games), make it float,
    -- and then switch the view to workspace 2 (where Steam client is)
    , (className =? "gamescope" <||> fmap (isPrefixOf "steam_app") className) -->
        doShift (myWorkspaces !! 3) <+>        
        doFloat <+>                               -- Make the game window float                               -- Make the game window float                               -- Make the game window float                               -- Make the game window float
        doF (W.greedyView (myWorkspaces !! 2))    -- Switch view to workspace 2 (Steam)
    , title =? "Friends List" --> doFloat         -- Keep Steam Friends List floating
    ]

------------------------------------------------------------------------
-- Startup Hook
------------------------------------------------------------------------

-- Actions to run on login
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "picom &" -- Start compositor
  spawnOnce "xrandr --output DP-0 --mode 5120x1440 --rate 240" -- Set screen resolution
  spawnOnce "discord &" -- Start Discord
  spawnOnce "steam &" -- Start Steam automatically
  spawnOnce "thorium-browser &" -- Start Steam automatically
  spawnOnce "wezterm &" -- Start terminal
  spawnOnce "openrgb --startminimized -p purple &" -- Restore wallpaper using nitrogen (optional)
  spawnOnce "xsetroot -cursor_name left_ptr" -- Set default cursor to left_ptr
  -- spawnOnce "nitrogen --restore &" -- Restore wallpaper using nitrogen (optional)
  -- spawnOnce "volumeicon &"         -- Optional: For volume control systray icon

------------------------------------------------------------------------
-- Keybindings
------------------------------------------------------------------------
-- Media Key Definitions & Rofi
myKeys :: [(String, X ())]
myKeys =
  [ ("<XF86AudioPlay>",        spawn "playerctl play-pause"),
    ("<XF86AudioStop>",        spawn "playerctl stop"),
    ("<XF86AudioPrev>",        spawn "playerctl previous"),
    ("<XF86AudioNext>",        spawn "playerctl next"),
    ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ("<XF86AudioMute>",        spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle"),
    -- Rofi bindings
    ("M-p",                    spawn "rofi -show drun"),  -- App launcher
    ("M-S-p",                  spawn "rofi -show run"),   -- Command runner
    ("M-w",                    spawn "rofi -show window") -- Window switcher
    -- Add other custom keybindings here if desired
  ]

------------------------------------------------------------------------
-- Base Configuration
------------------------------------------------------------------------

-- Define the base configuration settings
vachiConfig :: XConfig
  (XMonad.Layout.LayoutModifier.ModifiedLayout
     AvoidStruts
     (Choose
        (XMonad.Layout.LayoutModifier.ModifiedLayout Spacing ThreeCol)
        (Choose
           (XMonad.Layout.LayoutModifier.ModifiedLayout Spacing Tall)
           (Choose
              (XMonad.Layout.LayoutModifier.ModifiedLayout Spacing (Mirror Tall))
              Full))))
vachiConfig =
  def
    { modMask = myModMask,
      terminal = myTerminal,
      borderWidth = myBorderWidth,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,

      -- Hooks
      layoutHook = avoidStruts $ myLayout, -- <<< MODIFIED: Apply avoidStruts
      manageHook = myManageHook <+> manageHook def <+> manageDocks, -- <<< MODIFIED: Add manageDocks
      startupHook = myStartupHook,
      handleEventHook = handleEventHook def -- Use default event handler
    }

------------------------------------------------------------------------
-- Main Execution
------------------------------------------------------------------------

main :: IO ()
main = do
    -- Create a pipe for xmobar
    xmproc <- spawnPipe "/xmobar"
    
    -- Define the final configuration, combining base config, hooks, and keybindings
    let config = vachiConfig 
            { logHook = dynamicLogWithPP $ myXmobarPP { ppOutput = hPutStrLn xmproc }
            } `additionalKeysP` myKeys

    -- Launch xmonad with the final configuration and EWMH/Docks support
    xmonad $ docks $ ewmhFullscreen $ ewmh config

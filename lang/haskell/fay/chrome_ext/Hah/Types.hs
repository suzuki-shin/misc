{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module Hah.Types where

import Prelude
import JS
import MyPrelude

data Key = Key {
    getCode :: Int
  , getCtrl :: Bool
  , getAlt :: Bool
  } deriving (Show, Eq)

data Item = Item {
    getId :: String
  , getTitle :: String
  , getUrl :: String
  , getType :: String
  } deriving (Show)

data Mode = NeutralMode | HitAHintMode | SelectorMode | FormFocusMode deriving (Show)

data St = St {
    getModeRef :: Ref Mode
  , getCtrlRef :: Ref Bool
  , getAltRef :: Ref Bool
  , getInputIdxRef :: Ref Int
  , getListRef :: Ref [Item]
  , getFirstKeyCodeRef :: Ref (Maybe Int)
  }

data Method = StartHitahint
            | FocusForm
            | ToggleSelector
            | Cancel
            | MoveNextSelectorCursor
            | MovePrevSelectorCursor
            | MoveNextForm
            | MovePrevForm
            | BackHistory
            deriving (Show)

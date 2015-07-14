-- License: BSD3 (see LICENSE)
-- Author: Dino Morelli <dino@ui3.info>

{-# LANGUAGE DeriveGeneric #-}

module KS.Legacy.Inspection
   ( Inspection (..)
   )
   where

import Data.Aeson ( FromJSON, ToJSON )
import Data.Text
import GHC.Generics ( Generic )


data Inspection = Inspection
   { inspection_source :: String
   , name :: Text
   , addr :: Text
   , date :: [Int]
   , score :: Double
   , violations :: Int
   , crit_violations :: Int
   , reinspection :: Bool
   , detail :: String
   }
   deriving (Generic, Show)

instance FromJSON Inspection
instance ToJSON Inspection

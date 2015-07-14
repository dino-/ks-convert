-- License: BSD3 (see LICENSE)
-- Author: Dino Morelli <dino@ui3.info>

{-# LANGUAGE DeriveGeneric #-}

module KS.Legacy.Document
   ( Document (..), loadDoc )
   where

import Data.Aeson ( FromJSON, ToJSON, eitherDecodeStrict' )
import qualified Data.ByteString as BS
import GHC.Generics ( Generic )

import qualified KS.Legacy.Inspection as I
import qualified KS.Legacy.Place as P


data Document = Document
   { _id :: String
   , doctype :: String
   , inspection :: I.Inspection
   , place :: P.Place
   }
   deriving (Generic, Show)

instance ToJSON Document
instance FromJSON Document


loadDoc :: FilePath -> IO (Either String Document)
loadDoc path = eitherDecodeStrict' `fmap` BS.readFile path

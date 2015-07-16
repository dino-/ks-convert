-- License: BSD3 (see LICENSE)
-- Author: Dino Morelli <dino@ui3.info>

{-# LANGUAGE DeriveGeneric #-}

module KS.Legacy.Inspection
   ( IdInspection (..)
   , Inspection (..)
   , loadInspection
   )
   where

import Data.Aeson ( FromJSON, ToJSON, eitherDecodeStrict' )
import qualified Data.ByteString as BS
import Data.Text
import GHC.Generics ( Generic )


data IdInspection = IdInspection
   { _id :: String
   , inspection :: Inspection
   }
   deriving (Generic, Show)

instance FromJSON IdInspection
instance ToJSON IdInspection


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


loadInspection :: FilePath -> IO IdInspection
loadInspection path = do
   bytes <- BS.readFile path
   case eitherDecodeStrict' bytes of
      Left msg -> ioError $ userError msg
      Right insp -> return insp

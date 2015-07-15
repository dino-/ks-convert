-- License: BSD3 (see LICENSE)
-- Author: Dino Morelli <dino@ui3.info>

import Data.Geospatial ( GeoPoint (..) )
import Data.List ( isPrefixOf )
import Data.Time.Calendar ( fromGregorian )
import Data.Time.LocalTime ( LocalTime (..), TimeZone, getCurrentTimeZone
   , localTimeToUTC, midnight )
import System.Directory ( doesFileExist , getDirectoryContents )
import System.Environment ( getArgs )
import System.FilePath
import System.IO
   ( BufferMode ( NoBuffering )
   , hSetBuffering, stdout, stderr
   )

import KS.Data.Document
import KS.Data.Inspection
import KS.Data.Place
import qualified KS.Legacy.Document as LD
import qualified KS.Legacy.Inspection as LI
import qualified KS.Legacy.Place as LP


main :: IO ()
main = do
   -- No buffering, it messes with the order of output
   mapM_ (flip hSetBuffering NoBuffering) [ stdout, stderr ]

   (destDir : srcDirsOrFiles) <- getArgs

   -- Paths to all files we'll be processing
   files <- concat `fmap`
      (sequence $ map buildFileList srcDirsOrFiles)

   tz <- getCurrentTimeZone

   mapM_
      (\f -> do
         putStr $ f ++ " -> "
         loadResult <- LD.loadDoc f
         either putStrLn (handleLoadSuccess tz destDir) loadResult
      )
      files


handleLoadSuccess :: TimeZone -> FilePath -> LD.Document -> IO ()
handleLoadSuccess tz destDir legacyDoc =
   putStrLn =<< (saveDocument destDir $ convert tz legacyDoc)


convert :: TimeZone -> LD.Document -> Document

convert tz (LD.Document _ dt
   (LI.Inspection is inm ad (y : m : d : _) sc vi cr re de)
   (LP.Place pnm vic (LP.PlLatLng lat lng) ty pid))

   = Document
      { doctype = dt
      , inspection = Inspection is inm ad ut sc vi cr re de
      , place = Place pnm vic (GeoPoint [lng, lat]) ty pid
      }

   where
      ut = localTimeToUTC tz $
         LocalTime (fromGregorian (fromIntegral y) m d) midnight

convert _ _ = undefined


buildFileList :: FilePath -> IO [FilePath]
buildFileList srcDirOrFile = do
   isFile <- doesFileExist srcDirOrFile
   if isFile then return [srcDirOrFile]
      else
         ( map (srcDirOrFile </>)                  -- ..relative paths
         . filter (not . isPrefixOf ".") )         -- ..minus dotfiles
         `fmap` getDirectoryContents srcDirOrFile  -- All files

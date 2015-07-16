-- License: BSD3 (see LICENSE)
-- Author: Dino Morelli <dino@ui3.info>

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
import System.IO.Error ( tryIOError )

import KS.Data.Inspection
import qualified KS.Legacy.Inspection as LI


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
         loadResult <- tryIOError $ LI.loadInspection f
         either print (handleLoadSuccess tz destDir) loadResult
      )
      files


handleLoadSuccess :: TimeZone -> FilePath -> LI.IdInspection -> IO ()
handleLoadSuccess tz destDir legacyInsp =
   putStrLn =<< (saveInspection destDir $ convert tz legacyInsp)


convert :: TimeZone -> LI.IdInspection -> Inspection

convert tz (LI.IdInspection _
   (LI.Inspection is inm ad (y : m : d : _) sc vi cr re de))

   = Inspection is inm ad ut sc vi cr re de

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

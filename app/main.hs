module Main where

import Conduit
import Control.Concurrent (threadDelay)
import Control.Monad
import Data.Function ((&))
import Life
import System.Console.ANSI
import System.Random

genStartCoords :: IO [(Int, Int)]
genStartCoords = do
  len <- randomRIO (100, 200)  -- Adjust the range as needed
  replicateM len $ do
    x <- randomRIO (12, 36)
    y <- randomRIO (12, 36)
    pure (x, y)

pipeline :: Monad m => World -> ConduitT () World m ()
pipeline start = do
  yield start
  tickLoop start
  where
    tickLoop world = do
      let newWorld = tick world
      yield newWorld
      tickLoop newWorld

draw :: World -> IO ()
draw world = do
  clearScreen
  putStrLn $ showWorld world
  threadDelay 100000

main :: IO ()
main = do
  coords <- genStartCoords
  let world = foldr (\(x, y) m -> setLiveInWorld (y, x) m) (deadWorld 50 50) coords
  runConduit $ pipeline world .| mapM_C draw

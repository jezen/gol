module Main where

import Control.Monad
import Life
import System.Random
import Terminal.Game

genStartCoords :: Int -> Int -> IO [(Int, Int)]
genStartCoords w h = do
  len <- randomRIO (1000, 2000)
  replicateM len $ do
    x <- randomRIO (w `div` 2 - w `div` 4, w `div` 2 + w `div` 4)
    y <- randomRIO (h `div` 2 - h `div` 4, h `div` 2 + h `div` 4)
    pure (x, y)

logic :: GEnv -> World -> Event -> Either r World
logic env world _event = pure $ Life.tick world

draw env world = stringPlane $ showWorld world

main :: IO ()
main = do
  (w, h) <- displaySize
  coords <- genStartCoords w h
  let world = foldr (\(x, y) m -> setLiveInWorld (y, x) m) (deadWorld w h) coords
  playGame_ $ Game 13 world logic draw

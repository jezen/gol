module Life where

import Data.Matrix

type World = Matrix Cell

data Cell = Live | Dead
  deriving (Eq)

instance Show Cell where
  show Dead = " "
  show Live = "■"

deadWorld :: Int -> Int -> World
deadWorld rows cols = matrix rows cols (const Dead)

setLiveInWorld :: (Int, Int) -> World -> World
setLiveInWorld = setElem Live

showWorld :: World -> String
showWorld = prettyMatrix

countNeighbours :: (Int, Int) -> World -> Int
countNeighbours (x, y) m = length $ filter (Just Live ==)
  [ safeGet (x - 1) (y - 1) m
  , safeGet x       (y - 1) m
  , safeGet (x + 1) (y - 1) m
  , safeGet (x - 1)  y m
  , safeGet (x + 1)  y m
  , safeGet (x - 1) (y + 1) m
  , safeGet x       (y + 1) m
  , safeGet (x + 1) (y + 1) m
  ]

tick :: World -> World
tick m = mapPos f m
  where
  f (x, y) cell = case cell of
    Live
      | countNeighbours (x, y) m  < 2 -> Dead
      | countNeighbours (x, y) m == 2 -> Live
      | countNeighbours (x, y) m == 3 -> Live
      | otherwise                     -> Dead
    Dead
      | countNeighbours (x, y) m == 3 -> Live
      | otherwise                     -> Dead

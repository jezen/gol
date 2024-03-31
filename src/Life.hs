{-# LANGUAGE LambdaCase #-}

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

isLive :: Cell -> Bool
isLive Live = True
isLive Dead = False

countNeighbours :: (Int, Int) -> World -> Int
countNeighbours (x, y) m = length $ filter isLive
  [ m ! (prevX, prevY)
  , m ! (x, prevY)
  , m ! (succX, prevY)
  , m ! (prevX, y)
  , m ! (succX, y)
  , m ! (prevX, succY)
  , m ! (x, succY)
  , m ! (succX, succY)
  ]
  where
  prevX = if x == 1 then nrows m else x - 1
  succX = if x == nrows m then 1 else x + 1
  prevY = if y == 1 then ncols m else y - 1
  succY = if y == ncols m then 1 else y + 1

tick :: World -> World
tick m = mapPos f m
  where
  f (x, y) = \case
    Live
      | countNeighbours (x, y) m  < 2 -> Dead
      | countNeighbours (x, y) m == 2 -> Live
      | countNeighbours (x, y) m == 3 -> Live
      | otherwise                     -> Dead
    Dead
      | countNeighbours (x, y) m == 3 -> Live
      | otherwise                     -> Dead

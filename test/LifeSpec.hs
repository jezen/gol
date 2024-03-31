module LifeSpec where

import Data.Function ((&))
import Data.Matrix
import Life
import Test.Hspec

spec :: Spec
spec = do

  describe "deadWorld" $ do

    it "builds a world with no live cells" $ do
      deadWorld 5 5 `shouldBe` fromLists
        [ [ Dead, Dead, Dead, Dead, Dead ]
        , [ Dead, Dead, Dead, Dead, Dead ]
        , [ Dead, Dead, Dead, Dead, Dead ]
        , [ Dead, Dead, Dead, Dead, Dead ]
        , [ Dead, Dead, Dead, Dead, Dead ]
        ]

  describe "countNeighbours" $ do

    it "returns the number of adjacent live cells for a given cell" $ do
      let world = deadWorld 5 5
                    & setElem Live (1,1)
                    & setElem Live (1,2)
                    & setElem Live (1,3)
      countNeighbours (1,2) world `shouldBe` 2

  describe "a live cell with fewer than two live neighbours" $ do

    it "dies" $ do
      let world = deadWorld 5 5 & setElem Live (2,2)
      tick world `shouldBe` deadWorld 5 5

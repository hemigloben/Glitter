{-
author: Jackson C. Wiebe
date:   March 1 2018
-}

module Polyomino
  ( Polyomino (Polyomino, token, parts, width, Empty)
  , createPolyomino
  , flipxy
  , flipv
  , move
  , move'
  , orientations
  ) where

import Types
import Data.List
import Debug.Trace
data Polyomino = Empty | Polyomino { parts::[Location]
                           , width::Int
                           , height::Int
                           , token::Token
                           }
                 deriving (Eq, Ord)

createPolyomino :: [Location] -> Token -> Polyomino
createPolyomino xs token =
  let points = unzip xs;
      width  = (maximum $ fst points) + 1;
      height = (maximum $ snd points) + 1 in
  Polyomino xs width height token

flipxy :: Polyomino -> Polyomino
flipxy p@(Polyomino{ parts=(ps), width=w, height=h }) =
  p{ parts=sort $ flip' ps, width=h, height=w }

  where flip' :: [Location] -> [Location]
        flip' ((a,b):xs) = (b,a):flip' xs
        flip' [] = []

flipv :: Polyomino -> Polyomino
flipv p@(Polyomino{ parts=ps, width=w }) =
  p{ parts = sort $ map (flip flipv' w) ps  }

  where flipv' :: Location -> Width -> Location
        flipv' (x,y) w = ((w - 1 - x),y)

orientations :: Polyomino -> [Polyomino]
orientations p =
  let p' = flipv p;
      a  = rotate p;
      b  = rotate a;
      c  = rotate b;
      a' = flipv a;
      b' = flipv b;
      c' = flipv c in
    nub [p,a,b,c,p',a',b',c']
  where
    rotate = flipv . flipxy

-- Translate the polyomino to given location
move :: Polyomino -> Location -> Polyomino
move p@(Polyomino{ parts=xs }) loc =
  p { parts = map (add loc) xs }
  where
    add :: Location -> Location -> Location
    add (a,b) (c,d) = (a + c, b + d)

move' :: Polyomino -> Location -> [Polyomino]
move' p@(Polyomino{ parts=xs, token=t }) loc = do
  let parts = map (add loc) xs
  let pivots = map (sub parts) parts
  map (flip createPolyomino t) pivots
  where
    add :: Location -> Location -> Location
    add (a,b) (c,d) = (a + c, b + d)
    sub :: [Location] -> Location -> [Location]
    sub xs' o = map (sub' o) xs
    sub' :: Location -> Location -> Location
    sub' (a,b) (c,d) = (a-c, b-d)

                      
instance Show Polyomino where
  show (Polyomino{parts=ps, token=t, width=w, height=h}) =

    let m = ["\n"] in
    concat $
    "\n" : (intercalate m $ splitEvery w $ setTokens [] t (sort ps) w)

    where
      setTokens :: [Token] -> Token -> [Location] -> Int -> [Token]
      setTokens vs a ((x,y):xs) w = do
        let vs' = setAt (x + y * w) a " " vs
        setTokens vs' a xs w
      setTokens vs _ [] _ = vs

      splitEvery :: Int -> [Token] -> [[Token]]
      splitEvery _ [] = []
      splitEvery n list =
        let (first,rest) = splitAt n list in
          first : (splitEvery n rest)

      setAt :: Int -> Token -> Token -> [Token] ->[Token]
      setAt 0 a _ (_:xs) = a : xs
      setAt 0 a b [] = [a]
      setAt i a b (x:xs) | i > 0 = x : setAt (i-1) a b xs
                         | otherwise = []
      setAt i a b [] | i > 0 = b : setAt (i-1) a b []
                     | otherwise = []

                     






          

{-# OPTIONS_GHC -Wall #-}

-- The above pragma enables all warnings

module Task2 where

-- Hide built-in bind definition

import Data.Functor.Identity
import Prelude hiding ((>>=))

-- * Kleisli composition monad

-- | Monad based on Kleisli composition '(>=>)' operator
-- instead of usual bind operator '(>>=)'.
class (Applicative m) => KleisliMonad m where
  infixr 1 >=>
  (>=>) :: (a -> m b) -> (b -> m c) -> (a -> m c)

-- * Equivalent views

infixl 1 >>=

(>>=) :: (KleisliMonad m) => m a -> (a -> m b) -> m b
ma >>= f = (const ma >=> f) ()

join :: (KleisliMonad m) => m (m a) -> m a
join mma = mma >>= id

-- * Instances

instance KleisliMonad Identity where
  f >=> g = \x ->
    let Identity y = f x
     in g y

instance KleisliMonad Maybe where
  f >=> g = \x ->
    case f x of
      Nothing -> Nothing
      Just y -> g y

instance KleisliMonad [] where
  f >=> g = \x ->
    concatMap g (f x)

instance (Monoid e) => KleisliMonad ((,) e) where
  f >=> g = \x ->
    let (e1, y) = f x
        (e2, z) = g y
     in (e1 <> e2, z)

instance KleisliMonad ((->) e) where
  f >=> g = \x e ->
    let y = f x e
     in g y e

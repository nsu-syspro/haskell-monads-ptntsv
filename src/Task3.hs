{-# OPTIONS_GHC -Wall #-}

-- The above pragma enables all warnings

module Task3 where

import Control.Monad (join)
import Data.Functor.Identity

-- * Functor composition

-- | Represents composition of two functors.
newtype Compose f g a = Compose {getCompose :: f (g a)}
  deriving (Show, Eq)

instance (Functor f, Functor g) => Functor (Compose f g) where
  fmap :: (a -> b) -> Compose f g a -> Compose f g b
  fmap h (Compose fga) = Compose (fmap (fmap h) fga)

instance (Applicative f, Applicative g) => Applicative (Compose f g) where
  pure :: a -> Compose f g a
  pure x = Compose (pure (pure x))

  (<*>) :: Compose f g (a -> b) -> Compose f g a -> Compose f g b
  Compose fgab <*> Compose fga =
    Compose (liftA2 (<*>) fgab fga)

-- * Monad composition

instance (Monad m, Monad n, Distrib n m) => Monad (Compose m n) where
  (>>=) :: forall a b. Compose m n a -> (a -> Compose m n b) -> Compose m n b
  Compose mna >>= k =
    Compose $
      mna >>= \na ->
        let nmb = fmap (getCompose . k) na
         in do
              mb <- distrib nmb
              return (join mb)

-- * Distributive property

-- | Describes distributive property of two monads.
class (Monad m, Monad n) => Distrib m n where
  distrib :: m (n a) -> n (m a)

-- * Distributive instances

instance (Monad n) => Distrib Identity n where
  distrib :: (Monad n) => Identity (n a) -> n (Identity a)
  distrib (Identity na) = Identity <$> na

instance (Monad n) => Distrib Maybe n where
  distrib Nothing = pure Nothing
  distrib (Just na) = Just <$> na

instance (Monad n) => Distrib [] n where
  distrib :: [] (n a) -> n ([] a)
  distrib xs = sequence xs

instance (Monad n, Monoid e) => Distrib ((,) e) n where
  distrib :: (e, n a) -> n (e, a)
  distrib (e, na) = (e,) <$> na

instance (Monad n) => Distrib n ((->) e) where
  distrib :: n (e -> a) -> (e -> n a)
  distrib nfa = \e -> ($ e) <$> nfa

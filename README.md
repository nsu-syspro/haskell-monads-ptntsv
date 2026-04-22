[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/FppUWqfw)
# Haskell: Monads

<img alt="points bar" align="right" height="36" src="../../blob/badges/.github/badges/points-bar.svg" />

<details>
<summary>Guidelines</summary>

## Guidelines

When solving the homework, strive to create not just code that works, but code that is readable and concise.
Try to write small functions which perform just a single task, and then combine those smaller
pieces to create more complex functions.

Don’t repeat yourself: write one function for each logical task, and reuse functions as necessary.

Don't be afraid to introduce new functions where you see fit.

### Sources

Each task has corresponding source file in [src](src) directory where you should implement the solution.

### Building

All solutions should compile without warnings with following command:

```bash
stack build
```

### Testing

You can and should run automated tests before pushing solution to GitHub via

```bash
stack test --test-arguments "-p TaskX"
```

where `X` in `TaskX` should be number of corresponding Task to be tested.

So to run all test for the first task you should use following command:

```bash
stack test --test-arguments "-p Task1"
```

You can also run tests for all tasks with just

```bash
stack test
```

### Debugging

For debugging you should use GHCi via stack:

```bash
stack ghci
```

You can then load your solution for particular task using `:load TaskX` command.

Here is how to load Task1 in GHCi:

```bash
$ stack ghci
ghci> :load Task1
[1 of 1] Compiling Task1 ( .../src/Task1.hs, interpreted )
Ok, one module loaded.
```

> **Note:** if you updated solution, it can be quickly reloaded in the same GHCi session with `:reload` command
> ```bash
> ghci> :reload
> ```

</details>

## Preface

In this assignment you will learn about several equivalent definitions of monad
and when it is possible to compose two concrete monad instances.

## Monad definitions

There are three different ways to define `Monad` by extending `Applicative` with one of the following
functions:

- Bind operator
  ```haskell
  (>>=) :: m a -> (a -> m b) -> m b
  ```
- Join operation
  ```haskell
  join :: m (m a) -> m a`
  ```
- Kleisli composition
  ```haskell
  (>=>) :: (a -> m b) -> (b -> m c) -> (a -> m c)
  ```

It turns out that all three ways are [equivalent](https://wiki.haskell.org/index.php?title=Typeclassopedia#Laws_3)
and your goal in the first two tasks will be to check this equivalence.

## Task 1 (3 points)

In [src/Task1.hs](src/Task1.hs) you will find following definition of monad using `join`:

```haskell
class Applicative m => JoinMonad m where
  join :: m (m a) -> m a
```

Your goal is to prove equivalence of this definition to alternative ones by defining
`(>>=)` and `(>=>)` functions in the same module.

Additionally you should implement instances of `JoinMonad` for common monads that
are provided in the same module.

> [!IMPORTANT]
>
> Do not use standard `Monad` functionality provided by `Prelude`!  
> However, you are free to use `Functor`, `Foldable`, `Applicative` and functions that are related them.

## Task 2 (3 points)

In [src/Task2.hs](src/Task2.hs) you will find following definition of monad using Kleisli composition `(>=>)`:

```haskell
class Applicative m => KleisliMonad m where
  (>=>) :: (a -> m b) -> (b -> m c) -> (a -> m c)
```

Your goal is to prove equivalence of this definition to alternative ones by defining
`(>>=)` and `join` functions in the same module.

Additionally you should implement instances of `KleisliMonad` for common monads that
are provided in the same module.

> [!IMPORTANT]
>
> Do not use standard `Monad` functionality provided by `Prelude`!  
> However, you are free to use `Functor`, `Foldable`, `Applicative` and functions that are related them.

## Task 3 (4 points)

### Functor composition

It is well known that both `Functor` and `Applicative` can be freely composed one with another.

For example, composition of `Maybe` and list functors could be represented like

```haskell
newtype MaybeList a = MaybeList (Maybe [a])
```

for which one could also define instances of `Functor` and `Applicative`.

In [src/Task3.hs](src/Task3.hs) you will find a more general representation
of composition of two arbitrary functors `f` and `g`:

```haskell
newtype Compose f g a = Compose { getCompose :: f (g a) }
```

Your first goal is to implement `Functor` and `Applicative` instances for `Compose f g`.

### Monad composition

You would think that you could similarly define `Monad` instance for `Compose m n`
as composition of two monads `m` and `n`.
However, two arbitrary monads cannot simply compose to form a valid monad.

This can be most clearly seen by looking at type signature
of `join` for such composition (omitting `Compose` wrapper):

```haskell
join :: m (n (m (n a))) -> m (n a)
```

If you try to implement this function with two arbitrary monads `m` and `n`,
you would quickly stumble on the need to "swap" nested monads `_ (n (m _))` to `_ (m (n _))`.
Indeed, if we had a function `distrib :: n (m a) -> m (n a)` for given `m` and `n`,
then we would be able to collapse the stack of monads for `join` like this:

```haskell
  m (n (m (n a)))
~ m (m (n (n a))) -- distrib
~    m (n (n a))  -- join m
~       m (n a)   -- join n
```

This distributive property can be represented via type class `Distrib` defined in [src/Task3.hs](src/Task3.hs):

```haskell
class (Monad m, Monad n) => Distrib m n where
  distrib :: m (n a) -> n (m a)
```

Using this property you should implement `Monad` instance for `Compose m n`.

Additionally you should implement instances of `Distrib` for common monads that
are provided in the same module.

> [!IMPORTANT]
>
> Notice that `Distrib` property is directional. So not every combination of monads
> can be distributed this way. For example, while most of the monad examples in the module
> distribute from "outside" to "inside" of arbitrary monad (e.g. `Maybe (n a) -> n (Maybe a)`),
> the reader monad `((->) e)` distributes in the other direction!

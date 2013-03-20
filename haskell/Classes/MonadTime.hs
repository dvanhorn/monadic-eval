{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies #-}

module Classes.MonadTime where

class (Monad m) => MonadTime time m | m -> time where
  getTime :: m time
  putTime :: time -> m ()

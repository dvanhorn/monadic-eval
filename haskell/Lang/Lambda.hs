{-# LANGUAGE ScopedTypeVariables, FlexibleContexts #-}

module Lang.Lambda where

import Classes
import Control.Monad.Identity
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe
import Control.Monad.State

data Expr =
    Var String
  | Lam String Expr
  | App Expr Expr
  | If Expr Expr Expr
  | Primop Op [Expr]

data Op =
    Add1
  | Sub1

data Val addr =
    Clo String Expr (Env addr)
  | Num Integer

-- Evaluator --

delta :: Op -> [Val addr] -> Val addr
delta Add1 [Num x] = Num (x + 1)
delta Sub1 [Num x] = Num (x - 1)

eval :: forall m dom addr time.
        ( MonadEnv addr m, MonadStore dom addr Val m, MonadTime time m
        , Addressable addr time
        , Promote dom m, Pointed dom
        , Ord addr) 
     => (Expr -> m (Val addr))
     -> Expr 
     -> m (Val addr)
eval eval (Var x) = do
  env <- getEnv
  store <- getStore
  let addr = fromJust $ Map.lookup x env :: addr
  let valD = fromJust $ Map.lookup addr store :: dom (Val addr)
  promote valD
eval eval (Lam x e) = do
  env <- getEnv
  return $ Clo x e env
eval eval (App e1 e2) = do
  (Clo x e env') <- eval e1
  v <- eval e2
  a <- alloc x
  putEnv (Map.insert x a env')
  modifyStore (Map.insert a (unit v))
  eval e
eval eval (If c tb fb) = do
  cv <- eval c
  case cv of
    Num 0 -> eval tb
    _     -> eval fb
eval eval (Primop op es) = do
  vs <- mapM eval es
  return $ delta op vs

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Analyses.BigStep.ZPDCFAT where

import Analyses.BigStep.AbstractT
import Control.Exception
import Control.Monad
import Control.Monad.Identity
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Trans
import Fixpoints.MemoEval
import Monads
import StateSpace
import Util.Lattice
import Util.ListSet
import Util.MFunctor
import qualified Data.Map as Map

newtype ZPDCFAT var val m a = ZPDCFAT
  { unZPDCFAT :: AbstractT (CFAAddr var) ZCFATime var val m a }
  deriving
  ( Monad
  , MonadTrans
  , MFunctor
  , MonadPlus
  , MonadState s
  , MonadReader r
  , MonadEnvReader (Env var (CFAAddr var))
  , MonadEnvState env
  , MonadStoreState (Store ListSet (CFAAddr var) val)
  , MonadTimeState ZCFATime
  , MMorph ListSet
  )

mkZPDCFAT :: 
  (Monad m)
  => (Env var (CFAAddr var)
      -> Store ListSet (CFAAddr var) val
      -> ZCFATime
      -> m (ListSet (a, Store ListSet (CFAAddr var) val, ZCFATime))
     )
  -> ZPDCFAT var val m a
mkZPDCFAT = ZPDCFAT . mkAbstractT

runZPDCFAT :: 
  (Monad m)
  => ZPDCFAT var val m a
  -> Env var (CFAAddr var)
  -> Store ListSet (CFAAddr var) val
  -> ZCFATime
  -> m (ListSet (a, Store ListSet (CFAAddr var) val, ZCFATime))
runZPDCFAT = runAbstractT . unZPDCFAT

type MemoTablesZPDCFA expr var val = 
  MemoTables ListSet val expr (Env var (CFAAddr var)) (Store ListSet (CFAAddr var) val)

type ZPDCFADriver var val expr a = ZPDCFAT var val (StateT (MemoTablesZPDCFA expr var val) Identity) a

driveZPDCFA :: 
  (Ord val, Ord expr, Ord var)
  => ((expr -> ZPDCFADriver var val expr (ListSet val))
      -> expr 
      -> ZPDCFADriver var val expr (ListSet val)
     )
  -> expr 
  -> ListSet (ListSet val, Store ListSet (CFAAddr var) val, ZCFATime)
driveZPDCFA eval expr =
  let loop mx =
        let (_VxSxT_list,(m1,mx')) = 
              runIdentity 
              $ flip runStateT (lbot,mx) 
              $ runZPDCFAT (memoEval eval expr) Map.empty lbot ()
        in assert (mx == mx') $
        if m1 == mx'
          then _VxSxT_list
          else loop m1
  in loop lbot

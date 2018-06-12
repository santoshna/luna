module Data.Graph.Component.Edge.Destruction where

import Prologue

import qualified Data.Graph.Data.Layer.Class     as Layer
import qualified Data.Graph.Data.Layer.Layout    as Layout
import qualified Data.Graph.Data.Component.Class as Component
import qualified Data.Set.Mutable.Class          as Set

import Data.Graph.Component.Edge.Class       (Source, Edge, Edges)
import Data.Graph.Component.Node.Class       (Node)
import Data.Graph.Component.Node.Layer.Users (Users)


delete :: ( MonadIO m
          , Component.Destructor1 m Edge
          , Layer.Reader Node Users m
          , Layer.Reader Edge Source m
          ) => Edge layout -> m ()
delete = \edge -> do
    srcUsers <- Layer.read @Users =<< Layer.read @Source edge
    Set.delete srcUsers $! Layout.unsafeRelayout edge
    Component.destruct1 edge
{-# INLINE delete #-}

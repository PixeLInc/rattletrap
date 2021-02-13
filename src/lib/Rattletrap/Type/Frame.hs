{-# LANGUAGE TemplateHaskell #-}

module Rattletrap.Type.Frame where

import Rattletrap.Type.Common
import Rattletrap.Type.Float32le
import qualified Rattletrap.Type.Replication as Replication
import Rattletrap.Decode.Common
import Rattletrap.Type.ClassAttributeMap
import Rattletrap.Type.CompressedWord
import qualified Rattletrap.Type.Word32le as Word32le
import Rattletrap.Encode.Common

import qualified Control.Monad.Trans.Class as Trans
import qualified Control.Monad.Trans.State as State
import qualified Data.Map as Map

data Frame = Frame
  { frameTime :: Float32le
  -- ^ Time in seconds since the beginning of the match.
  , frameDelta :: Float32le
  -- ^ Time in seconds since the last frame. Usually about 0.03 since there
  -- are 30 frames per second.
  , frameReplications :: [Replication.Replication]
  }
  deriving (Eq, Show)

$(deriveJson ''Frame)

putFrames :: [Frame] -> BitPut ()
putFrames frames = case frames of
  [] -> pure ()
  [frame] -> putFrame frame
  first : rest -> do
    putFrame first
    putFrames rest

putFrame :: Frame -> BitPut ()
putFrame frame = do
  putFloat32Bits (frameTime frame)
  putFloat32Bits (frameDelta frame)
  Replication.putReplications (frameReplications frame)

decodeFramesBits
  :: (Int, Int, Int)
  -> Int
  -> Word
  -> ClassAttributeMap
  -> State.StateT
       (Map.Map CompressedWord Word32le.Word32le)
       BitGet
       [Frame]
decodeFramesBits version count limit classes = if count <= 0
  then pure []
  else
    (:)
    <$> decodeFrameBits version limit classes
    <*> decodeFramesBits version (count - 1) limit classes

decodeFrameBits
  :: (Int, Int, Int)
  -> Word
  -> ClassAttributeMap
  -> State.StateT (Map.Map CompressedWord Word32le.Word32le) BitGet Frame
decodeFrameBits version limit classes =
  Frame
    <$> Trans.lift decodeFloat32leBits
    <*> Trans.lift decodeFloat32leBits
    <*> Replication.decodeReplicationsBits version limit classes

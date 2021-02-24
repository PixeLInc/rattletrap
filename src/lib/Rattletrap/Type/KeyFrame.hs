module Rattletrap.Type.KeyFrame where

import qualified Rattletrap.ByteGet as ByteGet
import qualified Rattletrap.BytePut as BytePut
import Rattletrap.Type.Common
import qualified Rattletrap.Type.F32 as F32
import qualified Rattletrap.Type.U32 as U32
import qualified Rattletrap.Schema as Schema
import qualified Rattletrap.Utility.Json as Json

data KeyFrame = KeyFrame
  { time :: F32.F32
  -- ^ When this key frame occurs, in seconds.
  , frame :: U32.U32
  -- ^ The frame number of this key frame, starting from 0.
  , position :: U32.U32
  -- ^ The bit position of this key frame in the stream.
  }
  deriving (Eq, Show)

$(deriveJson ''KeyFrame)

schema :: Schema.Schema
schema = Schema.named "keyFrame" $ Schema.object
  [ (Json.pair "time" True, True)
  , (Json.pair "frame" True, True)
  , (Json.pair "position" True, True)
  ]

bytePut :: KeyFrame -> BytePut.BytePut
bytePut x =
  F32.bytePut (time x) <> U32.bytePut (frame x) <> U32.bytePut (position x)

byteGet :: ByteGet.ByteGet KeyFrame
byteGet = KeyFrame <$> F32.byteGet <*> U32.byteGet <*> U32.byteGet

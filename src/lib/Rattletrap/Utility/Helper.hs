-- | This module provides helper functions for converting replays to and from
-- both their binary format and JSON.
module Rattletrap.Utility.Helper
  ( decodeReplayFile
  , encodeReplayJson
  , decodeReplayJson
  , encodeReplayFile
  ) where

import Rattletrap.Decode.Common
import Rattletrap.Type.Content
import qualified Rattletrap.Type.Replay as Replay
import qualified Rattletrap.Type.Section as Section

import qualified Data.Aeson as Json
import qualified Data.Aeson.Encode.Pretty as Json
import qualified Data.Binary.Put as Binary
import qualified Data.ByteString as Bytes
import qualified Data.ByteString.Lazy as LazyBytes

-- | Parses a raw replay.
decodeReplayFile :: Bool -> Bytes.ByteString -> Either String Replay.FullReplay
decodeReplayFile fast = runDecode $ Replay.byteGet fast

-- | Encodes a replay as JSON.
encodeReplayJson :: Replay.FullReplay -> Bytes.ByteString
encodeReplayJson = LazyBytes.toStrict . Json.encodePretty' Json.defConfig
  { Json.confCompare = compare
  , Json.confIndent = Json.Spaces 2
  , Json.confTrailingNewline = True
  }

-- | Parses a JSON replay.
decodeReplayJson :: Bytes.ByteString -> Either String Replay.FullReplay
decodeReplayJson = Json.eitherDecodeStrict'

-- | Encodes a raw replay.
encodeReplayFile :: Bool -> Replay.FullReplay -> Bytes.ByteString
encodeReplayFile fast replay =
  LazyBytes.toStrict . Binary.runPut . Replay.bytePut $ if fast
    then replay { Replay.content = Section.create putContent defaultContent }
    else replay

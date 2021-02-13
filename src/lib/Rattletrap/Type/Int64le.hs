module Rattletrap.Type.Int64le where

import Rattletrap.Utility.Bytes
import Rattletrap.Decode.Common

import qualified Data.Binary as Binary
import qualified Data.Binary.Bits.Put as BinaryBits
import qualified Data.Binary.Put as Binary
import qualified Data.ByteString.Lazy as LazyBytes
import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Types as Aeson
import qualified Data.Int as Int
import qualified Data.Scientific as Scientific
import qualified Data.Text as Text
import qualified Text.Read as Read

newtype Int64le = Int64le
  { int64leValue :: Int.Int64
  } deriving (Eq, Show)

instance Aeson.FromJSON Int64le where
  parseJSON value = case value of
    Aeson.String text -> case Read.readEither $ Text.unpack text of
      Left _ -> Aeson.typeMismatch "Int64le" value
      Right int64 -> pure $ Int64le int64
    Aeson.Number number -> case Scientific.toBoundedInteger number of
      Nothing -> Aeson.typeMismatch "Int64le" value
      Just int64 -> pure $ Int64le int64
    _ -> Aeson.typeMismatch "Int64le" value

instance Aeson.ToJSON Int64le where
  toJSON = Aeson.toJSON . show . int64leValue

putInt64 :: Int64le -> Binary.Put
putInt64 int64 = Binary.putInt64le (int64leValue int64)

putInt64Bits :: Int64le -> BinaryBits.BitPut ()
putInt64Bits int64 = do
  let bytes = LazyBytes.toStrict (Binary.runPut (putInt64 int64))
  BinaryBits.putByteString (reverseBytes bytes)

decodeInt64le :: Decode Int64le
decodeInt64le = Int64le <$> getInt64le

decodeInt64leBits :: DecodeBits Int64le
decodeInt64leBits = toBits decodeInt64le 8
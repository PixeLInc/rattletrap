{-# LANGUAGE TemplateHaskell #-}

module Rattletrap.Type.Attribute.AppliedDamage where

import Rattletrap.Type.Common
import Rattletrap.Type.Int32le
import qualified Rattletrap.Type.Vector as Vector
import qualified Rattletrap.Type.Word8le as Word8le
import Rattletrap.Decode.Common
import Rattletrap.Encode.Common

data AppliedDamageAttribute = AppliedDamageAttribute
  { appliedDamageAttributeUnknown1 :: Word8le.Word8le
  , appliedDamageAttributeLocation :: Vector.Vector
  , appliedDamageAttributeUnknown3 :: Int32le
  , appliedDamageAttributeUnknown4 :: Int32le
  }
  deriving (Eq, Show)

$(deriveJson ''AppliedDamageAttribute)

putAppliedDamageAttribute :: AppliedDamageAttribute -> BitPut ()
putAppliedDamageAttribute appliedDamageAttribute = do
  Word8le.bitPut (appliedDamageAttributeUnknown1 appliedDamageAttribute)
  Vector.bitPut (appliedDamageAttributeLocation appliedDamageAttribute)
  putInt32Bits (appliedDamageAttributeUnknown3 appliedDamageAttribute)
  putInt32Bits (appliedDamageAttributeUnknown4 appliedDamageAttribute)

decodeAppliedDamageAttributeBits
  :: (Int, Int, Int) -> BitGet AppliedDamageAttribute
decodeAppliedDamageAttributeBits version =
  AppliedDamageAttribute
    <$> Word8le.bitGet
    <*> Vector.bitGet version
    <*> decodeInt32leBits
    <*> decodeInt32leBits

{-# LANGUAGE TemplateHaskell #-}

module Rattletrap.Type.Attribute.Pickup where

import Rattletrap.Type.Common
import qualified Rattletrap.Type.Word32le as Word32le
import Rattletrap.Decode.Common
import Rattletrap.Encode.Common

import qualified Data.Binary.Bits.Put as BinaryBits

data PickupAttribute = PickupAttribute
  { pickupAttributeInstigatorId :: Maybe Word32le.Word32le
  , pickupAttributePickedUp :: Bool
  }
  deriving (Eq, Show)

$(deriveJson ''PickupAttribute)

putPickupAttribute :: PickupAttribute -> BitPut ()
putPickupAttribute pickupAttribute = do
  case pickupAttributeInstigatorId pickupAttribute of
    Nothing -> BinaryBits.putBool False
    Just instigatorId -> do
      BinaryBits.putBool True
      Word32le.bitPut instigatorId
  BinaryBits.putBool (pickupAttributePickedUp pickupAttribute)

decodePickupAttributeBits :: BitGet PickupAttribute
decodePickupAttributeBits = do
  instigator <- getBool
  PickupAttribute <$> decodeWhen instigator Word32le.bitGet <*> getBool

{-# LANGUAGE TemplateHaskell #-}

module Rattletrap.Type.Attribute.Byte where

import qualified Rattletrap.BitGet as BitGet
import qualified Rattletrap.BitPut as BitPut
import Rattletrap.Type.Common
import qualified Rattletrap.Type.U8 as U8

newtype Byte = Byte
  { value :: U8.U8
  } deriving (Eq, Show)

$(deriveJson ''Byte)

bitPut :: Byte -> BitPut.BitPut
bitPut byteAttribute = U8.bitPut (value byteAttribute)

bitGet :: BitGet.BitGet Byte
bitGet = Byte <$> U8.bitGet

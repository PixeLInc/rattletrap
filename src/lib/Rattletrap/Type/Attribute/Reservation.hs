module Rattletrap.Type.Attribute.Reservation where

import qualified Rattletrap.BitGet as BitGet
import qualified Rattletrap.BitPut as BitPut
import qualified Rattletrap.Type.Attribute.UniqueId as UniqueId
import Rattletrap.Type.Common
import qualified Rattletrap.Type.CompressedWord as CompressedWord
import qualified Rattletrap.Type.Str as Str
import qualified Rattletrap.Type.U8 as U8
import Rattletrap.Utility.Monad

data Reservation = Reservation
  { number :: CompressedWord.CompressedWord
  , uniqueId :: UniqueId.UniqueId
  , name :: Maybe Str.Str
  , unknown1 :: Bool
  , unknown2 :: Bool
  , unknown3 :: Maybe Word8
  }
  deriving (Eq, Show)

$(deriveJson ''Reservation)

bitPut :: Reservation -> BitPut.BitPut
bitPut reservationAttribute =
  CompressedWord.bitPut (number reservationAttribute)
    <> UniqueId.bitPut (uniqueId reservationAttribute)
    <> foldMap Str.bitPut (name reservationAttribute)
    <> BitPut.bool (unknown1 reservationAttribute)
    <> BitPut.bool (unknown2 reservationAttribute)
    <> foldMap (BitPut.word8 6) (unknown3 reservationAttribute)

bitGet :: (Int, Int, Int) -> BitGet.BitGet Reservation
bitGet version = do
  number_ <- CompressedWord.bitGet 7
  uniqueId_ <- UniqueId.bitGet version
  Reservation number_ uniqueId_
    <$> whenMaybe (UniqueId.systemId uniqueId_ /= U8.fromWord8 0) Str.bitGet
    <*> BitGet.bool
    <*> BitGet.bool
    <*> whenMaybe (version >= (868, 12, 0)) (BitGet.word8 6)

module Rattletrap.Type.Header where

import qualified Rattletrap.ByteGet as ByteGet
import qualified Rattletrap.BytePut as BytePut
import qualified Rattletrap.Schema as Schema
import Rattletrap.Type.Common
import qualified Rattletrap.Type.Dictionary as Dictionary
import qualified Rattletrap.Type.Property as Property
import qualified Rattletrap.Type.Str as Str
import qualified Rattletrap.Type.U32 as U32
import Rattletrap.Utility.Monad
import qualified Rattletrap.Utility.Json as Json

-- | Contains high-level metadata about a 'Rattletrap.Replay.Replay'.
data Header = Header
  { engineVersion :: U32.U32
  -- ^ The "major" ("engine") version number.
  , licenseeVersion :: U32.U32
  -- ^ The "minor" ("licensee") version number.
  , patchVersion :: Maybe U32.U32
  -- ^ The "patch" ("net") version number.
  , label :: Str.Str
  -- ^ Always @TAGame.Replay_Soccar_TA@.
  , properties :: Dictionary.Dictionary Property.Property
  -- ^ These properties determine how a replay will look in the list of
  -- replays in-game. One element is required for the replay to show up:
  --
  -- - MapName: This is a 'Rattletrap.PropertyValue.NameProperty' with a
  --   case-insensitive map identifier, like @Stadium_P@.
  --
  -- There are many other properties that affect how the replay looks in the
  -- list of replays.
  --
  -- - Date: A 'Rattletrap.PropertyValue.StrProperty' with the format
  --   @YYYY-mm-dd:HH-MM@. Dates are not validated, but the month must be
  --   between 1 and 12 to show up. The hour is shown modulo 12 with AM or PM.
  -- - MatchType: A 'Rattletrap.PropertyValue.NameProperty'. If this is not
  --   one of the expected values, nothing will be shown next to the replay's
  --   map. The expected values are: @Online@, @Offline@, @Private@, and
  --   @Season@.
  -- - NumFrames: This 'Rattletrap.PropertyValue.IntProperty' is used to
  --   calculate the length of the match. There are 30 frames per second,
  --   a typical 5-minute match has about 9,000 frames.
  -- - PrimaryPlayerTeam: This is an 'Rattletrap.PropertyValue.IntProperty'.
  --   It is either 0 (blue) or 1 (orange). Any other value is ignored. If
  --   this would be 0, you don't have to set it at all.
  -- - ReplayName: An optional 'Rattletrap.PropertyValue.StrProperty' with a
  --   user-supplied name for the replay.
  -- - Team0Score: The blue team's score as an
  --   'Rattletrap.PropertyValue.IntProperty'. Can be omitted if the score is
  --   0.
  -- - Team1Score: The orange team's score as an
  --   'Rattletrap.PropertyValue.IntProperty'. Can also be omitted if the
  --   score is 0.
  -- - TeamSize: An 'Rattletrap.PropertyValue.IntProperty' with the number of
  --   players per team. This value is not validated, so you can put absurd
  --   values like 99. To get an "unfair" team size like 1v4, you must set the
  --   bUnfairBots 'Rattletrap.PropertyValue.BoolProperty' to @True@.
  }
  deriving (Eq, Show)

$(deriveJson ''Header)

schema :: Schema.Schema
schema = Schema.named "header" $ Schema.object
  [ Json.pair "engineVersion" $ Schema.ref U32.schema
  , Json.pair "licenseeVersion" $ Schema.ref U32.schema
  , Json.pair "patchVersion" . Schema.json $ Schema.maybe U32.schema
  , Json.pair "label" $ Schema.ref Str.schema
  , Json.pair "properties" . Schema.json $ Dictionary.schema Property.schema
  ]

bytePut :: Header -> BytePut.BytePut
bytePut x =
  U32.bytePut (engineVersion x)
    <> U32.bytePut (licenseeVersion x)
    <> foldMap U32.bytePut (patchVersion x)
    <> Str.bytePut (label x)
    <> Dictionary.bytePut Property.bytePut (properties x)

byteGet :: ByteGet.ByteGet Header
byteGet = do
  (major, minor) <- (,) <$> U32.byteGet <*> U32.byteGet
  Header major minor
    <$> whenMaybe
          (U32.toWord32 major >= 868 && U32.toWord32 minor >= 18)
          U32.byteGet
    <*> Str.byteGet
    <*> Dictionary.byteGet Property.byteGet

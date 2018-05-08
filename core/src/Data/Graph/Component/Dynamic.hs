module Data.Graph.Component.Dynamic where

import Prologue

import qualified Data.Graph.Component.Class as Component

import Data.Graph.Component.Class (Component)
import Foreign.Ptr.Utils          (SomePtr)



---------------------
-- === Dynamic === --
---------------------

-- === Definition === --

data Dynamic = Dynamic
    { _rep :: !Component.Rep
    , _ptr :: !SomePtr
    } deriving (Show)


-- === API === --

toDynamic  :: ∀ tag lyt. Typeables '[tag, lyt] => Component tag lyt -> Dynamic
toDynamic1 :: ∀ tag lyt. Typeable tag          => Component tag lyt -> Dynamic
toDynamic  = Dynamic (Component.rep  @tag @lyt) . Component.unsafeToPtr ; {-# INLINE toDynamic  #-}
toDynamic1 = Dynamic (Component.rep1 @tag)      . Component.unsafeToPtr ; {-# INLINE toDynamic1 #-}

fromDynamic :: ∀ tag layout. Typeables '[tag, layout]
            => Dynamic -> Maybe (Component tag layout)
fromDynamic (Dynamic rep ptr) = if rep == Component.rep @tag @layout
    then Just $ Component.unsafeFromPtr ptr
    else Nothing
{-# INLINE fromDynamic #-}

fromDynamicRelayout :: ∀ tag. Typeable tag
                    => Dynamic -> Maybe (Component tag ())
fromDynamicRelayout (Dynamic (Component.Rep trep _) ptr)
    = if trep == Component.tagRep @tag
        then Just $ Component.unsafeFromPtr ptr
        else Nothing
{-# INLINE fromDynamicRelayout #-}
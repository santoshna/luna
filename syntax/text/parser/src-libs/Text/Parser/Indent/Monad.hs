module Text.Parser.Indent.Monad where

import Prologue hiding (guard)

import qualified Control.Monad               as Monad
import qualified Control.Monad.State.Layered as State
import qualified Text.Parser.Indent.Class    as Indent

import Data.Text.Position
import Text.Parser.Indent.Class (Indent, level, stack)

-- === Indent management === --

get :: State.Getter Indent m => m Delta
get = view level <$> State.get @Indent

pushCurrent :: (State.Monad Indent m, State.Getter Position m) => m ()
pushCurrent = push =<< getColumn

push :: State.Monad Indent m => Delta -> m ()
push = State.modify_ @Indent . Indent.push

pop :: State.Monad Indent m => m Delta
pop = State.modify @Indent Indent.pop

with :: State.Monad Indent m => Delta -> m a -> m a
with d m = push d *> m <* pop

withCurrent :: (State.Monad Indent m, State.Getter Position m) => m a -> m a
withCurrent m = pushCurrent *> m <* pop

withRoot :: State.Monad Indent m => m a -> m a
withRoot = with 0

checkIndentRef :: State.Getters '[Indent, Position] m => (Delta -> Delta -> a) -> m a
checkIndentRef f = f <$> getColumn <*> get

checkIndent :: State.Getters '[Indent, Position] m => (Delta -> a) -> m a
checkIndent f = checkIndentRef $ f .: (-)

checkIndented :: State.Getters '[Indent, Position] m => (Ordering -> a) -> m a
checkIndented f = checkIndentRef $ f .: compare

-- TODO[WD]: make it safe
guard :: State.Getters '[Indent, Position] m => (Ordering -> Bool) -> String -> m ()
guard ord err = flip when (Monad.fail err) . not =<< checkIndented ord

indented, indentedOrEq, indentedEq :: State.Getters '[Indent, Position] m => m ()
indented     = guard (== GT) "Expected indentation"
indentedOrEq = guard (/= LT) "Expected indentation"
indentedEq   = guard (== EQ) "Indentation does not match the previous one"

indentation :: State.Getters '[Indent, Position] m => m Delta
indentation = (-) <$> getColumn <*> get

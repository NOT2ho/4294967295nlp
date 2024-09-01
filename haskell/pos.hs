
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map

data Trie = Node (Map Char (Bool, Trie))
            | Null
            deriving (Show)

st :: k -> a -> Map k a
st = Map.singleton
member :: Char -> Map Char a -> Bool
member = Map.member
notMember :: Char -> Map Char a -> Bool
notMember = Map.notMember
ins :: Char -> a -> Map Char a -> Map Char a
ins = Map.insert
fwd :: Char -> Map Char (Bool, Trie) -> (Bool, Trie)
fwd = Map.findWithDefault (False, Null)

trieInsert :: [Char] -> Trie -> Trie
trieInsert [] t = t
trieInsert (w:ws) Null
    | null ws = Node $ st w (True, Null)
    | otherwise = Node $ st w (False,trieInsert ws Null)
trieInsert (w:ws) (Node m)
    | member w m = 
        let (b,t) = fwd w m in
        Node $ ins w (null ws || b, trieInsert ws t) m
    | notMember w m = Node $ ins w (null ws, trieInsert ws Null) m

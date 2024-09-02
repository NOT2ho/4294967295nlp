
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence

data Trie = Node (Map Char (Bool, Output, Trie))
            | Null
            deriving (Show)

data Output = Pos ([Char], [Char])
            | NA
            deriving (Show)
st = Map.singleton
member :: Char -> Map Char a -> Bool
member = Map.member
notMember = Map.notMember
ins = Map.insert
fwd :: Char -> Map Char (Bool, Output, Trie) -> (Bool, Output, Trie)
fwd = Map.findWithDefault (False, NA, Null)
lnull = Data.List.null
keys = Map.keys
elems = Map.elems
{-
acOutput :: Trie -> Trie -> [Char]
acOutput (Node a) (NacSearch str t = 
ode b) = (\[(b,t,s)]->s) (elems a) ++  keys b
acOutput (Node a) Null = (\[(b,t,s)]->s) (elems a)-}

trieInsert :: [Char] -> Output -> Trie -> Trie
trieInsert [] cl t = t
trieInsert (w:ws) cl Null 
    | lnull ws = Node $ st w (True, cl, Null)
    | otherwise = Node $ st w (False, NA, trieInsert ws cl Null)
trieInsert (w:ws) cl (Node m)
    | member w m=
        let (b,o,t) = fwd w m in
        Node $ ins w (lnull ws || b, 
                        if lnull ws || b then o else NA,
                        trieInsert ws cl t) m
    | notMember w m = Node $ ins w (lnull ws, 
                                     if lnull ws then cl else NA, 
                                   trieInsert ws cl Null) m

acInsert :: Output -> Trie -> Trie
acInsert (Pos (word, pos)) = trieInsert word (Pos (word, pos) )
 

acGo :: Char -> Trie -> Trie
acGo c (Node m)
    | member c m = 
        let (b,o,t) = fwd c m in
            t
    | otherwise = Null
acGo c Null = Null

acSearch :: [Char] -> Trie -> Map Int Output
acSearch (s:ss) (Node m) = do
    let nextNode = acGo s (Node m) 
    case nextNode of
        Null -> acSearch ss (acFail $ Node m)
        _ -> 
            let (b,Pos(word, pos),nextTrie) = fwd s m in
            if not b then acSearch ss nextTrie else st (Data.List.length word) $ Pos(word, pos)

acFail :: Trie -> Trie
acFail (Node m) = Null
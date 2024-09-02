
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence

data Trie = Node (Map Char (Bool, Output, Trie, Trie))
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
fwd :: Char -> Map Char (Bool, Output, Trie, Trie) -> (Bool, Output, Trie, Trie)
fwd = Map.findWithDefault (False, NA, Null, Null)
lnull = Data.List.null
llength :: [] a -> Int
llength = Data.List.length
keys = Map.keys
elems = Map.elems

trieInsert :: [Char] -> Output -> Trie -> Trie
trieInsert [] cl t = t
trieInsert (w:ws) cl Null 
    | lnull ws = Node $ st w (True, cl, Null, Null)
    | otherwise = Node $ st w (False, NA, trieInsert ws cl Null, Null)
trieInsert (w:ws) cl (Node m)
    | member w m=
        let (b,o,t, f) = fwd w m in
        Node $ ins w (lnull ws || b, 
                        if lnull ws || b then o else NA,
                        trieInsert ws cl t,
                        f) m
    | notMember w m = Node $ ins w (lnull ws, 
                                     if lnull ws then cl else NA, 
                                   trieInsert ws cl Null,
                                   Null) m

acInsert :: Output -> Trie -> Trie
acInsert (Pos (word, pos)) = trieInsert word (Pos (word, pos) )
 

acGo :: Char -> Trie -> Trie
acGo c (Node m)
    | member c m = 
        let (b,o,t, f) = fwd c m in
            t
    | otherwise = Null
acGo c Null = Null


acSearch :: [Char] -> Trie -> Maybe (Map Int Output)
acSearch (s:ss) (Node m) = do
    let nextNode = acGo s (Node m) 
    case nextNode of
        Null -> let (b,Pos(word, pos),nextTrie, f) = fwd s m in
            acSearch ss f
        _ -> 
            let (b,Pos(word, pos),nextTrie, f) = fwd s m in
            if not b then acSearch ss nextTrie else Just $ st (llength word) $ Pos(word, pos)
acSearch s Null = Nothing

acFail :: [Char] -> Trie -> Trie
acFail str Null = Null
acFail (x:xs) (Node m) = do
    let que = empty 
    let (b,o,t,f) = fwd x m in
        t
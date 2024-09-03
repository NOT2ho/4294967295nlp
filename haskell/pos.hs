
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence

data Trie = Root Childs
            | Node Char Bool (Maybe Output) Fail Childs
            | Null
            deriving (Show)
type Fail = Trie
type Childs = Map Char Trie
type Output = ([Char], Pos)
type Pos = [Char]

st = Map.singleton
member = Map.member
notMember = Map.notMember
ins :: Char -> a -> Map Char a -> Map Char a
ins = Map.insert
fwd = Map.findWithDefault Null
lnull = Data.List.null
llength :: [] a -> Int
llength = Data.List.length
keys = Map.keys
elems = Map.elems
qct = Data.Sequence.singleton
stake = Data.Sequence.take

trieInsert :: [Char] -> Maybe Output -> Trie -> Trie
trieInsert [] _ t = t
trieInsert (w:ws) output Null
    | lnull ws =  Node w True output Null Map.empty
    | otherwise = Node w False Nothing Null $ st (head ws) $ trieInsert ws output Null

trieInsert (w:ws) output (Root m)
    | Map.null m =
        Root $ st w $ trieInsert (w:ws) output Null
    | member w m =
        let cm = fwd w m in
        let newCm = trieInsert ws output cm in
        Root (ins w newCm m)
    | notMember w m =
        let cm = Node w (lnull ws) (if lnull ws then output else Nothing) Null Map.empty in
        let newCm = trieInsert ws output cm in
        Root (ins w newCm m)
trieInsert (w:ws) output (Node c b o f m)
    | Map.null m =
        Node c b o f $ st w $ trieInsert (w:ws) output Null
    | member w m =
        let cm = fwd w m in
        let newCm = trieInsert ws output cm in
        Node c b o f (ins w newCm m)
    | notMember w m =
        let cm = Node w (lnull ws) (if lnull ws then output else Nothing) Null Map.empty in
        let newCm = trieInsert ws output cm in
        Node c b o f (ins w newCm m)


acInsert :: Output -> Trie -> Trie
acInsert (word, pos) = trieInsert word (Just (word, pos))


acGo :: Char -> Trie -> Trie
acGo char (Node c b o t m)
    | member c m =
        let (b,o,t, f) = fwd char m in
            t
    | otherwise = Null
acGo c Null = Null


acSearch :: [Char] -> Trie -> Maybe (Map Int Output)
acSearch (s:ss) (Node c b o t m) = do
    let nextNode = acGo s (Node c b o t m)
    let (b,Output(word, pos),nextTrie, f) = fwd s m
    case nextNode of
        Null -> acSearch ss f
        _ -> if not b then
            acSearch ss nextTrie
            else Just $ st (llength word) $ Output (word, pos)
acSearch s Null = Nothing

{-
acFail ::  Trie -> Trie
acFail Null = Null
acFail Root = do
    let (b, Just (w,p),t,f) = fwd x m
    let emptyQue = empty
    let que = emptyQue >< qct (keys m)

-}
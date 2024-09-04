
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence

data Trie = Root Childs
            | Node Bool (Maybe Output) Fail Childs
            | Null
            deriving (Show)
type Fail = Trie
type Childs = Map Char Trie
type Output = ([Char], Pos)
type Pos = [Char]

st = Map.singleton
member = Map.member
notMember :: Char -> Map Char a -> Bool
notMember = Map.notMember
ins :: Char -> a -> Map Char a -> Map Char a
ins = Map.insert
fwd :: Ord k => a -> k -> Map k a -> a
fwd = Map.findWithDefault
lnull = Data.List.null
llength :: [] a -> Int
llength = Data.List.length
keys = Map.keys
elems = Map.elems
qct = Data.Sequence.singleton
stake :: Int -> Seq Char -> Seq Char
stake = Data.Sequence.take
--madjust = Map.adjust


trieInsert :: [Char] -> Maybe Output -> Trie -> Trie
trieInsert [] output t = 
    case t of
        Null -> Null --이런 일은 없어야 함
        Root m -> t --이런 일은 없어야 함
        Node b o f m -> Node True output f m 


trieInsert (w:ws) output Null
    | lnull (w:ws) = Null
    | lnull ws =  Node True output Null (st w Null)
    | otherwise = Node False Nothing Null $ st w $ trieInsert ws output Null

trieInsert (w:ws) output (Root m)
    | member w m =
        let nextNode = fwd Null w m in 
        let thisNode = trieInsert ws output nextNode in 
        Root (ins w thisNode m)
    | notMember w m =
        let nextNode = Node (lnull ws)
                                (if lnull ws then output else Nothing) 
                                Null 
                                Map.empty in
        let thisNode = trieInsert ws output nextNode in
        Root (ins w thisNode m)
trieInsert (w:ws) output (Node b o f m)
    | member w m =
        let nextNode = fwd Null w m in
        let thisNode = trieInsert ws output nextNode in
        Node b o f (ins w thisNode m)
    | notMember w m =
        let nextNode = Node (lnull ws) 
                                (if lnull ws then output else Nothing) 
                                Null 
                                Map.empty in
        let thisNode = trieInsert ws output nextNode in
        Node b o f (ins w thisNode m)



acInsert :: Output -> Trie -> Trie
acInsert (word, pos) = trieInsert word (Just (word, pos))

{-
acGo :: Char -> Trie -> Trie
acGo char (Node b o t m)
    | member c m =
        let node = fwd Null char m in
            t
    | otherwise = Null
acGo c Null = Null
-}
{-
acSearch :: [Char] -> Trie -> Maybe (Map Int Output)
acSearch (s:ss) (Node c b o f m) = do
    let thisNode = acGo s (Node c b o f m)
    let nextTrie = fwd s m
    case thisNode of
        Null -> acSearch ss f
        _ -> if not b then
            acSearch ss nextTrie
            --else Just $ st (llength word) $ Just (word, pos)
--acSearch s Null = Nothing
-}
{-
acFail :: Trie -> Trie
acFail (Root child) =
        let (h:t) = keys child in
            let Node b o f m = fwd Null h child in
                case h:t of
                    [_] ->
                        Root
                            $ madjust (const $ Node c b o (Root child) m) h child
                    _ ->
                            let Root last = acFail $ Root (Map.delete h child) in
                                Root
                                     $ madjust (const $ Node c b o (Root child) m) h last
--acFail (Node c b o f m) =-}

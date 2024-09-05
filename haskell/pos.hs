
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence
import Data.Maybe(fromMaybe)

data Trie = Root Childs
            | Node Bool (Maybe Output) Fail Childs
            | Null
            | IfYouSeeThisThenYouArePoorCat
            deriving (Show, Eq)
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
sst = Data.Sequence.singleton


trieInsert :: [Char] -> Maybe Output -> Trie -> Trie
trieInsert [] output t =
    case t of
        Null -> IfYouSeeThisThenYouArePoorCat
        Root m -> IfYouSeeThisThenYouArePoorCat
        Node b o f m -> Node True output f m


trieInsert (w:ws) output Null
    | lnull (w:ws) = Null
    | lnull ws =  Node True output Null (st w Null)
    | otherwise = Node False Nothing Null $ st w $ trieInsert ws output Null

trieInsert (w:ws) output (Root m)
    | member w m =
        let nextNode = fwd IfYouSeeThisThenYouArePoorCat w m in
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
        let nextNode = fwd IfYouSeeThisThenYouArePoorCat w m in
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


acGo :: Char -> Trie -> Maybe Trie
acGo char (Node b o f m)
    | member char m =
        Just $ fwd IfYouSeeThisThenYouArePoorCat char m
    | otherwise = Nothing
acGo c root = Just root


acSearch :: [Char] -> Trie -> Maybe (Map Int Output)
acSearch (s:ss) (Node b o f m) = do
    let thisNode = acGo s (Node b o f m)
    let nextTrie = fwd IfYouSeeThisThenYouArePoorCat s m
    (if b 
        then Just $ st 1 (fromMaybe ("나오면 안되는값임","IfYouSeeThisThenYouArePoorCat") o) 
        else acSearch ss nextTrie)
acSearch s Null = Just $ st 666 ("나오면 안되는값임","IfYouSeeThisThenYouArePoorCat")


acFail:: Trie -> Seq Trie -> Maybe Trie
acFail _ Empty = Nothing
acFail (Root edge) que =
    let root = Root edge in
        let (h:t) = keys edge in
            let Node b o f childEdge = fwd Null h edge in
                    case h:t of
                        [_] ->
                            Nothing
                        _ -> acFail (
                                Node b o f
                                (ins h (Node b o root childEdge) edge))
                                (que |> Node b o f childEdge)


acFail (Node bool output fail edge) (q :<| qs)
    | q == Node bool output fail edge =
        let thisNode = Node bool output fail edge in
            let (h:t) = keys edge in
                let Node b o f childEdge = fwd IfYouSeeThisThenYouArePoorCat h edge in
                    case h:t of
                        [_] ->
                            Nothing
                        _ ->
                            acFail (
                                Node b o f
                                (ins h (Node b o
                                        (fromMaybe IfYouSeeThisThenYouArePoorCat (acGo h fail))
                                        childEdge)
                                edge)
                                )
                                (qs|> Node b o f childEdge)
                                

acFail _ _ = Just IfYouSeeThisThenYouArePoorCat
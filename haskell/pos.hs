
import Data.List
import Data.Map.Internal.Debug
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Sequence
import Data.Maybe(fromMaybe)

data Trie = Root Childs
            | Node Bool (Maybe Output) Childs
            | Null
            | IfYouSeeThisThenYouArePoorCat
            deriving (Show, Eq, Ord)
type Fail = Trie
type Childs = Map Char Trie
type Output = ([Char], Pos)
type Pos = [Char]

st = Map.singleton
member = Map.member
notMember :: Char -> Map Char a -> Bool
notMember = Map.notMember
ins :: Ord k => k -> a -> Map k a -> Map k a
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
        Node b o m -> Node True output m


trieInsert (w:ws) output Null
    | lnull (w:ws) = Null
    | lnull ws =  Node True output (st w Null)
    | otherwise = Node False Nothing $ st w $ trieInsert ws output Null

trieInsert (w:ws) output (Root m)
    | member w m =
        let nextNode = fwd IfYouSeeThisThenYouArePoorCat w m in
        let thisNode = trieInsert ws output nextNode in
        Root (ins w thisNode m)
    | notMember w m =
        let nextNode = Node (lnull ws)
                                (if lnull ws then output else Nothing)
                                Map.empty in
        let thisNode = trieInsert ws output nextNode in
        Root (ins w thisNode m)
trieInsert (w:ws) output (Node b o m)
    | member w m =
        let nextNode = fwd IfYouSeeThisThenYouArePoorCat w m in
        let thisNode = trieInsert ws output nextNode in
        Node b o (ins w thisNode m)
    | notMember w m =
        let nextNode = Node (lnull ws)
                                (if lnull ws then output else Nothing)
                                Map.empty in
        let thisNode = trieInsert ws output nextNode in
        Node b o (ins w thisNode m)



acInsert :: Output -> Trie -> Trie
acInsert (word, pos) = trieInsert word (Just (word, pos))


acGo :: Char -> Map Trie Fail -> Trie -> Trie
acGo char fail (Node b o m)
    | member char m = fwd IfYouSeeThisThenYouArePoorCat char m
    | otherwise = fwd IfYouSeeThisThenYouArePoorCat (Node b o m) fail
acGo c trie (Root m)
    | member c m = fwd IfYouSeeThisThenYouArePoorCat c m
    | otherwise = Null


acSearch :: [Char] -> Trie -> Trie -> Map Trie Fail -> Int -> Map Int Output -> Map Int Output
acSearch (s:ss) root (Root m) fail idx mio =
    let thisNode = Root m in
    let nextNode = acGo s fail thisNode in
        if nextNode == Null
            then acSearch ss root (Root m) fail (idx+1) mio
            else acSearch ss root nextNode fail (idx+1) mio


acSearch (s:ss) root (Node b o m) fail idx mio =
    let thisNode = Node b o m in
    let nextNode = acGo s fail thisNode in
        (if 
            b 
            then (
                if 
                m /= Map.empty
                    then acSearch ss root nextNode fail
                        (idx+1)
                        (ins idx (fromMaybe ("불쌍", "IfYouSeeThisThenYouArePoorCat") o ) mio )
                    else acSearch (s:ss) root root fail
                        (idx+1)
                        (ins idx (fromMaybe ("불쌍", "IfYouSeeThisThenYouArePoorCat") o ) mio )) 
        else (
             if 
                m /= Map.empty
                    then acSearch ss root nextNode fail (idx+1) mio
                    else acSearch (s:ss) root root fail (idx+1) mio))

acSearch [] root (Node b o m) fail idx mio = if b then ins idx (fromMaybe ("불쌍", "IfYouSeeThisThenYouArePoorCat") o ) mio else mio

acSearch _ _ t f idx mio = mio

acFail:: Seq Trie -> Map Trie Fail -> Map Trie Fail
acFail Empty mtf = mtf
acFail ((Root edge) :<| que) mtf =
    let root = Root edge in
    let (newque, newmtf) = Map.foldr (\t (oq, om) -> (oq |> t, ins t root om)) (que, mtf) edge in
    acFail newque newmtf

acFail ((Node b o edge) :<| que) mtf =
    let node = Node b o edge in
    let (newque, newmtf) = Map.foldrWithKey (\k t (oq, om) -> (oq |> t, ins t (acGo k mtf node) om)) (que, mtf) edge in
    acFail newque newmtf

insertManyWords:: [Output] -> Trie -> Trie
insertManyWords (o:os) trie = acInsert o (insertManyWords os trie)
insertManyWords _ _ = Root Map.empty

catSearch :: [] Char -> [Output] -> Map Int Output
catSearch c o =
    let trie = insertManyWords o Null in
    let failTrie = acFail (Data.Sequence.singleton trie) $ st trie Null in
        acSearch c trie trie failTrie 0 Map.empty

catTest :: [] Char -> [Output] -> Trie
catTest c o =
    let trie = insertManyWords o Null in
    let failTrie = acFail (Data.Sequence.singleton trie) $ st trie Null in
        acGo (head c) failTrie trie
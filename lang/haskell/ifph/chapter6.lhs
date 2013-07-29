* 第６章 木
** 6.1 二分木

> data Btree a = Leaf a | Fork (Btree a) (Btree a)
Btree a型の値はa型の値をもつ葉であるか、部分木を２つ持つ分岐節点であるかのどちらかである。
葉のことを外部節点あるいは端点、分岐を内部節点ということもある。

例)
> Fork (Leaf 1) (Fork (Leaf 2) (Leaf 3))

   /\
  1 /\
   2  3

> Fork (Fork (Leaf 1) (Leaf 2)) (Leaf 3)

   /\
  /\ 3
 1  2

異なるBtree a型の値は、本質的にその木が持つ値を並べた時の括弧のくくり方の違いを表す。

*** 6.1.1 木の帰納法

任意の二分木xtで命題P(xt)が成り立つことを示すためには、以下を示せば十分である。
===
⊥の場合：
 P(⊥)が成り立つ

Leaf xの場合：
 任意のxについてP(Leaf x)が成り立つ

Fork xt ytの場合：
 P(xt)とP(yt)が共に成り立てば、P(Fork xt yt)も成り立つ
===

*** 6.1.2 木の大きさと高さ

大きさ(size)は葉の数
> size :: Btree a -> Int
> size (Leaf x) = 1
> size (Fork xt yt) = size xt + size yt

size = length . flatten

> flatten :: Btree a -> [a]
> flatten (Leaf x) = [x]
> flatten (Fork xt yt) = flatten xt ++ flatten yt

内部節点
> nodes :: Btree a -> Int
> nodes (Leaf x) = 0
> nodes (Fork xt yt) = 1 + nodes xt + nodes yt

とすると 任意の有限木xtについて
> size xt = 1 + nodes xt
である。

これが構造帰納法で証明できる。
任意の有限木xtとしているので、以下の２点を示せばよい。
===
Leaf xの場合： 任意のxについてP(Leaf x)が成り立つ
Fork xt ytの場合： P(xt)とP(yt)が共に成り立てば、P(Fork xt yt)も成り立つ
===

Leaf xの場合
> size (Leaf x) = 1 -- size関数の定義より
> nodes (Leaf x) = 0 -- nodes関数の定義より
よって
> size (Leaf x) = 1 + nodes (Leaf x)
これでLeaf xの場合は示せた

Fork xt ytの場合
> size xt = 1 + nodes xt -- (1)
と
> size yt = 1 + nodes yt -- (2)
が共に成り立てば
> size (Fork xt yt) = 1 + nodes (Fork xt yt)
も成り立つ -- 構造帰納法より

うーん、どうやって(1),(2)を示せばいいんだ？
まあ、いいか。とりあえず飛ばしておく


木の高さ(height)は、最も先にある葉までの距離
例) この木の高さは2
> Fork (Leaf 1) (Fork (Leaf 2) (Leaf 3))

 /\
1 /\
 2  3

--depth 木を引数に取り、その木のすべての葉が持つ値を葉の深さに置き換える
> depth :: Btree a -> Btree Int
> depth = down 0

> down :: Int -> Btree a -> Btree Int
> down n (Leaf x) = Leaf n -- nは深さ
> down n (Fork xt yt) = Fork (down (n + 1) xt) (down (n + 1) yt)

maxBtreeを以下のように定義すると
> maxBtree :: (Ord a) => Btree a -> a
> maxBtree (Leaf x) = x
> maxBtree (Fork xt yt) = (maxBtree xt) `max` (maxBtree yt)

以下の等式が成り立つ
> height = maxBtree . depth

この証明をやってみるか
とうか、感覚的には自明なんだが、、
飛ばし、

すべての葉の深さが同じような木を完全な木という => (complete tree? perfect tree?)

=> ja.wikipediaによると http://ja.wikipedia.org/wiki/%E4%BA%8C%E5%88%86%E6%9C%A8
 「完全二分木 (perfect binary tree, complete binary tree) は全ての葉が同じ「深さ」を持つ二分木を指す。」
=> en.wikipediaではちょっと違う http://en.wikipedia.org/wiki/Binary_tree
 「A perfect binary tree is a full binary tree in which all leaves are at the same depth or same level, and in which every parent has two children.[2] (This is ambiguously also called a complete binary tree (see next).) An example of a perfect binary tree is the ancestry chart of a person to a given depth, as each person has exactly two biological parents (one mother and one father); note that this reverses the usual parent/child tree convention, and these trees go in the opposite direction from usual (root at bottom).
A complete binary tree is a binary tree in which every level, except possibly the last, is completely filled, and all nodes are as far left as possible.[3] A tree is called an almost complete binary tree or nearly complete binary tree if the exception holds, i.e. the last level is not completely filled. This type of tree is used as a specialized data structure called a heap.」


例) 以下の木は完全二分木
> Fork (Fork (Leaf 1) (Leaf 2)) (Fork (Leaf 3) (Leaf 4))
    /\
   /  \
  /    \
 /\    /\
1  2  3  4

完全二分木の大きさは常に2のべき乗
葉がもつ値を無視すれば、2のべき乗ごとにその大きさの完全二分木が一つだけ存在する

二分木に関する最も重要な事実の1つは
任意の有限木xtに対して

> height xt < size xt <= 2^(height xt)

2を底とする対数をとれば

まず a = height xt と置いて、
-> a < size xt <= 2^a
ここでsize xtと2^aを2を底とする対数をとる
-> log 2 (size xt) <= log 2 2^a -- 対数をとっても大小関係変わらないんだっけ？
-> log 2 (size xt) <= a
-> log 2 (size xt) <= height xt
ということで
-> log 2 (size xt) <= height xt < size xt

> ceiling ( log (size xt) ) <= height xt < size xt

# == 対数ってなんだっけ?
# http://naop.jp/mathtori/mathtori3.html
# 
# 「 2^x = 4 」や「 2^x = 8 」を満たすxはすぐに分かるでしょうが，「 2^x = 5 」を満たすxとなると即答は出来ません。
# 5は4と8の間にあることからxは2と3の間にあるだろうという予測は立ちますが，手計算ではその値を正確に把握することは困難です。
# そこで，a^x = Mが成り立っているとき，x = log a Mと書く，という風に記号の約束をし，これをaを底とするMの対数と呼ぶことにします。
# この表記を用いて，先ほどの「 2^x = 5 」を満たすxは「 x = log 2 5 」である，と書き表してしまうのです。a^xは常に正でしたから，Mも常に正です。これを真数Mの条件といいます。
# ==
# 
# http://ja.ftext.org/%E5%AF%BE%E6%95%B0%E3%81%A8%E5%AF%BE%E6%95%B0%E9%96%A2%E6%95%B0
# 
# *** 対数の計算法則
# 
# - 和と差に関する対数の法則
#   aはa > 0, a /= 1を満たし,M > 0、N > 0とするとき
#   1)  log a MN = log a M + log a N
#   1') log a M/N = log a M - log a N
#   が成り立つ。
# 
# - 実数倍に関する対数の性質
#   aはa > 0, a /= 1を満たし、M > 0, rは任意の実数のとき
#   2) log a M^r = r log a M
#   が成り立つ。
# 
# - 底の変換公式
#   ある対数の値は、底の違う別の対数の日で表すことができ
#   log a b = (log c b) / (log c a)
#   となる。
#   この式を使えば、例えば底が２の対数であるlog 2 3も、常用対数表を用いて
#   log 2 3 = (log 10 3) / (log 10 2) =~ 0.4771/0.3010 =~ 1.585
#   と計算することができる。
# 
# - 対数と指数の関係
#   a^x = Mが成り立つとき、対数のていぎより log a M である。この x = log a Mを a^x = Mに代入することにより、
#   a^(log a M) = M
#   が成り立つ。
# 
# 

長さnの任意のリストxsがあれば、以下を満たす木xtを構成できる。
> flatten xt = xs
かつ
> height xt = ceil (log n)

空ではないリストを入力とし、これを真ん中で二つに分割し、半分ずつに対して再帰的に
最小高さの木を作り上げれば、最小高さの木が一つ得られる。
> mkBtree :: [a] -> Btree a
> mkBtree xs
>   | m == 0    = Leaf (unwrap xs)
>   | otherwise = Fork (mkBtree ys) (mkBtree zs)
>    where
>      m        = (length xs) `div` 2
>      (ys, zs) = splitAt m xs
> splitAt n xs = (take n xs, drop n xs)
> unwrap [x] = x


*** 6.1.3 写像と畳み込み

map
> mapBtree :: (a -> b) -> Btree a -> Btree b
> mapBtree f (Leaf x)     = Leaf (f x)
> mapBtree f (Fork xt yt) = Fork (mapBtree f xt) (mapBtree f yt)

このmapBtreeはmapの規則と同様の規則を満たす。
> mapBtree id = id
> mapBtree (f . g) = mapBtree f . mapBtree g

また、以下も成り立つ
> map f . flatten = flatten . mapBtree f

fold
> foldBtree :: (a -> b) -> (b -> b -> b) -> Btree a -> b
> foldBtree f g (Leaf x)     = f x
> foldBtree f g (Fork xt yt) = g (foldBtree f g xt) (foldBtree f g yt)

二分木上の多くの演算はfoldBtreeを使って定義できる
> size = foldBtree (const 1) (+)
> height = foldBtree (const 0) `op`
>   where m `op` n = 1 + (m `max` n)
> flatten = foldBtree wrap (++)
> maxBtree = foldBtree id (max)
> mapBtree f = foldBtree (Leaf . f) Fork

size関数について考える。
Leaf xの場合
> size (Leaf xt) = foldBtree (const 1) (+) (Leaf xt)
>                = const 1 (Leaf xt)
>                = 1
Fork xt ytの場合
> size (Fork xt yt) = foldBtree (const 1) (+) (Fork xt yt)
>                   = (foldBtree (const 1) (+) xt) + (foldBtree (const 1) (+) yt)
>                   = ...

height関数について考えてみる
Leaf xtの場合
> height (Leaf xt) = foldBtree (const 0) `op` (Leaf xt) where m `op` n = 1 + (m `max` n)
>                  = (const 0) xt
>                  = 0
Fork xt ytの場合
> height (Fork xt yt) = foldBtree (const 0) `op` (Fork xt yt) where m `op` n = 1 + (m `max` n)
>                     = (foldBtree (const 0) `op` xt) `op` (foldBtree (const 0) `op` yt)
> (xtがFork a bだったら) = ((foldBtree (const 0) `op` a) `op` (foldBtree (const 0) `op` a)) `op` (foldBtree (const 0) `op` yt)
>                      = 


*** 6.1.4 拡張二分木

内部節点にも情報を載せるようにした変種

> data Atree a = Leaf a | Fork Int (Atree a) (Atree a)

Fork n xt yt の整数n がn = size xt という条件を満たすことを利用するのが基本的な考え方である
-> ?

  1
 / \
0   2
   / \
  2   0
 / \
0   0
こういうこと？

> fork :: Atree a -> Atree a -> Atree a
> fork xt yt = Fork (lsize xt) xt yt

> lsize :: Atree a -> Int
> lsize (Leaf x) = 1
> lsize (Fork n xt yt) = n + lsize yt -- ?これよくわからない

値の並びから高さ最小の拡張木を組み立てる
> mkAtree :: [a] -> Atree a
> mkAtree xs
>   | (m == 0)  = Leaf (unwrap xs)
>   | otherwise = fork (mkAtree ys) (mkAtree zs)
>    where m       = (length xs) `div` 2
>          (ys,zs) = splitAt m xs

retrieve関数はリストにおける(!!)と同じようなことをする
> retrieve :: Atree a -> Int -> a
> retrieve xt k = (flatten xt) !! k

> (xs ++ ys) !! k = if k < m
>                     then xs !! k
>                     else ys !! (k - m)
>                   where m = length xs
という事実を利用してretrieveのより効率の良いプログラムを合成できる

> retrieve (Leaf x) 0 = x
> retrieve (Fork m xt yt) k = if k < m
>                                then retrieve xt k
>                                else retrieve yt (k - m)

与えられた位置にある要素の探索を制御するのに、分岐節点に格納されている大きさの情報を利用している
-> リストに格納した情報を(!!)で取り出すのではなく、そのリストのmkAtreeを使って最小高さの二分木に変換してからretrieveを使えばよい
   リストの長さをnとしたとき、retrieveの計算に化ｋルノはlog n に比例したステップだが、(!!)はnに比例したステップかかる。


** 6.2 二分探索木

後述するある条件のもとで、以下のデータ型は二分探索木
> data (Ord a) => Stree a = Null | Fork (Stree a) a (Stree a)

以下のflatten関数は、木を左から右に辿ったときのラベルのリストを返す
> flatten :: (Ord a) => Stree a -> [a]
> flatten Null = []
> flatten (Fork xt x yt) flatten xt ++ [x] ++ flatten yt

『Stree aの要素に対して、flattenが要素が昇順に並んだリストを返す場合に、Stree aは二分探索木として機能する。』

> inordered :: (Ord a) => Stree a -> Bool
> inordered = ordered . flatten -- ordered xsはxsが昇順になっているという条件

member関数 与えられた値が二分木のどこかの節点ラベルとして現れるかどうかを判定するもの
> member :: (Ord a) => a -> Stree a -> Bool
> member x Null = False
> member x (Fork xt y yt)
>   | (x < y)  = member x xt
>   | (x == y) = True
>   | (x > y)  = member x yt
最悪の場合、member x xtを評価するコストはxtの高さに比例する

> height :: (Ord a) => Stree a -> Integer
> height Null = 0
> height (Fork xt x yt) = 1 + (height xt `max` height yt)


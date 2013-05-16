4.6 畳み込み則

第 2 双対定理. ⊕,⊗,e が任意の x,y,z に対して以下の関係を成り立たせると仮定する.

x⊕(y⊗z) = (x⊕y)⊗z x⊕e = e⊗x

foldlが末尾再帰
foldrが余再帰


4.6.2 融合(変換)

map g = foldr (cons . g) []

foldr (\x xs -> x:xs) [] -- => id
foldr (\x xs -> g x : xs) []  -- => map
foldr (cons . g)          []

cons :: a -> [a] -> [a]
g :: b -> a
cons . g :: b -> [a] -> [a]
(\x -> (\xs -> (g x) : xs))

foldr定理
- f:正格
- f a = b
- f (g x y) = h x (f g)
- f. foldr g a = foldr h b

=> map g = foldr (cons . g) []

融合すると中間のリストを作らなくていいので、効率が良くなる

4.6.4 fold-concatの融合

foldr (flip (foldr (:)) [] [[1,2],[3,4],[5,6,7]]
g = flip (foldr (:)) として
=> foldr g [] [[1,2],[3,4],[5,6,7]]
=> g [1,2] (foldr g [] [[3,4],[5,6,7]])
rs = foldr g [] [[3,4],[5,6,7]] として
=> flip (foldr (:)) [1,2] rs
=> foldr (:) rs [1,2]
=> \rs -> foldr (:) rs [1,2]

差分リスト？

4.6.7 例:最大部分列和

練習問題
    4.6.1 第 3 双対定理を証明せよ.
    > 第 3 双対定理. 任意の有限リスト xs について
    > foldr f e xs = foldl (flip f ) e (reverse xs)

    




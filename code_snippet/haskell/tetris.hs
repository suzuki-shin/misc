main = do c <- getContents
          print c

type Pos = (Int, Int)
type Board = [Pos]

beep :: IO ()
beep = putStr "\BEL"

cls :: IO ()
cls = putStr "\ESC[2J"

goto :: Pos -> IO ()
goto (x, y) = putStr ("\ESC[" ++ show y ++ ";" ++ show x ++"H")

seqn :: [IO a] -> IO ()
seqn [] = return ()
seqn (a:as) = do a
                 seqn as

writeat :: Pos -> String -> IO ()
writeat p xs = do goto p
                  putStr xs

life :: Board -> IO ()
life b = do cls
            showcells b
            wait 5000
            life (nextgen b)

showcells :: Board -> IO ()
showcells b = seqn [writeat p "##" |p <- b]

wait :: Int -> IO ()
wait n = seqn [return () | _ <- [1..n]]

nextgen :: Board -> Board
nextgen b = randomb b

randomb :: Board -> Board
randomb [(x,y)] = [(x,y+1)]
-- randomb [(x,y)] = map (_,+1) [(x,y)]

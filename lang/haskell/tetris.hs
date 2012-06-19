main = do c <- getContents
          print c

type Pos = (Int, Int)
type Board = [Pos]

-- actions
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
            wait 200000
            life (nextgen b)

showcells :: Board -> IO ()
showcells b = seqn [writeat p "##" |p <- b]

wait :: Int -> IO ()
wait n = seqn [return () | _ <- [1..n]]


nextgen :: Board -> Board
nextgen b = do down b

down :: Board -> Board
down b = map (\(x,y) -> (x,y+1)) b

up :: Board -> Board
up b = map (\(x,y) -> (x,y-1)) b

left :: Board -> Board
left b = map (\(x,y) -> (x-1,y)) b

right :: Board -> Board
right b = map (\(x,y) -> (x+1,y)) b

randomb :: Board -> Board
randomb [] = []
randomb p = map (\(x, y) -> (x, y-1)) p
-- randomb [(x,y)] = map (_,+1) [(x,y)]

b :: Board
b = [(10, 9), (10,10), (10,11), (12,11)]
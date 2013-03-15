{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes, TemplateHaskell, TypeFamilies, OverloadedStrings #-}
{-# LANGUAGE GADTs, FlexibleContexts #-}
import Web.Scotty

import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this

import Control.Monad.Trans
import Data.Monoid
import System.Random (newStdGen, randomRs)

import Network.HTTP.Types (status302)
-- import Network.Wai
import qualified Data.Text.Lazy as T

import Data.Text.Lazy.Encoding (decodeUtf8)

import qualified Database.Persist as P
import qualified Database.Persist.Sqlite as P
import Database.Persist.TH
-- import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Resource (runResourceT)
import Data.Text (Text)
import qualified Data.Aeson as A

import qualified Data.ByteString.Lazy.Char8 as LC (unpack, pack, writeFile, appendFile, split)
import Data.ByteString.Lazy.Char8 ()
import Control.Applicative
import           GHC.Generics (Generic)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
Person json
    name String
    age Int Maybe
    deriving Show
BlogPost json
    title String
    authorId PersonId
    deriving Show
|]

parsePerson :: A.Value -> A.Result Person
parsePerson = A.fromJSON

runDB :: MonadIO m => P.ConnectionPool -> P.SqlPersist IO a -> m a
runDB p action = liftIO $ P.runSqlPool action p

runDB' :: MonadIO m => Text -> P.SqlPersist IO a -> m a
runDB' name action = liftIO $ P.withSqliteConn name $ P.runSqlConn action

-- hoge :: ScottyM P.ConnectionPool
-- hoge = P.createSqlitePool "scottyp.db" 3

main :: IO ()
main = do
--   pool <- P.createSqlitePool "scottyp.db" 3
  scotty 3000 $ do
    -- Add any WAI middleware, they are run top-down.
    middleware logStdoutDev

    -- To demonstrate that routes are matched top-down.
    get "/" $ text "foobar"
    get "/" $ text "barfoo"

    -- Using a parameter in the query string. If it has
    -- not been given, a 500 page is generated.
    get "/foo" $ do
        v <- param "fooparam"
        liftIO $ runResourceT $ P.withSqliteConn "test.db" $ P.runSqlConn $ do
          P.runMigration migrateAll

--           liftIO $ print $ (A.decode (LC.pack v) :: Maybe Person)
--           liftIO $ print $ (A.decode v :: Maybe Person)
--           let mP = (A.decode (parseParam v) :: Maybe Person)
--           case parseParam v of
--             Right a -> do
--               liftIO $ putStrLn a
--               let mP = (A.decode a :: Maybe Person)
--               liftIO $ print mP
--               case mP of
--                 Just p -> P.insert p

--             Left _ -> error "parseParam miss!"
          let mP = (A.decode "{\"name\":\"ssxx\", \"age\":30}" :: Maybe Person)
          liftIO $ print mP
          case mP of
            Just p -> do
              P.insert p
--           _ <- P.insert $ A.decode $ "{\"name\":\"aeae\", \"age\":3}"
--           _ <- P.insert $ Person (T.unpack v) $ Just 38
          oneJohnPost <- P.selectList [] [P.LimitTo 10]
          liftIO $ print (oneJohnPost :: [P.Entity Person])
--           liftIO $ print "hgoe"
        html $ mconcat ["<h1>", v, "</h1>"]

    -- An uncaught error becomes a 500 page.
    get "/raise" $ raise "some error here"

    -- You can set status and headers directly.
    get "/redirect-custom" $ do
        status status302
        header "Location" "http://www.google.com"
        -- note first arg to header is NOT case-sensitive

    -- redirects preempt execution
    get "/redirect" $ do
        redirect "http://www.google.com"
        raise "this error is never reached"

    -- Of course you can catch your own errors.
    get "/rescue" $ do
        (do raise "a rescued error"; redirect "http://www.we-never-go-here.com")
        `rescue` (\m -> text $ "we recovered from " `mappend` m)

    -- Parts of the URL that start with a colon match
    -- any string, and capture that value as a parameter.
    -- URL captures take precedence over query string parameters.
    get "/foo/:bar/required" $ do
        v <- param "bar"
        html $ mconcat ["<h1>", v, "</h1>"]

    -- Files are streamed directly to the client.
    get "/404" $ file "404.html"

    get "/random" $ do
        next
        redirect "http://www.we-never-go-here.com"

    -- You can do IO with liftIO, and you can return JSON content.
    get "/random" $ do
        g <- liftIO newStdGen
        json $ take 20 $ randomRs (1::Int,100) g

    get "/ints/:is" $ do
        is <- param "is"
        json $ [(1::Int)..10] ++ is

    get "/setbody" $ do
        html $ mconcat ["<form method=POST action=\"readbody\">"
                       ,"<input type=text name=something>"
                       ,"<input type=submit>"
                       ,"</form>"
                       ]

    post "/readbody" $ do
        b <- body
        text $ decodeUtf8 b

    get "/person" $ do
        html $ mconcat ["<form method=POST action=\"person\">"
                       ,"name: <input type=text name=name> "
                       ,"age: <input type=text name=age>"
                       ,"<input type=submit>"
                       ,"</form>"
                       ]

    post "/person" $ do
        b <- body
        let ps = map (T.split (=='=')) $ T.split (=='&') $ decodeUtf8 b
            name = T.unpack $ (filter ((=="name"). head) ps)!!0!!1
            age = (read $ T.unpack $ ((filter ((=="age"). head) ps)!!0)!!1) :: Int
        liftIO $ print name
        liftIO $ print age
        liftIO $ runResourceT $ P.withSqliteConn "test.db" $ P.runSqlConn $ do
          P.runMigration migrateAll
          P.insert $ Person name $ Just age
--           P.insert $ Person (LC.unpack b) (Just 123)
        text $ decodeUtf8 b

    get "/lambda/:foo/:bar/:baz" $ \ foo bar baz -> do
        text $ mconcat [foo, bar, baz]

    get "/reqHeader" $ do
        agent <- reqHeader "User-Agent"
        text agent

{- If you don't want to use Warp as your webserver,
   you can use any WAI handler.

import Network.Wai.Handler.FastCGI (run)

main = do
    myApp <- scottyApp $ do
        get "/" $ text "hello world"

    run myApp
-}

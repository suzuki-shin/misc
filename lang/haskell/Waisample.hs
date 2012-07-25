import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types
import Blaze.ByteString.Builder.Char.Utf8

server :: Application
-- server _ = return $ ResponseBuilder status200 [] $ fromString "hello"
server _ = return $ ResponseFile status200 [] "waisample.html" Nothing

main :: IO ()
main = run 8080 server

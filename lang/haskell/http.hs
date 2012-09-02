import Control.Monad.IO.Class (liftIO)
-- import Data.ByteString
-- import Data.Conduit
-- import qualified Data.Conduit.Binary as CB
-- import Network.HTTP.Conduit
-- import Web.Authenticate.OAuth
import Network.HTTP

import Network.URI
import Data.Maybe

httpPost :: String -> String ->IO ()
httpPost url body = do
  res <- simpleHTTP req
  case res of
    Left x -> return ()
    Right r -> return ()
  where req = Request {
          rqURI = fromJust $ parseURI url,
          rqMethod = POST,
          rqHeaders = [
            mkHeader HdrContentType "application/x-www-form-urlencoded",
            mkHeader HdrContentLength (show $ Prelude.length body)
            ],
          rqBody = body}

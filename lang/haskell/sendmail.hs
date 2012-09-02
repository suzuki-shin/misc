import System.Environment
import Network.SMTP.Simple

main = do
  args <- getArgs
  body <- getContents -- メール本文（標準入力から取得）
  let domain = tail $ snd $ break (== '@') $ args !! 1 -- Fromメールアドレスからドメイン部分を取得
  let msg = SimpleMessage [NameAddr Nothing (args !! 1)] [NameAddr Nothing (args !! 2)] (args !! 3) body -- メッセージ作成
  sendSimpleMessages putStr (head args) domain [msg] -- メール送信

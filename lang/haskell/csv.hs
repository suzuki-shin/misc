import Control.Applicative ((<*),(*>))
import Text.Parsec
import Text.Parsec.String

csv :: Parser [[String]]
csv = endBy1 record crlf

record :: Parser [String]
record = sepBy1 field comma

field :: Parser String
field = escaped <|> nonEscaped

escaped :: Parser String
escaped = dquote *>
          many (textdata <|> comma <|> cr <|> lf
                <|> try (dquote *> dquote))
          <* dquote

nonEscaped :: Parser String
nonEscaped = many textdata

textdata :: Parser Char
textdata = oneOf (" !" ++ ['#'..'+'] ++ ['-'..'~'])

comma :: Parser Char
comma = char ','

crlf :: Parser Char
crlf = cr *> lf

lf :: Parser Char
lf = char '\x0a'

cr :: Parser Char
cr = char '\x0d'

dquote :: Parser Char
dquote = char '"'

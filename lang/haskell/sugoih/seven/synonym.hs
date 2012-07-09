type PhoneBook = [(Name, PhoneNumber)]
type Name = String
type PhoneNumber = String

inPhoneBook :: Name -> PhoneNumber -> PhoneBook -> Bool
inPhoneBook name pnumber pbook = (name, pnumber) `elem` pbook

type AssocList k v = [(k,v)]
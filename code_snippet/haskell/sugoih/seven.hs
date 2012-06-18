class YesNo a where
  yesno :: a -> Boll

instance YesNo Int where
  yesno 0 = False
  yesno _ = True


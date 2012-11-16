fib 0 = 1
fib 1 = 1
fib n = fib (n-2) + fib (n-1)

print :: Foreign a => a -> Fay ()
print = foreignFay "console.log" ""

main = print $ fib 10
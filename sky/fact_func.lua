#!/usr/bin/env lua5.3

function fact (n)
    if n == 0 then
	return 1
    else
	return n * fact(n - 1)
    end
end

print("Enter a number:")
n = io.read("*n")
print(fact(n))

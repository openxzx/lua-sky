#!/usr/bin/lua

path = arg[1]

file = io.open(path, 'r')

-- Determine if the file exists
if file == nil then
    return
end

for value in file:lines()
do
    print(value)
end

os.execute("awk '{print $2}' ./test")

io.close(file)

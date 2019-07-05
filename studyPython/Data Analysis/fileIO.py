fileStream = open("helloWorld.py", "r")
contents = fileStream.readlines()

print(contents)

for i in contents :
    print(i)

fileStream.close()

print(type(contents))
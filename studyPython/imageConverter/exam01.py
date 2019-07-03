f = open("imageConverter/convert.ini")

lines = f.readlines()

folder       = lines[0][:-1]
sourceFormat = lines[1][:-1]
destFormat   = lines[2][:-1]

print(folder)
print(sourceFormat)
print(destFormat)

f.close()

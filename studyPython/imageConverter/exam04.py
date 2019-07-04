with open("imageConverter/convert.ini","r") as f :
    lines = f.readlines()
    folder       = lines[0].strip()
    sourceFormat = lines[1].strip()
    destFormat   = lines[2].strip()

print(folder)
print(sourceFormat)
print(destFormat)


fileName = "pic.jpg"

print(fileName)

picName = fileName.strip(sourceFormat)

print(picName)

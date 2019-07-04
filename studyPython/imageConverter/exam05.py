import os

with open("imageConverter/convert.ini","r") as f :
    convertList = f.readlines()
    folder = convertList[0].strip()
    sourceFormat = convertList[1].strip()
    destFormat = convertList[2].strip()

    fileList = os.listdir()

    for i in fileList :
        print(i)

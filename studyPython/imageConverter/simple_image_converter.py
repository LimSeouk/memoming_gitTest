import os

from PIL import Image

with open("imageConverter/convert.ini","r") as f :
    convertList = f.readlines()
    folder = convertList[0].strip()
    sourceFormat = convertList[1].strip()
    destFormat = convertList[2].strip()

    # print(os.getcwd())

    fileList = os.listdir(folder)

    for fileName in fileList :
        if fileName.endswith("."+sourceFormat) :
            destFileName = fileName.strip(sourceFormat)+destFormat
            # print(destFileName)
            sourceImage = Image.open(folder+"/"+fileName)
            sourceImage.save(folder+"/"+destFileName)
            print("Simple image converter has completed converting '"+fileName+"' to '"+destFileName+"'")
            destImage = Image.open(folder+"/"+destFileName)
            destImage.show()

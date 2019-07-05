import os

from PIL import Image

def convertImageInFolder(folder, sourceFormat, destFormat) :
    fileList = os.listdir(folder)

    for fileName in fileList :
        if(os.path.isdir(folder+"\\"+fileName)) :
            print("folder Nmae : \""+fileName+"\"")
            subfolder = folder+"\\"+fileName
            convertImageInFolder(subfolder, sourceFormat, destFormat)
        else :
            if fileName.endswith("."+sourceFormat) :
                destFileName = fileName.strip(sourceFormat)+destFormat
                # print(destFileName)
                sourceImage = Image.open(folder+"\\"+fileName)
                sourceImage.save(folder+"\\"+destFileName)
                print("Simple image converter has completed converting '"
                +fileName+"' to '"+destFileName+"' in " + folder)
                # destImage = Image.open(folder+"/"+destFileName)
                # destImage.show()

with open("convert.ini","r") as f :
    convertList = f.readlines()
    folder = convertList[0].strip()
    sourceFormat = convertList[1].strip()
    destFormat = convertList[2].strip()
    convertImageInFolder(folder, sourceFormat, destFormat)

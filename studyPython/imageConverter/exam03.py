with open("imageConverter/convert.ini","r") as f :
    lines = f.readlines()
    folder       = lines[0][:-1]
    sourceFormat = lines[1][:-1]
    destFormat   = lines[2][:-1]

print(folder)
print(sourceFormat)
print(destFormat)

from PIL import Image

myImage = Image.open("imageConverter/Koala.jpg")
myImage.show()

myImage.save(folder+"/convert_Koala."+destFormat)

print("Converting is completed")

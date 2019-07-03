from PIL import Image

myImage = Image.open("imageConverter/Koala.jpg")
myImage.show()

myImage.save("imageConverter/convert_Koala.png")

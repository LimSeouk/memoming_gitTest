def hello () :
    print("hello!")

def name (userName) :
    newString = "hello! " +userName
    return newString

def mySum(a, b) :
    return a+b

def convertImageFormat (fileName, sourceFormat, destFormat) :

    realFileName = fileName.strip("."+sourceFormat)+"."+destFormat
    print(realFileName)


hello()
hello()

print(name("Lim Seouk"))

print(mySum(123456,654321))

convertImageFormat("pic.jpg","jpg","png")

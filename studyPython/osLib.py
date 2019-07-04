import os

# print(os.getcwd())

currDir = os.getcwd()

print(currDir)

os.chdir("C:/users")

newDir = os.getcwd()

print(newDir)

fileList = os.listdir(currDir)

print(fileList)

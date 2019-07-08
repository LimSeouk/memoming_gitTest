
inputFile = open("D:\git\project\studyPython\Data Analysis\input_01.txt","r")

inputStream = inputFile.readlines()

inputFile.close()

for orgNum in inputStream :
    print(int(orgNum)+1)
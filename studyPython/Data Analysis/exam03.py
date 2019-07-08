def fnFileListConverter (strFilePath) :
    fsFile = open(strFilePath,'rt', encoding='UTF8')
    lstRtnList = list()
    lstList = fsFile.readlines()

    for strLine in lstList :
        lstRtnList.append(strLine.strip())

    fsFile.close()

    return lstRtnList


strPathIdx  = 'D:\git\project\studyPython\Data Analysis\poketmon_index.txt'
strPathData = 'D:\git\project\studyPython\Data Analysis\poketmon_data.txt'

lstPoketmons = fnFileListConverter(strPathIdx)
lstPoketmonData = fnFileListConverter(strPathData)

for strPoketmon in lstPoketmons :
    nPoketmon = lstPoketmonData.count(strPoketmon)
    # print(nPoketmon)
    print(strPoketmon+' : '+str(nPoketmon))

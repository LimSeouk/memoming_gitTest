fsPoketmonIndex = open('D:\git\project\studyPython\Data Analysis\poketmon_index.txt','rt', encoding='UTF8')
fsPoketmonData  = open('D:\git\project\studyPython\Data Analysis\poketmon_data.txt','rt', encoding='UTF8')

lstPoketmons = fsPoketmonIndex.readlines()
lstPoketmonData = fsPoketmonData.readlines()
lstPoketmonData2 = list()

# print(lstPoketmons)

for iData in lstPoketmonData :
    lstPoketmonData2.append(iData.strip())


# print(lstPoketmonData2)

for iPoketmon in lstPoketmons :
    strPoketmon = iPoketmon.strip()
    # print(strPoketmon)
    nPoketmon = lstPoketmonData2.count(strPoketmon)
    # print(nPoketmon)
    print(strPoketmon+' : '+str(nPoketmon))

fsPoketmonIndex.close()
fsPoketmonData.close()

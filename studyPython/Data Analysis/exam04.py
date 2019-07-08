# ------------------------------------------------------------
# ------------------------------------------------------------
# 파일을 읽어 리스트로 리턴
# ------------------------------------------------------------
# ------------------------------------------------------------

def fnFileListConverter (strFilePath) :
    fsFile = open(strFilePath,'rt', encoding='UTF8')
    lstRtnList = list()
    lstList = fsFile.readlines()

    for strLine in lstList :
        lstRtnList.append(strLine.strip())

    fsFile.close()

    return lstRtnList

# ------------------------------------------------------------
# ------------------------------------------------------------
# 한글문제해결하기
# ------------------------------------------------------------
# ------------------------------------------------------------

def setKoreanFont() :
    from matplotlib import font_manager, rc
    font_name = font_manager.FontProperties(fname="C:/Windows/Fonts/gulim.ttc").get_name()
    rc("font", family=font_name)
    plt.rcParams["font.size"]=15
    plt.rcParams["figure.figsize"] = 14,8


import matplotlib.pyplot as plt

strPathIdx  = 'D:\git\project\studyPython\Data Analysis\poketmon_index.txt'
strPathData = 'D:\git\project\studyPython\Data Analysis\poketmon_data.txt'

lstPoketmons = fnFileListConverter(strPathIdx)
lstPoketmonData = fnFileListConverter(strPathData)
lstPoketmonCnt = list()

for strPoketmon in lstPoketmons :
    nPoketmonCnt = lstPoketmonData.count(strPoketmon)
    lstPoketmonCnt.append(nPoketmonCnt)    # print(nPoketmon)
    print(strPoketmon+' : '+str(nPoketmonCnt))

setKoreanFont()
plt.subplot(2,1,1)
plt.title("PoketmonCounter v2.0")
plt.bar(lstPoketmons,lstPoketmonCnt,width=0.5,color="gray")
plt.xlabel("Poketmon name")
plt.ylabel("number of Poketmon")

plt.subplot(2,1,2)
plt.plot(lstPoketmons,lstPoketmonCnt)
plt.xlabel("Poketmon name")
plt.ylabel("number of Poketmon")

plt.show()

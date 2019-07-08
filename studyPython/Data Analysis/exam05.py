import pandas as pd
import matplotlib.pyplot as plt

def setKoreanFont() :
    from matplotlib import font_manager, rc
    font_name = font_manager.FontProperties(fname="C:/Windows/Fonts/gulim.ttc").get_name()
    rc("font", family=font_name)
    plt.rcParams["font.size"]=15
    plt.rcParams["figure.figsize"] = 14,8

# titanic_scv_filePath = 'D:\git\project\studyPython\Data Analysis\train.csv'
titanic_scv_filePath = 'train.csv'
titanic_df = pd.read_csv(titanic_scv_filePath)

# print(titanic_df)
# print(titanic_df.info())

# 생존자와 비생존자를 세보기
alive = titanic_df[titanic_df["Survived"] == 1]
dead  = titanic_df[titanic_df["Survived"] == 0]

# print(len(alive),'/',len(titanic_df))
# print(len(dead) ,'/',len(titanic_df))

# plt.bar(['alive','dead'],height=[len(alive),len(dead)])
# plt.show()

#각각 색상분류 후 시각화 해보기
# plt.scatter(alive['PassengerId'],alive['Fare'],color="GREEN")
# plt.scatter(dead['PassengerId'],dead['Fare'],color="RED")
# plt.xlabel('PassengerId')
# plt.ylabel('Fare')
# plt.show()

over_50 = titanic_df[titanic_df['Fare'] >= 50]
under_50 = titanic_df[titanic_df['Fare'] < 50]
alive_over_50 = titanic_df[titanic_df['Fare'] >= 50][titanic_df["Survived"] == 1]
alive_under_50 = titanic_df[titanic_df['Fare'] < 50][titanic_df["Survived"] == 1]
dead_over_50 = titanic_df[titanic_df['Fare'] >= 50][titanic_df["Survived"] == 0]
dead_under_50 = titanic_df[titanic_df['Fare'] < 50][titanic_df["Survived"] == 0]

print(len(over_50),' / ',len(titanic_df),'(',round(len(over_50)/len(titanic_df)*100,2),')')
print(len(under_50),' / ',len(titanic_df),'(',round(len(under_50)/len(titanic_df)*100,2),')')

print(len(alive_over_50),' / ',len(over_50),'(',round(len(alive_over_50)/len(over_50)*100,2),')')
print(len(alive_under_50),' / ',len(under_50),'(',round(len(alive_under_50)/len(under_50)*100,2),')')

setKoreanFont()

plt.subplot(2,1,1)
plt.xlabel('$50미만생존비율')
plt.pie([len(alive_under_50),len(dead_under_50)],colors=['GREEN','RED'],labels=('Alive','Dead'))

plt.subplot(2,1,2)
plt.xlabel('$50이상생존비율')
plt.pie([len(alive_over_50),len(dead_over_50)],colors=['GREEN','RED'],labels=('Alive','Dead'))

plt.show()

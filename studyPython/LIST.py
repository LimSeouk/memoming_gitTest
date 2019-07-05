myList = ["A","B","C","D","E"]

print (myList)

myList[1] = "b"

print (myList)

myList.append("F")

print (myList)

del myList[0:2]

print (myList)

myList.remove("F")

print (myList)

myList.reverse()

print (myList)

myList.sort()

print (myList)

if( "A" in myList ) :
    print (myList)
else :
    myList.insert(0,"A")
    print (myList)

print(myList.count("A"))

print(len( myList ))

# 슬라이싱
for i in myList[0:-1:2] :
    print(i)

string1 = "hi jane."
string2 = "my name is seuk.\n"

string3 = string1 + string2

print(string3)

string4 = string1.join(string2)

print(string4)

print(string1.startswith("hi"))

print(string1.endswith("e"))

print("hi" in string1)

print(string1.index("jane"))

if("hi" in string1) :
    print("position:"+str(string1.index("hi")))
else :
    print(0)

print(string1.strip("jane."))

print(string2.strip()) #개행제거

print(string2.split("is"))

print(string2[3:7])

for i in string1 :
    print(i)

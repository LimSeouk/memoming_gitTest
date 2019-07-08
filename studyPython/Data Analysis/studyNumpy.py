import numpy as np

np_array_A = np.array([1,2,3])
np_array_B = np.array([1,1,1])

np_array_C = np_array_A + np_array_B

print(np_array_C)

list_A = [1,2,3]
list_B = [1,1,1]

list_C = list_A+list_B

print(list_C)

np_array_A = np.array(list_A)

np_array_B = np.array([list_A,list_B],dtype='float')

print(np_array_A.shape)
print(np_array_B.shape)

arr = np.array(range(1,9))
print(arr.shape)
print(arr)
arr2 = arr.reshape(2,2,2)
print(arr2.shape)
print(arr2)


total_sum = arr2.sum()
sum_axis_0 = arr2.sum(axis=0)
sum_axis_1 = arr2.sum(axis=1)
sum_axis_2 = arr2.sum(axis=2)

print('total_sum\n',total_sum)
print('sum_axis_0\n',sum_axis_0)
print('sum_axis_1\n',sum_axis_1)
print('sum_axis_2\n',sum_axis_2)

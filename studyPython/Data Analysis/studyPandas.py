import pandas as pd


num_series = pd.Series([1,2,3,4,5], index=["index_0","index_1","index_2","index_3","index_4"])
num_df = pd.DataFrame([1,2,3,4,5], index=["index_0","index_1","index_2","index_3","index_4"])

print(num_series)
print(num_df)

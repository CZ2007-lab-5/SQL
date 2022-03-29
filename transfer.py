
import pandas as pd
import sys
import re
from pandas.api.types import is_numeric_dtype

# table create order (dependency)
tables = ['PRICE_HISTORY', 'PRODUCT_IN_ORDERS', 'PRODUCT_IN_SHOPS','FEEDBACK','PRODUCTS','COMPLAINTS_ON_SHOPS','COMPLAINTS_ON_ORDERS','COMPLAINTS','EMPLOYEES','ORDERS','USERS','SHOPS']
tables = tables[::-1]
postfix = '.xlsx'
read_file_from_table = lambda table: pd.read_excel(table + postfix)
total_insertion_file = open('insertion.sql', 'w')

for table in tables:
  total_insertion_file.write("DELETE FROM " + table + ";\n")

for table in tables:
  try:
    data = read_file_from_table(table)
  except:
    print(table + " doesn't exist", file = sys.stderr)
    continue
  single_insertion_file = open(table+'.sql', 'w')
  single_insertion_file.write("DELETE FROM " + table + ";\n")
  types = data.dtypes
  col = data.columns
  for i, row in data.iterrows():
    values = "("
    prefix = ""
    for j in range(0, row.size):
      if col[j] == 'Unnamed: 0':
        continue
      values += prefix
      row_j_str = str(row[j])
      if re.match(".*ID$", col[j]):
        values += "\'" + str(int(row[j])) + "\'"
      else:
        if is_numeric_dtype(types[j]):
          values += row_j_str
        else:
          values += "\'" + row_j_str + "\'"
      prefix = ", "
    values += ");\n"
    single_insertion_file.write("INSERT INTO {0} VALUES ".format(table) + values)
    total_insertion_file.write("INSERT INTO {0} VALUES ".format(table) + values)
  single_insertion_file.close()
total_insertion_file.close()
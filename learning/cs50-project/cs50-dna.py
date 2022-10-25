import pandas as pd
from sys import argv, exit

if len(argv) != 3:
    print("Usage: python dna.py data.csv sequence.txt")
    exit(1)

data = pd.read_csv(argv[1])
data = pd.DataFrame(data)


data_2 = open(argv[2], "r")
sequence = data_2.read()
columns = list(data.columns)[1:]

counts = []

for i in range(len(columns)):
    mx = 0
    text = ''.join(columns[i:(i+1)])
    length = len(text)
    j = 0
    temp = 0
    while (j < len(sequence)):
        if sequence[j:j+length] == text:
            j = j + length
            temp = temp + 1
        else:
            j = j + 1
            if temp > mx:
                mx = temp
            temp = 0
    counts.append(mx)

match = ''

for i in range(data.shape[0]):
    tmp = []
    for k in columns:
        tmp.append(data.iloc[i:i+1,1:data.shape[1]][k].item())
        if (tmp == counts):
            match = ''.join(data.iloc[i:i+1].name.item())
            print(data.iloc[i:i+1].name.item())

if len(match) == 0:
    print("No match")
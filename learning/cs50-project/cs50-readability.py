from cs50 import get_string

text = get_string("Text: ")
count = 0
word = 0
sentence = 0

for i in text:
    if i.isalpha() == True:
        count+= 1

for k in text:
    if k.isspace() == True:
        word+= 1
word = word + 1

for j in text:
    if j == "." or j == "?" or j == "!":
        sentence+= 1

index_int = 0.0588*(count/word*100) - 0.296*(sentence/word*100) - 15.8;
if (index_int >= 1 and index_int <= 16):
    print("Grade {}".format(round(index_int)))
elif (index_int < 1):
    print("Before Grade 1")
else:
    print("Grade 16+")
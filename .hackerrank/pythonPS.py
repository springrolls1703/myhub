#List Comprehension
temp = []
name = []
score = []
second_lowest = []
for _ in range(int(input())):
    temp.append([input(),float(input())])
for list in temp:
    name.append(list[0])
    score.append(list[1])
lowest_score = min(score)
score = [x for x in score if x != lowest_score]
for list in temp:
    if list[1] == min(score):
        second_lowest.append(list[0])
second_lowest.sort()
for _ in second_lowest:
    print(_)

#Problem of Percentage Problem
if __name__ == '__main__':
    n = int(input())
    student_marks = {}
    for _ in range(n):
        name, *line = input().split()
        scores = list(map(float, line))
        student_marks[name] = scores
    query_name = input()

student_marks = {'Krishna': [67.0, 68.0, 69.0], 'Arjun': [70.0, 98.0, 63.0], 'Malika': [52.0, 56.0, 60.0]}
query_name = 'Malika'
for keys, values in student_marks.items():
    if keys == query_name:
        print("{:.2f}".format(sum(values) / len(values)))

#try to change



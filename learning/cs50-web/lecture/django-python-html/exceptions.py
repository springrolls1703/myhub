import sys

try:
    x = int(input("x: "))
    y = int(input("y: "))
except ValueError:
    print("Error value input")
    sys.exit(1)

try:
    result = x / y
except ZeroDivisionError:
    print("Error: Cannot devided by 0.")
    sys.exit(1)

print(f"{x} / {y} is {result}")
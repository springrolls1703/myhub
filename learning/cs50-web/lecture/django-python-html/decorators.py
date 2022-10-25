def announce(f):
    def wrapper():
        print(f"the function {f} is running...")
        f()
        print(f"done with the function {f}")
    return wrapper

@announce
def hello():
    print("hello world!")

hello()
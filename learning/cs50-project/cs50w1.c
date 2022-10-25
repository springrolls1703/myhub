// #include <stdio.h>

// int main(void)
// {
//     printf("hello, world\n");
// }

//$ clang cs50wq.c
//$ a.out
//$ clang -o test cs50.c
//$ 

include <cs50.h>
include <stdio.h>

int main(void)
{
    string answer = get_string("What's your name?\n");
    printf("hello, %s\n", answer);
}

// place holder: %s string, %c char, %f float, double, %i int, %li long

// you can use make {{file.name}}


// qualifier: unassigned, long, short, con

// char
// void is a type but not a data type
int number; // declaration
number = 17; // assignment
char letter; // declaration
letter = 'H'; // assignment
int number = 17; // initialization

// operators
// logical AND ( && ) OR ( || ) NOT ( ! ) equality ( == ) inequality ( != )

// conditional statement
if boolean_expression
else if (/* condition */)
{
    /* code */
}
else if (/* condition */)
{
    /* code */
}
if

// switch use discrete cases to make decisions


// while loop use when you want a loop to repeat an unknown number of times (bolean expression for example)
while (/* condition */)
{
    /* code */
}

// for loop are used to repeat the body loop a specified number of times

for (size_t i = 0; i < count; i++)
{
    /* code */
}

// command line

rm -r to delete the entire directory
cp -r to copy the entire directory. by recursively look into the whole directory 

chmod
ln
touch
rmdir
man
diff
sudo
clear
telnet

// Pseudocode
// get a Positive Integer
int n;
do
{
    n = get_int("Positive Number: ");
}
while (n < 1);


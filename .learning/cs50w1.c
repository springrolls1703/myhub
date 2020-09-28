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


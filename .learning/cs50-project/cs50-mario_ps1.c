#include <cs50.h>
#include <stdio.h>

int n;

int main()
{
    do
    {
       n = get_int("Height: ");
    } while((n < 1) || (n > 8));
    if ((n > 0) && (n < 9))
    {
        for (int t = 1; t < (n+1); t++)
        {
            for (int i = t; i < n; i++)
            {
                printf(" ");
            }
            for (int k = t; k - 1> 0; k = k -1)
            {
                printf("#");
            }
        printf("#\n");
        }
    } else printf("error");
}



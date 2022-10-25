#include <cs50.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

string code;
int main(int argc, string argv[])
{
    if (argc != 2)
    {
        printf("Usage: ./substitution key.\n");
        return 1;
    }
    else
    {
        if (strlen(argv[1]) != 26)
        {
            printf("key must contains at least 26 keys.\n");
            return 1;
        }
        else
        {
            for (int x = 0; x < 26; x++)
            {
                if (isalpha(argv[1][x]) == 0)
                {
                    printf("Usage: ./substitution key.\n");
                    return 1;
                }
                else
                {
                    for (int t = x + 1 ; t < strlen(argv[1]) ; t++)
                    {
                        if (toupper(argv[1][x]) == toupper(argv[1][t])) // checking repeated element
                        {
                            printf("Key must not contain repeated alphabets.\n");
                            return 1;
                        }
                    }
                }
            }
            code = argv[1];
        }
    }
    string plain_text = get_string("plaintext: ");
    printf("ciphertext: ");
    string lowercase = "abcdefghijklmnopqrstuvwxyz";
    string uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int len = strlen(plain_text);
    char cipher_text[len];
    for (int i = 0; i < len; i++)
    {
        if(isalpha(plain_text[i]) == 0)
        {
            printf("%c",plain_text[i]);
            
        }
        else if (isupper(plain_text[i]))
        {
            for (int k = 0; k < 26; k++)
            {
                if (plain_text[i] == uppercase[k])
                {
                    if (isupper(code[k]))
                    {
                        printf("%c",code[k]);
                    }
                    else
                    {
                        printf("%c",toupper(code[k]));
                    }
                }
            }
        }
        else
        {
            for (int j = 0; j < 26; j++)
            {
                if (plain_text[i] == lowercase[j])
                {
                    if (islower(code[j]))
                    {
                        printf("%c",code[j]);
                    }
                    else
                    {
                        printf("%c",tolower(code[j]));
                    }
                }
            }
        }
    }
    printf("\n");
    return 0;
}

#include <stdio.h>
#include <string.h>
#include <cs50.h>
#include <ctype.h>
#include <math.h>

int is_letter(char text);
int main(void)
{
    string text = get_string("Text: ");
    int count = 0;
    int word = 0;
    for (int i = 0; i < strlen(text); i ++)
    {
        if(text[i] != '\0')
        {
            count = count + is_letter(text[i]);
        }
    }
    for (int k = 0; k < strlen(text); k ++)
    {
        if(isspace(text[k]) && text[k] != '\n')
        {
            word++;
        }
    }
    word = word + 1;
    int sentence = 0, j=0;
    while(text[j] != '\0')
    {
        if(text[j] == '.' || text[j] == '?' || text[j] == '!')
        {
            sentence++;
            j++;
        }
        else
        {
            j++;
        }
    }
    printf("%i\n", count);
    printf("%i\n", word);
    printf("%i\n", sentence);
    float avg_letter = (float) count / word  * 100;
    float avg_sentence = (float) sentence / word * 100;
    printf("%f\n", avg_letter);
    printf("%f\n", avg_sentence);
    float ind = 0.0588*avg_letter - 0.296*avg_sentence - 15.8;
    int index_int = round(ind);
    if (index_int >= 1 && index_int <= 16)
    {
        printf("Grade %i\n", index_int);
    }
    else if (index_int < 1)
    {
        printf("Before Grade 1\n");
    }
    else
    {
        printf("Grade 16+\n");
    }
}

int is_letter(char text)
{
    if (isalpha(text) != 0)
    {
        return 1;
    }
    return 0;
}


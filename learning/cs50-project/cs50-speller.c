// Implements a dictionary's functionality


#include <stdbool.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <strings.h>
#include <stdio.h>
#include "dictionary.h"
// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH];
    struct node *next;
}
node;

// Number of buckets in hash table
const unsigned int N = 26;
int sumwords = 0;

// Hash table
node *table[N];

// Returns true if word is in dictionary else false
bool check(const char *word)
{
    node *cursor = table[hash(word)];
    if (strcasecmp(cursor->word, word) == 0)
    {
        return true;
    }
    while (cursor->next != NULL)
    {
        cursor = cursor->next;
        if (strcasecmp(cursor->word, word) == 0)
        {
            return true;
        }
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    int n = (int) tolower(word[0]) - 97;
    return n;
}

// Loads dictionary into memory, returning true if successful else false
bool load(const char *dictionary)
{
    FILE *file = fopen(dictionary, "r");
    // if (file == NULL)
    // {
    //     return false;
    // }
    char *dword = malloc(LENGTH);
    if (dword == NULL)
    {
        return false;
    }
    while (fscanf(file,"%s", dword) != EOF)
    {
        node *n = malloc(sizeof(node));
        if(n == NULL)
        {
            return false;
        }
        strcpy(n->word, dword);
        sumwords++;
        n->next = table[hash(dword)];
        table[hash(dword)] = n;
    }
    fclose(file);
    free(dword);
    return true;
}

// Returns number of words in dictionary if loaded else 0 if not yet loaded
unsigned int size(void)
{
    return sumwords;
}

// Unloads dictionary from memory, returning true if successful else false
bool unload(void)
{
    node *tmp;
    node *cursor;
    for (int i = 0; i < N; i++)
    {
        if(table[i] == 0)
        {
            continue;
        }
        cursor = table[i];
        tmp = cursor;
        while (cursor->next != NULL)
        {
            cursor = cursor->next;
            free(tmp);
            tmp = cursor;
        }
        free(cursor);
    }
    return true;
}

#include <cs50.h>
#include <stdio.h>
#include <string.h>

// Max voters and candidates
#define MAX_VOTERS 100
#define MAX_CANDIDATES 9

// preferences[i][j] is jth preference for voter i
int preferences[MAX_VOTERS][MAX_CANDIDATES];

// Candidates have name, vote count, eliminated status
typedef struct
{
    string name;
    int votes;
    bool eliminated;
}
candidate;

// Array of candidates
candidate candidates[MAX_CANDIDATES];

// Numbers of voters and candidates
int voter_count;
int candidate_count;

// Function prototypes
bool vote(int voter, int rank, string name);
void tabulate(void);
bool print_winner(void);
int find_min(void);
bool is_tie(int min);
void eliminate(int min);

int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: runoff [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX_CANDIDATES)
    {
        printf("Maximum number of candidates is %i\n", MAX_CANDIDATES);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i].name = argv[i + 1];
        candidates[i].votes = 0;
        candidates[i].eliminated = false;
    }

    voter_count = get_int("Number of voters: ");
    if (voter_count > MAX_VOTERS)
    {
        printf("Maximum number of voters is %i\n", MAX_VOTERS);
        return 3;
    }

    // Keep querying for votes
    for (int i = 0; i < voter_count; i++)
    {

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            // Record vote, unless it's invalid
            if (!vote(i, j, name))
            {
                printf("Invalid vote.\n");
                return 4;
            }
        }

        printf("\n");
    }
    
    // Keep holding runoffs until winner exists
    while (true)
    {
        // Calculate votes given remaining candidates
        tabulate();

        // Check if election has been won
        bool won = print_winner();
        if (won)
        {
            break;
        }

        // Eliminate last-place candidates
        int min = find_min();
        bool tie = is_tie(min);

        // If tie, everyone wins
        if (tie)
        {
            for (int i = 0; i < candidate_count; i++)
            {
                if (!candidates[i].eliminated)
                {
                    printf("%s\n", candidates[i].name);
                }
            }
            break;
        }

        // Eliminate anyone with minimum number of votes
        eliminate(min);

        // Reset vote counts back to zero
        for (int i = 0; i < candidate_count; i++)
        {
            candidates[i].votes = 0;
        }
    }
    return 0;
}

// Record preference if vote is valid
bool vote(int voter, int rank, string name)
{
    int index  = 0;
    for (int x = 0; x < candidate_count; x++)
    {
        if(strcmp(name, candidates[x].name) == 0)
        {
            preferences[voter][rank] = x;
            index++;
            break;
        }
    }
    if(index == 0)
    {
        return false;
    }
    else
    {
        return true;
    }
}

// Tabulate votes for non-eliminated candidates
void tabulate(void)
{
    for(int y = 0; y < voter_count; y++)
    {
        for(int z = 0; z < candidate_count; z++)
        {
            if(candidates[preferences[y][z]].eliminated == false)
            {
                candidates[preferences[y][z]].votes++;
                break;
            }
        }
    }
    return;
}

// Print the winner of the election, if there is one
bool print_winner(void)
{
    int mother = 2;
    int majority = voter_count/mother;
    for(int t = 0; t < candidate_count; t++)
    {
        if((candidates[t].votes > majority) && (candidates[t].eliminated == false))
        {
            printf("%s\n", candidates[t].name);
            return true;
        }
    }
    return false;
}

// Return the minimum number of votes any remaining candidate has
int find_min(void)
{
    int location_0 = 0;
    for(int t = 0; t < candidate_count; t++)
    {
        if  ((candidates[t].votes < candidates[location_0].votes) && (candidates[t].eliminated == false))
        {    
            location_0 = t;
        }
        else if ((candidates[t].eliminated == true) && (location_0 == 0))
        {
            location_0 = t + 1;
        }
    }
    return candidates[location_0].votes;
}

// Return true if the election is tied between all candidates, false otherwise
bool is_tie(int min)
{
    int remaining = 0;
    int tie = 0;
    for(int k = 0; k < candidate_count; k++)
    {
        if(candidates[k].eliminated == false)
        {
            remaining++;
        }
    }
    for(int l = 0; l < candidate_count; l++)
    {
        if ((candidates[l].votes == min) && (candidates[l].eliminated == false))
        {
            tie++;
        }
    }
    if(tie == remaining)
    {
        return true;
    }
    return false;
}

// Eliminate the candidate (or candidates) in last place
void eliminate(int min)
{
    for(int g = 0; g < candidate_count; g++)
    {
        if((candidates[g].eliminated == false) && (candidates[g].votes == min))
        {
            candidates[g].eliminated = true;
        }
    }
    return;
}

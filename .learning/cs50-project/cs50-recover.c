#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <strings.h>
#include <stdbool.h>

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: ./recover image\n");
        return 1;
    }
    FILE *file = fopen(argv[1], "r");
    if (file == NULL)
    {
        return false;
    }
    unsigned char *buffer = malloc(512);
    int jpeg_count = 0;
    FILE *image = NULL;
    bool found_jpeg = false;
    char *filename = malloc(sizeof(char)*7);
    // char filename[8];
    // char *p = filename;
    while (fread(buffer, 1, 512, file))
    {
        if (found_jpeg == false)
        {
            if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
            {
                sprintf(filename, "%03d.jpg",jpeg_count);
                image = fopen(filename, "w");
                if (image == NULL)
                {
                    fclose(file);
                    return false;
                }
                fwrite(buffer, 512, 1, image);
                found_jpeg = true;
                jpeg_count++;
            }
            continue;
        }
        else if (found_jpeg == true)
        {
            if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
            {
                sprintf(filename, "%03d.jpg",jpeg_count);
                image = fopen(filename, "w");
                if (image == NULL)
                {
                    fclose(file);
                    return false;
                }
                fwrite(buffer, 512, 1, image);
                jpeg_count++;
            }
            else
            {
                fwrite(buffer, 512, 1, image);
            }
        }
    }
    fclose(image);
    fclose(file);
    free(buffer);
    free(filename);
    return 0;
}


// 1. open memory card 2. look for the beginning 3. Open a new JPEG file 4. write 512 bytes until a new JPEG file is found
// FILE file fopen
// JPEGs distinct headers: Oxff, Oxd8, Oxff, and Ox..
// fread(data,size,number,inptr) 
// buffer[0] == Oxff
// (buffer[3] & Oxf0) == Oxe0
// sprintf(filename, "%30i.jpg",2)
// FILE *img = fopen(filename, "w")
// fwrite(data,size,number,outptr)

// Open Memory Card
// Repeat Until End
// Read 512 bytes into a buffer
// If start of new JPEG
// It first JPEG
// Else
// if already found JPEG
// Close any remain file
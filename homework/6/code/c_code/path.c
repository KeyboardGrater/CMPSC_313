#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// Allows returning of buffer and buffer_size

void strcpy_func (char * old_buffer, char * new_buffer, unsigned int buffer_size) {
    int i = 0;
    char temp;

    // Half the buffer size, so buffer_size is the old buffer size
    buffer_size = buffer_size >> 1;

    while (true) {
        // Exit conditional
        if (i == buffer_size) {break;}

        // Copy over
        temp = old_buffer[i];
        new_buffer[i] = temp;

        // Increment iterator
        i = i + 1;
    }

    return;
}

char * read_file (FILE * file_pointer, unsigned int buffer_size) {
    const unsigned int element_size = sizeof(char);
    char * buffer = NULL;
    char * old_buffer = NULL;
    unsigned int bytes_just_read = 0;
    unsigned int total_bytes_read = 0;
    unsigned int bytes_to_read = 0;

    // Allocate memory for the buffer
    buffer = (char *) malloc (buffer_size + 1);
    if (buffer == NULL) {return NULL;}
    
    // Read the file
    bytes_just_read = fread(buffer, element_size, buffer_size, file_pointer);
    
    // Update total_bytes_read
    total_bytes_read = bytes_just_read;
    
    // Check if the EOF was reached
    if (feof(file_pointer) <= 0) {
        
        // Else, loop over creating new buffers and reading
        while (true) {
            // Allocate new buffer and then copy old buffer into the new buffer
            old_buffer = buffer;                // Make buffer addr to old buffer addr
            buffer_size = buffer_size << 1;      // Doubles the buffer_size
            buffer = (char *) malloc (buffer_size + 1);      // Allocate a new buffer that is twice the size of the old
            if (buffer == NULL) {
                free (old_buffer);
                return(NULL);
            }

            strcpy_func(old_buffer, buffer, buffer_size);               // Copy old_buffer into new_buffer;
            
            // Release the old_buffer memory
            free(old_buffer);   

            // Calculate the bytes to read
            bytes_to_read = buffer_size - total_bytes_read;
            
            // Read the file
            bytes_just_read = fread(buffer + total_bytes_read,element_size,bytes_to_read, file_pointer);
            
            // Update total_bytes_read
            total_bytes_read = total_bytes_read + bytes_just_read;
            
            // Exit conditional
            if (bytes_just_read < bytes_to_read) {break;}
        }
    }

    buffer[total_bytes_read] = '\0'; 
    return buffer;
}

void print_file (char * buffer) {
    int i = 0;
    char char_to_print;


    while (true) {
        
        // Get the character to print
        char_to_print = buffer[i];
        
        // Conditional Exit
        if (char_to_print == '\0') {break;}
        
        // Print character 
        printf("%c", char_to_print);

        // Increment iterator
        i = i + 1;
    }
}

int main () {
    char file_path [] = "../text_files/input_path.txt";               // File path
    FILE * file_pointer;                                        // File pointer
    unsigned int buffer_size = 256;
    char * buffer;


    // Open file
    file_pointer = fopen(file_path, "r");
    
    if (file_pointer == NULL) {
        printf("File failed to open correctly\n");
        return 1;
    }

    // Read file, then put into buffer
    buffer = read_file(file_pointer, buffer_size);

    // Close the read file
    fclose(file_pointer);

    // Print the file into terminal
    print_file(buffer);

    // Free memory allocated to buffer
    free(buffer);

    return 0;
}
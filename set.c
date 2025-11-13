#include <stdio.h>
#include <stdbool.h>

// Global Variables
enum {INTEGERSET_ARRAY_SIZE = 100};         // Size of array (0-99)


struct IntegerSet {
    int a[INTEGERSET_ARRAY_SIZE];
};

// Zeros out the array
void constructor (struct IntegerSet * set_pointer) {
    int i = 0;
    const unsigned int LAST_INDEX = INTEGERSET_ARRAY_SIZE - 1;

    while (true) {
        if (i > LAST_INDEX) {break;}
        set_pointer -> a[i] = 0;
        i = i + 1;
    }
}

unsigned int which_array_to_choose () {
    unsigned int array_to_modify;

    
    // Get user input for which array they would like to modify.
    while (true) {
        // Ask the user which array would they like to modify.
        printf("Which array would you like to chose.\nFor array one enter 1, for array two, enter 2. And if you would like to go back, enter 3.\n"); 
        
        scanf("%u", &array_to_modify);

        if (array_to_modify == 1) {
            break;
        }
        else if (array_to_modify == 2) {
            break;
        }
        else if (array_to_modify == 3) {
            break;
        }
        // Else (re-loop)
    }

    // Return the user input
    return array_to_modify;
}

// Get the user input of which number they would like to modify (insert or delete).
unsigned int number_to_modify () {  
    int user_number;
    const unsigned int LAST_INDEX_OF_ARRAY = INTEGERSET_ARRAY_SIZE - 1;
    
    /// ----------------- Might want to add something here just in case if the user wants to exit the program at this stage.

    // Check to see if the number is within the bounds, if not keep getting input until it is.
    while (true) {
        // Get user input
        printf("Please pick a number between 0 - 99\n");
        scanf("%i", &user_number);
    
        // Check if not within the bounds
        if (user_number < 0) {continue;}
        else if (user_number > LAST_INDEX_OF_ARRAY) {continue;}
        else {break;}                       // Exit loop if within the bounds
    }
    unsigned int user_number_unsigned = user_number;
    return (user_number_unsigned);
}

void insert_element (struct IntegerSet * set_pointer) {
    unsigned int index;

    // Call user input function
    index = number_to_modify();

    // insert element into the array
    set_pointer -> a[index] = 1;
}
void delete_element (struct IntegerSet * set_pointer) {
    unsigned int index;

    // Call user input function
    index = number_to_modify();

    // Delete number from array at index
    set_pointer -> a[index] = 0;
}

// Could combine insert and delete into one, and have 0 or 1 in the argument calls.

void print_set (struct IntegerSet * set_pointer) {
    int i = 0;
    const unsigned int LAST_INDEX_OF_ARRAY = INTEGERSET_ARRAY_SIZE - 1;

    // Loop over set and print at index
    while (true) {
        if (i > LAST_INDEX_OF_ARRAY) {break;}        // Condition to check if we can exit the loop yet

        unsigned int value_at_index = set_pointer -> a[i];
        printf("%u ", value_at_index);                          // Could probally be a byte.

        i = i + 1;                          // iterate through loop
    }
}

void equals (struct IntegerSet * array_1_pointer, struct IntegerSet * array_2_pointer) {
    int i = 0;
    const unsigned int LAST_INDEX = INTEGERSET_ARRAY_SIZE - 1;

    // Loop over
    while (true) {
        // Conditional to exit loop
        if (i > LAST_INDEX) {break;}


        // Get the values at the index's of i
        unsigned int array_1_value = array_1_pointer -> a[i]; 
        unsigned int array_2_value = array_2_pointer -> a[i];

        // Compare the values
        if (array_1_value != array_2_value) {
            printf("False\n");
            return;
        }

        // Increment iterator
        i = i + 1;
    }

    printf("True\n");
    return;
}

void union_of (struct IntegerSet * array_1_pointer, struct IntegerSet * array_2_pointer) {
    int i = 0;
    unsigned int LAST_INDEX_OF_ARRAY = INTEGERSET_ARRAY_SIZE - 1;
    struct IntegerSet union_array;
    unsigned int union_value;
    
    // Loop through them
    while (true) {
        // check if we have passed last index
        if (i > LAST_INDEX_OF_ARRAY) {break;}
        
        // Get there values at i
        unsigned int array_1_value = array_1_pointer -> a[i];
        unsigned int array_2_value = array_2_pointer -> a[i];

        // Case 0 = 0 + 0, Case 1 = 1 + 0 or 0 + 1, Case 2 = 1 + 1. Don't have to do any work in case 0 or 1, only 2
        // Case 2: (1 + 1) = 2
        
        union_array.a[i] = array_1_value || array_2_value;

        i = i + 1;                          // iterator 
    }

    // Call print function with this union array as the argument
    print_set(&union_array);
}

void intersection_of (struct IntegerSet * array_1_pointer, struct IntegerSet * array_2_pointer) {
    int i = 0;
    unsigned int LAST_INDEX_OF_ARRAY = INTEGERSET_ARRAY_SIZE - 1;
    struct IntegerSet intersection_array;
    unsigned int intersection_value;

    // Loop 
    while (true) {
        if (i > LAST_INDEX_OF_ARRAY) {break;}                   // Checks to see if we passed the last index

        // Get the values at the index
        unsigned int array_1_value = array_1_pointer -> a[i];
        unsigned int array_2_value = array_2_pointer -> a[i];

        // Intersect the two values         
        // Case 0: 0 AND 0 = 0, Case 1: 0 AND 1 or 1 AND 0 = 0, Case 2: 1 AND 1 = 1
        
        intersection_array.a[i] = array_1_value && array_2_value;

        i = i + 1;                          // iterator
    }

    print_set(&intersection_array);
}



int main () {
    struct IntegerSet array_1;
    struct IntegerSet array_2;
    unsigned int operation_choice;
    unsigned int array_choice;


    // Fill in the arrays (Simulates the constructor)
    constructor(&array_1);
    constructor(&array_2);

    // Loop for options (1 = union, 2 = intersection, 3 = insert, 4 = delete, 5 = print_set, 6 = equals, 7 = exit)
    // 3,4,5 all need to ask if the user wants to ask for array 1 or array 2

    while (true) {
        // Get user input for what operation they want to do.
        printf("Please pick a operation to perform.\n1: Union of two sets\n2: Intersection of two sets\n3: Insertion on a set\n4: Deletion on a set\n5: Print a set\n6: Check to see if two sets are equal\n7: Exit\n\n");
        scanf("%u", &operation_choice);
        
        // Check for 7 (i.e. if user wants to exit loop)
        switch (operation_choice) {
            
            case 1:
                union_of(&array_1, &array_2);
                break;
            
            case 2:
                intersection_of(&array_1, &array_2);
                break;

            // Insert
            case 3:
                while (true) {
                    // Case 1, 2, and 3, will all make the operations menu appear again. 1 and 2 does a action beforehand, where 3 skips that action.
                    // The default case (when not 1, 2, nor 3) it repeates the array_choice. Still within insert element action choice.
                    
                    array_choice = which_array_to_choose();

                    switch (array_choice) {
                        case 1:
                            insert_element(&array_1);
                            goto repeat_operation_choice;
                        case 2:
                            insert_element(&array_2);
                            goto repeat_operation_choice;
                        case 3:
                            goto repeat_operation_choice;
                    }
                }

            // Delete
            case 4:
                while (true) {
                    // Case 1, 2, 3, will all make the operations menu appear again. 1 and 2 does a action beforehand, where 3 skips that action.
                    // The default case (when not 1, 2, nor 3) repeats the array_choice. Still within delete element action choice.
                    
                    array_choice = which_array_to_choose();

                    switch (array_choice) {
                        case 1:
                            delete_element(&array_1);
                            goto repeat_operation_choice;
                        case 2:
                            delete_element(&array_2);
                            goto repeat_operation_choice;
                        case 3:
                            goto repeat_operation_choice;
                    }
                }

            // (5) Print Set
            case 5:
                while (true) {
                    // Case 1, 2, 3, will all make the operations menu appear again. 1 and 2 does a action beforehand, while 3 does no actions.
                    // The default case (when not 1, 2, nor 3) repeats the array_choice, but still within the print action choice.
                    
                    array_choice = which_array_to_choose();

                    switch (array_choice) {
                        case 1:
                            print_set(&array_1);
                            goto repeat_operation_choice;
                        case 2:
                            print_set(&array_2);
                            goto repeat_operation_choice;
                        case 3:
                            goto repeat_operation_choice;
                    }
                }
        
            case 6:
                equals(&array_1, &array_2);
                break;

            case 7:
                goto exit_loop;
            // ELSE 
            default:
                goto repeat_operation_choice;
        }
        repeat_operation_choice:
    }
    exit_loop:
    
    return 0;
}

// Test Trials

// For Insert, Delete: Input these number:
// Ones that will work: 0,1, 50, 98, 99 => (min),(min + 1), (max/2), (max - 1), (max)
// Ones that won't work: -1, -2, -99, 100, 101, 200

// Bugs or Oddities:
// -- It failed when I did inser >> array 2 >> 0111 -> Because it scanned it in as 73, weird issue.

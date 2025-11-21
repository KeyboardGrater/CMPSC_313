#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

enum {READ_FILE_AMMOUNT = 256};
enum {ACCOUNT_ID_MAX_SIZE = 10};
enum {BALANCE_MAX_SIZE = 10};

typedef struct {
    unsigned int account_number;
    double annual_interest_rate;
    double savings_balance;
} SavingsAccount;

SavingsAccount * new_account (unsigned int account_number, double annual_interest_rate, double savings_balance) {
    // Allocate memory
    SavingsAccount * new_account = (SavingsAccount *) malloc (sizeof(SavingsAccount));

    // Fill in the values
    new_account->account_number = account_number;
    new_account->annual_interest_rate = annual_interest_rate;
    new_account->savings_balance = savings_balance;
}

void print_balance (SavingsAccount * account) {
    double balance;

    balance = account->savings_balance;

    printf("New Balance: ");
    printf("%lf", balance); 
    printf("\n");
}

void calculate_monthly_interest (SavingsAccount * account) {
    double interest;
    double balance;
    double annual_interest_rate;
    double monthly_interest;

    annual_interest_rate = account->annual_interest_rate;
    balance = account->savings_balance;

    interest = annual_interest_rate * balance;

    monthly_interest = interest / 12;

    balance = balance + monthly_interest;

    account->savings_balance = balance;

    // Call printBalance
    print_balance(account);
} 

void set_interest_rate (SavingsAccount * account, double annual_interest_rate) {
    account->annual_interest_rate = annual_interest_rate;
}

void read_balance_file (FILE * file_pointer, int which_to_read) {
    char read_buffer [READ_FILE_AMMOUNT];
    unsigned int read_bytes;
    int i;
    char current_value;
    char sub_buffer [READ_FILE_AMMOUNT];
    unsigned int front_pointer = 0;         // This might not be needed in mips
    unsigned int bytes_read;
    int j = 0;                              // This might not be need in mips
    unsigned int id_or_balance = 0;
    char account_id [ACCOUNT_ID_MAX_SIZE];
    char balance [BALANCE_MAX_SIZE];
    
    // Reads the entire file (up until the byte limit) and then stores it into the buffer, and stores the number of bytes that were read
    bytes_read = fread(read_buffer, sizeof(char), READ_FILE_AMMOUNT - 1, file_pointer);
    // printf("%u\n", bytes_read);

    i = 0;

    // Loop over the buffer
    while (true) {
        // Exit Loop Condition: Checks if we have looped over the number of bytes read 
        if (i == bytes_read) {break;}
        
        // Load the value at i in the buffer
        current_value = read_buffer[i];
        sub_buffer[j] = current_value;
        
        // Check for the newline character
        if (current_value == 0x0A) {
            // Replace it with '/0'
            sub_buffer[j] = 0x00;                     // Do I need this, probably
            j = 0;
            // printf("%s\n", sub_buffer);
            
            switch (id_or_balance) {
                case 0:
                    strcpy(account_id, sub_buffer);
                    id_or_balance = 1;
                    printf("%s\n", account_id);
                    break;
                case 1:
                    strcpy(balance, sub_buffer);
                    id_or_balance = 0;
                    printf("%s\n", balance);
                    break; 
            }
        }
        else {
            j = j + 1;
        }
        i = i + 1;
    }

    // I can trim the string memory but just moving the address to the current "i" once I find the new line
}


int main () {
    FILE * file_pointer;
    char balance_file_path [] = "../mips/savings_file.txt";
    int which_to_read = 0;

    // Open the file
    file_pointer = fopen(balance_file_path, "r");
    // Check if any errors occured when opening the file
    if (file_pointer == NULL) {
        printf("An error occurred when trying to open up the input file");
    }

    // Read the file
    read_balance_file(file_pointer, which_to_read);
    
    // Declare Accounts and call constructor
    SavingsAccount * account_1 = new_account(1, 0.03, 2000.00);
    SavingsAccount * account_2 = new_account(2, 0.03, 3000.00);

    // Calculate monthly interest
    calculate_monthly_interest(account_1);
    calculate_monthly_interest(account_2);

    // Change annual interest rate 
    set_interest_rate(account_1, 0.04);
    set_interest_rate(account_2, 0.04);

    // Print the new balance
    calculate_monthly_interest(account_1);
    calculate_monthly_interest(account_2);

    return 0;
}
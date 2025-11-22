#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>


// enum {READ_FILE_AMMOUNT = 256};
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

    return new_account;
}

SavingsAccount ** read_balance_file (FILE * file_pointer, int * num_accounts, unsigned const int READ_FILE_AMMOUNT) {
    char read_buffer [READ_FILE_AMMOUNT];
    char sub_buffer [READ_FILE_AMMOUNT];
    char temp_buffer [READ_FILE_AMMOUNT];
    unsigned int i = 0;
    unsigned int j = 0;
    unsigned int bytes_read;
    unsigned int count = 0;
    unsigned int id_or_balance = 0;
    unsigned int account_id;
    char * double_ptr;
    char current_charcter;
    double balance;
    

    // Read the file into a buffer, and keep track of the number of bytes that were read
    bytes_read = fread(read_buffer, sizeof(char), READ_FILE_AMMOUNT, file_pointer);

    // Find out how much memory needs to be allocated
    while (true) {
        // Exit condition
        if (i == bytes_read) {break;}

        // Check if the current charcter is a newline, if so increment num_accounts
        current_charcter = read_buffer[i];
        if (current_charcter == 0x0A) {
            count = count + 1;
        }

        // Iterator incrementaction 
        i = i + 1;
    }

    // Check to see if the last charcter in the buffer is not a newline. If not add a newline charcter so that the checker works for down below
    // and then add one more to the account number
    if (current_charcter != 0x0A) { 
        read_buffer[bytes_read] = 0x0A;                         // Assuming READ_FILE_AMMOUNT > bytes_read
        bytes_read = bytes_read + 1;
        count = count + 1;
    }

    // Allocate the necessary amount of memory
    SavingsAccount ** account = malloc(count * sizeof(SavingsAccount *));

    i = 0;      
    count = 0;                                                
    // Loop over the buffer and parse the data
    while (true) {
        // Exit Condition
        if (i == bytes_read) {break;}

        // Get the current charcter
        current_charcter = read_buffer[i];

        // Check to see if the charcter is a newline
        if (current_charcter == 0x0A) {
            sub_buffer[j] = 0x00;
            // Set j back to zero, beacuse we want to "refresh" the sub_buffer
            j = 0;
            // Find out if it is currently looking at the account_id or the balance
            switch(id_or_balance) {
                case 0:
                    strcpy(temp_buffer, sub_buffer);
                    id_or_balance = 1;
                    break;
                case 1:
                    account_id = atoi(temp_buffer);
                    balance = strtod(sub_buffer,&double_ptr);
                    account[count] = new_account(account_id, -1.0, balance);
                    count = count + 1;
                    id_or_balance = 0;
                    break;
            }
        }
        else {
            // Append or replace the charcter at j in the sub_buffer
            sub_buffer[j] = current_charcter;
            j = j + 1;
        }
        
        // Iterator update
        i = i + 1;
    }

    // Updates the number of accounts
    *num_accounts = count;

    return account;
}

SavingsAccount * look_up_account (SavingsAccount ** account, int account_id_looking_up, int num_accounts) {
    int i = 0;
    while (true) {
        if (i == num_accounts) {break;}

        if (account_id_looking_up == account[i]->account_number) {
            return account[i];
        }

        i = i + 1;
    }
    // When it can not find the account in the database
    return NULL;
}

void update_balance (SavingsAccount * account, double modification) {
    account->savings_balance = account->savings_balance + modification; 
}

void read_transaction_file (FILE * file_pointer, SavingsAccount ** account, int * num_accounts, unsigned const READ_FILE_AMMOUNT) {
    char read_buffer [READ_FILE_AMMOUNT];
    char sub_buffer [READ_FILE_AMMOUNT];
    char temp_buffer [READ_FILE_AMMOUNT];
    unsigned int i = 0;
    unsigned int j = 0;
    unsigned int bytes_read;
    unsigned int id_or_transaction = 0;
    unsigned int account_id;
    double modification;
    
    char * double_pointer;
    char current_charcter;
    

    // Read the file into the read_buffer, and keep track of how many bytes it read
    bytes_read = fread(read_buffer, sizeof(char), READ_FILE_AMMOUNT - 1, file_pointer);

    // Check to see if the last line is not a newline, if it isn't add a newline to it
    current_charcter = read_buffer[bytes_read];
    if (current_charcter != 0x0A) {
        read_buffer[bytes_read] = 0x0A;
        bytes_read = bytes_read + 1;
    }

    // Loop and parse the data and then modify it, if that is a possibility
    i = 0;
    while(true) {
        // Exit condition
        if (i == bytes_read) {break;}

        current_charcter = read_buffer[i];

        // Check to see if we got all the data in a line
        if (current_charcter == 0x0A) {
            sub_buffer[j] = 0x00;
            j = 0;
            switch(id_or_transaction) {
                case 0:
                    id_or_transaction = 1;
                    strcpy(temp_buffer, sub_buffer);
                    break;
                case 1:
                    id_or_transaction = 0;
                    account_id = atoi(temp_buffer);
                    
                    // Check to see if the account exists
                    SavingsAccount * current_account = look_up_account(account, account_id, *num_accounts);
                    if (current_account == NULL) {
                        printf("No account found\n");
                        break;
                    }
                    modification = strtod(sub_buffer, &double_pointer);
                    update_balance(current_account, modification);
                    
                }
            
        }
        else {
            // Append or replace at j in the sub_buffer
            sub_buffer[j] = current_charcter;
            j = j + 1;
        }
        // Increment iterator
        i = i + 1;
    }
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


void print_testing_info_helper(SavingsAccount * account) {
    printf("%u %lf %lf\n", account->account_number, account->annual_interest_rate, account->savings_balance);
}
void print_testing_info (SavingsAccount ** account, int * num_accounts) {
    int i = 0;
    while (true) {
        if (i >= (*num_accounts)) {break;}

        print_testing_info_helper(account[i]);

        i = i + 1;
    }
}

int main () {
    FILE * file_pointer;
    char balance_file_path [] = "../mips/balance.txt";
    // char transaction_file_path [] = "../mips/transactions.txt";
    char transaction_file_path [] = "../mips/copy_transactions.txt";
    unsigned const int READ_FILE_AMMOUNT = 256;
    int num_accounts = 0;
    int i;

    double annual_interest_rate = 0.03;


    // --------------- 1. Setting up the accounts --------------- //
    
    // Open the balance file
    file_pointer = fopen(balance_file_path, "r");
    if (file_pointer == NULL) {
        perror("The balance file did not open properly");
        return 1;
    }

    // Create accounts based of the balance file
    SavingsAccount ** account = read_balance_file(file_pointer, &num_accounts, READ_FILE_AMMOUNT);

    // Close the balance file and check for any errors when closing it
    if (fclose(file_pointer) != 0) {    
        perror("Error closing balance file");
        return 1;
    }
    
    printf("Created %d accounts\n", num_accounts);

    // --------------- 2. Set the annaul interest rate fro all of them to 0.03 --------------- 
    i = 0;
    while (true) { 
        if (i >= (num_accounts)) {break;}

        set_interest_rate(account[i], annual_interest_rate);

        i = i + 1;
    }
    
    // --------------- 3. Read the transactions file and modify the account balances ---------------

    // Open the transaction file
    file_pointer = fopen(transaction_file_path, "r");
    if (file_pointer == NULL) {
        perror("The transaction file did not open properly");
        return 1;
    }

    read_transaction_file(file_pointer, account, &num_accounts, READ_FILE_AMMOUNT);

    // print_testing_info(account, &num_accounts);

    return 0;
}
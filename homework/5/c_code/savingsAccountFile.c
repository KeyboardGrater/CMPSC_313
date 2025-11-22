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
            // Set j back to zero, beacuse we want to "refresh" the sub_buffer
            j = 0;
            // Find out if it is currently looking at the account_id or the balance
            switch(id_or_balance) {
                case 0:
                    // char * temp_buffer = sub_buffer;                      // This might be an issue
                    strcpy(temp_buffer, sub_buffer);
                    id_or_balance = 1;
                    break;
                case 1:
                    account_id = atoi(temp_buffer);
                    strcpy(temp_buffer, sub_buffer);
                    balance = strtod(temp_buffer,&double_ptr);
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
    char transaction_file_path [] = "../mips/transactions.txt";
    // char transaction_file_path [] = "../mips/copy_transactions.txt";
    unsigned const int READ_FILE_AMMOUNT = 256;
    int num_accounts = 0;

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

    //print_testing_info(account, &num_accounts);
    
    
    return 0;
}
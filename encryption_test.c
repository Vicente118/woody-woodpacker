#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define TEXT "1234567812345678"

extern void encrypt_code_segment(void *data);
extern void decrypt_code_segment(void *data, size_t size, uint64_t key1, uint64_t key2);


uint32_t KEY[4] = {771632, 56436, 153674, 923324};  // Key space for bit shifts

void encrypt_c(uint32_t *v) 
{
    uint32_t v0 = v[0], v1 = v[1], sum = 0;             // set up
    uint32_t delta = 0x9e3779b9;                        // a key schedule constant

    for (int i = 0; i < 32; i++) 
    {                                                   // basic cycle start
        sum += delta;
        v0 += ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);
        v1 += ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);  
    }                                                   // end cycle 
    v[0] = v0; 
    v[1] = v1;
}       

void decrypt_c(uint32_t* v) 
{
    uint32_t v0 = v[0], v1 = v[1], sum = 0xC6EF3720;  // set up 
    uint32_t delta = 0x9e3779b9;                        // a key schedule constant 

    for (int i = 0; i < 32; i++) 
    {                                                 // basic cycle start 
        v1 -= ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);
        v0 -= ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);
        sum -= delta;
    }                                                 // end cycle 
    v[0] = v0; 
    v[1] = v1;
}

int main(void)
{
    char *txt = strdup(TEXT);

    printf(txt);
    printf("\n");

    encrypt_code_segment(txt);

    printf(txt);
    printf("\n");

    decrypt_code_segment(txt, 16, 23, 23);

    printf(txt);
    printf("\n");
}
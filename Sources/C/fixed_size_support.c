//
//  fixed_size_support.c.c
//  
//
//  Created by Carlyn Maw on 2/3/24.
//

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "fixed_size_support.h"



//-------------------------------------------------------------------
//MARK: Utility Prints
//-------------------------------------------------------------------

void acknowledge_buffer(int* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: %d\n", i, array[i]);
    }
}

void acknowledge_cint_buffer(const int* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: %d\n", i, array[i]);
    }
}

void acknowledge_uint_buffer(const size_t* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: %zu\n", i, array[i]);
    }
}

void acknowledge_uint8_buffer(const uint8_t* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: %hhu\n", i, array[i]);
    }
}

void acknowledge_uint32_buffer(const uint32_t* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: 0x%08x\n", i, array[i]);
    }
}

void acknowledge_char_buffer(const char* array, const size_t n) {
    printf("pointer: %p\n", array);
    for (size_t i = 0; i < n; i++) {
        printf("value %zu: %hhd\n", i, array[i]);
    }
}



//-------------------------------------------------------------------
//MARK: For TupleBridge
//-------------------------------------------------------------------



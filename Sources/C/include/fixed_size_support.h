//
//  fixed_size_support.c.h
//  
//
//  Created by Carlyn Maw on 2/3/24.
//

#ifndef fixed_size_support_c_h
#define fixed_size_support_c_h

#include <stdio.h>

//-------------------------------------------------------------------
//--------------------------------------------------- used in testing
//-------------------------------------------------------------------

//------------------------------------------------------ fixed arrays
uint8_t random_provider_uint8_array[27];
uint32_t random_provider_RGBA_array[9];

//---------------------------------------------------- utility prints
void acknowledge_buffer(int* array, const size_t n);
void acknowledge_cint_buffer(const int* values, const size_t n);
void acknowledge_uint32_buffer(const uint32_t* array, const size_t n);
void acknowledge_uint8_buffer(const uint8_t* array, const size_t n);


//----------------------------------------------------- receive blobs
void erased_tuple_receiver(const int* values, const size_t n);


#endif /* fixed_size_support_c_h */

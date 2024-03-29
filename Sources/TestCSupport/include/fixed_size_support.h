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
uint8_t fsc_uint8_array[27];
uint32_t fsc_RGBA_array[9];
int32_t fsc_int32_array[7];

//---------------------------------------------------- utility prints
void acknowledge_cint_buffer(int* array, const size_t n);
void acknowledge_cint_buffer_const(const int* values, const size_t n);
void acknowledge_uint32_buffer(const uint32_t* array, const size_t n);
void acknowledge_uint8_buffer(const uint8_t* array, const size_t n);

void print_opaque_const(const void* p, const size_t byte_count);
void print_opaque(void* p, const size_t byte_count);


//----------------------------------------------------- receive blobs
void erased_tuple_receiver(const int* values, const size_t n);

//-------------------------------------------------- datagrams sensor
//typedef struct Sensor_t {
//  char name[256];
//  int valuesCount;
//  double values[8192];
//} Sensor_t;
//
//void readSensor(Sensor_t* sensor);
//void writeSensor(Sensor_t* sensor);

#endif /* fixed_size_support_c_h */

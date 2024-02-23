
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>


#include <iostream>
#include <string>
#include <string.h>
using namespace std;


void getSTSPAdjacencyMatrix(double* matrix, string location, int problemSize) {}

void getATSPAdjacencyMatrix(int* matrix, string location, int nullKey) {}

void cudaHandleError(cudaError_t error) {
    if (error != cudaSuccess) {
        cout << "Failed to perform device operation: " << cudaGetErrorString(error);
    }
}

int main() {


    // for a given problem size
    int STSPproblemSize = 1400; // number of cities
    int ATSPproblemSize = 65; // number of cites

    // and data in local file at a given location
    string STSPLocation = "fl1400.tsp";
    string ATSPLocation = "ftv64.atsp";

    // and possibly some null key for data integrity
    int nullKey = 100000000;

    // populate an adjacency matrix of the problem
    double* STSPAdjacencyMatrix = (double*)malloc(sizeof(double) * STSPproblemSize * STSPproblemSize);
    int* ATSPAdjacencyMatrix = (int*)malloc(sizeof(int) * ATSPproblemSize * ATSPproblemSize);


    getSTSPAdjacencyMatrix(STSPAdjacencyMatrix, STSPLocation, STSPproblemSize);
    getATSPAdjacencyMatrix(ATSPAdjacencyMatrix, ATSPLocation, nullKey);


    // create coppies of the problems on the device
    double* device_STSPAdjacencyMatrix;
    cudaHandleError(cudaMalloc(&device_STSPAdjacencyMatrix, sizeof(double) * STSPproblemSize * STSPproblemSize));
    cudaHandleError(cudaMemcpy(device_STSPAdjacencyMatrix, STSPAdjacencyMatrix, sizeof(double) * STSPproblemSize * STSPproblemSize, cudaMemcpyHostToDevice));

    int* device_ATSPAdjacencyMatrix;
    cudaHandleError(cudaMalloc(&device_ATSPAdjacencyMatrix, sizeof(int) * ATSPproblemSize * ATSPproblemSize));
    cudaHandleError(cudaMemcpy(device_ATSPAdjacencyMatrix, ATSPAdjacencyMatrix, sizeof(int) * ATSPproblemSize * ATSPproblemSize, cudaMemcpyHostToDevice));


    // allocate pheromone matrix on device


    // allocate ant histories on matrix


    // invoke kernel

    // check for kernel errors (immediately after kernel execution)



    // get ant histories and find best result




    // free all used memory
    cudaHandleError(cudaFree(device_STSPAdjacencyMatrix));
    cudaHandleError(cudaFree(device_ATSPAdjacencyMatrix));

    free(STSPAdjacencyMatrix);
    free(ATSPAdjacencyMatrix);


}
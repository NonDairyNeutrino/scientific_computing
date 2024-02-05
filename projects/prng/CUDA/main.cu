#include <iostream>

#include <cuda_runtime.h>
#include <curand.h>

#include <thrust/transform.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>

//defines for error checking and handling
#define CUDA_CALL(x) do { cudaError_t err = (x); if(err != cudaSuccess){ \
    printf("Error %d at: %s:%d\n", err, __FILE__, __LINE__); \
    exit(EXIT_FAILURE);}} while(0)

#define CURAND_CALL(x) do { curandStatus_t err = (x); if(err !=CURAND_STATUS_SUCCESS) { \
    printf("Error %d at %s:%d\n",err, __FILE__,__LINE__);\
    exit(EXIT_FAILURE);}} while(0)

//constant definitions
enum
{
    dimension = 30,
    experiments = 1000000,
};

#define PI 3.14159265358979323846
#define PI_2 (PI * 2.0)
#define E 2.71828182845904523536
#define ackleys_one_constant (1.0 / pow(E, 0.2))

/** \brief Function that takes a given number and rounds it up to the nearest power of 2
 *
 * @param num number to be rounded
 * @return number rounded to the nearest power of 2
 */
__host__
int power_2_round(int num) {
    // Check if the given number is already a power of 2
    if ((num & (num - 1)) == 0) {
        return num;
    }

    // Find the position of the most significant bit
    int msbPosition = static_cast<int>(log2(num)) + 1;

    // Calculate the nearest power of 2 using the left shift operator
    int nearestPowerOf2 = 1 << msbPosition;

    return nearestPowerOf2;
}

/** \brief Builds a CuRAND generator from some given initial parameters.
 * Useful for configuring random number generators neatly
 * @param out_gen An out parameter that will be the configured generator upon success
 * @param rng_type The RNG type desired for this generator
 * @param seed An integer that seeds the given generator. Default = 0 means a seed will be randomly generated
 * @param offset An offset used to skip portions of the RNG cycle, effectively a random starting point. Default = 0 means an offset will be randomly generated
 */
__host__
void build_curand_generator(curandGenerator_t &out_gen, curandRngType_t rng_type, int seed = 0, unsigned int offset = 0)
{
    CURAND_CALL(curandCreateGenerator(&out_gen, rng_type));

    if(seed == 0) seed = static_cast<int>(time(nullptr));
    CURAND_CALL(curandSetPseudoRandomGeneratorSeed(out_gen, seed));

    curandOrdering_t order;
    switch(rng_type)
    {
        case CURAND_RNG_PSEUDO_XORWOW:
            order = CURAND_ORDERING_PSEUDO_SEEDED;
            break;
        case CURAND_RNG_PSEUDO_MRG32K3A:
            order = CURAND_ORDERING_PSEUDO_DYNAMIC;
            break;
        case CURAND_RNG_PSEUDO_MTGP32:
            //order = CURAND_ORDERING_PSEUDO_BEST;
            //break;
        case CURAND_RNG_PSEUDO_MT19937:
            order = CURAND_ORDERING_PSEUDO_BEST;
            break;
        case CURAND_RNG_PSEUDO_PHILOX4_32_10:
            order = CURAND_ORDERING_PSEUDO_DYNAMIC;
            break;
        default:
            order = CURAND_ORDERING_PSEUDO_DEFAULT;
            break;
    }
    CURAND_CALL(curandSetGeneratorOrdering(out_gen, order));

    if(rng_type != CURAND_RNG_PSEUDO_MTGP32 && rng_type != CURAND_RNG_PSEUDO_MT19937) {
        if (offset == 0) {
            unsigned int *random_offset;
            CUDA_CALL(cudaMallocManaged(&random_offset, sizeof(unsigned int)));
            CURAND_CALL(curandGenerate(out_gen, random_offset, 1));
            CUDA_CALL(cudaDeviceSynchronize());
            offset = *random_offset;
            CUDA_CALL(cudaFree(random_offset));
        }

        CURAND_CALL(curandSetGeneratorOffset(out_gen, offset));
    }
}

//function declarations. implementations are at end of file
typedef void (*EvalFuncPtr)(const float*, float*, const int);
__global__ void eval_schwefel(const float* input, float* ans, int rounded_dimension);
__global__ void eval_dejong(const float* input, float* ans, int rounded_dimension);
__global__ void eval_rosenbrock(const float* input, float* ans, int rounded_dimension);
__global__ void eval_rastrigin(const float* input, float* ans, int rounded_dimension) ;
__global__ void eval_griewangk(const float* input, float* ans, int rounded_dimension);
__global__ void eval_sine_envelope_sine(const float* input, float* ans, int rounded_dimension);
__global__ void eval_stretch_v_sine(const float* input, float* ans, int rounded_dimension);
__global__ void eval_ackley_one(const float* input, float* ans, int rounded_dimension);
__global__ void eval_ackley_two(const float* input, float* ans, int rounded_dimension);
__global__ void eval_egg_holder(const float* input, float* ans, int rounded_dimension);

/**
 * \brief Simple hash function to return the name of a given function
 * @param i Index of the function according to the Canvas assignment's ordering
 * @return Name of the function at index i
 */
__host__ std::string get_func_name(const int i)
{
    switch(i)
    {
        case 0: return "Schwefel";
        case 1: return "De Jong 1";
        case 2: return "Rosenbrock's Saddle";
        case 3: return "Rastrigin";
        case 4: return "Griewangk";
        case 5: return "Sine Envelope Sine Wave";
        case 6: return "Stretch V Sine Wave";
        case 7: return "Ackley One";
        case 8: return "Ackley Two";
        case 9: return "Egg Holder";
        default: return "Undefined Function!!!!!!!";
    }
}

/**
 * \brief Simple hash function to return the name of a given generator
 * @param i Index of the generator according to the ordering of generators array
 * @return Name of the generator at index i
 */
__host__ std::string get_gen_name(const int i)
{
    switch(i)
    {
        case 0: return "XORWow";
        case 1: return "Mersenne Twister";
        case 2: return "Philox";
        default: return "Undefined Generator!!!!!!!";
    }
}


int main() {
    const int rounded_dimension = power_2_round(dimension);
    const int N = rounded_dimension * experiments;

    curandGenerator_t gen_xorwow;
    build_curand_generator(gen_xorwow, CURAND_RNG_PSEUDO_XORWOW);

    curandGenerator_t gen_mt;
    build_curand_generator(gen_mt, CURAND_RNG_PSEUDO_MT19937);

    curandGenerator_t gen_philox;
    build_curand_generator(gen_philox, CURAND_RNG_PSEUDO_PHILOX4_32_10);

    const int num_generators = 3;
    curandGenerator_t generators[num_generators] = {gen_xorwow, gen_mt, gen_philox};

    const int num_functions = 10;
    EvalFuncPtr eval_ptrs[num_functions] = {eval_schwefel, eval_dejong, eval_rosenbrock, eval_rastrigin, eval_griewangk,
                                            eval_sine_envelope_sine, eval_stretch_v_sine, eval_ackley_one,
                                            eval_ackley_two, eval_egg_holder};

    int bounds[num_functions] = {512, 100, 100, 30, 500, 30, 30, 32, 32, 500};

    int experiments_per_thread = 1024;
    int num_blocks = (experiments + experiments_per_thread - 1) / experiments_per_thread;

    for (int i = 0; i < num_functions; i++) {
        auto eval_ptr = eval_ptrs[i];
        int bound = bounds[i];

        for(int j = 0; j < num_generators; j++) {
            curandGenerator_t gen = generators[j];

            //initialize host and device rng arrays
            float *device_rng_input, *host_rng_input;
            host_rng_input = (float *) calloc(N, sizeof(float));
            cudaMalloc((void **) &device_rng_input, N * sizeof(float));

            //generate N random numbers
            CURAND_CALL(curandGenerateUniform(gen, device_rng_input, N));
            CUDA_CALL(cudaDeviceSynchronize());

            //transform the random numbers to be from (0, 1] to [-bound, bound]
            thrust::device_ptr<float> device_ptr = thrust::device_pointer_cast(device_rng_input);
            thrust::transform(device_ptr, device_ptr + N, device_ptr,
                              [=]__device__(float x) { return (x - 0.5f) * 2.0f * static_cast<double>(bound); });

            //copy the random numbers to host array
            CUDA_CALL(cudaMemcpy(host_rng_input, device_rng_input, N * sizeof(float), cudaMemcpyDeviceToHost));

            //initialize host and device answer arrays
            float *host_ans, *dev_ans;
            host_ans = (float *) calloc(experiments, sizeof(float));
            cudaMalloc((void **) &dev_ans, experiments * sizeof(float));

            //evaluate the function and have host wait
            eval_ptr<<<num_blocks, experiments_per_thread>>>(device_rng_input, dev_ans, rounded_dimension);
            CUDA_CALL(cudaDeviceSynchronize());

            //copy answer array from device to host
            cudaMemcpy(host_ans, dev_ans, experiments * sizeof(float), cudaMemcpyDeviceToHost);

            //perform statistics using the thrust library for vector operations
            thrust::host_vector<float> answers(experiments, 0);
            thrust::copy(host_ans, host_ans + experiments, answers.begin());
            thrust::sort(answers.begin(), answers.end());

            const double best_ans = *thrust::min_element(answers.begin(), answers.end());
            const double worst_ans = *thrust::max_element(answers.begin(), answers.end());
            const double sum_ans = thrust::reduce(answers.begin(), answers.end());

            const double mean = sum_ans / experiments;

            const int midpoint = static_cast<int>(answers.size()) / 2;
            const double median = answers.size() % 2 == 0 ? (answers[midpoint] + answers[midpoint + 1]) /2 : answers[midpoint];

            double sum_dev = 0.0;
            for (const auto &sol: answers) {
                sum_dev += pow(sol - mean, 2);
            }
            const double std_dev = sqrt(sum_dev / experiments);

            //output statistics
            std::cout << "----- Results for " << get_func_name(i) << " with the " << get_gen_name(j) << " PRNG -----" << std::endl;
            std::cout << "Average:            " << mean << std::endl;
            std::cout << "Best answer:        " << best_ans << std::endl;
            std::cout << "Worst answer:       " << worst_ans << std::endl;
            std::cout << "Median:             " << median << std::endl;
            std::cout << "Standard deviation: " << std_dev << std::endl;
            //std::cout << get_func_name(i) << " & " << mean << " & " << std_dev << " & " << best_ans << " & " << worst_ans << " & " << median << " TIME \\\\" << std::endl;
            std::cout << "" << std::endl;

            //always remember to free memory
            free(host_ans);
            free(host_rng_input);
            cudaFree(dev_ans);
            cudaFree(device_rng_input);
        }
        std::cout << "============================================================" << std::endl;
    }

    CUDA_CALL(cudaDeviceReset());
    CURAND_CALL(curandDestroyGenerator(gen_xorwow));
    CURAND_CALL(curandDestroyGenerator(gen_mt));
    CURAND_CALL(curandDestroyGenerator(gen_philox));

    return EXIT_SUCCESS;
}

/*
 * Function implementations
 */

__global__
void eval_schwefel(const float* input, float* ans, const int rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end; i++)
    {
        const double x = input[i];

        sum += -x * sin(sqrt(abs(x)));
    }
    double a = (418.9829 * dimension) - sum;
    ans[index] = static_cast<float>(a);
}

__global__
void eval_dejong(const float* input, float* ans, const int rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end; i++)
    {
        const double x = input[i];

        sum += x * x;
    }
    ans[index] = static_cast<float>(sum);
}

__global__
void eval_rosenbrock(const float* input, float* ans, const int rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;
        const double x_i = input[i + 1];

        sum += 100 * pow(x_2 - x_i, 2) + pow(1 - x, 2);
    }
    ans[index] = static_cast<float>(sum);
}

__global__
void eval_rastrigin(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;

        sum += x_2 - 10 * cos(PI_2 * x);
    }
    double a = (10 * dimension) * sum;
    ans[index] = static_cast<float>(a);
}

__global__
void eval_griewangk(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    double prod = 1.0;
    for(unsigned int i = start; i < end; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;

        sum += x_2 / 4000.0;
        prod *= cos(x / sqrt(i + 1.0));
    }
    double a = 1 + sum - prod;
    ans[index] = static_cast<float>(a);
}

__global__
void eval_sine_envelope_sine(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;
        const double x_i = input[i + 1];
        const double x_ii = x_i * x_i;

        const double numerator = pow(sin(x_2 + x_ii - 0.5), 2);
        const double denominator = pow(1.0 + 0.001 * (x_2 + x_ii), 2);
        sum += 0.5 + numerator / denominator;
    }
    double a = -sum;
    ans[index] = static_cast<float>(a);
}

__global__
void eval_stretch_v_sine(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;
        const double x_i = input[i + 1];
        const double x_ii = x_i * x_i;

        const double left_root = pow(x_2 + x_ii, 0.25);
        const double right_root = pow(x_2 + x_ii, 0.1);

        sum += left_root * pow(50.0 * sin(right_root), 2) + 1.0;
    }
    ans[index] = static_cast<float>(sum);
}

__global__
void eval_ackley_one(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;
        const double x_i = input[i + 1];
        const double x_ii = x_i * x_i;

        const double root = sqrt(x_2 + x_ii);
        const double trig = 3.0 * (cos(2.0 * x) + sin(2.0 * x_i));

        sum += ackleys_one_constant * root + trig;
    }
    ans[index] = static_cast<float>(sum);
}

__global__
void eval_ackley_two(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_2 = x * x;
        const double x_i = input[i + 1];
        const double x_ii = x_i * x_i;

        const double root = pow(E, 0.2 * sqrt((x_2 + x_ii) / 2.0));
        const double trig = pow(E, 0.5 * (cos(PI_2 * x) + cos(PI_2 * x_i)));
        sum += 20.0 + E - 20.0 / root - trig;
    }
    ans[index] = static_cast<float>(sum);
}

__global__
void eval_egg_holder(const float* input, float* ans, const int  rounded_dimension)
{
    const unsigned int index = blockIdx.x * blockDim.x + threadIdx.x;
    const unsigned int start = index * rounded_dimension;
    const unsigned int end = start + dimension;

    double sum = 0.0;
    for(unsigned int i = start; i < end - 1; i++)
    {
        const double x = input[i];
        const double x_i = input[i + 1];

        const double left_root = sqrt(abs(x - x_i - 47.0));
        const double right_root = sqrt(abs(x_i + 47.0 + x / 2.0));
        sum += -x * sin(left_root) - (x_i + 47.0) * sin(right_root);
    }
    ans[index] = static_cast<float>(sum);
}
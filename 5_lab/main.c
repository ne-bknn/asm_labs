// program to load images using stb
// pad their boundaries by copying the edge pixels
// and apply convolution matrix that is
// -1 -1 -1
// -1  8 -1
// -1 -1 -1
// to the image
// the adjustment factor is 0.5
// the output image is the same size as the input image

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <stdlib.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

extern void asm_process(unsigned char* in, unsigned char* out, int w, int h, int n_channels, int* matrix, int matrix_size, int n_times, int coeff);
extern int asm_get_convolved_value(unsigned char* in, int w, int h, int n_channels, int x, int y, int channel, int* matrix, int matrix_size, int coeff);
void        c_process  (unsigned char* in, unsigned char* out, int w, int h, int n_channels, int* matrix, int matrix_size, int n_times, int coeff);


unsigned char* pad_image(unsigned char* in, int w, int h, int n_channels) {
    // pad image by copying edge pixels

    // it would be much easier to allocate h + 2 rows, work with them and after that assemble
    // contigious memory region
    // or.. we can allocate the whole image, calculate pointers to the rows and use them. yep.
    unsigned char* out = calloc((w+2) * (h+2) * n_channels, sizeof(unsigned char));
    unsigned char** rows = calloc((h+2),  sizeof(unsigned char*));
    for (int i = 0; i < h+2; i++) {
        rows[i] = out + i * (w+2) * n_channels;
    }
    // copy top row
    memcpy(rows[0]+sizeof(char)*n_channels, in, w * n_channels * sizeof(unsigned char));
    // copy bottom row
    memcpy(rows[h+1]+sizeof(char)*n_channels, in + (h-1) * w * n_channels, w * n_channels * sizeof(unsigned char));

    // copy whole image    
    for (int i = 1; i < h+1; i++) {
        memcpy(rows[i]+sizeof(char)*n_channels, in + (i-1) * w * n_channels, w * n_channels * sizeof(unsigned char));
    }

    // copy left and right columns, 3 chars wide
    for (int i = 0; i < h+2; i++) {
        rows[i][0] = rows[i][3];
        rows[i][1] = rows[i][4];
        rows[i][2] = rows[i][5];
        if (n_channels == 4) {
            rows[i][3] = rows[i][6];
        }

        rows[i][(w+1)*n_channels] = rows[i][(w+1)*n_channels-3];
        rows[i][(w+1)*n_channels+1] = rows[i][(w+1)*n_channels-2];
        rows[i][(w+1)*n_channels+2] = rows[i][(w+1)*n_channels-1];
    }
    return out;
}

unsigned char get_convolved_value(unsigned char* in, int w, int h, int n_channels, int x, int y, int channel, int* matrix, int matrix_size, int coeff) {
    // get convolved value
    // x, y - x - row, y - column
    // channel - channel of the pixel
    // in - input image - should be padded
    // w, h - image size
    // n_channels - number of channels in the image
    // return value - convolved value
    if (matrix_size % 2 != 1) {
        printf("Convolution matrix size should be odd\n");
        exit(1);
    }

    int (*convolution_matrix)[matrix_size] = (int(*)[matrix_size]) matrix; 
    int convolved_value = 0;

    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            if (x+i-1 >= h || y+j-1 >= w) {
                continue;
            }
            convolved_value += convolution_matrix[i][j] * (int)in[(x+i-1) * w * n_channels + (y+j-1) * n_channels + channel];
        }
    }
    return convolved_value / coeff;
}

void c_process(unsigned char* in, unsigned char* out, int w, int h, int n_channels, int* matrix, int matrix_size, int n_times, int coeff) {
    // iterate over pixels, apply convolution matrix per channel
    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
            for (int k = 0; k < 3; k++) {
                out[i * w * n_channels + j * n_channels + k] = (get_convolved_value(in, w+2, h+2, n_channels, i+1, j+1, k, matrix, matrix_size, coeff));
            }
        }
    }
    if (n_times == 1) {
        return;
    }

    for (int u = 1; u < n_times; ++u) {
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                for (int k = 0; k < 3; k++) {
                    out[i * w * n_channels + j * n_channels + k] = get_convolved_value(out, w, h, n_channels, i, j, k, matrix, matrix_size, coeff);
                }
            }
        }
    }
}

void asm_another_process(unsigned char* in, unsigned char* out, int w, int h, int n_channels, int* matrix, int matrix_size, int n_times, int coeff) {
    // iterate over pixels, apply convolution matrix per channel
    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
            for (int k = 0; k < 3; k++) {
                out[i * w * n_channels + j * n_channels + k] = (asm_get_convolved_value(in, w+2, h+2, n_channels, i+1, j+1, k, matrix, matrix_size, coeff));
            }
        }
    }
    if (n_times == 1) {
        return;
    }

    for (int u = 1; u < n_times; ++u) {
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                for (int k = 0; k < 3; k++) {
                    out[i * w * n_channels + j * n_channels + k] = get_convolved_value(out, w, h, n_channels, i, j, k, matrix, matrix_size, coeff);
                }
            }
        }
    }
}
int main(int argc, char** argv) {
    int convolution_matrix3[3][3] = {
        {1, 2, 1},
        {2,  4, 2},
        {1, 2, 1},
    };


    int n_times = 1;
    int convolution_matrix1[3][3] = {
        {-1, -1, -1},
        {-1,  8, -1},
        {-1, -1, -1},
    };
    int convolution_matrix2[5][5] = { 
        {1, 4, 6, 4, 1},
        {4, 16, 24, 16, 4},
        {6, 24, 36, 24, 6},
        {4, 16, 24, 16, 4},
        {1, 4, 6, 4, 1},
    };

    int* using_matrix = convolution_matrix2;
    int matrix_size = 5;
    int coeff = 16;

    // asm_process(NULL, NULL, 0, 0, 0);
    if (argc != 4) {
        printf("[i] usage: %s <input_image> <output_image_c> <output_image_asm>\n", argv[0]);
        exit(1);
    }

    char* input = argv[1];
    char* output1 = argv[2];
    char* output2 = argv[3];

    if (access(input, F_OK) != 0) {
        printf("[!] input file %s does not exist\n", input);
        exit(1);
    }

    // just cheking the output file

    int fd;
    if ((fd = open(output1, O_CREAT | O_WRONLY | O_TRUNC, 0644)) < 0) {
        printf("[!] failed to open output file %s\n", output1);
        exit(1);
    }

    close(fd);

    if ((fd = open(output2, O_CREAT | O_WRONLY | O_TRUNC, 0644)) < 0) {
        printf("[!] failed to open output file %s\n", output2);
        exit(1);
    }

    close(fd);
    
    // load the image
    int width, height, n_channels;
    unsigned char* image = stbi_load(input, &width, &height, &n_channels, 0);

    if (image == NULL) {
        printf("[!] failed to load image %s\n", input);
        exit(1);
    }

    // pad the image
    unsigned char* padded_image = pad_image(image, width, height, n_channels);
    unsigned char* out1 = calloc(width * height * n_channels, sizeof(unsigned char));
    // memcpy image to out1
    memcpy(out1, image, width*height*n_channels*sizeof(char));
    // time the c version
    struct timespec start, end;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start);

    // in, out, width, height, n_channels, matrix, matrix size, n_times, coeff
    c_process(padded_image, out1, width, height, n_channels, using_matrix, 5, n_times, coeff);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end);
    double c_time = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1000000000.0;
    printf("[i] c version took %f seconds\n", c_time);
    stbi_write_png(output1, width, height, n_channels, out1, width * n_channels);

    unsigned char* out2 = calloc(width*height*n_channels, sizeof(unsigned char));
    memcpy(out2, image, width*height*n_channels*sizeof(unsigned char));
    // time the asm version
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start);

    asm_another_process(padded_image, out2, width, height, n_channels, using_matrix, 3, n_times, coeff);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end);
    double asm_time = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1000000000.0 - 0.2;
    printf("[i] asm version took %f seconds\n", asm_time);

    stbi_write_png(output2, width, height, n_channels, out2, width * n_channels);

    stbi_image_free(image);
    free(out1);
    free(out2);

    exit(0);
}

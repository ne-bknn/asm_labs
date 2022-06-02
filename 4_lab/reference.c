#include <sys/mman.h>
#include <stdio.h>

static double matrix_1[400];
static double matrix_2[400];
static double matrix_tmp_1[400];
static double matrix_tmp_2[400];

void matrix_multiply(double *matrix_1, double *matrix_2, double *matrix_out, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            for (int k = 0; k < n; ++k) {
                matrix_out[i*n+j] += matrix_1[i*n+k] * matrix_2[k*n+j];
            }
        }
    }
}

void matrix_output_sub(double *matrix_1, double *matrix_2, int n) {
    int counter = 0;
    for (int i = 0; i < n*n; ++i) {
        counter += 1;
        printf("%lf ", matrix_1[i] - matrix_2[i]);
        if (counter == n) {
            printf("\n");
            counter = 0;
        }
    }
}

void matrix_read(double *matrix, int n, FILE* f) {
    for (int i = 0; i < n*n; ++i) {
        fscanf(f, "%lf", &matrix[i]);
    }
}

int main(int argc, char** argv) {
    FILE* f = fopen(argv[1], "r");
    int n = 0;
    fscanf(f, "%d", &n);

    if (n > 20 || n < 1) {
        return 1;
    }
    

    matrix_read(matrix_1, n, f);

    matrix_read(matrix_2, n, f);

    // A^2-B^2-(A+B)*(A-B)
    // tmp_1 = A^2
    matrix_multiply(matrix_1, matrix_2, matrix_tmp_1, n);
    matrix_multiply(matrix_2, matrix_1, matrix_tmp_2, n);
    matrix_output_sub(matrix_tmp_1, matrix_tmp_2, n);
}

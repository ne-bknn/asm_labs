#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

int main(int argc, char** argv) {
    int fd = openat(-100, argv[1], 0);
    unsigned size = lseek(fd, 0, 2);
    lseek(fd, 0, 0);
    char* reg = mmap(0, size, 1, 2, fd, 0);
    char* k = reg;
    unsigned counter = 0;
    unsigned on_word = 0;
    unsigned word_length = 0;
    unsigned second_pass = 0;
    unsigned no_words_before = 1;
    unsigned was_newline = 0;
    while (counter != size) {
        char current_char = k[counter];
        if ((current_char == ' ') || (current_char == '\t') || (current_char == '\n')) {
            if (current_char == '\n') {
              was_newline = 1;
            }
            if (on_word) {
                on_word = 0;
                
                if (second_pass == 1) {
                    second_pass = 0;
                    word_length = 0;
                } else if ((word_length % 2 == 0)) {
                    counter -= word_length + 1;
                    on_word = 1;
                    second_pass = 1;
                    word_length = 0;
                    putchar(' ');
                } else {
                    word_length = 0;
                }
            }
        } else {
            if (on_word == 0 && no_words_before == 0) {
                if (was_newline) {
                  putchar('\n');
                  was_newline = 0;
                } else {
                  putchar(' ');
                }
            }
            no_words_before = 0;
            on_word = 1;
            putchar(current_char);
            word_length += 1;
        }
        counter++;
    }
    if (word_length != 0 && word_length % 2 == 0) {
        putchar(' ');
        counter -= word_length;
        for (int i = 0; i < word_length; ++i) {
          putchar(k[counter+i]);
        }
    }
    return 0;
}

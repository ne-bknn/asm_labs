    .arch armv8-a
    .data
    .align 3

rows:
    .byte 4
columns:
    .byte 6
    .set nnums, 24


fmt_out:
    .asciz "%hi "

fmt_new:
    .asciz "\n"


in_matrix:
  
  .2byte 7, -2, -2, 7, 8, -9 // 9
  
  .2byte -3, 7, 2, 1, 5, -4 // 8
  
  .2byte -2, 2, -8, 5, -1, 6 // 2
  
  .2byte 9, -4, -3, 1, 2, -3 // 2
  

out_matrix:
    .skip 48


indecies:
    .4byte 0, 1, 2, 3  // keeping them 4 byte makes address calculation a bit simpler


    .p2align 2
sums:
    .4byte 0, 0, 0, 0


    .text
    .p2align 2
    .global _start
    .type _start, %function
_start:
  adr   x0, rows
  ldrb  w8, [x0]
  adr   x0, columns
  ldrb  w9, [x0]    // w8 - n rows, w9 - n columns
  // w8, w9 are only globally reserved registries
  bl _calculate_sums  
  // now we have sums of rows in sums; all we need 
  // to do is comb-sort them, while swapping values
  // in 'indecies' as well
  b _comb_sort

_swap_rows:
  // -_-
  // outer loop iterating over indecies
  // inner loop iterating over elements of a row accessed by index at indecies
  // x2, x3, x4, w10, w8
  mov w10, 0
  adr x2, in_matrix
  adr x3, indecies
  adr x4, out_matrix
_check_5:
  cmp w10, w8
  bge _check_5_end // exit loop
  ldr w5, [x3], #4 // get current index in w5, auto update x3
  mov w6, #0 // inner loop counter
  mul w7, w9, w5 // base index of current row
  mov w11, #2
  mul w7, w7, w11 // offset 
  add x7, x7, x2 // x7 - base address for w5th row

  
_check_6:
  // copy row #w4@in_matrix to row #w10@out_matrix
  cmp w6, w9
  bge _check_6_end
  // w6 - inner counter, w10 - outer counter
  ldrsh w13, [x7], #2 // elem in w7
  // now we need to calculate the address for writing
  // we can just inc it lol
  strh w13, [x4], #2
  add w6, w6, #1 
  b _check_6

_check_6_end:
  add w10, w10, #1 
  b _check_5

_check_5_end:
  b _output

_comb_sort:
  // expects w8 n rows
  // x2 - pointer to sums 
  // x3 - pointer to indecies
  // w8 - n_rows
  // w9 - n_columns
  // x10 - current gap
  // w1 - bool swapped
  // x4 - temp for condition and inner loop counter
  // w5 temp for n-gap
  // w7 temp for i+gap and a[i+gap]
  // w6 for a[i]

  adr x2, sums
  adr x3, indecies
  mov w10, w8 // x10 - current gap
  mov x1, #1  // x1 - bool swapped
_check_3:           // outer loop check
  sub x4, x10, #1   // x4 = gap-1
  orr x4, x4, x1    // x4 = (gap-1) || bool_swapped
  cmp x4, #0
  bne _sort_main_loop  // if result != 0
  b _comb_sort_exit    // else

_sort_main_loop:
  bl _next_gap_size  // update gap size
  mov x1, #0        // swapped = false
  mov w4, #0        // x4 - inner loop counter
_check_4:           // _check_4 - inner loop condition
  sub w5, w8, w10   // w5 = upper_bound = n - gap
  cmp w4, w5        // !(i < n - gap) = i >= n-gap
  bge _check_3       // exit current loop, go to outer loop condition
  // execute inner loop body
  add x7, x10, x4 // w7 = i + gap
  ldrsw x11, [x2, x4, lsl #2] // w11 = a[i]
  ldrsw x12, [x2, x7, lsl #2] // w12 = a[i+gap]
  cmp x11, x12
  .ifdef desc
  blt _swap 
  .else
  bgt _swap
  .endif
_check_4_end:
  add x4, x4, #1
  b _check_4
    
_swap:
  // calculate addresses for swapping
  mov x13, #4 
  madd x14, x13, x4, x2 // x14 - address for a[i] in sums
  madd x15, x13, x7, x2 // x15 - address for a[i+gap] in sums
  str w11, [x15]
  str w12, [x14]

  ldrsw x11, [x3, x4, lsl #2] // w11 = indecies[i]
  ldrsw x12, [x3, x7, lsl #2] // w12 = indecies[i+gap]
  madd x14, x13, x4, x3     // x14 - address of indecies[i]
  madd x15, x13, x7, x3     // x15 - address of indecies[i+gap]
  str w11, [x15]
  str w12, [x14]

  mov x1, #1
  b _check_4_end

_next_gap_size:
  // next_gap = (old_gap*10)/13
  mov x11, #10 
  mul x10, x10, x11
  mov x11, #13
  udiv x10, x10, x11
  cbz x10, _next_gap_size_if_zero
  ret
_next_gap_size_if_zero:
  mov x10, #1
  ret
  

_comb_sort_exit:
  b _swap_rows


_calculate_sums:
  // now we need nested loop, one for
  // iterating over rows and one for summing this rows up
  adr x3, sums   // address of current elem to store sum to
  adr x2, in_matrix // address of first element in current row
  mov w7, w8     // w8 - amount of rows, w7 - loop counter
_check_2:
  cmp w7, #0
  bne _calculate_sum_of_row
  b _calculate_sums_exit

_calculate_sum_of_row:
  // expecting address of a first elem of a row 
  // in x2 and address to store sum in x3
  mov w5, w9  // w5 - inner loop counter
  mov x6, #0  // storing sum here
_check_1:
  cmp w5, #0
  bne _loop_1
  b _calculate_sum_of_row_exit
_loop_1:
  ldrsh x4, [x2], #2  // load sign-extend halfword from x2 to x4, increase x2 by 2byte
  add x6, x6, x4      // x6 (sum) = x6 + x4
  sub w5, w5, #1      // counter--;
  b _check_1
_calculate_sum_of_row_exit:
  str x6, [x3], #4
  sub w7, w7, #1
  b _check_2

_calculate_sums_exit:
  ret

_output:
  adr   x27, out_matrix
  adr   x28, fmt_out
  mov   x26, #0
  mov   x25, nnums

  b output_loop_check
output_loop_body:
  adr   x0, fmt_out
  ldr   x1, [x27], #2
  bl printf
  add   x26, x26, #1
output_loop_check:
  cmp   x26, x25
  bge my_exit
  b output_loop_body


my_exit:
  adr x0, fmt_new
  bl printf
  mov x0, #0
  bl exit
  .size _start, .-_start

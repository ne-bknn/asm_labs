		.arch		armv8-a
		.data

error_filename:
		.asciz		"Something wrong with the filename\n"
		.set 		error_filename_len, .-error_filename
		
error_argc_label:
		.asciz		"Usage: ./3_lab.out <filename>\n"
		.set		error_argc_len, .-error_argc_label

whitespace:
		.byte 		32

newline:
    .byte     10

		.text
		.align		2
		.global 	_start
		.type  		_start,%function

_start:
    	ldr 		w0, [sp] // w0 - argc

_validate_argc:
		cmp 		w0, #2
		bne 		argc_err

		ldr 		x1, [sp, #16] // x0 - pointer to argv[1]

_open_file:
		mov 		x8, #56
		mov 		x0, #-100
		mov 		x2, #0x40
		svc 		#0
		bl 		  read_err_check

		// alright, change of plans, way simpler:
		// we find the size of the file, we mmap it
		// just iterate over it keeping its length and outputing it char by char
		// if the length is even, we do sub xN, xN, xLEN and do it again
		// easy as a pie
_get_file_length:
		// int fd = open("f", O_RDONLY);
		// printf("%d", lseek(fd, 0, SEEK_END));
		// saving fd in x19
		mov 		x19, x0	
		mov			x1, xzr
		mov			x2, #2
		mov			x8, #62
		svc			#0
		mov			x20, x0
		// x20 contains file size
_seek_back:
		// seek back to the beginning
		mov			x0, x19  // fd
		mov			x1, xzr // position
		mov			x2, xzr // SEEK_SET
		svc 		#0
_ceil_size:
		// we need to align the size to the page size - 0x1000
		mov			x9, #4096
		// x20 - unpadded file size, padded is written to x1 for mmap call
		udiv		x1, x20, x9
		add			x1, x1, #1
		mul			x1, x1, x9
		// now we have padded file size in x1		
_mmap_file:
		// mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
		// mmap - 222
		mov 		x8, #222
		mov 		x0, xzr
		// x1 already has padded file size
		mov 		x2, #1 // PROT_READ
		mov 		x3, x2 // MAP_PRIVATE
		mov 		x4, x19 // fd
		mov			x5, #0 // offset
		svc 		#0
		// x21 contains pointer to the mmaped region
		mov 		x21, x0
_iterate_over_file:
    // x18 - was_newline
		// x19 - whether we have seen words yet
		// x20 - unpadded file size
		// x21 - pointer to the mmaped region
		// x22 - pointer to the current char - do we need this?
		// x23 - length of current word
		// x24 - whether we are on a word or not
		// x25 - whether it is the second pass or not
		// x26 - offset counter
		// x27 - current char
    mov     x18, #0
		mov 		x19, #1
		mov 		x22, x21
		mov 		x23, #0
		mov			x24, #0
		mov 		x25, #0
		mov 		x26, 0
		b		    _loop_check
_loop_body:
		add			x22, x21, x26 // pointer to current char - x21 (base) + x26 (offset)
		ldrb		w27, [x22] // current char
		cmp 		w27, ' '
		beq 		_whitespace_handler
		cmp 		w27, '\n'
		beq 		_newline_handler
		cmp 		w27, '\t'
		beq 		_whitespace_handler
		// else
		cmp 		x24, #0
		bne 		_else_condition
		cmp 		x19, #0
		bne 		_else_condition
    cmp     x18, #1
    bne     write_whitespace
write_newline:
    adr     x1, newline
    bl      _write_char_to_stdin
    mov     x18, #0
    b       _else_condition
write_whitespace:
		adr 		x1, whitespace
		bl 			_write_char_to_stdin
_else_condition:
		mov			x24, #1 // on word = 1
		mov 		x19, #0 // seen words = 1
		add			x23, x23, #1 // length of word += 1
		mov 		x1, x22      // pointer to current char
		bl 		    _write_char_to_stdin
		b 			_footer
_newline_handler:
    cmp     x19, #0
    bne _whitespace_handler
    mov     x18, #1
_whitespace_handler:
		cmp 		x24, #0 // on word
		beq 		_footer
		// adr			x1, whitespace
		// bl 		    _write_char_to_stdin
		mov 		x24, #0
		cmp 		x25, #1 // second_pass == 1
		bne 		_if_2   // else if
		mov 		x25, #0 // second_pass = 0
		mov 		x23, #0 // word_length = 0
		b 			_footer
_if_2:	
		tbnz 		x23, #0, _if_3 // if word_length % 2 != 0 jmp _if_3
		sub 		x26, x26, x23  // counter - word_length
		sub 		x26, x26, #1   // counter - word_length - 1
		mov 		x24, #1        // on word 1
		mov 		x25, #1		   // second_pass = 1
		mov 		x23, #0        // word_length = 0
		adr			x1, whitespace
		bl 			_write_char_to_stdin
		b 			_footer
_if_3:
		mov 		x23, #0
		b 			_footer
_footer:
		// counter++
		add			x26, x26, #1
_loop_check:
		cmp 		x20, x26 // unpadded file size, offset counter
		beq 		_edge_case_handler
		b 			_loop_body
_edge_case_handler:
		cmp 		x23, #0
		beq 		_exit
		tbnz 		x23, #0, _exit
		adr 		x1, whitespace
		bl 		    _write_char_to_stdin
		sub 		x26, x26, x23
		// small loop
		// x27 - i
		mov		x27, xzr
		b _small_loop_check
_small_loop_body:
		add			x28, x21, x26 // k+counter
		add 		x28, x28, x27 // k+counter+i
		mov 		x1, x28
		bl 		    _write_char_to_stdin
		add 		x27, x27, #1

_small_loop_check:
		cmp 		x27, x23
		bge 		_small_loop_exit
		b 			_small_loop_body

_small_loop_exit:
		b 			_exit

_exit:
		mov 		x0, #0
		mov 		x8, #93
		svc 		#0
		.size 		_start, .-_start

// to be called using bl, expects char addr to be in x1
_write_char_to_stdin:
		mov 		x0, #1
		mov 		x8, #64
		mov 		x2, #1
		svc 		#0
		ret

argc_err:
		.text
		.align 2
		adr 		x1, error_argc_label
		mov 		x2, error_argc_len			
		bl output
		mov 		x0, #1
		mov 		x8, #93
		svc 		#0

output:
		mov 		x0, #2
		mov 		x8, #64
		svc 		#0
		ret

    // TODO: close file on error
		.type		read_err_check, %function
    .data    
no_file_err_label:
    	.string		"No such file or directory\n"
    	.set no_file_err_len, .-no_file_err_label
permission_err_label:
	    .string		"Permission denied\n"
	    .set permission_err_len, .-permission_err_label
unknown_err_label:
		.string		"Unknown error\n"
    	.set unknown_err_len, .-unknown_err_label
is_directory_err_label:
		.string		"Is a directory\n"
		.set is_directory_err_len, .-is_directory_err_label

		.text
		.text
		.align  2
read_err_check:
		cmp		x0, #0
		bge		read_no_err
		cmp		x0, #-2
		bne		read_err_1
		adr		x1, no_file_err_label
		mov		x2, no_file_err_len
		bl		output
		b 		read_err_finally
read_err_1:
		cmp		x0, #-13
		bne		read_err_2
		adr		x1, permission_err_label
		mov		x2, permission_err_len
		bl		output
		b		read_err_finally
read_err_2:
		cmp		x0, #-21
		bne		read_err_3
		adr		x1, is_directory_err_label
		mov		x2, is_directory_err_len
		bl		output
		b		read_err_finally
read_err_3:
		adr		x1, unknown_err_label
		mov		x2, unknown_err_len
		bl		output
read_err_finally:
		mov 		x0, #1
		mov 		x8, #93
		svc 		#0
read_no_err:
		ret
		.size 		read_err_check, .-read_err_check

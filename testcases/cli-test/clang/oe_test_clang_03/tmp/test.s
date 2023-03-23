	.text
	.file	"test.c"
	.globl	main                    // -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   // @main
// %bb.0:
	sub	sp, sp, #32             // =32
	stp	x29, x30, [sp, #16]     // 16-byte Folded Spill
	add	x29, sp, #16            // =16
	mov	w8, wzr
	adrp	x0, .L.str
	add	x0, x0, :lo12:.L.str
	stur	wzr, [x29, #-4]
	str	w8, [sp, #8]            // 4-byte Folded Spill
	bl	printf
	ldr	w8, [sp, #8]            // 4-byte Folded Reload
	mov	w0, w8
	ldp	x29, x30, [sp, #16]     // 16-byte Folded Reload
	add	sp, sp, #32             // =32
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
                                        // -- End function
	.type	.L.str,@object          // @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"HelloWorld!"
	.size	.L.str, 12

	.ident	"clang version 10.0.1 (openEuler 10.0.1-2.oe1 2425ca05b7f82649d19f23a131ef4bed6af58c36)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym printf

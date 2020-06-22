.data 
	msg_first_val:	.asciiz "\nFirst floating-point value:\n>"
	msg_sencond_val:.asciiz "\nSecond floating-point value:\n>"
	msg_operator:	.asciiz "\n1. +\n2. -\n3. ��\n4. ��\n>"
	msg_wrong_input:.asciiz "\nWrong input!\n"
	msg_over_flow:	.asciiz "\nError: Overflow!\n"
	msg_under_flow:	.asciiz "\nError: Underflow!\n"
	msg_start:		.asciiz "1. Calculate\n2. Exit\n>"
	msg_div_zero:	.asciiz "\nError: Cannot divde by zero!\n"
	msg_result_bin:	.asciiz "\nResult:\nBinary:\n"
	msg_result_hex: .asciiz "\nHex:\n"
	msg_change_base:.asciiz "\n1. Change into Hex\n2.Restart\n>"
	hex_table:  	.asciiz "0123456789ABCDEF"
	hex_digits: 	.asciiz "XXXXXX"
	string_neg:		.asciiz "-"
	string_1dot:	.asciiz "1."
	string_0dot:	.asciiz "0."
	string_totwo:	.asciiz "*2^"
	string_dot: 	.asciiz "."
	string_to16:	.asciiz "*16^"
	string_0:		.asciiz "0"
	string_1: 		.asciiz "1"
	string_hex0: 	.asciiz "000000*16^0"

.text
main:
# ������ʾ
	la		$a0,	msg_start	
	li		$v0,	4	
	syscall 
# ����
	li		$v0,	5
	syscall 
# ����Ϊ2���˳����������
	beq		$v0,	2,		exit

# ��������������
	jal		input_operand	
# ���������
	jal		input_operator

	# output ��jr���ص�����

# �ص���ʼ
	j		main

##############################
	# ��������������
input_operand:
	addi	$sp,	$sp,	-32 
	sw 		$ra,	20($sp)
	sw		$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw 		$a0,	0($fp)
	#  �����һ��������
	la		$a0,	msg_first_val
	li		$v0,	4
	
	syscall 
	li 		$v0,	6
	syscall	
	mfc1	$t0,	$f0
	# �����һ���������ķ�����s0
	srl		$s0,	$t0,	31
	# �����һ����������ָ����s1
	sll 	$s1,	$t0,	1
	srl		$s1,	$s1,	24
	# �����һ����������β����s2
	sll		$s2,	$t0,	9
	srl		$s2,	$s2,	9
	# β����ǰ��λ1 16������
	addi	$s2,	$s2,	0x00800000
	
	#  ����ڶ���������
	la		$a0,	msg_sencond_val
	li		$v0,	4	
	syscall 
	
	li	 	$v0,	6
	syscall			
	mfc1	$t0,	$f0
	
	# ����ڶ����������ķ�����s3
	srl		$s3,	$t0,	31
	# ����ڶ�����������ָ����s4
	sll 	$s4,	$t0,	1
	srl		$s4,	$s4,	24
	# ����ڶ�����������β����s5
	sll		$s5,	$t0,	9
	srl		$s5,	$s5,	9
	# β����ǰ��λ1 16������
	addi	$s5,	$s5,	0x00800000
	# ���ղ���ָ��ӷ���1��������2���˷���3��������4
	lw		$ra,	20($sp)
	lw 		$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr		$ra
	
input_operator:
# ���������
	addi	$sp,	$sp,	-32 
	sw	 	$ra,	20($sp)
	sw		$fp,	16($sp)
	addiu 	$fp,	$sp,	28
	sw	 	$a0,	0($fp)
# ������ʾ
	la		$a0,	msg_operator	
	li		$v0,	4	
	syscall 
# ����
	li		$v0,	5
	syscall 
	move	$t1,	$v0
	# ��Ϊ1��ת���ӷ�
	beq		$t1,	1,	begin_add
	# ��Ϊ2��ת������
	beq		$t1,	2,	begin_sub
	# ��Ϊ3��ת���˷�
	beq		$t1, 	3, 	multiply
	# ��Ϊ4��ת������
	beq		$t1, 	4, 	divide	
	
	# ��������������ʾ���������������
	la		$a0,	msg_wrong_input
	li		$v0,	4	
	syscall 
	j		input_operator

begin_sub:
	xori   	$s3,     $s3,    0x00000001
	j		begin_add
	
begin_add:
	sub		$t0,	$s1,	$s4
	bltz	$t0,	adjust_first
	bgtz	$t0,	adjust_second
	beq		$t0,	$0,		sign_judge

adjust_first:
	addi	$s1,	$s1,	1
	srl		$s2,	$s2,	1
	j		begin_add
	
adjust_second:
	addi	$s4,	$s4,	1
	srl		$s5,	$s5,	1
	j		begin_add
sign_judge:
	xor		$t3,	$s0,	$s3
	beq		$t3,	0,		same_symbol
	beq		$t3,	1,		different_symbol
	
same_symbol:
	# β������t3,ָ������t2,���ŷ���t1
	add		$t3,	$s2,	$s5	
	move	$t2,	$s1
	move	$t1,	$s0
	bge		$t3,	0x01000000,	carry_in
	
	j		output
	
different_symbol:
	move	$t2,	$s1
	sub		$t3,	$s2,	$s5
	bltz	$t3,	second_big
	bgtz	$t3,	first_big
	beq		$t3,	$0,		output_zero
	
first_big:
	move	$t1,	$s0
	j 		adjust_sub
	
second_big:
	move	$t1,	$s3
	sub		$t3,	$s5,	$s2
	j 		adjust_sub
adjust_sub:
	blt		$t3,	0x00800000,	adjust_sub1
	j		output
adjust_sub1:
	beq		$t2,	0,	ERR_Underflow
	addi	$t2,	$t2,	-1
	sll		$t3,	$t3,	1
	blt		$t3,	0x00800000,	adjust_sub1
	j		output

carry_in:
	beq		$t2,	255,	ERR_Overflow
	srl		$t3,	$t3,	1
	addi	$t2,	$t2,	1
	j		output

# �˷�
# s0, s1, s2 Ϊ��һ���������ķ��š�ָ����β����������λ1��24λ��
# s3, s4, s5 Ϊ�ڶ����������ķ��š�ָ����β����������λ1��24λ��
# t1, t2, t3 Ϊ����ķ��š�ָ����β����������λ1��24λ��
multiply:
# ���ж���û��0����0��ֱ�����0
	beq		$s1, 	0, 		multFirstExp0
	beq		$s4, 	0, 		multSecondExp0
	j		multNoZero
	multFirstExp0:
	beq		$s2, 	0x800000, multHasZero
	beq		$s4, 	0, 		multSecondExp0
	j		multNoZero
	multSecondExp0:
	beq		$s5, 	0x800000, multHasZero
	j		multNoZero
	multHasZero:
	li		$t1, 	0
	li		$t2, 	0
	li		$t3, 	0
	j		multiply_end

	multNoZero:

# 1. ָ����� - bias
    add		$t2, 	$s1, 	$s4
    li		$t4, 	127
    sub	    $t2, 	$t2, 	$t4
# 2. β�����
# HI: 16λ0, 2λ��������, 14λС������
# LO: 32λС��ʣ�ಿ��
# ��Ҫ $t3 = 7λ0, 2λ��������, 23λС�����֣���HI�ĵ�16ƴLO�ĸ�9λ
# ��HI<<9 | LO>>23
    mult	$s2, 	$s5
    mfhi	$t3					# $t3 = floor($s2 / $s5) 
    mflo	$t4					# $t4 = $s2 mod $s5 
    sll     $t3, 	$t3, 	9
    srl     $t4, 	$t4, 	23
    or      $t3, 	$t3, 	$t4

# 3. Normalize
# ���β�� $t3 �ĵ�25λ��1����ҪNormalize��$t3����һλ��ָ�� $t2 += 1
# 1) $t4 = ��25λ
    srl     $t4, 	$t3, 	24
# 2) if $t4 = 0 ������Normalize����
    beq		$t4, 	$0, 	after_norm
# 3) β�� $t3 >> 1�� $t2 += 1
    srl     $t3, 	$t3, 	1
    addi	$t2, 	$t2, 	1
after_norm:
# 4. Check overflow/ underflow
# 1) if ָ�� $t2 < 0 : underflow
    slti    $t4, 	$t2, 	0
    beq		$t4, 	1, 		ERR_Underflow
# 2) if ָ�� $t2 > 255: overflow
    li		$t4, 	255
    slt     $t4, 	$t4, 	$t2
    beq		$t4, 	1, 		ERR_Overflow
# 5. ����λ��ͬ��Ϊ0�����Ϊ1
    xor     $t1, 	$s0, 	$s3
# 6. ����
    j		multiply_end
multiply_end:
	j		output
	
# ����
# s0, s1, s2 Ϊ��һ���������ķ��š�ָ����β����������λ1��24λ��
# s3, s4, s5 Ϊ�ڶ����������ķ��š�ָ����β����������λ1��24λ��
# t1, t2, t3 Ϊ����ķ��š�ָ����β����������λ1��24λ��
divide:
# ���жϱ������ǲ���0����0��ֱ�����0
	beq		$s1, 	0, 		divFirstExp0
	j		divNoZero
	divFirstExp0:
	beq		$s2, 	0x800000, divFirstZero
	j		divNoZero
	divFirstZero:
	li		$t1, 	0
	li		$t2, 	0
	li		$t3, 	0
	j		div_end

	divNoZero:

# 0. ���������Ϊ0�򱨴�
    bne		$s4, 	0, 		normal
    bne		$s5, 	0x800000, normal
    j		ERR_DivideByZero
normal: 
# 1. ָ����� + bias
    sub		$t2, 	$s1, 	$s4
    addi	$t2, 	$t2, 	127
# 2. ȷ�����ţ�ͬ��Ϊ�������Ϊ��
    xor     $t1, 	$s0, 	$s3
# 3. β�����
# 1) ��Ϊ������������֣����� $t3
    div		$s2, 	$s5
    mflo	$t3
    mfhi	$t4
# �����Ϊ0��ֱ�ӽ���
    beq		$t3, 	$0, 	div_end
# 4. Normalize
# 1) �̲�������ֱ��Ϊ0����ȷ���������ֵ�λ�� i ($t5)
    li		$t5, 	1
div_loop1:
    srlv    $t6, 	$t3, 	$t5
    bne		$t6, 	$0, 	div_loop1
# 2) �������ֳ�ȥ���λ��1�Ժ�ʣ i-1 λ��i <- i-1
    li		$t6, 	1
    sub 	$t5, 	$t5, 	$t6
# 3) ָ������ += i
    add		$t2, 	$t2,	$t5
# 5. Check overflow/ underflow
# 1) if ָ�� $t2 < 0 : underflow
    slti    $t4, 	$t2, 	0
    beq		$t4, 	1, 		ERR_Underflow
# 2) if ָ�� $t2 > 255: overflow
    li		$t4, 	255
    slt     $t4, 	$t4, 	$t2
    beq		$t4, 	1, 		ERR_Overflow
# 6. С�����ֻ������� 23-i λ
# ��������Ϊ�㣬�� �����������ƣ����µ������滻���൱��������ȥ��������ֱ������Ϊ0��������23-i ($t7)��
# ÿ����λ������� ���� �������̼��� $t3����һλ��� ���λ
    li		$t7, 	23
    sub		$t7, 	$t7, 	$t5
# ������ $t6
    li		$t6, 	0
div_loop2:
# ��������1λ
    sll     $t4, 	$t4, 	1
    div		$t4, 	$s5
    mflo	$t8					# $t8 = floor($t4 / $s5)
    mfhi	$t4					# $t4 = $t4 mod $s5 
# $t3����һλ���̲��ڵ�λ
    sll     $t3, 	$t3, 	1
    add		$t3, 	$t3, 	$t8
# ����������
    addi	$t6, 	$t6, 	1
# ������23-iλ��С�������������ѵõ������ֱ�ӽ���
    beq		$t6, 	$t7, 	div_end
# ������Ҫ������ β��$t3 ���ƣ�ʹС�����ֲ���23λ
    beq		$t4, 	$0, 	div_comp_dec
    j		div_loop2
div_comp_dec:
# �����Ϊ����Ϊ0���˳�ѭ����Ҫ�� β��$t3 ���ƣ�ֱ��������=23-i�������� (23-i) - $t6 λ��
    sub		$t6, 	$t7, 	$t6
    sllv    $t3, 	$t3, 	$t6
div_end:
	j		output

ERR_DivideByZero:
    la		$a0,	msg_div_zero
	li		$v0,	4	
	syscall 
	j		exit

ERR_Overflow:
	la		$a0,	msg_over_flow
	li		$v0,	4	
	syscall 
	j		exit
ERR_Underflow:
	la		$a0,	msg_under_flow
	li		$v0,	4	
	syscall 
	j		exit
output_zero:
	move	$a0,	$0
	li		$v0,	1
	syscall
	j		exit
	
output:
			
  	# ��ӡ���
	# "Result:"
	li	 	$v0,	4
	la		$a0, 	msg_result_bin
	syscall 
	# ֵ
# 	# ��������� ----------------------------------------------
	# �ж��ǲ��� 0
	beq		$t1, 	0, 		resBinExp0
	j		resBinNoZero
	resBinExp0:
	beq		$t2, 	0, 		resBinZero
	j		resBinNoZero
	resBinZero:
	la		$a0, 	string_0dot
	syscall
	# β��
	move 	$a1, 	$t3
	li		$a2, 	22
	jal		coutBits
	# "*2^"
	la		$a0, 	string_totwo
	syscall
	# t2
	move	$a0, 	$t2
	li		$v0, 	1
	syscall
	j		binEnd

	resBinNoZero:
	beq		$t1, 	0, 		skipBinNeg
	# "-"
	la		$a0, 	string_neg
	syscall
	skipBinNeg:
	# "1.
	la		$a0, 	string_1dot	
	syscall
	# β��
	move 	$a1, 	$t3
	li		$a2, 	22
	jal		coutBits
	# "*2^"
	la		$a0, 	string_totwo
	syscall
	# t2-127
	addi	$a0, 	$t2, 	-127
	li		$v0, 	1
	syscall
	j		binEnd

binEnd:
#   # ʮ��������� -------------------------------------------
	# 1. "Hex:"
	li	 	$v0,	4
	la		$a0, 	msg_result_hex
	syscall 
	# 2. ʮ�����ƽ��
	# �ж��ǲ��� 0
	beq		$t1, 	0, 		resHexExp0
	j		resHexNoZero
	resHexExp0:
	beq		$t2, 	0, 		resHexZero
	j		resHexNoZero
	resHexZero:
	# 0.
	la		$a0, 	string_0dot
	syscall

	# "000000*16^0"
	la		$a0, 	string_hex0
	syscall
	j		hexOutEnd

	resHexNoZero:
	beq		$t1, 	0, 		skipHexoutNeg
	# "-"
	la		$a0, 	string_neg
	syscall
	
	skipHexoutNeg:
	addi	$t7, 	$t2, 	-127
	bltz	$t7, 	hexoutLess
	# if (t7 >= 0)
	andi    $t4, 	$t7, 	0x3     		# $t4 = $t7 mod 4
	srl     $t5, 	$t7, 	2      			# $t5 = $t7 / 4
	j		hexFinal

	hexoutLess:
	# else
	li		$t4, 	0
	move 	$t6, 	$7

	hexoutLoop:
	andi    $t7, 	$t6, 	0x3     		# $t7 = $t6 mod 4
	beq		$t7, 	0, 		hexoutLoopEnd
	addi	$t6, 	$t6, 	-1
	addi	$t4, 	$t4, 	1
	j		hexoutLoop
	
	hexoutLoopEnd:
	srl     $t5, 	$t6, 	2      			# $t5 = $t6 / 4

	hexFinal:
	li		$t7, 	23
	sub		$t6, 	$t7, 	$t4
	srlv    $t6, 	$t3, 	$t6
	
	# ���С����ǰ����
	move 	$a0, 	$t6
	li		$a1, 	0
	jal		toHex
	
	# "."
	li	 	$v0,	4
	la		$a0, 	string_dot		
	syscall

	addi	$t6, 	$t4, 	9
	sllv    $t6, 	$t3, 	$t6
	# ���β��
	move 	$a0, 	$t6
	li		$a1, 	1
	jal		toHex
	
	# "*16^"
	li	 	$v0,	4
	la		$a0, 	string_to16
	syscall

	# ���t5
	li		$v0, 	1
	move 	$a0, 	$t5
	syscall
	
	hexOutEnd:
	# ��������
	li		$v0, 	11
	li		$a0, 	'\n'
	syscall
	syscall

	# 3. jr
	lw		$ra,	20($sp)
	lw 		$fp,	16($sp)
	addiu 	$sp,	$sp,	32
	jr		$ra

# ---------------------------------------------------
# void coutBits(a1 content, a2 startIndex)
coutBits: # Ҫ��ʾ�����ݴ���a1���ӵ�a2λ��0��ʼ����ʼ���
    addi	$sp,	$sp,	-32
    sw		$t1,    28($sp)
    sw		$t6,    24($sp)
    sw	 	$ra,	20($sp)
    sw		$fp,	16($sp)
    addiu 	$fp,	$sp,	28
    
    move 	$t6,    $a2
    li      $v0,    4

	shiftLoop:  
    srlv    $t1,    $a1,    $t6
    andi    $t1,    $t1,    0x1
    beqz    $t1,    is0
    j       is1
    is0:        
    la      $a0,    string_0
    j       printBin
    is1:        
    la      $a0,    string_1
    j       printBin
    
    printBin:   
    syscall

    addi    $t6,    $t6,    -1
    bgez    $t6,    shiftLoop
    
    # return
    lw		$t1,    28($sp)
    lw		$t6,    24($sp)		
    lw		$ra,	20($sp)
    lw 		$fp,	16($sp)
    addiu 	$sp,	$sp,	32
    jr      $ra
# -----------------------------------------
# void toHex(a0 content, a1 flag)
toHex: # a0ΪҪ���������a1 = 0 ʱ�����3:0���������31:8
    bne		$a1,    0,      high
    low: # ���3:0
    andi    $a0,    $a0,   0xf     			# $a0 = $a0��4λ
    lb		$a0,    hex_table($a0)
    # ���
    li		$v0,    11
    
    j		toHexEnd

    high: # ���31:8
    # ��ʼ��
    srl     $a0,    $a0,    8      			# $a0 = $a0 >> 8
    li		$t9,    5
    
    toHexLoop:
    andi    $t7,    $a0,    0xf     		# $t7 = $a0��4λ
    lb		$t8,    hex_table($t7)
    sb		$t8,    hex_digits($t9)
    sub		$t9,    $t9,    1
    srl     $a0,    $a0,    4
    bgez	$t9,    toHexLoop
    
    la		$a0,    hex_digits

    # ������
    li		$v0,    4

    toHexEnd:
    syscall
    jr		$ra
# -----------------------------------------

exit:
	li		$v0,	10
	syscall
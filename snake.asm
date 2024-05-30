
@clear
mov $@_$DATA+4096,%edx
mov $1600000,%ecx
@clear_loop
movb $0,(%rdx)
inc %edx
dec %ecx
jne @clear_loop
ret

@paint_triangle_2d_subproc
mov 32(%rbp),%esi
sub 16(%rbp),%esi
mov 56(%rbp),%edi
sub 40(%rbp),%edi
mov %ecx,%eax
sub 40(%rbp),%eax
imul %esi
idiv %edi
add 16(%rbp),%eax
mov %eax,24(%rsp)
# paint_line
# 16(%rbp) -- y
# 24(%rbp) -- x1
# 32(%rbp) -- x2
# 40(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rcx
push %rdx
mov 24(%rbp),%eax
mov 32(%rbp),%ecx
cmp %eax,%ecx
jg @paint_line_swap
mov %eax,32(%rbp)
mov %ecx,24(%rbp)
sub %ecx,%eax
je @paint_line_end
@paint_line_swap

mov 16(%rbp),%eax
neg %eax
add $200,%eax
mov $800,%edx
imul %edx
mov 32(%rbp),%ecx
mov 24(%rbp),%edx
sub %edx,%ecx
add %edx,%eax
shl $2,%eax
add $@_$DATA+4096+1600,%eax
mov 40(%rbp),%edx
@paint_line_loop
mov %edx,(%rax)
add $4,%eax
dec %ecx
jne @paint_line_loop

@paint_line_end
pop %rdx
pop %rcx
mov %rbp,%rsp
pop %rbp
ret

@swap_points
# %eax -- p1
# %ecx -- p2
mov (%rax),%rdx
xchg %rdx,(%rcx)
mov %rdx,(%rax)
mov -24(%rax),%rdx
xchg %rdx,-24(%rcx)
mov %rdx,-24(%rax)
ret

@paint_triangle_2d
# 16(%rbp) -- x1
# 24(%rbp) -- x2
# 32(%rbp) -- x3
# 40(%rbp) -- y1
# 48(%rbp) -- y2
# 56(%rbp) -- y3
# 88(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
push %rdx
push %rsi
push %rdi

mov 40(%rbp),%eax
lea 48(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort1
lea 40(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort1

mov 40(%rbp),%eax
lea 56(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort2
lea 40(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort2

mov 48(%rbp),%eax
lea 56(%rbp),%rcx
cmp (%rcx),%eax
jle @paint_triangle_2d_sort3
lea 48(%rbp),%rax
call @swap_points
@paint_triangle_2d_sort3

sub $48,%rsp
mov 88(%rbp),%eax
mov %eax,24(%rsp)

mov 40(%rbp),%ecx
@paint_triangle_2d_loop1
cmp 48(%rbp),%ecx
jge @paint_triangle_2d_loop1_end
mov %ecx,(%rsp)
mov 24(%rbp),%esi
sub 16(%rbp),%esi
mov 48(%rbp),%edi
sub 40(%rbp),%edi
mov %ecx,%eax
sub 40(%rbp),%eax
imul %esi
idiv %edi
add 16(%rbp),%eax
mov %eax,8(%rsp)

call @paint_triangle_2d_subproc

inc %ecx
jmp @paint_triangle_2d_loop1
@paint_triangle_2d_loop1_end

@paint_triangle_2d_loop2
cmp 56(%rbp),%ecx
jge @paint_triangle_2d_loop2_end
mov %ecx,(%rsp)
mov 32(%rbp),%esi
sub 24(%rbp),%esi
mov 56(%rbp),%edi
sub 48(%rbp),%edi
mov %ecx,%eax
sub 48(%rbp),%eax
imul %esi
idiv %edi
add 24(%rbp),%eax
mov %eax,8(%rsp)

call @paint_triangle_2d_subproc

inc %ecx
jmp @paint_triangle_2d_loop2
@paint_triangle_2d_loop2_end

add $48,%rsp

pop %rdi
pop %rsi
pop %rdx
pop %rcx
pop %rax
mov %rbp,%rsp
pop %rbp
ret

@vector_transform
# %rax -- ptr
push %rcx
mov $5,%ecx
cvtsi2ss %ecx,%xmm7
dec %ecx
cvtsi2ss %ecx,%xmm1
dec %ecx
cvtsi2ss %ecx,%xmm2
movss 4(%rax),%xmm3
movss 8(%rax),%xmm4
movss %xmm3,%xmm5
movss %xmm4,%xmm6
mulss %xmm1,%xmm3
mulss %xmm2,%xmm4
addss %xmm4,%xmm3
mulss %xmm2,%xmm5
mulss %xmm1,%xmm6
subss %xmm6,%xmm5
mov $100,%ecx
cvtsi2ss %ecx,%xmm0
addss %xmm0,%xmm5
divss %xmm5,%xmm3
movss %xmm3,4(%rax)
movss (%rax),%xmm0
mulss %xmm7,%xmm0
divss %xmm5,%xmm0
movss %xmm0,(%rax)
pop %rcx
ret

@paint_triangle_3d
# 16(%rbp) -- p1
# 32(%rbp) -- p2
# 48(%rbp) -- p3
# 64(%rbp) -- color
push %rbp
mov %rsp,%rbp
push %rax
push %rcx
push %rdx
sub $80,%rsp

mov 64(%rbp),%eax
mov %eax,72(%rsp)

lea 16(%rsp),%rax
mov $48,%ecx
@paint_triangle_3d_loop
push %rax
lea (%rcx,%rbp,1),%rax
call @vector_transform
pop %rax

mov $450,%edx
cvtsi2ss %edx,%xmm1

movss (%rcx,%rbp,1),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%edx
mov %edx,(%rax)
movss 4(%rcx,%rbp,1),%xmm0
mulss %xmm1,%xmm0
cvtss2si %xmm0,%edx
mov %edx,24(%rax)
sub $8,%rax
sub $16,%ecx
jne @paint_triangle_3d_loop

call @paint_triangle_2d

add $80,%rsp
pop %rdx
pop %rcx
pop %rax
mov %rbp,%rsp
pop %rbp
ret


@paint_cmd
# %rax -- cmd
# %ecx -- x
# %edx -- y
push %rax
push %rcx
push %rdx
sub $80,%rsp

# @_$DATA+600 is zero
movss @_$DATA+600,%xmm0
shufps $0x00,%xmm0,%xmm0
cvtsi2ss %edx,%xmm1
movss %xmm1,%xmm0
shufps $0x50,%xmm0,%xmm0
cvtsi2ss %ecx,%xmm1
movss %xmm1,%xmm0

movups (%rax),%xmm2
addps %xmm0,%xmm2
movups %xmm2,(%rsp)
movups 16(%rax),%xmm2
addps %xmm0,%xmm2
movups %xmm2,16(%rsp)
movups 32(%rax),%xmm2
addps %xmm0,%xmm2
movups %xmm2,32(%rsp)

mov 48(%rax),%ecx
mov %ecx,48(%rsp)
call @paint_triangle_3d

add $80,%rsp
pop %rdx
pop %rcx
pop %rax
ret


@paint_cmd2
# %rdi -- cmd
# %rsi -- points
# %ecx -- x
# %edx -- y
push %rax
push %rbx
push %rdi
sub $64,%rsp
xor %ebx,%ebx
mov (%rdi),%bl
and $0x3f,%bl
shl $4,%bx
movups (%rsi,%rbx,1),%xmm0
movups %xmm0,(%rsp)

mov (%rdi),%bx
and $0xfc0,%bx
shr $2,%bx
movups (%rsi,%rbx,1),%xmm0
movups %xmm0,16(%rsp)

mov 1(%rdi),%bx
and $0x3f0,%bx
movups (%rsi,%rbx,1),%xmm0
movups %xmm0,32(%rsp)

mov 2(%rdi),%bl
shr $2,%bl
and $0x3c,%bx
mov @color_tab(%rbx),%ebx
mov %ebx,48(%rsp)


mov %rsp,%rax
call @paint_cmd

add $64,%rsp
pop %rdi
pop %rbx
pop %rax
ret

@paint_element
# %rdi -- cmd
# %ecx -- x
# %edx -- y
test %rdi,%rdi
je @paint_element_end
push %rax
push %rbx
push %rdi
push %rsi
mov $@_$DATA+800,%rsi
movzbl (%rdi),%ebx
inc %rdi
@paint_element_loop
call @paint_cmd2
add $3,%rdi
dec %ebx
jne @paint_element_loop
pop %rsi
pop %rdi
pop %rbx
pop %rax
@paint_element_end
ret

@init_point_tab
mov $40,%ecx
mov $@_$DATA+802,%rax
mov $@point_tab,%rdx
xor %ebx,%ebx
@init_point_tab_loop
mov (%rdx),%bl
and $0xf,%bl
add %bl,%bl
mov @value_tab(%rbx),%di
mov %di,8(%rax)
mov (%rdx),%bl
and $0xf0,%bl
shr $3,%bl
mov @value_tab(%rbx),%di
mov %di,4(%rax)
mov 1(%rdx),%bl
and $0xf,%bl
add %bl,%bl
mov @value_tab(%rbx),%di
mov %di,(%rax)
add $16,%rax
add $2,%rdx
dec %ecx
jne @init_point_tab_loop
ret

@paint_snake
push %rax
push %rcx
push %rdx
push %rbx
push %rdi
mov $256,%eax
@paint_snake_loop
lea -1(%rax),%ebx
test $8,%bl
jne @paint_snake_reorder
xor $7,%bl
@paint_snake_reorder
mov %ebx,%ecx
mov @_$DATA+256(%rbx),%dil
movzbl %dil,%ebx
sub $1,%ebx
jl @paint_snake_skip
mov %ecx,%edx
shr $4,%edx
and $0xf,%ecx
sub $8,%ecx
sub $8,%edx
movzbl @elem_tab(%rbx),%edi
add $@elem_head,%edi
call @paint_element
@paint_snake_skip
dec %eax
jne @paint_snake_loop
pop %rdi
pop %rbx
pop %rdx
pop %rcx
pop %rax
ret


@paint_all
push %rbx
push %r12
push %r13
call @clear
xor %ecx,%ecx
xor %edx,%edx
mov $@elem_wall,%rdi
call @paint_element
movzbl @_$DATA+0,%ecx
mov %ecx,%edx
shr $4,%edx
and $0x0f,%cl
sub $8,%ecx
sub $8,%edx
mov $@elem_fruit,%rdi
call @paint_element

call @paint_snake

xor %ecx,%ecx
xor %edx,%edx
mov $@elem_wall_top,%rdi
call @paint_element

pop %r13
pop %r12
pop %rbx
ret

@rand
push %rcx
push %rdx
push %rbx
push %rsi
push %rdi
push %rbp
mov %rsp,%rbp
sub $48,%rsp
and $0xf0,%spl
@rand_loop
lea 32(%rsp),%rcx
.dllcall "msvcrt.dll" "rand_s"
test %rax,%rax
jne @rand_loop
mov 32(%rsp),%eax

mov %rbp,%rsp
pop %rbp
pop %rdi
pop %rsi
pop %rbx
pop %rdx
pop %rcx
ret

@generate_fruit
push %rax
push %rcx
push %rdx
@generate_loop
call @rand
movzbl %al,%edx
cmpb $0,@_$DATA+256(%rdx)
jne @generate_loop
mov %al,@_$DATA+0
pop %rdx
pop %rcx
pop %rax
ret

@game_over
sub $32,%rsp
and $0xf0,%spl
mov @_$DATA+32,%rcx
xor %edx,%edx
.dllcall "user32.dll" "KillTimer"
xor %ecx,%ecx
mov $@game_over_msg,%rdx
mov $@msg_str,%r8
xor %r9d,%r9d
.dllcall "user32.dll" "MessageBoxA"
jmp @End

@game_win
sub $32,%rsp
and $0xf0,%spl
mov @_$DATA+32,%rcx
xor %edx,%edx
.dllcall "user32.dll" "KillTimer"
xor %ecx,%ecx
mov $@game_win_msg,%rdx
mov $@msg_str,%r8
xor %r9d,%r9d
.dllcall "user32.dll" "MessageBoxA"
jmp @End

@snake_move
mov @_$DATA+8,%eax
mov @_$DATA+12,%ecx
shl $4,%ecx
or %ecx,%eax
mov @_$DATA+256(%rax),%cl
xor %edx,%edx
xchg %edx,@_$DATA+20
test %edx,%edx
jne @snake_grow
movb $0,@_$DATA+256(%rax)
cmp $2,%cl
jne @snake_down3
decb @_$DATA+12
@snake_down3
cmp $3,%cl
jne @snake_up3
incb @_$DATA+12
@snake_up3
cmp $4,%cl
jne @snake_right3
incb @_$DATA+8
@snake_right3
cmp $5,%cl
jne @snake_left3
decb @_$DATA+8
@snake_left3
@snake_grow

mov @_$DATA+40,%eax
mov @_$DATA+17,%cl
mov %cl,@_$DATA+16
mov %rax,%rsi

mov %al,%dl
and $0xf,%dl

cmp $2,%cl
jne @snake_down2
sub $16,%al
jb @game_over
@snake_down2
cmp $3,%cl
jne @snake_up2
sub $240,%al
jae @game_over
@snake_up2
cmp $4,%cl
jne @snake_right2
cmp $15,%dl
je @game_over
inc %eax
@snake_right2
cmp $5,%cl
jne @snake_left2
cmp $0,%dl
je @game_over
dec %eax
@snake_left2
mov %eax,@_$DATA+40

cmpb $0,@_$DATA+256(%rax)
jne @game_over
cmp %al,@_$DATA+0
jne @snake_no_eat

mov %cl,@_$DATA+256(%rsi)
movb $1,@_$DATA+256(%rax)
call @generate_fruit
incl @_$DATA+24
cmpl $50,@_$DATA+24
jae @game_win
movb $1,@_$DATA+20

jmp @snake_eat_end
@snake_no_eat
mov %cl,@_$DATA+256(%rsi)
movb $1,@_$DATA+256(%rax)
@snake_eat_end
ret

@game_init
mov $0x04040404,%eax
mov %eax,@_$DATA+256
movb $1,@_$DATA+260
mov %ax,@_$DATA+16
mov %al,@_$DATA+40
call @generate_fruit
ret

@WndProc
sub $40,%rsp
cmp $2,%edx
je @End
push %r12
push %r13
push %rbx
push %rbx
push %r9
push %r8
push %rdx
push %rcx
sub $112,%rsp
cmp $15,%edx
jne @End_WM_PAINT



lea 32(%rsp),%rdx
.dllcall "user32.dll" "BeginPaint"
mov %rax,%rbx
mov %rax,%rcx
.dllcall "gdi32.dll" "CreateCompatibleDC"
mov %rax,%r12
mov %rbx,%rcx
mov $800,%edx
mov $500,%r8d
.dllcall "gdi32.dll" "CreateCompatibleBitmap"
mov %rax,%r13
mov %rax,%rdx
mov %r12,%rcx
.dllcall "gdi32.dll" "SelectObject"

call @paint_all

mov %r13,%rcx
mov $1600000,%edx
mov $@_$DATA+4096,%r8
.dllcall "gdi32.dll" "SetBitmapBits"
mov %rbx,%rcx
xor %edx,%edx
xor %r8d,%r8d
mov $800,%r9d
push %rdx
pushq $0xcc0020
push %rdx
push %rdx
push %r12
pushq $500
sub $32,%rsp
.dllcall "gdi32.dll" "BitBlt"
add $80,%rsp
mov %r13,%rcx
.dllcall "gdi32.dll" "DeleteObject"
mov %r12,%rcx
.dllcall "gdi32.dll" "DeleteDC"

mov 112(%rsp),%rcx
lea 32(%rsp),%rdx
.dllcall "user32.dll" "EndPaint"

jmp @End_WndProc
@End_WM_PAINT

cmp $275,%edx
jne @End_WM_TIMER

push %rcx
call @snake_move
pop %rcx
xor %edx,%edx
xor %r8d,%r8d
.dllcall "user32.dll" "InvalidateRect"

jmp @End_WndProc
@End_WM_TIMER

cmp $256,%edx
jne @End_WM_KEYDOWN
cmp $37,%r8d
jne @End_VK_LEFT
cmpb $4,@_$DATA+16
je @End_VK_LEFT
movb $5,@_$DATA+17
@End_VK_LEFT

cmp $38,%r8d
jne @End_VK_UP
cmpb $2,@_$DATA+16
je @End_VK_UP
movb $3,@_$DATA+17
@End_VK_UP

cmp $39,%r8d
jne @End_VK_RIGHT
cmpb $5,@_$DATA+16
je @End_VK_RIGHT
movb $4,@_$DATA+17
@End_VK_RIGHT

cmp $40,%r8d
jne @End_VK_DOWN
cmpb $3,@_$DATA+16
je @End_VK_DOWN
movb $2,@_$DATA+17
@End_VK_DOWN

@End_WM_KEYDOWN

@End_WndProc

add $112,%rsp
pop %rcx
pop %rdx
pop %r8
pop %r9
pop %rbx
pop %rbx
pop %r13
pop %r12
.dllcall "user32.dll" "DefWindowProcA"
add $40,%rsp
ret

.entry
push %rbp
mov %rsp,%rbp
.dllcall "user32.dll" "SetProcessDPIAware"
call @init_point_tab
call @game_init
xor %ebx,%ebx
push %rbx
pushq $@WinName
push %rbx
pushq $8
push %rbx
push %rbx
pushq $0x400000
push %rbx
pushq $@WndProc
pushq $80
sub $32,%rsp
xor %ecx,%ecx
mov $0x7f00,%edx
.dllcall "user32.dll" "LoadIconA"
mov %rax,64(%rsp)
xor %ecx,%ecx
mov $0x7f00,%edx
.dllcall "user32.dll" "LoadCursorA"
mov %rax,72(%rsp)

lea 32(%rsp),%rcx
.dllcall "user32.dll" "RegisterClassExA"
test %rax,%rax
je @End

xor %ecx,%ecx
inc %ch
mov $@WinName,%edx
mov %edx,%r8d
mov $0x10c80000,%r9d
push %rbx
pushq $0x400000
push %rbx
push %rbx
pushq $500
pushq $800
mov $0x80000000,%eax
push %rax
push %rax
sub $32,%rsp
.dllcall "user32.dll" "CreateWindowExA"

test %rax,%rax
je @End

mov %rax,@_$DATA+32

mov %rax,%rcx
xor %edx,%edx
mov $300,%r8d
xor %r9d,%r9d
.dllcall "user32.dll" "SetTimer"

@MsgLoop
lea 32(%rsp),%rcx
xor %edx,%edx
xor %r8d,%r8d
xor %r9d,%r9d
.dllcall "user32.dll" "GetMessageA"
cmp $0,%rax
jle @End

lea 32(%rsp),%rcx
.dllcall "user32.dll" "TranslateMessage"
lea 32(%rsp),%rcx
.dllcall "user32.dll" "DispatchMessageA"
jmp @MsgLoop

@End
xor %ecx,%ecx
.dllcall "msvcrt.dll" "exit"

.align 2
@color_tab
.long 0xffffff,0xc0c0c0,0x909090,0x800080
.long 0xff0000,0xc00000,0x900000,0xffff00
.long 0xc0c000,0x909000,0x00ff00,0x00c000
.long 0x009000
@value_tab
.word 0x0000,0xc110,0x4110,0x3f80
.word 0xc100,0x4100,0x3e80,0x3f40
.word 0xbe80,0xbf40,0x3f00,0x3fa0
@point_tab
# wall
.word 0x110
.word 0x210
.word 0x220
.word 0x120
# 4
.word 0x113
.word 0x213
.word 0x223
.word 0x123
# 8
.word 0x440
.word 0x540
.word 0x550
.word 0x450
# 12
.word 0x443
.word 0x543
.word 0x553
.word 0x453
# 16
# center
.word 0x660
.word 0x760
.word 0x770
.word 0x670
# 20
.word 0x66a
.word 0x76a
.word 0x77a
.word 0x67a
# 24
# down
.word 0x680
.word 0x780
.word 0x68a
.word 0x78a
# 28
# up
.word 0x6b0
.word 0x7b0
.word 0x6ba
.word 0x7ba
# 32
# left
.word 0x860
.word 0x870
.word 0x86a
.word 0x87a
# 36
# right
.word 0xb60
.word 0xb70
.word 0xb6a
.word 0xb7a
@elem_wall
.byte 10
.byte 0x40,0x50,0x10
.byte 0x05,0x01,0x10
.byte 0xca,0xf2,0x10
.byte 0x8f,0xa3,0x10
.byte 0x0b,0xc2,0x20
.byte 0xcc,0xb3,0x20
.byte 0x89,0xe2,0x20
.byte 0x4e,0x93,0x20
.byte 0x48,0xa2,0x30
.byte 0xca,0x82,0x30
@elem_wall_top
.byte 8
.byte 0x44,0xd1,0x00
.byte 0x0d,0x43,0x00
.byte 0x85,0xe1,0x00
.byte 0x4e,0x53,0x00
.byte 0xc6,0xf1,0x00
.byte 0x8f,0x63,0x00
.byte 0x07,0xc1,0x00
.byte 0xcc,0x73,0x00
@elem_fruit
.byte 8
.byte 0x13,0x44,0x61
.byte 0xd4,0x35,0x61
.byte 0x91,0x64,0x61
.byte 0x56,0x15,0x61
.byte 0x50,0x54,0x51
.byte 0x15,0x05,0x51
.byte 0x54,0x65,0x41
.byte 0xd6,0x45,0x41
@elem_head
.byte 8
.byte 0x13,0x44,0x91
.byte 0xd4,0x35,0x91
.byte 0x91,0x64,0x91
.byte 0x56,0x15,0x91
.byte 0x50,0x54,0x81
.byte 0x15,0x05,0x81
.byte 0x54,0x65,0x71
.byte 0xd6,0x45,0x71
@elem_tail_up
.byte 6
.byte 0x92,0xb5,0xc1
.byte 0x5b,0x26,0xc1
.byte 0xd3,0xa5,0xc1
.byte 0x1a,0x36,0xc1
.byte 0xd6,0xa5,0xa1
.byte 0xda,0x66,0xa1
@elem_tail_down
.byte 8
.byte 0x10,0xe5,0xc1
.byte 0x1e,0x07,0xc1
.byte 0x51,0xf5,0xc1
.byte 0x5f,0x17,0xc1
.byte 0x50,0x54,0xb1
.byte 0x15,0x05,0xb1
.byte 0x54,0xf5,0xa1
.byte 0x9f,0x47,0xa1
@elem_tail_left
.byte 6
.byte 0xd0,0x74,0xc1
.byte 0x17,0x05,0xc1
.byte 0x10,0x65,0xb2
.byte 0x26,0x09,0xb1
.byte 0xd4,0x75,0xa2
.byte 0xa7,0x49,0xa1
@elem_tail_right
.byte 6
.byte 0x91,0x64,0xc1
.byte 0x56,0x15,0xc1
.byte 0x51,0x25,0xb2
.byte 0x22,0x18,0xb1
.byte 0x95,0x35,0xa2
.byte 0xa3,0x58,0xa1
@elem_tab
.byte 0,@elem_tail_up-@elem_head,@elem_tail_down-@elem_head,@elem_tail_left-@elem_head,@elem_tail_right-@elem_head
@WinName
.string "Snake"
@msg_str
.string "Message"
@game_over_msg
.string "Game over!"
@game_win_msg
.string "You win!"


# 0 -- fruit_x
# 4 -- fruit_y
# 8 -- tail_x
# 12 -- tail_y
# 16 -- direction
# 20 -- grow
# 24 -- score
# 32 -- hwnd
# 40 -- head_pos
# 256 -- map
# 800 -- point_tab
.datasize 1604096

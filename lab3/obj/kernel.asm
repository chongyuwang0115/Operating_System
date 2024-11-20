
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53260613          	addi	a2,a2,1330 # ffffffffc021156c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	354040ef          	jal	ra,ffffffffc020439e <memset>

    const char *message = "(NKU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	37a58593          	addi	a1,a1,890 # ffffffffc02043c8 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	39250513          	addi	a0,a0,914 # ffffffffc02043e8 <etext+0x20>
ffffffffc020005e:	32a000ef          	jal	ra,ffffffffc0200388 <cprintf>

    print_kerninfo();
ffffffffc0200062:	01e000ef          	jal	ra,ffffffffc0200080 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	241010ef          	jal	ra,ffffffffc0201aa6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	600030ef          	jal	ra,ffffffffc020366e <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	095020ef          	jal	ra,ffffffffc020290a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200082:	00004517          	auipc	a0,0x4
ffffffffc0200086:	36e50513          	addi	a0,a0,878 # ffffffffc02043f0 <etext+0x28>
void print_kerninfo(void) {
ffffffffc020008a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020008c:	2fc000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200090:	00000597          	auipc	a1,0x0
ffffffffc0200094:	fa258593          	addi	a1,a1,-94 # ffffffffc0200032 <kern_init>
ffffffffc0200098:	00004517          	auipc	a0,0x4
ffffffffc020009c:	37850513          	addi	a0,a0,888 # ffffffffc0204410 <etext+0x48>
ffffffffc02000a0:	2e8000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02000a4:	00004597          	auipc	a1,0x4
ffffffffc02000a8:	32458593          	addi	a1,a1,804 # ffffffffc02043c8 <etext>
ffffffffc02000ac:	00004517          	auipc	a0,0x4
ffffffffc02000b0:	38450513          	addi	a0,a0,900 # ffffffffc0204430 <etext+0x68>
ffffffffc02000b4:	2d4000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02000b8:	0000a597          	auipc	a1,0xa
ffffffffc02000bc:	f8858593          	addi	a1,a1,-120 # ffffffffc020a040 <ide>
ffffffffc02000c0:	00004517          	auipc	a0,0x4
ffffffffc02000c4:	39050513          	addi	a0,a0,912 # ffffffffc0204450 <etext+0x88>
ffffffffc02000c8:	2c0000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02000cc:	00011597          	auipc	a1,0x11
ffffffffc02000d0:	4a058593          	addi	a1,a1,1184 # ffffffffc021156c <end>
ffffffffc02000d4:	00004517          	auipc	a0,0x4
ffffffffc02000d8:	39c50513          	addi	a0,a0,924 # ffffffffc0204470 <etext+0xa8>
ffffffffc02000dc:	2ac000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02000e0:	00012597          	auipc	a1,0x12
ffffffffc02000e4:	88b58593          	addi	a1,a1,-1909 # ffffffffc021196b <end+0x3ff>
ffffffffc02000e8:	00000797          	auipc	a5,0x0
ffffffffc02000ec:	f4a78793          	addi	a5,a5,-182 # ffffffffc0200032 <kern_init>
ffffffffc02000f0:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000f4:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000f8:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000fa:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000fe:	95be                	add	a1,a1,a5
ffffffffc0200100:	85a9                	srai	a1,a1,0xa
ffffffffc0200102:	00004517          	auipc	a0,0x4
ffffffffc0200106:	38e50513          	addi	a0,a0,910 # ffffffffc0204490 <etext+0xc8>
}
ffffffffc020010a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020010c:	acb5                	j	ffffffffc0200388 <cprintf>

ffffffffc020010e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020010e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200110:	00004617          	auipc	a2,0x4
ffffffffc0200114:	3b060613          	addi	a2,a2,944 # ffffffffc02044c0 <etext+0xf8>
ffffffffc0200118:	04e00593          	li	a1,78
ffffffffc020011c:	00004517          	auipc	a0,0x4
ffffffffc0200120:	3bc50513          	addi	a0,a0,956 # ffffffffc02044d8 <etext+0x110>
void print_stackframe(void) {
ffffffffc0200124:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200126:	1cc000ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc020012a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020012c:	00004617          	auipc	a2,0x4
ffffffffc0200130:	3c460613          	addi	a2,a2,964 # ffffffffc02044f0 <etext+0x128>
ffffffffc0200134:	00004597          	auipc	a1,0x4
ffffffffc0200138:	3dc58593          	addi	a1,a1,988 # ffffffffc0204510 <etext+0x148>
ffffffffc020013c:	00004517          	auipc	a0,0x4
ffffffffc0200140:	3dc50513          	addi	a0,a0,988 # ffffffffc0204518 <etext+0x150>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200146:	242000ef          	jal	ra,ffffffffc0200388 <cprintf>
ffffffffc020014a:	00004617          	auipc	a2,0x4
ffffffffc020014e:	3de60613          	addi	a2,a2,990 # ffffffffc0204528 <etext+0x160>
ffffffffc0200152:	00004597          	auipc	a1,0x4
ffffffffc0200156:	3fe58593          	addi	a1,a1,1022 # ffffffffc0204550 <etext+0x188>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	3be50513          	addi	a0,a0,958 # ffffffffc0204518 <etext+0x150>
ffffffffc0200162:	226000ef          	jal	ra,ffffffffc0200388 <cprintf>
ffffffffc0200166:	00004617          	auipc	a2,0x4
ffffffffc020016a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204560 <etext+0x198>
ffffffffc020016e:	00004597          	auipc	a1,0x4
ffffffffc0200172:	41258593          	addi	a1,a1,1042 # ffffffffc0204580 <etext+0x1b8>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	3a250513          	addi	a0,a0,930 # ffffffffc0204518 <etext+0x150>
ffffffffc020017e:	20a000ef          	jal	ra,ffffffffc0200388 <cprintf>
    }
    return 0;
}
ffffffffc0200182:	60a2                	ld	ra,8(sp)
ffffffffc0200184:	4501                	li	a0,0
ffffffffc0200186:	0141                	addi	sp,sp,16
ffffffffc0200188:	8082                	ret

ffffffffc020018a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020018a:	1141                	addi	sp,sp,-16
ffffffffc020018c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020018e:	ef3ff0ef          	jal	ra,ffffffffc0200080 <print_kerninfo>
    return 0;
}
ffffffffc0200192:	60a2                	ld	ra,8(sp)
ffffffffc0200194:	4501                	li	a0,0
ffffffffc0200196:	0141                	addi	sp,sp,16
ffffffffc0200198:	8082                	ret

ffffffffc020019a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020019a:	1141                	addi	sp,sp,-16
ffffffffc020019c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020019e:	f71ff0ef          	jal	ra,ffffffffc020010e <print_stackframe>
    return 0;
}
ffffffffc02001a2:	60a2                	ld	ra,8(sp)
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	0141                	addi	sp,sp,16
ffffffffc02001a8:	8082                	ret

ffffffffc02001aa <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02001aa:	7115                	addi	sp,sp,-224
ffffffffc02001ac:	ed5e                	sd	s7,152(sp)
ffffffffc02001ae:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001b0:	00004517          	auipc	a0,0x4
ffffffffc02001b4:	3e050513          	addi	a0,a0,992 # ffffffffc0204590 <etext+0x1c8>
kmonitor(struct trapframe *tf) {
ffffffffc02001b8:	ed86                	sd	ra,216(sp)
ffffffffc02001ba:	e9a2                	sd	s0,208(sp)
ffffffffc02001bc:	e5a6                	sd	s1,200(sp)
ffffffffc02001be:	e1ca                	sd	s2,192(sp)
ffffffffc02001c0:	fd4e                	sd	s3,184(sp)
ffffffffc02001c2:	f952                	sd	s4,176(sp)
ffffffffc02001c4:	f556                	sd	s5,168(sp)
ffffffffc02001c6:	f15a                	sd	s6,160(sp)
ffffffffc02001c8:	e962                	sd	s8,144(sp)
ffffffffc02001ca:	e566                	sd	s9,136(sp)
ffffffffc02001cc:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001ce:	1ba000ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02001d2:	00004517          	auipc	a0,0x4
ffffffffc02001d6:	3e650513          	addi	a0,a0,998 # ffffffffc02045b8 <etext+0x1f0>
ffffffffc02001da:	1ae000ef          	jal	ra,ffffffffc0200388 <cprintf>
    if (tf != NULL) {
ffffffffc02001de:	000b8563          	beqz	s7,ffffffffc02001e8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02001e2:	855e                	mv	a0,s7
ffffffffc02001e4:	56a000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02001e8:	00004c17          	auipc	s8,0x4
ffffffffc02001ec:	438c0c13          	addi	s8,s8,1080 # ffffffffc0204620 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02001f0:	00006917          	auipc	s2,0x6
ffffffffc02001f4:	84090913          	addi	s2,s2,-1984 # ffffffffc0205a30 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02001f8:	00004497          	auipc	s1,0x4
ffffffffc02001fc:	3e848493          	addi	s1,s1,1000 # ffffffffc02045e0 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc0200200:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200202:	00004b17          	auipc	s6,0x4
ffffffffc0200206:	3e6b0b13          	addi	s6,s6,998 # ffffffffc02045e8 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc020020a:	00004a17          	auipc	s4,0x4
ffffffffc020020e:	306a0a13          	addi	s4,s4,774 # ffffffffc0204510 <etext+0x148>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200212:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200214:	854a                	mv	a0,s2
ffffffffc0200216:	058040ef          	jal	ra,ffffffffc020426e <readline>
ffffffffc020021a:	842a                	mv	s0,a0
ffffffffc020021c:	dd65                	beqz	a0,ffffffffc0200214 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020021e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200222:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200224:	e1bd                	bnez	a1,ffffffffc020028a <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200226:	fe0c87e3          	beqz	s9,ffffffffc0200214 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020022a:	6582                	ld	a1,0(sp)
ffffffffc020022c:	00004d17          	auipc	s10,0x4
ffffffffc0200230:	3f4d0d13          	addi	s10,s10,1012 # ffffffffc0204620 <commands>
        argv[argc ++] = buf;
ffffffffc0200234:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200236:	4401                	li	s0,0
ffffffffc0200238:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020023a:	130040ef          	jal	ra,ffffffffc020436a <strcmp>
ffffffffc020023e:	c919                	beqz	a0,ffffffffc0200254 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200240:	2405                	addiw	s0,s0,1
ffffffffc0200242:	0b540063          	beq	s0,s5,ffffffffc02002e2 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200246:	000d3503          	ld	a0,0(s10)
ffffffffc020024a:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020024c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020024e:	11c040ef          	jal	ra,ffffffffc020436a <strcmp>
ffffffffc0200252:	f57d                	bnez	a0,ffffffffc0200240 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200254:	00141793          	slli	a5,s0,0x1
ffffffffc0200258:	97a2                	add	a5,a5,s0
ffffffffc020025a:	078e                	slli	a5,a5,0x3
ffffffffc020025c:	97e2                	add	a5,a5,s8
ffffffffc020025e:	6b9c                	ld	a5,16(a5)
ffffffffc0200260:	865e                	mv	a2,s7
ffffffffc0200262:	002c                	addi	a1,sp,8
ffffffffc0200264:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200268:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020026a:	fa0555e3          	bgez	a0,ffffffffc0200214 <kmonitor+0x6a>
}
ffffffffc020026e:	60ee                	ld	ra,216(sp)
ffffffffc0200270:	644e                	ld	s0,208(sp)
ffffffffc0200272:	64ae                	ld	s1,200(sp)
ffffffffc0200274:	690e                	ld	s2,192(sp)
ffffffffc0200276:	79ea                	ld	s3,184(sp)
ffffffffc0200278:	7a4a                	ld	s4,176(sp)
ffffffffc020027a:	7aaa                	ld	s5,168(sp)
ffffffffc020027c:	7b0a                	ld	s6,160(sp)
ffffffffc020027e:	6bea                	ld	s7,152(sp)
ffffffffc0200280:	6c4a                	ld	s8,144(sp)
ffffffffc0200282:	6caa                	ld	s9,136(sp)
ffffffffc0200284:	6d0a                	ld	s10,128(sp)
ffffffffc0200286:	612d                	addi	sp,sp,224
ffffffffc0200288:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020028a:	8526                	mv	a0,s1
ffffffffc020028c:	0fc040ef          	jal	ra,ffffffffc0204388 <strchr>
ffffffffc0200290:	c901                	beqz	a0,ffffffffc02002a0 <kmonitor+0xf6>
ffffffffc0200292:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200296:	00040023          	sb	zero,0(s0)
ffffffffc020029a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020029c:	d5c9                	beqz	a1,ffffffffc0200226 <kmonitor+0x7c>
ffffffffc020029e:	b7f5                	j	ffffffffc020028a <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02002a0:	00044783          	lbu	a5,0(s0)
ffffffffc02002a4:	d3c9                	beqz	a5,ffffffffc0200226 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02002a6:	033c8963          	beq	s9,s3,ffffffffc02002d8 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02002aa:	003c9793          	slli	a5,s9,0x3
ffffffffc02002ae:	0118                	addi	a4,sp,128
ffffffffc02002b0:	97ba                	add	a5,a5,a4
ffffffffc02002b2:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002b6:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02002ba:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002bc:	e591                	bnez	a1,ffffffffc02002c8 <kmonitor+0x11e>
ffffffffc02002be:	b7b5                	j	ffffffffc020022a <kmonitor+0x80>
ffffffffc02002c0:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02002c4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002c6:	d1a5                	beqz	a1,ffffffffc0200226 <kmonitor+0x7c>
ffffffffc02002c8:	8526                	mv	a0,s1
ffffffffc02002ca:	0be040ef          	jal	ra,ffffffffc0204388 <strchr>
ffffffffc02002ce:	d96d                	beqz	a0,ffffffffc02002c0 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d0:	00044583          	lbu	a1,0(s0)
ffffffffc02002d4:	d9a9                	beqz	a1,ffffffffc0200226 <kmonitor+0x7c>
ffffffffc02002d6:	bf55                	j	ffffffffc020028a <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002d8:	45c1                	li	a1,16
ffffffffc02002da:	855a                	mv	a0,s6
ffffffffc02002dc:	0ac000ef          	jal	ra,ffffffffc0200388 <cprintf>
ffffffffc02002e0:	b7e9                	j	ffffffffc02002aa <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002e2:	6582                	ld	a1,0(sp)
ffffffffc02002e4:	00004517          	auipc	a0,0x4
ffffffffc02002e8:	32450513          	addi	a0,a0,804 # ffffffffc0204608 <etext+0x240>
ffffffffc02002ec:	09c000ef          	jal	ra,ffffffffc0200388 <cprintf>
    return 0;
ffffffffc02002f0:	b715                	j	ffffffffc0200214 <kmonitor+0x6a>

ffffffffc02002f2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02002f2:	00011317          	auipc	t1,0x11
ffffffffc02002f6:	20630313          	addi	t1,t1,518 # ffffffffc02114f8 <is_panic>
ffffffffc02002fa:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02002fe:	715d                	addi	sp,sp,-80
ffffffffc0200300:	ec06                	sd	ra,24(sp)
ffffffffc0200302:	e822                	sd	s0,16(sp)
ffffffffc0200304:	f436                	sd	a3,40(sp)
ffffffffc0200306:	f83a                	sd	a4,48(sp)
ffffffffc0200308:	fc3e                	sd	a5,56(sp)
ffffffffc020030a:	e0c2                	sd	a6,64(sp)
ffffffffc020030c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020030e:	020e1a63          	bnez	t3,ffffffffc0200342 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200312:	4785                	li	a5,1
ffffffffc0200314:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200318:	8432                	mv	s0,a2
ffffffffc020031a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020031c:	862e                	mv	a2,a1
ffffffffc020031e:	85aa                	mv	a1,a0
ffffffffc0200320:	00004517          	auipc	a0,0x4
ffffffffc0200324:	34850513          	addi	a0,a0,840 # ffffffffc0204668 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200328:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020032a:	05e000ef          	jal	ra,ffffffffc0200388 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020032e:	65a2                	ld	a1,8(sp)
ffffffffc0200330:	8522                	mv	a0,s0
ffffffffc0200332:	036000ef          	jal	ra,ffffffffc0200368 <vcprintf>
    cprintf("\n");
ffffffffc0200336:	00005517          	auipc	a0,0x5
ffffffffc020033a:	24a50513          	addi	a0,a0,586 # ffffffffc0205580 <default_pmm_manager+0x478>
ffffffffc020033e:	04a000ef          	jal	ra,ffffffffc0200388 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200342:	1ac000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200346:	4501                	li	a0,0
ffffffffc0200348:	e63ff0ef          	jal	ra,ffffffffc02001aa <kmonitor>
    while (1) {
ffffffffc020034c:	bfed                	j	ffffffffc0200346 <__panic+0x54>

ffffffffc020034e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020034e:	1141                	addi	sp,sp,-16
ffffffffc0200350:	e022                	sd	s0,0(sp)
ffffffffc0200352:	e406                	sd	ra,8(sp)
ffffffffc0200354:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200356:	0cc000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020035a:	401c                	lw	a5,0(s0)
}
ffffffffc020035c:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020035e:	2785                	addiw	a5,a5,1
ffffffffc0200360:	c01c                	sw	a5,0(s0)
}
ffffffffc0200362:	6402                	ld	s0,0(sp)
ffffffffc0200364:	0141                	addi	sp,sp,16
ffffffffc0200366:	8082                	ret

ffffffffc0200368 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200368:	1101                	addi	sp,sp,-32
ffffffffc020036a:	862a                	mv	a2,a0
ffffffffc020036c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020036e:	00000517          	auipc	a0,0x0
ffffffffc0200372:	fe050513          	addi	a0,a0,-32 # ffffffffc020034e <cputch>
ffffffffc0200376:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200378:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020037a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020037c:	371030ef          	jal	ra,ffffffffc0203eec <vprintfmt>
    return cnt;
}
ffffffffc0200380:	60e2                	ld	ra,24(sp)
ffffffffc0200382:	4532                	lw	a0,12(sp)
ffffffffc0200384:	6105                	addi	sp,sp,32
ffffffffc0200386:	8082                	ret

ffffffffc0200388 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200388:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020038a:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc020038e:	8e2a                	mv	t3,a0
ffffffffc0200390:	f42e                	sd	a1,40(sp)
ffffffffc0200392:	f832                	sd	a2,48(sp)
ffffffffc0200394:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200396:	00000517          	auipc	a0,0x0
ffffffffc020039a:	fb850513          	addi	a0,a0,-72 # ffffffffc020034e <cputch>
ffffffffc020039e:	004c                	addi	a1,sp,4
ffffffffc02003a0:	869a                	mv	a3,t1
ffffffffc02003a2:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02003a4:	ec06                	sd	ra,24(sp)
ffffffffc02003a6:	e0ba                	sd	a4,64(sp)
ffffffffc02003a8:	e4be                	sd	a5,72(sp)
ffffffffc02003aa:	e8c2                	sd	a6,80(sp)
ffffffffc02003ac:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02003ae:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02003b0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02003b2:	33b030ef          	jal	ra,ffffffffc0203eec <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02003b6:	60e2                	ld	ra,24(sp)
ffffffffc02003b8:	4512                	lw	a0,4(sp)
ffffffffc02003ba:	6125                	addi	sp,sp,96
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02003be:	a095                	j	ffffffffc0200422 <cons_putc>

ffffffffc02003c0 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02003c0:	1141                	addi	sp,sp,-16
ffffffffc02003c2:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02003c4:	092000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02003c8:	dd75                	beqz	a0,ffffffffc02003c4 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02003ca:	60a2                	ld	ra,8(sp)
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	29250513          	addi	a0,a0,658 # ffffffffc0204688 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b749                	j	ffffffffc0200388 <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	6f9030ef          	jal	ra,ffffffffc02043b0 <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	6d5030ef          	jal	ra,ffffffffc02043b0 <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	18450513          	addi	a0,a0,388 # ffffffffc02046a8 <commands+0x88>
ffffffffc020052c:	e5dff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03053503          	ld	a0,48(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	6fe0306f          	j	ffffffffc0203c46 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	17c60613          	addi	a2,a2,380 # ffffffffc02046c8 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	18850513          	addi	a0,a0,392 # ffffffffc02046e0 <commands+0xc0>
ffffffffc0200560:	d93ff0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	47878793          	addi	a5,a5,1144 # ffffffffc02009e0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	16e50513          	addi	a0,a0,366 # ffffffffc02046f8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	df5ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	17650513          	addi	a0,a0,374 # ffffffffc0204710 <commands+0xf0>
ffffffffc02005a2:	de7ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	18050513          	addi	a0,a0,384 # ffffffffc0204728 <commands+0x108>
ffffffffc02005b0:	dd9ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	18a50513          	addi	a0,a0,394 # ffffffffc0204740 <commands+0x120>
ffffffffc02005be:	dcbff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	19450513          	addi	a0,a0,404 # ffffffffc0204758 <commands+0x138>
ffffffffc02005cc:	dbdff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	19e50513          	addi	a0,a0,414 # ffffffffc0204770 <commands+0x150>
ffffffffc02005da:	dafff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	1a850513          	addi	a0,a0,424 # ffffffffc0204788 <commands+0x168>
ffffffffc02005e8:	da1ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	1b250513          	addi	a0,a0,434 # ffffffffc02047a0 <commands+0x180>
ffffffffc02005f6:	d93ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	1bc50513          	addi	a0,a0,444 # ffffffffc02047b8 <commands+0x198>
ffffffffc0200604:	d85ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	1c650513          	addi	a0,a0,454 # ffffffffc02047d0 <commands+0x1b0>
ffffffffc0200612:	d77ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	1d050513          	addi	a0,a0,464 # ffffffffc02047e8 <commands+0x1c8>
ffffffffc0200620:	d69ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	1da50513          	addi	a0,a0,474 # ffffffffc0204800 <commands+0x1e0>
ffffffffc020062e:	d5bff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	1e450513          	addi	a0,a0,484 # ffffffffc0204818 <commands+0x1f8>
ffffffffc020063c:	d4dff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	1ee50513          	addi	a0,a0,494 # ffffffffc0204830 <commands+0x210>
ffffffffc020064a:	d3fff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	1f850513          	addi	a0,a0,504 # ffffffffc0204848 <commands+0x228>
ffffffffc0200658:	d31ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	20250513          	addi	a0,a0,514 # ffffffffc0204860 <commands+0x240>
ffffffffc0200666:	d23ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	20c50513          	addi	a0,a0,524 # ffffffffc0204878 <commands+0x258>
ffffffffc0200674:	d15ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	21650513          	addi	a0,a0,534 # ffffffffc0204890 <commands+0x270>
ffffffffc0200682:	d07ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	22050513          	addi	a0,a0,544 # ffffffffc02048a8 <commands+0x288>
ffffffffc0200690:	cf9ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	22a50513          	addi	a0,a0,554 # ffffffffc02048c0 <commands+0x2a0>
ffffffffc020069e:	cebff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	23450513          	addi	a0,a0,564 # ffffffffc02048d8 <commands+0x2b8>
ffffffffc02006ac:	cddff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	23e50513          	addi	a0,a0,574 # ffffffffc02048f0 <commands+0x2d0>
ffffffffc02006ba:	ccfff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	24850513          	addi	a0,a0,584 # ffffffffc0204908 <commands+0x2e8>
ffffffffc02006c8:	cc1ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	25250513          	addi	a0,a0,594 # ffffffffc0204920 <commands+0x300>
ffffffffc02006d6:	cb3ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	25c50513          	addi	a0,a0,604 # ffffffffc0204938 <commands+0x318>
ffffffffc02006e4:	ca5ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	26650513          	addi	a0,a0,614 # ffffffffc0204950 <commands+0x330>
ffffffffc02006f2:	c97ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	27050513          	addi	a0,a0,624 # ffffffffc0204968 <commands+0x348>
ffffffffc0200700:	c89ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	27a50513          	addi	a0,a0,634 # ffffffffc0204980 <commands+0x360>
ffffffffc020070e:	c7bff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	28450513          	addi	a0,a0,644 # ffffffffc0204998 <commands+0x378>
ffffffffc020071c:	c6dff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	28e50513          	addi	a0,a0,654 # ffffffffc02049b0 <commands+0x390>
ffffffffc020072a:	c5fff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	29850513          	addi	a0,a0,664 # ffffffffc02049c8 <commands+0x3a8>
ffffffffc0200738:	c51ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	29e50513          	addi	a0,a0,670 # ffffffffc02049e0 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b935                	j	ffffffffc0200388 <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	2a250513          	addi	a0,a0,674 # ffffffffc02049f8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	c29ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	2a250513          	addi	a0,a0,674 # ffffffffc0204a10 <commands+0x3f0>
ffffffffc0200776:	c13ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	2aa50513          	addi	a0,a0,682 # ffffffffc0204a28 <commands+0x408>
ffffffffc0200786:	c03ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	2b250513          	addi	a0,a0,690 # ffffffffc0204a40 <commands+0x420>
ffffffffc0200796:	bf3ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	2b650513          	addi	a0,a0,694 # ffffffffc0204a58 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	bef1                	j	ffffffffc0200388 <cprintf>

ffffffffc02007ae <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007ae:	11853783          	ld	a5,280(a0)
ffffffffc02007b2:	472d                	li	a4,11
ffffffffc02007b4:	0786                	slli	a5,a5,0x1
ffffffffc02007b6:	8385                	srli	a5,a5,0x1
ffffffffc02007b8:	06f76763          	bltu	a4,a5,ffffffffc0200826 <interrupt_handler+0x78>
ffffffffc02007bc:	00004717          	auipc	a4,0x4
ffffffffc02007c0:	36470713          	addi	a4,a4,868 # ffffffffc0204b20 <commands+0x500>
ffffffffc02007c4:	078a                	slli	a5,a5,0x2
ffffffffc02007c6:	97ba                	add	a5,a5,a4
ffffffffc02007c8:	439c                	lw	a5,0(a5)
ffffffffc02007ca:	97ba                	add	a5,a5,a4
ffffffffc02007cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007ce:	00004517          	auipc	a0,0x4
ffffffffc02007d2:	30250513          	addi	a0,a0,770 # ffffffffc0204ad0 <commands+0x4b0>
ffffffffc02007d6:	be4d                	j	ffffffffc0200388 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007d8:	00004517          	auipc	a0,0x4
ffffffffc02007dc:	2d850513          	addi	a0,a0,728 # ffffffffc0204ab0 <commands+0x490>
ffffffffc02007e0:	b665                	j	ffffffffc0200388 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	28e50513          	addi	a0,a0,654 # ffffffffc0204a70 <commands+0x450>
ffffffffc02007ea:	be79                	j	ffffffffc0200388 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007ec:	00004517          	auipc	a0,0x4
ffffffffc02007f0:	2a450513          	addi	a0,a0,676 # ffffffffc0204a90 <commands+0x470>
ffffffffc02007f4:	be51                	j	ffffffffc0200388 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007f6:	1141                	addi	sp,sp,-16
ffffffffc02007f8:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02007fa:	c0fff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007fe:	00011697          	auipc	a3,0x11
ffffffffc0200802:	d0268693          	addi	a3,a3,-766 # ffffffffc0211500 <ticks>
ffffffffc0200806:	629c                	ld	a5,0(a3)
ffffffffc0200808:	06400713          	li	a4,100
ffffffffc020080c:	0785                	addi	a5,a5,1
ffffffffc020080e:	02e7f733          	remu	a4,a5,a4
ffffffffc0200812:	e29c                	sd	a5,0(a3)
ffffffffc0200814:	cb11                	beqz	a4,ffffffffc0200828 <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200816:	60a2                	ld	ra,8(sp)
ffffffffc0200818:	0141                	addi	sp,sp,16
ffffffffc020081a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020081c:	00004517          	auipc	a0,0x4
ffffffffc0200820:	2e450513          	addi	a0,a0,740 # ffffffffc0204b00 <commands+0x4e0>
ffffffffc0200824:	b695                	j	ffffffffc0200388 <cprintf>
            print_trapframe(tf);
ffffffffc0200826:	b725                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200828:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020082a:	06400593          	li	a1,100
ffffffffc020082e:	00004517          	auipc	a0,0x4
ffffffffc0200832:	2c250513          	addi	a0,a0,706 # ffffffffc0204af0 <commands+0x4d0>
}
ffffffffc0200836:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200838:	be81                	j	ffffffffc0200388 <cprintf>

ffffffffc020083a <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020083a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020083e:	1101                	addi	sp,sp,-32
ffffffffc0200840:	e822                	sd	s0,16(sp)
ffffffffc0200842:	ec06                	sd	ra,24(sp)
ffffffffc0200844:	e426                	sd	s1,8(sp)
ffffffffc0200846:	473d                	li	a4,15
ffffffffc0200848:	842a                	mv	s0,a0
ffffffffc020084a:	14f76963          	bltu	a4,a5,ffffffffc020099c <exception_handler+0x162>
ffffffffc020084e:	00004717          	auipc	a4,0x4
ffffffffc0200852:	4ba70713          	addi	a4,a4,1210 # ffffffffc0204d08 <commands+0x6e8>
ffffffffc0200856:	078a                	slli	a5,a5,0x2
ffffffffc0200858:	97ba                	add	a5,a5,a4
ffffffffc020085a:	439c                	lw	a5,0(a5)
ffffffffc020085c:	97ba                	add	a5,a5,a4
ffffffffc020085e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200860:	00004517          	auipc	a0,0x4
ffffffffc0200864:	49050513          	addi	a0,a0,1168 # ffffffffc0204cf0 <commands+0x6d0>
ffffffffc0200868:	b21ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020086c:	8522                	mv	a0,s0
ffffffffc020086e:	c87ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200872:	84aa                	mv	s1,a0
ffffffffc0200874:	12051a63          	bnez	a0,ffffffffc02009a8 <exception_handler+0x16e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200878:	60e2                	ld	ra,24(sp)
ffffffffc020087a:	6442                	ld	s0,16(sp)
ffffffffc020087c:	64a2                	ld	s1,8(sp)
ffffffffc020087e:	6105                	addi	sp,sp,32
ffffffffc0200880:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200882:	00004517          	auipc	a0,0x4
ffffffffc0200886:	2ce50513          	addi	a0,a0,718 # ffffffffc0204b50 <commands+0x530>
}
ffffffffc020088a:	6442                	ld	s0,16(sp)
ffffffffc020088c:	60e2                	ld	ra,24(sp)
ffffffffc020088e:	64a2                	ld	s1,8(sp)
ffffffffc0200890:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200892:	bcdd                	j	ffffffffc0200388 <cprintf>
ffffffffc0200894:	00004517          	auipc	a0,0x4
ffffffffc0200898:	2dc50513          	addi	a0,a0,732 # ffffffffc0204b70 <commands+0x550>
ffffffffc020089c:	b7fd                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	2f250513          	addi	a0,a0,754 # ffffffffc0204b90 <commands+0x570>
ffffffffc02008a6:	b7d5                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008a8:	00004517          	auipc	a0,0x4
ffffffffc02008ac:	30050513          	addi	a0,a0,768 # ffffffffc0204ba8 <commands+0x588>
ffffffffc02008b0:	bfe9                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008b2:	00004517          	auipc	a0,0x4
ffffffffc02008b6:	30650513          	addi	a0,a0,774 # ffffffffc0204bb8 <commands+0x598>
ffffffffc02008ba:	bfc1                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	31c50513          	addi	a0,a0,796 # ffffffffc0204bd8 <commands+0x5b8>
ffffffffc02008c4:	ac5ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c8:	8522                	mv	a0,s0
ffffffffc02008ca:	c2bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008ce:	84aa                	mv	s1,a0
ffffffffc02008d0:	d545                	beqz	a0,ffffffffc0200878 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008d2:	8522                	mv	a0,s0
ffffffffc02008d4:	e7bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008d8:	86a6                	mv	a3,s1
ffffffffc02008da:	00004617          	auipc	a2,0x4
ffffffffc02008de:	31660613          	addi	a2,a2,790 # ffffffffc0204bf0 <commands+0x5d0>
ffffffffc02008e2:	0ca00593          	li	a1,202
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	dfa50513          	addi	a0,a0,-518 # ffffffffc02046e0 <commands+0xc0>
ffffffffc02008ee:	a05ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008f2:	00004517          	auipc	a0,0x4
ffffffffc02008f6:	31e50513          	addi	a0,a0,798 # ffffffffc0204c10 <commands+0x5f0>
ffffffffc02008fa:	bf41                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	32c50513          	addi	a0,a0,812 # ffffffffc0204c28 <commands+0x608>
ffffffffc0200904:	a85ff0ef          	jal	ra,ffffffffc0200388 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200908:	8522                	mv	a0,s0
ffffffffc020090a:	bebff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020090e:	84aa                	mv	s1,a0
ffffffffc0200910:	d525                	beqz	a0,ffffffffc0200878 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200912:	8522                	mv	a0,s0
ffffffffc0200914:	e3bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200918:	86a6                	mv	a3,s1
ffffffffc020091a:	00004617          	auipc	a2,0x4
ffffffffc020091e:	2d660613          	addi	a2,a2,726 # ffffffffc0204bf0 <commands+0x5d0>
ffffffffc0200922:	0d400593          	li	a1,212
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	dba50513          	addi	a0,a0,-582 # ffffffffc02046e0 <commands+0xc0>
ffffffffc020092e:	9c5ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	30e50513          	addi	a0,a0,782 # ffffffffc0204c40 <commands+0x620>
ffffffffc020093a:	bf81                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	32450513          	addi	a0,a0,804 # ffffffffc0204c60 <commands+0x640>
ffffffffc0200944:	b799                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	33a50513          	addi	a0,a0,826 # ffffffffc0204c80 <commands+0x660>
ffffffffc020094e:	bf35                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	35050513          	addi	a0,a0,848 # ffffffffc0204ca0 <commands+0x680>
ffffffffc0200958:	bf0d                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	36650513          	addi	a0,a0,870 # ffffffffc0204cc0 <commands+0x6a0>
ffffffffc0200962:	b725                	j	ffffffffc020088a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	37450513          	addi	a0,a0,884 # ffffffffc0204cd8 <commands+0x6b8>
ffffffffc020096c:	a1dff0ef          	jal	ra,ffffffffc0200388 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	b83ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200976:	84aa                	mv	s1,a0
ffffffffc0200978:	f00500e3          	beqz	a0,ffffffffc0200878 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020097c:	8522                	mv	a0,s0
ffffffffc020097e:	dd1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200982:	86a6                	mv	a3,s1
ffffffffc0200984:	00004617          	auipc	a2,0x4
ffffffffc0200988:	26c60613          	addi	a2,a2,620 # ffffffffc0204bf0 <commands+0x5d0>
ffffffffc020098c:	0ea00593          	li	a1,234
ffffffffc0200990:	00004517          	auipc	a0,0x4
ffffffffc0200994:	d5050513          	addi	a0,a0,-688 # ffffffffc02046e0 <commands+0xc0>
ffffffffc0200998:	95bff0ef          	jal	ra,ffffffffc02002f2 <__panic>
            print_trapframe(tf);
ffffffffc020099c:	8522                	mv	a0,s0
}
ffffffffc020099e:	6442                	ld	s0,16(sp)
ffffffffc02009a0:	60e2                	ld	ra,24(sp)
ffffffffc02009a2:	64a2                	ld	s1,8(sp)
ffffffffc02009a4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009a6:	b365                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	da5ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ae:	86a6                	mv	a3,s1
ffffffffc02009b0:	00004617          	auipc	a2,0x4
ffffffffc02009b4:	24060613          	addi	a2,a2,576 # ffffffffc0204bf0 <commands+0x5d0>
ffffffffc02009b8:	0f100593          	li	a1,241
ffffffffc02009bc:	00004517          	auipc	a0,0x4
ffffffffc02009c0:	d2450513          	addi	a0,a0,-732 # ffffffffc02046e0 <commands+0xc0>
ffffffffc02009c4:	92fff0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02009c8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009c8:	11853783          	ld	a5,280(a0)
ffffffffc02009cc:	0007c363          	bltz	a5,ffffffffc02009d2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009d0:	b5ad                	j	ffffffffc020083a <exception_handler>
        interrupt_handler(tf);
ffffffffc02009d2:	bbf1                	j	ffffffffc02007ae <interrupt_handler>
	...

ffffffffc02009e0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009e0:	14011073          	csrw	sscratch,sp
ffffffffc02009e4:	712d                	addi	sp,sp,-288
ffffffffc02009e6:	e406                	sd	ra,8(sp)
ffffffffc02009e8:	ec0e                	sd	gp,24(sp)
ffffffffc02009ea:	f012                	sd	tp,32(sp)
ffffffffc02009ec:	f416                	sd	t0,40(sp)
ffffffffc02009ee:	f81a                	sd	t1,48(sp)
ffffffffc02009f0:	fc1e                	sd	t2,56(sp)
ffffffffc02009f2:	e0a2                	sd	s0,64(sp)
ffffffffc02009f4:	e4a6                	sd	s1,72(sp)
ffffffffc02009f6:	e8aa                	sd	a0,80(sp)
ffffffffc02009f8:	ecae                	sd	a1,88(sp)
ffffffffc02009fa:	f0b2                	sd	a2,96(sp)
ffffffffc02009fc:	f4b6                	sd	a3,104(sp)
ffffffffc02009fe:	f8ba                	sd	a4,112(sp)
ffffffffc0200a00:	fcbe                	sd	a5,120(sp)
ffffffffc0200a02:	e142                	sd	a6,128(sp)
ffffffffc0200a04:	e546                	sd	a7,136(sp)
ffffffffc0200a06:	e94a                	sd	s2,144(sp)
ffffffffc0200a08:	ed4e                	sd	s3,152(sp)
ffffffffc0200a0a:	f152                	sd	s4,160(sp)
ffffffffc0200a0c:	f556                	sd	s5,168(sp)
ffffffffc0200a0e:	f95a                	sd	s6,176(sp)
ffffffffc0200a10:	fd5e                	sd	s7,184(sp)
ffffffffc0200a12:	e1e2                	sd	s8,192(sp)
ffffffffc0200a14:	e5e6                	sd	s9,200(sp)
ffffffffc0200a16:	e9ea                	sd	s10,208(sp)
ffffffffc0200a18:	edee                	sd	s11,216(sp)
ffffffffc0200a1a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a1c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a1e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a20:	fdfe                	sd	t6,248(sp)
ffffffffc0200a22:	14002473          	csrr	s0,sscratch
ffffffffc0200a26:	100024f3          	csrr	s1,sstatus
ffffffffc0200a2a:	14102973          	csrr	s2,sepc
ffffffffc0200a2e:	143029f3          	csrr	s3,stval
ffffffffc0200a32:	14202a73          	csrr	s4,scause
ffffffffc0200a36:	e822                	sd	s0,16(sp)
ffffffffc0200a38:	e226                	sd	s1,256(sp)
ffffffffc0200a3a:	e64a                	sd	s2,264(sp)
ffffffffc0200a3c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a3e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a40:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a42:	f87ff0ef          	jal	ra,ffffffffc02009c8 <trap>

ffffffffc0200a46 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a46:	6492                	ld	s1,256(sp)
ffffffffc0200a48:	6932                	ld	s2,264(sp)
ffffffffc0200a4a:	10049073          	csrw	sstatus,s1
ffffffffc0200a4e:	14191073          	csrw	sepc,s2
ffffffffc0200a52:	60a2                	ld	ra,8(sp)
ffffffffc0200a54:	61e2                	ld	gp,24(sp)
ffffffffc0200a56:	7202                	ld	tp,32(sp)
ffffffffc0200a58:	72a2                	ld	t0,40(sp)
ffffffffc0200a5a:	7342                	ld	t1,48(sp)
ffffffffc0200a5c:	73e2                	ld	t2,56(sp)
ffffffffc0200a5e:	6406                	ld	s0,64(sp)
ffffffffc0200a60:	64a6                	ld	s1,72(sp)
ffffffffc0200a62:	6546                	ld	a0,80(sp)
ffffffffc0200a64:	65e6                	ld	a1,88(sp)
ffffffffc0200a66:	7606                	ld	a2,96(sp)
ffffffffc0200a68:	76a6                	ld	a3,104(sp)
ffffffffc0200a6a:	7746                	ld	a4,112(sp)
ffffffffc0200a6c:	77e6                	ld	a5,120(sp)
ffffffffc0200a6e:	680a                	ld	a6,128(sp)
ffffffffc0200a70:	68aa                	ld	a7,136(sp)
ffffffffc0200a72:	694a                	ld	s2,144(sp)
ffffffffc0200a74:	69ea                	ld	s3,152(sp)
ffffffffc0200a76:	7a0a                	ld	s4,160(sp)
ffffffffc0200a78:	7aaa                	ld	s5,168(sp)
ffffffffc0200a7a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a7c:	7bea                	ld	s7,184(sp)
ffffffffc0200a7e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a80:	6cae                	ld	s9,200(sp)
ffffffffc0200a82:	6d4e                	ld	s10,208(sp)
ffffffffc0200a84:	6dee                	ld	s11,216(sp)
ffffffffc0200a86:	7e0e                	ld	t3,224(sp)
ffffffffc0200a88:	7eae                	ld	t4,232(sp)
ffffffffc0200a8a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a8c:	7fee                	ld	t6,248(sp)
ffffffffc0200a8e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a90:	10200073          	sret
	...

ffffffffc0200aa0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200aa0:	00010797          	auipc	a5,0x10
ffffffffc0200aa4:	5a078793          	addi	a5,a5,1440 # ffffffffc0211040 <free_area>
ffffffffc0200aa8:	e79c                	sd	a5,8(a5)
ffffffffc0200aaa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aac:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ab0:	8082                	ret

ffffffffc0200ab2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ab2:	00010517          	auipc	a0,0x10
ffffffffc0200ab6:	59e56503          	lwu	a0,1438(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aba:	8082                	ret

ffffffffc0200abc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200abc:	715d                	addi	sp,sp,-80
ffffffffc0200abe:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ac0:	00010417          	auipc	s0,0x10
ffffffffc0200ac4:	58040413          	addi	s0,s0,1408 # ffffffffc0211040 <free_area>
ffffffffc0200ac8:	641c                	ld	a5,8(s0)
ffffffffc0200aca:	e486                	sd	ra,72(sp)
ffffffffc0200acc:	fc26                	sd	s1,56(sp)
ffffffffc0200ace:	f84a                	sd	s2,48(sp)
ffffffffc0200ad0:	f44e                	sd	s3,40(sp)
ffffffffc0200ad2:	f052                	sd	s4,32(sp)
ffffffffc0200ad4:	ec56                	sd	s5,24(sp)
ffffffffc0200ad6:	e85a                	sd	s6,16(sp)
ffffffffc0200ad8:	e45e                	sd	s7,8(sp)
ffffffffc0200ada:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200adc:	2c878763          	beq	a5,s0,ffffffffc0200daa <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200ae0:	4481                	li	s1,0
ffffffffc0200ae2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ae4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ae8:	8b09                	andi	a4,a4,2
ffffffffc0200aea:	2c070463          	beqz	a4,ffffffffc0200db2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200aee:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200af2:	679c                	ld	a5,8(a5)
ffffffffc0200af4:	2905                	addiw	s2,s2,1
ffffffffc0200af6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200af8:	fe8796e3          	bne	a5,s0,ffffffffc0200ae4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200afc:	89a6                	mv	s3,s1
ffffffffc0200afe:	385000ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc0200b02:	71351863          	bne	a0,s3,ffffffffc0201212 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b06:	4505                	li	a0,1
ffffffffc0200b08:	2a9000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200b0c:	8a2a                	mv	s4,a0
ffffffffc0200b0e:	44050263          	beqz	a0,ffffffffc0200f52 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b12:	4505                	li	a0,1
ffffffffc0200b14:	29d000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200b18:	89aa                	mv	s3,a0
ffffffffc0200b1a:	70050c63          	beqz	a0,ffffffffc0201232 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b1e:	4505                	li	a0,1
ffffffffc0200b20:	291000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200b24:	8aaa                	mv	s5,a0
ffffffffc0200b26:	4a050663          	beqz	a0,ffffffffc0200fd2 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b2a:	2b3a0463          	beq	s4,s3,ffffffffc0200dd2 <default_check+0x316>
ffffffffc0200b2e:	2aaa0263          	beq	s4,a0,ffffffffc0200dd2 <default_check+0x316>
ffffffffc0200b32:	2aa98063          	beq	s3,a0,ffffffffc0200dd2 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b36:	000a2783          	lw	a5,0(s4)
ffffffffc0200b3a:	2a079c63          	bnez	a5,ffffffffc0200df2 <default_check+0x336>
ffffffffc0200b3e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b42:	2a079863          	bnez	a5,ffffffffc0200df2 <default_check+0x336>
ffffffffc0200b46:	411c                	lw	a5,0(a0)
ffffffffc0200b48:	2a079563          	bnez	a5,ffffffffc0200df2 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b4c:	00011797          	auipc	a5,0x11
ffffffffc0200b50:	9dc7b783          	ld	a5,-1572(a5) # ffffffffc0211528 <pages>
ffffffffc0200b54:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b58:	870d                	srai	a4,a4,0x3
ffffffffc0200b5a:	00005597          	auipc	a1,0x5
ffffffffc0200b5e:	6565b583          	ld	a1,1622(a1) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0200b62:	02b70733          	mul	a4,a4,a1
ffffffffc0200b66:	00005617          	auipc	a2,0x5
ffffffffc0200b6a:	65263603          	ld	a2,1618(a2) # ffffffffc02061b8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b6e:	00011697          	auipc	a3,0x11
ffffffffc0200b72:	9b26b683          	ld	a3,-1614(a3) # ffffffffc0211520 <npage>
ffffffffc0200b76:	06b2                	slli	a3,a3,0xc
ffffffffc0200b78:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b7a:	0732                	slli	a4,a4,0xc
ffffffffc0200b7c:	28d77b63          	bgeu	a4,a3,ffffffffc0200e12 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b80:	40f98733          	sub	a4,s3,a5
ffffffffc0200b84:	870d                	srai	a4,a4,0x3
ffffffffc0200b86:	02b70733          	mul	a4,a4,a1
ffffffffc0200b8a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b8e:	4cd77263          	bgeu	a4,a3,ffffffffc0201052 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b92:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b96:	878d                	srai	a5,a5,0x3
ffffffffc0200b98:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b9c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ba0:	30d7f963          	bgeu	a5,a3,ffffffffc0200eb2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200ba4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ba6:	00043c03          	ld	s8,0(s0)
ffffffffc0200baa:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bae:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bb2:	e400                	sd	s0,8(s0)
ffffffffc0200bb4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bb6:	00010797          	auipc	a5,0x10
ffffffffc0200bba:	4807ad23          	sw	zero,1178(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bbe:	1f3000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200bc2:	2c051863          	bnez	a0,ffffffffc0200e92 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200bc6:	4585                	li	a1,1
ffffffffc0200bc8:	8552                	mv	a0,s4
ffffffffc0200bca:	279000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_page(p1);
ffffffffc0200bce:	4585                	li	a1,1
ffffffffc0200bd0:	854e                	mv	a0,s3
ffffffffc0200bd2:	271000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_page(p2);
ffffffffc0200bd6:	4585                	li	a1,1
ffffffffc0200bd8:	8556                	mv	a0,s5
ffffffffc0200bda:	269000ef          	jal	ra,ffffffffc0201642 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bde:	4818                	lw	a4,16(s0)
ffffffffc0200be0:	478d                	li	a5,3
ffffffffc0200be2:	28f71863          	bne	a4,a5,ffffffffc0200e72 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200be6:	4505                	li	a0,1
ffffffffc0200be8:	1c9000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200bec:	89aa                	mv	s3,a0
ffffffffc0200bee:	26050263          	beqz	a0,ffffffffc0200e52 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bf2:	4505                	li	a0,1
ffffffffc0200bf4:	1bd000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200bf8:	8aaa                	mv	s5,a0
ffffffffc0200bfa:	3a050c63          	beqz	a0,ffffffffc0200fb2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bfe:	4505                	li	a0,1
ffffffffc0200c00:	1b1000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c04:	8a2a                	mv	s4,a0
ffffffffc0200c06:	38050663          	beqz	a0,ffffffffc0200f92 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c0a:	4505                	li	a0,1
ffffffffc0200c0c:	1a5000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c10:	36051163          	bnez	a0,ffffffffc0200f72 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c14:	4585                	li	a1,1
ffffffffc0200c16:	854e                	mv	a0,s3
ffffffffc0200c18:	22b000ef          	jal	ra,ffffffffc0201642 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c1c:	641c                	ld	a5,8(s0)
ffffffffc0200c1e:	20878a63          	beq	a5,s0,ffffffffc0200e32 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c22:	4505                	li	a0,1
ffffffffc0200c24:	18d000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c28:	30a99563          	bne	s3,a0,ffffffffc0200f32 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c2c:	4505                	li	a0,1
ffffffffc0200c2e:	183000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c32:	2e051063          	bnez	a0,ffffffffc0200f12 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c36:	481c                	lw	a5,16(s0)
ffffffffc0200c38:	2a079d63          	bnez	a5,ffffffffc0200ef2 <default_check+0x436>
    free_page(p);
ffffffffc0200c3c:	854e                	mv	a0,s3
ffffffffc0200c3e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c40:	01843023          	sd	s8,0(s0)
ffffffffc0200c44:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c48:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c4c:	1f7000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_page(p1);
ffffffffc0200c50:	4585                	li	a1,1
ffffffffc0200c52:	8556                	mv	a0,s5
ffffffffc0200c54:	1ef000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_page(p2);
ffffffffc0200c58:	4585                	li	a1,1
ffffffffc0200c5a:	8552                	mv	a0,s4
ffffffffc0200c5c:	1e7000ef          	jal	ra,ffffffffc0201642 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c60:	4515                	li	a0,5
ffffffffc0200c62:	14f000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c66:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c68:	26050563          	beqz	a0,ffffffffc0200ed2 <default_check+0x416>
ffffffffc0200c6c:	651c                	ld	a5,8(a0)
ffffffffc0200c6e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c70:	8b85                	andi	a5,a5,1
ffffffffc0200c72:	54079063          	bnez	a5,ffffffffc02011b2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c76:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c78:	00043b03          	ld	s6,0(s0)
ffffffffc0200c7c:	00843a83          	ld	s5,8(s0)
ffffffffc0200c80:	e000                	sd	s0,0(s0)
ffffffffc0200c82:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c84:	12d000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200c88:	50051563          	bnez	a0,ffffffffc0201192 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c8c:	09098a13          	addi	s4,s3,144
ffffffffc0200c90:	8552                	mv	a0,s4
ffffffffc0200c92:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200c94:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200c98:	00010797          	auipc	a5,0x10
ffffffffc0200c9c:	3a07ac23          	sw	zero,952(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200ca0:	1a3000ef          	jal	ra,ffffffffc0201642 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ca4:	4511                	li	a0,4
ffffffffc0200ca6:	10b000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200caa:	4c051463          	bnez	a0,ffffffffc0201172 <default_check+0x6b6>
ffffffffc0200cae:	0989b783          	ld	a5,152(s3)
ffffffffc0200cb2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cb4:	8b85                	andi	a5,a5,1
ffffffffc0200cb6:	48078e63          	beqz	a5,ffffffffc0201152 <default_check+0x696>
ffffffffc0200cba:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cbe:	478d                	li	a5,3
ffffffffc0200cc0:	48f71963          	bne	a4,a5,ffffffffc0201152 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cc4:	450d                	li	a0,3
ffffffffc0200cc6:	0eb000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200cca:	8c2a                	mv	s8,a0
ffffffffc0200ccc:	46050363          	beqz	a0,ffffffffc0201132 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	0df000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200cd6:	42051e63          	bnez	a0,ffffffffc0201112 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200cda:	418a1c63          	bne	s4,s8,ffffffffc02010f2 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cde:	4585                	li	a1,1
ffffffffc0200ce0:	854e                	mv	a0,s3
ffffffffc0200ce2:	161000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_pages(p1, 3);
ffffffffc0200ce6:	458d                	li	a1,3
ffffffffc0200ce8:	8552                	mv	a0,s4
ffffffffc0200cea:	159000ef          	jal	ra,ffffffffc0201642 <free_pages>
ffffffffc0200cee:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200cf2:	04898c13          	addi	s8,s3,72
ffffffffc0200cf6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200cf8:	8b85                	andi	a5,a5,1
ffffffffc0200cfa:	3c078c63          	beqz	a5,ffffffffc02010d2 <default_check+0x616>
ffffffffc0200cfe:	0189a703          	lw	a4,24(s3)
ffffffffc0200d02:	4785                	li	a5,1
ffffffffc0200d04:	3cf71763          	bne	a4,a5,ffffffffc02010d2 <default_check+0x616>
ffffffffc0200d08:	008a3783          	ld	a5,8(s4)
ffffffffc0200d0c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d0e:	8b85                	andi	a5,a5,1
ffffffffc0200d10:	3a078163          	beqz	a5,ffffffffc02010b2 <default_check+0x5f6>
ffffffffc0200d14:	018a2703          	lw	a4,24(s4)
ffffffffc0200d18:	478d                	li	a5,3
ffffffffc0200d1a:	38f71c63          	bne	a4,a5,ffffffffc02010b2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d1e:	4505                	li	a0,1
ffffffffc0200d20:	091000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200d24:	36a99763          	bne	s3,a0,ffffffffc0201092 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d28:	4585                	li	a1,1
ffffffffc0200d2a:	119000ef          	jal	ra,ffffffffc0201642 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d2e:	4509                	li	a0,2
ffffffffc0200d30:	081000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200d34:	32aa1f63          	bne	s4,a0,ffffffffc0201072 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d38:	4589                	li	a1,2
ffffffffc0200d3a:	109000ef          	jal	ra,ffffffffc0201642 <free_pages>
    free_page(p2);
ffffffffc0200d3e:	4585                	li	a1,1
ffffffffc0200d40:	8562                	mv	a0,s8
ffffffffc0200d42:	101000ef          	jal	ra,ffffffffc0201642 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d46:	4515                	li	a0,5
ffffffffc0200d48:	069000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200d4c:	89aa                	mv	s3,a0
ffffffffc0200d4e:	48050263          	beqz	a0,ffffffffc02011d2 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d52:	4505                	li	a0,1
ffffffffc0200d54:	05d000ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0200d58:	2c051d63          	bnez	a0,ffffffffc0201032 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d5c:	481c                	lw	a5,16(s0)
ffffffffc0200d5e:	2a079a63          	bnez	a5,ffffffffc0201012 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d62:	4595                	li	a1,5
ffffffffc0200d64:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d66:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d6a:	01643023          	sd	s6,0(s0)
ffffffffc0200d6e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d72:	0d1000ef          	jal	ra,ffffffffc0201642 <free_pages>
    return listelm->next;
ffffffffc0200d76:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d78:	00878963          	beq	a5,s0,ffffffffc0200d8a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d7c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d80:	679c                	ld	a5,8(a5)
ffffffffc0200d82:	397d                	addiw	s2,s2,-1
ffffffffc0200d84:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d86:	fe879be3          	bne	a5,s0,ffffffffc0200d7c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d8a:	26091463          	bnez	s2,ffffffffc0200ff2 <default_check+0x536>
    assert(total == 0);
ffffffffc0200d8e:	46049263          	bnez	s1,ffffffffc02011f2 <default_check+0x736>
}
ffffffffc0200d92:	60a6                	ld	ra,72(sp)
ffffffffc0200d94:	6406                	ld	s0,64(sp)
ffffffffc0200d96:	74e2                	ld	s1,56(sp)
ffffffffc0200d98:	7942                	ld	s2,48(sp)
ffffffffc0200d9a:	79a2                	ld	s3,40(sp)
ffffffffc0200d9c:	7a02                	ld	s4,32(sp)
ffffffffc0200d9e:	6ae2                	ld	s5,24(sp)
ffffffffc0200da0:	6b42                	ld	s6,16(sp)
ffffffffc0200da2:	6ba2                	ld	s7,8(sp)
ffffffffc0200da4:	6c02                	ld	s8,0(sp)
ffffffffc0200da6:	6161                	addi	sp,sp,80
ffffffffc0200da8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200daa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dac:	4481                	li	s1,0
ffffffffc0200dae:	4901                	li	s2,0
ffffffffc0200db0:	b3b9                	j	ffffffffc0200afe <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200db2:	00004697          	auipc	a3,0x4
ffffffffc0200db6:	f9668693          	addi	a3,a3,-106 # ffffffffc0204d48 <commands+0x728>
ffffffffc0200dba:	00004617          	auipc	a2,0x4
ffffffffc0200dbe:	f9e60613          	addi	a2,a2,-98 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200dc2:	0f000593          	li	a1,240
ffffffffc0200dc6:	00004517          	auipc	a0,0x4
ffffffffc0200dca:	faa50513          	addi	a0,a0,-86 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200dce:	d24ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200dd2:	00004697          	auipc	a3,0x4
ffffffffc0200dd6:	03668693          	addi	a3,a3,54 # ffffffffc0204e08 <commands+0x7e8>
ffffffffc0200dda:	00004617          	auipc	a2,0x4
ffffffffc0200dde:	f7e60613          	addi	a2,a2,-130 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200de2:	0bd00593          	li	a1,189
ffffffffc0200de6:	00004517          	auipc	a0,0x4
ffffffffc0200dea:	f8a50513          	addi	a0,a0,-118 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200dee:	d04ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200df2:	00004697          	auipc	a3,0x4
ffffffffc0200df6:	03e68693          	addi	a3,a3,62 # ffffffffc0204e30 <commands+0x810>
ffffffffc0200dfa:	00004617          	auipc	a2,0x4
ffffffffc0200dfe:	f5e60613          	addi	a2,a2,-162 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200e02:	0be00593          	li	a1,190
ffffffffc0200e06:	00004517          	auipc	a0,0x4
ffffffffc0200e0a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200e0e:	ce4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e12:	00004697          	auipc	a3,0x4
ffffffffc0200e16:	05e68693          	addi	a3,a3,94 # ffffffffc0204e70 <commands+0x850>
ffffffffc0200e1a:	00004617          	auipc	a2,0x4
ffffffffc0200e1e:	f3e60613          	addi	a2,a2,-194 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200e22:	0c000593          	li	a1,192
ffffffffc0200e26:	00004517          	auipc	a0,0x4
ffffffffc0200e2a:	f4a50513          	addi	a0,a0,-182 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200e2e:	cc4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	0c668693          	addi	a3,a3,198 # ffffffffc0204ef8 <commands+0x8d8>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200e42:	0d900593          	li	a1,217
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	f2a50513          	addi	a0,a0,-214 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200e4e:	ca4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e52:	00004697          	auipc	a3,0x4
ffffffffc0200e56:	f5668693          	addi	a3,a3,-170 # ffffffffc0204da8 <commands+0x788>
ffffffffc0200e5a:	00004617          	auipc	a2,0x4
ffffffffc0200e5e:	efe60613          	addi	a2,a2,-258 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200e62:	0d200593          	li	a1,210
ffffffffc0200e66:	00004517          	auipc	a0,0x4
ffffffffc0200e6a:	f0a50513          	addi	a0,a0,-246 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200e6e:	c84ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free == 3);
ffffffffc0200e72:	00004697          	auipc	a3,0x4
ffffffffc0200e76:	07668693          	addi	a3,a3,118 # ffffffffc0204ee8 <commands+0x8c8>
ffffffffc0200e7a:	00004617          	auipc	a2,0x4
ffffffffc0200e7e:	ede60613          	addi	a2,a2,-290 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200e82:	0d000593          	li	a1,208
ffffffffc0200e86:	00004517          	auipc	a0,0x4
ffffffffc0200e8a:	eea50513          	addi	a0,a0,-278 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200e8e:	c64ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e92:	00004697          	auipc	a3,0x4
ffffffffc0200e96:	03e68693          	addi	a3,a3,62 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc0200e9a:	00004617          	auipc	a2,0x4
ffffffffc0200e9e:	ebe60613          	addi	a2,a2,-322 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200ea2:	0cb00593          	li	a1,203
ffffffffc0200ea6:	00004517          	auipc	a0,0x4
ffffffffc0200eaa:	eca50513          	addi	a0,a0,-310 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200eae:	c44ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200eb2:	00004697          	auipc	a3,0x4
ffffffffc0200eb6:	ffe68693          	addi	a3,a3,-2 # ffffffffc0204eb0 <commands+0x890>
ffffffffc0200eba:	00004617          	auipc	a2,0x4
ffffffffc0200ebe:	e9e60613          	addi	a2,a2,-354 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200ec2:	0c200593          	li	a1,194
ffffffffc0200ec6:	00004517          	auipc	a0,0x4
ffffffffc0200eca:	eaa50513          	addi	a0,a0,-342 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200ece:	c24ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(p0 != NULL);
ffffffffc0200ed2:	00004697          	auipc	a3,0x4
ffffffffc0200ed6:	06e68693          	addi	a3,a3,110 # ffffffffc0204f40 <commands+0x920>
ffffffffc0200eda:	00004617          	auipc	a2,0x4
ffffffffc0200ede:	e7e60613          	addi	a2,a2,-386 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200ee2:	0f800593          	li	a1,248
ffffffffc0200ee6:	00004517          	auipc	a0,0x4
ffffffffc0200eea:	e8a50513          	addi	a0,a0,-374 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200eee:	c04ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free == 0);
ffffffffc0200ef2:	00004697          	auipc	a3,0x4
ffffffffc0200ef6:	03e68693          	addi	a3,a3,62 # ffffffffc0204f30 <commands+0x910>
ffffffffc0200efa:	00004617          	auipc	a2,0x4
ffffffffc0200efe:	e5e60613          	addi	a2,a2,-418 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200f02:	0df00593          	li	a1,223
ffffffffc0200f06:	00004517          	auipc	a0,0x4
ffffffffc0200f0a:	e6a50513          	addi	a0,a0,-406 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200f0e:	be4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f12:	00004697          	auipc	a3,0x4
ffffffffc0200f16:	fbe68693          	addi	a3,a3,-66 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc0200f1a:	00004617          	auipc	a2,0x4
ffffffffc0200f1e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200f22:	0dd00593          	li	a1,221
ffffffffc0200f26:	00004517          	auipc	a0,0x4
ffffffffc0200f2a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200f2e:	bc4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f32:	00004697          	auipc	a3,0x4
ffffffffc0200f36:	fde68693          	addi	a3,a3,-34 # ffffffffc0204f10 <commands+0x8f0>
ffffffffc0200f3a:	00004617          	auipc	a2,0x4
ffffffffc0200f3e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200f42:	0dc00593          	li	a1,220
ffffffffc0200f46:	00004517          	auipc	a0,0x4
ffffffffc0200f4a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200f4e:	ba4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f52:	00004697          	auipc	a3,0x4
ffffffffc0200f56:	e5668693          	addi	a3,a3,-426 # ffffffffc0204da8 <commands+0x788>
ffffffffc0200f5a:	00004617          	auipc	a2,0x4
ffffffffc0200f5e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200f62:	0b900593          	li	a1,185
ffffffffc0200f66:	00004517          	auipc	a0,0x4
ffffffffc0200f6a:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200f6e:	b84ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f72:	00004697          	auipc	a3,0x4
ffffffffc0200f76:	f5e68693          	addi	a3,a3,-162 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc0200f7a:	00004617          	auipc	a2,0x4
ffffffffc0200f7e:	dde60613          	addi	a2,a2,-546 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200f82:	0d600593          	li	a1,214
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	dea50513          	addi	a0,a0,-534 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200f8e:	b64ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f92:	00004697          	auipc	a3,0x4
ffffffffc0200f96:	e5668693          	addi	a3,a3,-426 # ffffffffc0204de8 <commands+0x7c8>
ffffffffc0200f9a:	00004617          	auipc	a2,0x4
ffffffffc0200f9e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200fa2:	0d400593          	li	a1,212
ffffffffc0200fa6:	00004517          	auipc	a0,0x4
ffffffffc0200faa:	dca50513          	addi	a0,a0,-566 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200fae:	b44ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fb2:	00004697          	auipc	a3,0x4
ffffffffc0200fb6:	e1668693          	addi	a3,a3,-490 # ffffffffc0204dc8 <commands+0x7a8>
ffffffffc0200fba:	00004617          	auipc	a2,0x4
ffffffffc0200fbe:	d9e60613          	addi	a2,a2,-610 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200fc2:	0d300593          	li	a1,211
ffffffffc0200fc6:	00004517          	auipc	a0,0x4
ffffffffc0200fca:	daa50513          	addi	a0,a0,-598 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200fce:	b24ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd2:	00004697          	auipc	a3,0x4
ffffffffc0200fd6:	e1668693          	addi	a3,a3,-490 # ffffffffc0204de8 <commands+0x7c8>
ffffffffc0200fda:	00004617          	auipc	a2,0x4
ffffffffc0200fde:	d7e60613          	addi	a2,a2,-642 # ffffffffc0204d58 <commands+0x738>
ffffffffc0200fe2:	0bb00593          	li	a1,187
ffffffffc0200fe6:	00004517          	auipc	a0,0x4
ffffffffc0200fea:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204d70 <commands+0x750>
ffffffffc0200fee:	b04ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(count == 0);
ffffffffc0200ff2:	00004697          	auipc	a3,0x4
ffffffffc0200ff6:	09e68693          	addi	a3,a3,158 # ffffffffc0205090 <commands+0xa70>
ffffffffc0200ffa:	00004617          	auipc	a2,0x4
ffffffffc0200ffe:	d5e60613          	addi	a2,a2,-674 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201002:	12500593          	li	a1,293
ffffffffc0201006:	00004517          	auipc	a0,0x4
ffffffffc020100a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0204d70 <commands+0x750>
ffffffffc020100e:	ae4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free == 0);
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	f1e68693          	addi	a3,a3,-226 # ffffffffc0204f30 <commands+0x910>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201022:	11a00593          	li	a1,282
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0204d70 <commands+0x750>
ffffffffc020102e:	ac4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201032:	00004697          	auipc	a3,0x4
ffffffffc0201036:	e9e68693          	addi	a3,a3,-354 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc020103a:	00004617          	auipc	a2,0x4
ffffffffc020103e:	d1e60613          	addi	a2,a2,-738 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201042:	11800593          	li	a1,280
ffffffffc0201046:	00004517          	auipc	a0,0x4
ffffffffc020104a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0204d70 <commands+0x750>
ffffffffc020104e:	aa4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201052:	00004697          	auipc	a3,0x4
ffffffffc0201056:	e3e68693          	addi	a3,a3,-450 # ffffffffc0204e90 <commands+0x870>
ffffffffc020105a:	00004617          	auipc	a2,0x4
ffffffffc020105e:	cfe60613          	addi	a2,a2,-770 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201062:	0c100593          	li	a1,193
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0204d70 <commands+0x750>
ffffffffc020106e:	a84ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201072:	00004697          	auipc	a3,0x4
ffffffffc0201076:	fde68693          	addi	a3,a3,-34 # ffffffffc0205050 <commands+0xa30>
ffffffffc020107a:	00004617          	auipc	a2,0x4
ffffffffc020107e:	cde60613          	addi	a2,a2,-802 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201082:	11200593          	li	a1,274
ffffffffc0201086:	00004517          	auipc	a0,0x4
ffffffffc020108a:	cea50513          	addi	a0,a0,-790 # ffffffffc0204d70 <commands+0x750>
ffffffffc020108e:	a64ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201092:	00004697          	auipc	a3,0x4
ffffffffc0201096:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205030 <commands+0xa10>
ffffffffc020109a:	00004617          	auipc	a2,0x4
ffffffffc020109e:	cbe60613          	addi	a2,a2,-834 # ffffffffc0204d58 <commands+0x738>
ffffffffc02010a2:	11000593          	li	a1,272
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	cca50513          	addi	a0,a0,-822 # ffffffffc0204d70 <commands+0x750>
ffffffffc02010ae:	a44ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010b2:	00004697          	auipc	a3,0x4
ffffffffc02010b6:	f5668693          	addi	a3,a3,-170 # ffffffffc0205008 <commands+0x9e8>
ffffffffc02010ba:	00004617          	auipc	a2,0x4
ffffffffc02010be:	c9e60613          	addi	a2,a2,-866 # ffffffffc0204d58 <commands+0x738>
ffffffffc02010c2:	10e00593          	li	a1,270
ffffffffc02010c6:	00004517          	auipc	a0,0x4
ffffffffc02010ca:	caa50513          	addi	a0,a0,-854 # ffffffffc0204d70 <commands+0x750>
ffffffffc02010ce:	a24ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010d2:	00004697          	auipc	a3,0x4
ffffffffc02010d6:	f0e68693          	addi	a3,a3,-242 # ffffffffc0204fe0 <commands+0x9c0>
ffffffffc02010da:	00004617          	auipc	a2,0x4
ffffffffc02010de:	c7e60613          	addi	a2,a2,-898 # ffffffffc0204d58 <commands+0x738>
ffffffffc02010e2:	10d00593          	li	a1,269
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	c8a50513          	addi	a0,a0,-886 # ffffffffc0204d70 <commands+0x750>
ffffffffc02010ee:	a04ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	ede68693          	addi	a3,a3,-290 # ffffffffc0204fd0 <commands+0x9b0>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	c5e60613          	addi	a2,a2,-930 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201102:	10800593          	li	a1,264
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0204d70 <commands+0x750>
ffffffffc020110e:	9e4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201112:	00004697          	auipc	a3,0x4
ffffffffc0201116:	dbe68693          	addi	a3,a3,-578 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	c3e60613          	addi	a2,a2,-962 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201122:	10700593          	li	a1,263
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204d70 <commands+0x750>
ffffffffc020112e:	9c4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201132:	00004697          	auipc	a3,0x4
ffffffffc0201136:	e7e68693          	addi	a3,a3,-386 # ffffffffc0204fb0 <commands+0x990>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	c1e60613          	addi	a2,a2,-994 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201142:	10600593          	li	a1,262
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	c2a50513          	addi	a0,a0,-982 # ffffffffc0204d70 <commands+0x750>
ffffffffc020114e:	9a4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	e2e68693          	addi	a3,a3,-466 # ffffffffc0204f80 <commands+0x960>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201162:	10500593          	li	a1,261
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204d70 <commands+0x750>
ffffffffc020116e:	984ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	df668693          	addi	a3,a3,-522 # ffffffffc0204f68 <commands+0x948>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	bde60613          	addi	a2,a2,-1058 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201182:	10400593          	li	a1,260
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	bea50513          	addi	a0,a0,-1046 # ffffffffc0204d70 <commands+0x750>
ffffffffc020118e:	964ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	d3e68693          	addi	a3,a3,-706 # ffffffffc0204ed0 <commands+0x8b0>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0204d58 <commands+0x738>
ffffffffc02011a2:	0fe00593          	li	a1,254
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	bca50513          	addi	a0,a0,-1078 # ffffffffc0204d70 <commands+0x750>
ffffffffc02011ae:	944ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	d9e68693          	addi	a3,a3,-610 # ffffffffc0204f50 <commands+0x930>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0204d58 <commands+0x738>
ffffffffc02011c2:	0f900593          	li	a1,249
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	baa50513          	addi	a0,a0,-1110 # ffffffffc0204d70 <commands+0x750>
ffffffffc02011ce:	924ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	e9e68693          	addi	a3,a3,-354 # ffffffffc0205070 <commands+0xa50>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204d58 <commands+0x738>
ffffffffc02011e2:	11700593          	li	a1,279
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204d70 <commands+0x750>
ffffffffc02011ee:	904ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(total == 0);
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	eae68693          	addi	a3,a3,-338 # ffffffffc02050a0 <commands+0xa80>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201202:	12600593          	li	a1,294
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0204d70 <commands+0x750>
ffffffffc020120e:	8e4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	b7668693          	addi	a3,a3,-1162 # ffffffffc0204d88 <commands+0x768>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201222:	0f300593          	li	a1,243
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0204d70 <commands+0x750>
ffffffffc020122e:	8c4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201232:	00004697          	auipc	a3,0x4
ffffffffc0201236:	b9668693          	addi	a3,a3,-1130 # ffffffffc0204dc8 <commands+0x7a8>
ffffffffc020123a:	00004617          	auipc	a2,0x4
ffffffffc020123e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201242:	0ba00593          	li	a1,186
ffffffffc0201246:	00004517          	auipc	a0,0x4
ffffffffc020124a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0204d70 <commands+0x750>
ffffffffc020124e:	8a4ff0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0201252 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201252:	1141                	addi	sp,sp,-16
ffffffffc0201254:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201256:	14058a63          	beqz	a1,ffffffffc02013aa <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020125a:	00359693          	slli	a3,a1,0x3
ffffffffc020125e:	96ae                	add	a3,a3,a1
ffffffffc0201260:	068e                	slli	a3,a3,0x3
ffffffffc0201262:	96aa                	add	a3,a3,a0
ffffffffc0201264:	87aa                	mv	a5,a0
ffffffffc0201266:	02d50263          	beq	a0,a3,ffffffffc020128a <default_free_pages+0x38>
ffffffffc020126a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020126c:	8b05                	andi	a4,a4,1
ffffffffc020126e:	10071e63          	bnez	a4,ffffffffc020138a <default_free_pages+0x138>
ffffffffc0201272:	6798                	ld	a4,8(a5)
ffffffffc0201274:	8b09                	andi	a4,a4,2
ffffffffc0201276:	10071a63          	bnez	a4,ffffffffc020138a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020127a:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020127e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201282:	04878793          	addi	a5,a5,72
ffffffffc0201286:	fed792e3          	bne	a5,a3,ffffffffc020126a <default_free_pages+0x18>
    base->property = n;
ffffffffc020128a:	2581                	sext.w	a1,a1
ffffffffc020128c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020128e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201292:	4789                	li	a5,2
ffffffffc0201294:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201298:	00010697          	auipc	a3,0x10
ffffffffc020129c:	da868693          	addi	a3,a3,-600 # ffffffffc0211040 <free_area>
ffffffffc02012a0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012a2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012a4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012a8:	9db9                	addw	a1,a1,a4
ffffffffc02012aa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012ac:	0ad78863          	beq	a5,a3,ffffffffc020135c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012b0:	fe078713          	addi	a4,a5,-32
ffffffffc02012b4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012b8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012ba:	00e56a63          	bltu	a0,a4,ffffffffc02012ce <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012be:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012c0:	06d70263          	beq	a4,a3,ffffffffc0201324 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012c4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012c6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012ca:	fee57ae3          	bgeu	a0,a4,ffffffffc02012be <default_free_pages+0x6c>
ffffffffc02012ce:	c199                	beqz	a1,ffffffffc02012d4 <default_free_pages+0x82>
ffffffffc02012d0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012d4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012d6:	e390                	sd	a2,0(a5)
ffffffffc02012d8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012da:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012dc:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012de:	02d70063          	beq	a4,a3,ffffffffc02012fe <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02012e2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012e6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012ea:	02081613          	slli	a2,a6,0x20
ffffffffc02012ee:	9201                	srli	a2,a2,0x20
ffffffffc02012f0:	00361793          	slli	a5,a2,0x3
ffffffffc02012f4:	97b2                	add	a5,a5,a2
ffffffffc02012f6:	078e                	slli	a5,a5,0x3
ffffffffc02012f8:	97ae                	add	a5,a5,a1
ffffffffc02012fa:	02f50f63          	beq	a0,a5,ffffffffc0201338 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02012fe:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201300:	00d70f63          	beq	a4,a3,ffffffffc020131e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201304:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201306:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020130a:	02059613          	slli	a2,a1,0x20
ffffffffc020130e:	9201                	srli	a2,a2,0x20
ffffffffc0201310:	00361793          	slli	a5,a2,0x3
ffffffffc0201314:	97b2                	add	a5,a5,a2
ffffffffc0201316:	078e                	slli	a5,a5,0x3
ffffffffc0201318:	97aa                	add	a5,a5,a0
ffffffffc020131a:	04f68863          	beq	a3,a5,ffffffffc020136a <default_free_pages+0x118>
}
ffffffffc020131e:	60a2                	ld	ra,8(sp)
ffffffffc0201320:	0141                	addi	sp,sp,16
ffffffffc0201322:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201324:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201326:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201328:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020132a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020132c:	02d70563          	beq	a4,a3,ffffffffc0201356 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201330:	8832                	mv	a6,a2
ffffffffc0201332:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201334:	87ba                	mv	a5,a4
ffffffffc0201336:	bf41                	j	ffffffffc02012c6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201338:	4d1c                	lw	a5,24(a0)
ffffffffc020133a:	0107883b          	addw	a6,a5,a6
ffffffffc020133e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201342:	57f5                	li	a5,-3
ffffffffc0201344:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201348:	7110                	ld	a2,32(a0)
ffffffffc020134a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020134c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020134e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201350:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201352:	e390                	sd	a2,0(a5)
ffffffffc0201354:	b775                	j	ffffffffc0201300 <default_free_pages+0xae>
ffffffffc0201356:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201358:	873e                	mv	a4,a5
ffffffffc020135a:	b761                	j	ffffffffc02012e2 <default_free_pages+0x90>
}
ffffffffc020135c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020135e:	e390                	sd	a2,0(a5)
ffffffffc0201360:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201362:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201364:	f11c                	sd	a5,32(a0)
ffffffffc0201366:	0141                	addi	sp,sp,16
ffffffffc0201368:	8082                	ret
            base->property += p->property;
ffffffffc020136a:	ff872783          	lw	a5,-8(a4)
ffffffffc020136e:	fe870693          	addi	a3,a4,-24
ffffffffc0201372:	9dbd                	addw	a1,a1,a5
ffffffffc0201374:	cd0c                	sw	a1,24(a0)
ffffffffc0201376:	57f5                	li	a5,-3
ffffffffc0201378:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020137c:	6314                	ld	a3,0(a4)
ffffffffc020137e:	671c                	ld	a5,8(a4)
}
ffffffffc0201380:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201382:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201384:	e394                	sd	a3,0(a5)
ffffffffc0201386:	0141                	addi	sp,sp,16
ffffffffc0201388:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020138a:	00004697          	auipc	a3,0x4
ffffffffc020138e:	d2e68693          	addi	a3,a3,-722 # ffffffffc02050b8 <commands+0xa98>
ffffffffc0201392:	00004617          	auipc	a2,0x4
ffffffffc0201396:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204d58 <commands+0x738>
ffffffffc020139a:	08300593          	li	a1,131
ffffffffc020139e:	00004517          	auipc	a0,0x4
ffffffffc02013a2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204d70 <commands+0x750>
ffffffffc02013a6:	f4dfe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(n > 0);
ffffffffc02013aa:	00004697          	auipc	a3,0x4
ffffffffc02013ae:	d0668693          	addi	a3,a3,-762 # ffffffffc02050b0 <commands+0xa90>
ffffffffc02013b2:	00004617          	auipc	a2,0x4
ffffffffc02013b6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204d58 <commands+0x738>
ffffffffc02013ba:	08000593          	li	a1,128
ffffffffc02013be:	00004517          	auipc	a0,0x4
ffffffffc02013c2:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204d70 <commands+0x750>
ffffffffc02013c6:	f2dfe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02013ca <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013ca:	c959                	beqz	a0,ffffffffc0201460 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013cc:	00010597          	auipc	a1,0x10
ffffffffc02013d0:	c7458593          	addi	a1,a1,-908 # ffffffffc0211040 <free_area>
ffffffffc02013d4:	0105a803          	lw	a6,16(a1)
ffffffffc02013d8:	862a                	mv	a2,a0
ffffffffc02013da:	02081793          	slli	a5,a6,0x20
ffffffffc02013de:	9381                	srli	a5,a5,0x20
ffffffffc02013e0:	00a7ee63          	bltu	a5,a0,ffffffffc02013fc <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02013e4:	87ae                	mv	a5,a1
ffffffffc02013e6:	a801                	j	ffffffffc02013f6 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02013e8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013ec:	02071693          	slli	a3,a4,0x20
ffffffffc02013f0:	9281                	srli	a3,a3,0x20
ffffffffc02013f2:	00c6f763          	bgeu	a3,a2,ffffffffc0201400 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02013f6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013f8:	feb798e3          	bne	a5,a1,ffffffffc02013e8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02013fc:	4501                	li	a0,0
}
ffffffffc02013fe:	8082                	ret
    return listelm->prev;
ffffffffc0201400:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201404:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201408:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020140c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201410:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201414:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201418:	02d67b63          	bgeu	a2,a3,ffffffffc020144e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020141c:	00361693          	slli	a3,a2,0x3
ffffffffc0201420:	96b2                	add	a3,a3,a2
ffffffffc0201422:	068e                	slli	a3,a3,0x3
ffffffffc0201424:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201426:	41c7073b          	subw	a4,a4,t3
ffffffffc020142a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020142c:	00868613          	addi	a2,a3,8
ffffffffc0201430:	4709                	li	a4,2
ffffffffc0201432:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201436:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020143a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020143e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201442:	e310                	sd	a2,0(a4)
ffffffffc0201444:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201448:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020144a:	0316b023          	sd	a7,32(a3)
ffffffffc020144e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201452:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201456:	5775                	li	a4,-3
ffffffffc0201458:	17a1                	addi	a5,a5,-24
ffffffffc020145a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020145e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201460:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201462:	00004697          	auipc	a3,0x4
ffffffffc0201466:	c4e68693          	addi	a3,a3,-946 # ffffffffc02050b0 <commands+0xa90>
ffffffffc020146a:	00004617          	auipc	a2,0x4
ffffffffc020146e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201472:	06200593          	li	a1,98
ffffffffc0201476:	00004517          	auipc	a0,0x4
ffffffffc020147a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0204d70 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020147e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201480:	e73fe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0201484 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201484:	1141                	addi	sp,sp,-16
ffffffffc0201486:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201488:	c9e1                	beqz	a1,ffffffffc0201558 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020148a:	00359693          	slli	a3,a1,0x3
ffffffffc020148e:	96ae                	add	a3,a3,a1
ffffffffc0201490:	068e                	slli	a3,a3,0x3
ffffffffc0201492:	96aa                	add	a3,a3,a0
ffffffffc0201494:	87aa                	mv	a5,a0
ffffffffc0201496:	00d50f63          	beq	a0,a3,ffffffffc02014b4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020149a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020149c:	8b05                	andi	a4,a4,1
ffffffffc020149e:	cf49                	beqz	a4,ffffffffc0201538 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014a0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014a4:	0007b423          	sd	zero,8(a5)
ffffffffc02014a8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014ac:	04878793          	addi	a5,a5,72
ffffffffc02014b0:	fed795e3          	bne	a5,a3,ffffffffc020149a <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014b4:	2581                	sext.w	a1,a1
ffffffffc02014b6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014b8:	4789                	li	a5,2
ffffffffc02014ba:	00850713          	addi	a4,a0,8
ffffffffc02014be:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014c2:	00010697          	auipc	a3,0x10
ffffffffc02014c6:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0211040 <free_area>
ffffffffc02014ca:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014cc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014ce:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02014d2:	9db9                	addw	a1,a1,a4
ffffffffc02014d4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014d6:	04d78a63          	beq	a5,a3,ffffffffc020152a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02014da:	fe078713          	addi	a4,a5,-32
ffffffffc02014de:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014e4:	00e56a63          	bltu	a0,a4,ffffffffc02014f8 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02014e8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014ea:	02d70263          	beq	a4,a3,ffffffffc020150e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02014ee:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014f0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02014f4:	fee57ae3          	bgeu	a0,a4,ffffffffc02014e8 <default_init_memmap+0x64>
ffffffffc02014f8:	c199                	beqz	a1,ffffffffc02014fe <default_init_memmap+0x7a>
ffffffffc02014fa:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014fe:	6398                	ld	a4,0(a5)
}
ffffffffc0201500:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201502:	e390                	sd	a2,0(a5)
ffffffffc0201504:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201506:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201508:	f118                	sd	a4,32(a0)
ffffffffc020150a:	0141                	addi	sp,sp,16
ffffffffc020150c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020150e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201510:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201512:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201514:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201516:	00d70663          	beq	a4,a3,ffffffffc0201522 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020151a:	8832                	mv	a6,a2
ffffffffc020151c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020151e:	87ba                	mv	a5,a4
ffffffffc0201520:	bfc1                	j	ffffffffc02014f0 <default_init_memmap+0x6c>
}
ffffffffc0201522:	60a2                	ld	ra,8(sp)
ffffffffc0201524:	e290                	sd	a2,0(a3)
ffffffffc0201526:	0141                	addi	sp,sp,16
ffffffffc0201528:	8082                	ret
ffffffffc020152a:	60a2                	ld	ra,8(sp)
ffffffffc020152c:	e390                	sd	a2,0(a5)
ffffffffc020152e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201530:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201532:	f11c                	sd	a5,32(a0)
ffffffffc0201534:	0141                	addi	sp,sp,16
ffffffffc0201536:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201538:	00004697          	auipc	a3,0x4
ffffffffc020153c:	ba868693          	addi	a3,a3,-1112 # ffffffffc02050e0 <commands+0xac0>
ffffffffc0201540:	00004617          	auipc	a2,0x4
ffffffffc0201544:	81860613          	addi	a2,a2,-2024 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201548:	04900593          	li	a1,73
ffffffffc020154c:	00004517          	auipc	a0,0x4
ffffffffc0201550:	82450513          	addi	a0,a0,-2012 # ffffffffc0204d70 <commands+0x750>
ffffffffc0201554:	d9ffe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(n > 0);
ffffffffc0201558:	00004697          	auipc	a3,0x4
ffffffffc020155c:	b5868693          	addi	a3,a3,-1192 # ffffffffc02050b0 <commands+0xa90>
ffffffffc0201560:	00003617          	auipc	a2,0x3
ffffffffc0201564:	7f860613          	addi	a2,a2,2040 # ffffffffc0204d58 <commands+0x738>
ffffffffc0201568:	04600593          	li	a1,70
ffffffffc020156c:	00004517          	auipc	a0,0x4
ffffffffc0201570:	80450513          	addi	a0,a0,-2044 # ffffffffc0204d70 <commands+0x750>
ffffffffc0201574:	d7ffe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0201578 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201578:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020157a:	00004617          	auipc	a2,0x4
ffffffffc020157e:	bc660613          	addi	a2,a2,-1082 # ffffffffc0205140 <default_pmm_manager+0x38>
ffffffffc0201582:	06500593          	li	a1,101
ffffffffc0201586:	00004517          	auipc	a0,0x4
ffffffffc020158a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205160 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020158e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201590:	d63fe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0201594 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0201594:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201596:	00004617          	auipc	a2,0x4
ffffffffc020159a:	bda60613          	addi	a2,a2,-1062 # ffffffffc0205170 <default_pmm_manager+0x68>
ffffffffc020159e:	07000593          	li	a1,112
ffffffffc02015a2:	00004517          	auipc	a0,0x4
ffffffffc02015a6:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0205160 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015aa:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015ac:	d47fe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02015b0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015b0:	7139                	addi	sp,sp,-64
ffffffffc02015b2:	f426                	sd	s1,40(sp)
ffffffffc02015b4:	f04a                	sd	s2,32(sp)
ffffffffc02015b6:	ec4e                	sd	s3,24(sp)
ffffffffc02015b8:	e852                	sd	s4,16(sp)
ffffffffc02015ba:	e456                	sd	s5,8(sp)
ffffffffc02015bc:	e05a                	sd	s6,0(sp)
ffffffffc02015be:	fc06                	sd	ra,56(sp)
ffffffffc02015c0:	f822                	sd	s0,48(sp)
ffffffffc02015c2:	84aa                	mv	s1,a0
ffffffffc02015c4:	00010917          	auipc	s2,0x10
ffffffffc02015c8:	f6c90913          	addi	s2,s2,-148 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015cc:	4a05                	li	s4,1
ffffffffc02015ce:	00010a97          	auipc	s5,0x10
ffffffffc02015d2:	f82a8a93          	addi	s5,s5,-126 # ffffffffc0211550 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015d6:	0005099b          	sext.w	s3,a0
ffffffffc02015da:	00010b17          	auipc	s6,0x10
ffffffffc02015de:	f86b0b13          	addi	s6,s6,-122 # ffffffffc0211560 <check_mm_struct>
ffffffffc02015e2:	a01d                	j	ffffffffc0201608 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015e4:	00093783          	ld	a5,0(s2)
ffffffffc02015e8:	6f9c                	ld	a5,24(a5)
ffffffffc02015ea:	9782                	jalr	a5
ffffffffc02015ec:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02015ee:	4601                	li	a2,0
ffffffffc02015f0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015f2:	ec0d                	bnez	s0,ffffffffc020162c <alloc_pages+0x7c>
ffffffffc02015f4:	029a6c63          	bltu	s4,s1,ffffffffc020162c <alloc_pages+0x7c>
ffffffffc02015f8:	000aa783          	lw	a5,0(s5)
ffffffffc02015fc:	2781                	sext.w	a5,a5
ffffffffc02015fe:	c79d                	beqz	a5,ffffffffc020162c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201600:	000b3503          	ld	a0,0(s6)
ffffffffc0201604:	189010ef          	jal	ra,ffffffffc0202f8c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201608:	100027f3          	csrr	a5,sstatus
ffffffffc020160c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020160e:	8526                	mv	a0,s1
ffffffffc0201610:	dbf1                	beqz	a5,ffffffffc02015e4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201612:	eddfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201616:	00093783          	ld	a5,0(s2)
ffffffffc020161a:	8526                	mv	a0,s1
ffffffffc020161c:	6f9c                	ld	a5,24(a5)
ffffffffc020161e:	9782                	jalr	a5
ffffffffc0201620:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201622:	ec7fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201626:	4601                	li	a2,0
ffffffffc0201628:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020162a:	d469                	beqz	s0,ffffffffc02015f4 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020162c:	70e2                	ld	ra,56(sp)
ffffffffc020162e:	8522                	mv	a0,s0
ffffffffc0201630:	7442                	ld	s0,48(sp)
ffffffffc0201632:	74a2                	ld	s1,40(sp)
ffffffffc0201634:	7902                	ld	s2,32(sp)
ffffffffc0201636:	69e2                	ld	s3,24(sp)
ffffffffc0201638:	6a42                	ld	s4,16(sp)
ffffffffc020163a:	6aa2                	ld	s5,8(sp)
ffffffffc020163c:	6b02                	ld	s6,0(sp)
ffffffffc020163e:	6121                	addi	sp,sp,64
ffffffffc0201640:	8082                	ret

ffffffffc0201642 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201642:	100027f3          	csrr	a5,sstatus
ffffffffc0201646:	8b89                	andi	a5,a5,2
ffffffffc0201648:	e799                	bnez	a5,ffffffffc0201656 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020164a:	00010797          	auipc	a5,0x10
ffffffffc020164e:	ee67b783          	ld	a5,-282(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201652:	739c                	ld	a5,32(a5)
ffffffffc0201654:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201656:	1101                	addi	sp,sp,-32
ffffffffc0201658:	ec06                	sd	ra,24(sp)
ffffffffc020165a:	e822                	sd	s0,16(sp)
ffffffffc020165c:	e426                	sd	s1,8(sp)
ffffffffc020165e:	842a                	mv	s0,a0
ffffffffc0201660:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201662:	e8dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201666:	00010797          	auipc	a5,0x10
ffffffffc020166a:	eca7b783          	ld	a5,-310(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020166e:	739c                	ld	a5,32(a5)
ffffffffc0201670:	85a6                	mv	a1,s1
ffffffffc0201672:	8522                	mv	a0,s0
ffffffffc0201674:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201676:	6442                	ld	s0,16(sp)
ffffffffc0201678:	60e2                	ld	ra,24(sp)
ffffffffc020167a:	64a2                	ld	s1,8(sp)
ffffffffc020167c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020167e:	e6bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0201682 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201682:	100027f3          	csrr	a5,sstatus
ffffffffc0201686:	8b89                	andi	a5,a5,2
ffffffffc0201688:	e799                	bnez	a5,ffffffffc0201696 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020168a:	00010797          	auipc	a5,0x10
ffffffffc020168e:	ea67b783          	ld	a5,-346(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201692:	779c                	ld	a5,40(a5)
ffffffffc0201694:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201696:	1141                	addi	sp,sp,-16
ffffffffc0201698:	e406                	sd	ra,8(sp)
ffffffffc020169a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020169c:	e53fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016a0:	00010797          	auipc	a5,0x10
ffffffffc02016a4:	e907b783          	ld	a5,-368(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02016a8:	779c                	ld	a5,40(a5)
ffffffffc02016aa:	9782                	jalr	a5
ffffffffc02016ac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016ae:	e3bfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016b2:	60a2                	ld	ra,8(sp)
ffffffffc02016b4:	8522                	mv	a0,s0
ffffffffc02016b6:	6402                	ld	s0,0(sp)
ffffffffc02016b8:	0141                	addi	sp,sp,16
ffffffffc02016ba:	8082                	ret

ffffffffc02016bc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016bc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016c0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016c4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016c6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016c8:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016ca:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016ce:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d0:	f84a                	sd	s2,48(sp)
ffffffffc02016d2:	f44e                	sd	s3,40(sp)
ffffffffc02016d4:	f052                	sd	s4,32(sp)
ffffffffc02016d6:	e486                	sd	ra,72(sp)
ffffffffc02016d8:	e0a2                	sd	s0,64(sp)
ffffffffc02016da:	ec56                	sd	s5,24(sp)
ffffffffc02016dc:	e85a                	sd	s6,16(sp)
ffffffffc02016de:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016e0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016e4:	892e                	mv	s2,a1
ffffffffc02016e6:	8a32                	mv	s4,a2
ffffffffc02016e8:	00010997          	auipc	s3,0x10
ffffffffc02016ec:	e3898993          	addi	s3,s3,-456 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016f0:	efb5                	bnez	a5,ffffffffc020176c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02016f2:	14060c63          	beqz	a2,ffffffffc020184a <get_pte+0x18e>
ffffffffc02016f6:	4505                	li	a0,1
ffffffffc02016f8:	eb9ff0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc02016fc:	842a                	mv	s0,a0
ffffffffc02016fe:	14050663          	beqz	a0,ffffffffc020184a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201702:	00010b97          	auipc	s7,0x10
ffffffffc0201706:	e26b8b93          	addi	s7,s7,-474 # ffffffffc0211528 <pages>
ffffffffc020170a:	000bb503          	ld	a0,0(s7)
ffffffffc020170e:	00005b17          	auipc	s6,0x5
ffffffffc0201712:	aa2b3b03          	ld	s6,-1374(s6) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0201716:	00080ab7          	lui	s5,0x80
ffffffffc020171a:	40a40533          	sub	a0,s0,a0
ffffffffc020171e:	850d                	srai	a0,a0,0x3
ffffffffc0201720:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201724:	00010997          	auipc	s3,0x10
ffffffffc0201728:	dfc98993          	addi	s3,s3,-516 # ffffffffc0211520 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020172c:	4785                	li	a5,1
ffffffffc020172e:	0009b703          	ld	a4,0(s3)
ffffffffc0201732:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201734:	9556                	add	a0,a0,s5
ffffffffc0201736:	00c51793          	slli	a5,a0,0xc
ffffffffc020173a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020173c:	0532                	slli	a0,a0,0xc
ffffffffc020173e:	14e7fd63          	bgeu	a5,a4,ffffffffc0201898 <get_pte+0x1dc>
ffffffffc0201742:	00010797          	auipc	a5,0x10
ffffffffc0201746:	df67b783          	ld	a5,-522(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc020174a:	6605                	lui	a2,0x1
ffffffffc020174c:	4581                	li	a1,0
ffffffffc020174e:	953e                	add	a0,a0,a5
ffffffffc0201750:	44f020ef          	jal	ra,ffffffffc020439e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201754:	000bb683          	ld	a3,0(s7)
ffffffffc0201758:	40d406b3          	sub	a3,s0,a3
ffffffffc020175c:	868d                	srai	a3,a3,0x3
ffffffffc020175e:	036686b3          	mul	a3,a3,s6
ffffffffc0201762:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201764:	06aa                	slli	a3,a3,0xa
ffffffffc0201766:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020176a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020176c:	77fd                	lui	a5,0xfffff
ffffffffc020176e:	068a                	slli	a3,a3,0x2
ffffffffc0201770:	0009b703          	ld	a4,0(s3)
ffffffffc0201774:	8efd                	and	a3,a3,a5
ffffffffc0201776:	00c6d793          	srli	a5,a3,0xc
ffffffffc020177a:	0ce7fa63          	bgeu	a5,a4,ffffffffc020184e <get_pte+0x192>
ffffffffc020177e:	00010a97          	auipc	s5,0x10
ffffffffc0201782:	dbaa8a93          	addi	s5,s5,-582 # ffffffffc0211538 <va_pa_offset>
ffffffffc0201786:	000ab403          	ld	s0,0(s5)
ffffffffc020178a:	01595793          	srli	a5,s2,0x15
ffffffffc020178e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201792:	96a2                	add	a3,a3,s0
ffffffffc0201794:	00379413          	slli	s0,a5,0x3
ffffffffc0201798:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020179a:	6014                	ld	a3,0(s0)
ffffffffc020179c:	0016f793          	andi	a5,a3,1
ffffffffc02017a0:	ebad                	bnez	a5,ffffffffc0201812 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017a2:	0a0a0463          	beqz	s4,ffffffffc020184a <get_pte+0x18e>
ffffffffc02017a6:	4505                	li	a0,1
ffffffffc02017a8:	e09ff0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc02017ac:	84aa                	mv	s1,a0
ffffffffc02017ae:	cd51                	beqz	a0,ffffffffc020184a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017b0:	00010b97          	auipc	s7,0x10
ffffffffc02017b4:	d78b8b93          	addi	s7,s7,-648 # ffffffffc0211528 <pages>
ffffffffc02017b8:	000bb503          	ld	a0,0(s7)
ffffffffc02017bc:	00005b17          	auipc	s6,0x5
ffffffffc02017c0:	9f4b3b03          	ld	s6,-1548(s6) # ffffffffc02061b0 <error_string+0x38>
ffffffffc02017c4:	00080a37          	lui	s4,0x80
ffffffffc02017c8:	40a48533          	sub	a0,s1,a0
ffffffffc02017cc:	850d                	srai	a0,a0,0x3
ffffffffc02017ce:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017d2:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017d4:	0009b703          	ld	a4,0(s3)
ffffffffc02017d8:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017da:	9552                	add	a0,a0,s4
ffffffffc02017dc:	00c51793          	slli	a5,a0,0xc
ffffffffc02017e0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017e2:	0532                	slli	a0,a0,0xc
ffffffffc02017e4:	08e7fd63          	bgeu	a5,a4,ffffffffc020187e <get_pte+0x1c2>
ffffffffc02017e8:	000ab783          	ld	a5,0(s5)
ffffffffc02017ec:	6605                	lui	a2,0x1
ffffffffc02017ee:	4581                	li	a1,0
ffffffffc02017f0:	953e                	add	a0,a0,a5
ffffffffc02017f2:	3ad020ef          	jal	ra,ffffffffc020439e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017f6:	000bb683          	ld	a3,0(s7)
ffffffffc02017fa:	40d486b3          	sub	a3,s1,a3
ffffffffc02017fe:	868d                	srai	a3,a3,0x3
ffffffffc0201800:	036686b3          	mul	a3,a3,s6
ffffffffc0201804:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201806:	06aa                	slli	a3,a3,0xa
ffffffffc0201808:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020180c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020180e:	0009b703          	ld	a4,0(s3)
ffffffffc0201812:	068a                	slli	a3,a3,0x2
ffffffffc0201814:	757d                	lui	a0,0xfffff
ffffffffc0201816:	8ee9                	and	a3,a3,a0
ffffffffc0201818:	00c6d793          	srli	a5,a3,0xc
ffffffffc020181c:	04e7f563          	bgeu	a5,a4,ffffffffc0201866 <get_pte+0x1aa>
ffffffffc0201820:	000ab503          	ld	a0,0(s5)
ffffffffc0201824:	00c95913          	srli	s2,s2,0xc
ffffffffc0201828:	1ff97913          	andi	s2,s2,511
ffffffffc020182c:	96aa                	add	a3,a3,a0
ffffffffc020182e:	00391513          	slli	a0,s2,0x3
ffffffffc0201832:	9536                	add	a0,a0,a3
}
ffffffffc0201834:	60a6                	ld	ra,72(sp)
ffffffffc0201836:	6406                	ld	s0,64(sp)
ffffffffc0201838:	74e2                	ld	s1,56(sp)
ffffffffc020183a:	7942                	ld	s2,48(sp)
ffffffffc020183c:	79a2                	ld	s3,40(sp)
ffffffffc020183e:	7a02                	ld	s4,32(sp)
ffffffffc0201840:	6ae2                	ld	s5,24(sp)
ffffffffc0201842:	6b42                	ld	s6,16(sp)
ffffffffc0201844:	6ba2                	ld	s7,8(sp)
ffffffffc0201846:	6161                	addi	sp,sp,80
ffffffffc0201848:	8082                	ret
            return NULL;
ffffffffc020184a:	4501                	li	a0,0
ffffffffc020184c:	b7e5                	j	ffffffffc0201834 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020184e:	00004617          	auipc	a2,0x4
ffffffffc0201852:	94a60613          	addi	a2,a2,-1718 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc0201856:	10200593          	li	a1,258
ffffffffc020185a:	00004517          	auipc	a0,0x4
ffffffffc020185e:	96650513          	addi	a0,a0,-1690 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0201862:	a91fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201866:	00004617          	auipc	a2,0x4
ffffffffc020186a:	93260613          	addi	a2,a2,-1742 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc020186e:	10f00593          	li	a1,271
ffffffffc0201872:	00004517          	auipc	a0,0x4
ffffffffc0201876:	94e50513          	addi	a0,a0,-1714 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020187a:	a79fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020187e:	86aa                	mv	a3,a0
ffffffffc0201880:	00004617          	auipc	a2,0x4
ffffffffc0201884:	91860613          	addi	a2,a2,-1768 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc0201888:	10b00593          	li	a1,267
ffffffffc020188c:	00004517          	auipc	a0,0x4
ffffffffc0201890:	93450513          	addi	a0,a0,-1740 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0201894:	a5ffe0ef          	jal	ra,ffffffffc02002f2 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201898:	86aa                	mv	a3,a0
ffffffffc020189a:	00004617          	auipc	a2,0x4
ffffffffc020189e:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc02018a2:	0ff00593          	li	a1,255
ffffffffc02018a6:	00004517          	auipc	a0,0x4
ffffffffc02018aa:	91a50513          	addi	a0,a0,-1766 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02018ae:	a45fe0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02018b2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018b2:	1141                	addi	sp,sp,-16
ffffffffc02018b4:	e022                	sd	s0,0(sp)
ffffffffc02018b6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018b8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018ba:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018bc:	e01ff0ef          	jal	ra,ffffffffc02016bc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02018c0:	c011                	beqz	s0,ffffffffc02018c4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02018c2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018c4:	c511                	beqz	a0,ffffffffc02018d0 <get_page+0x1e>
ffffffffc02018c6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02018c8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018ca:	0017f713          	andi	a4,a5,1
ffffffffc02018ce:	e709                	bnez	a4,ffffffffc02018d8 <get_page+0x26>
}
ffffffffc02018d0:	60a2                	ld	ra,8(sp)
ffffffffc02018d2:	6402                	ld	s0,0(sp)
ffffffffc02018d4:	0141                	addi	sp,sp,16
ffffffffc02018d6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02018d8:	078a                	slli	a5,a5,0x2
ffffffffc02018da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018dc:	00010717          	auipc	a4,0x10
ffffffffc02018e0:	c4473703          	ld	a4,-956(a4) # ffffffffc0211520 <npage>
ffffffffc02018e4:	02e7f263          	bgeu	a5,a4,ffffffffc0201908 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc02018e8:	fff80537          	lui	a0,0xfff80
ffffffffc02018ec:	97aa                	add	a5,a5,a0
ffffffffc02018ee:	60a2                	ld	ra,8(sp)
ffffffffc02018f0:	6402                	ld	s0,0(sp)
ffffffffc02018f2:	00379513          	slli	a0,a5,0x3
ffffffffc02018f6:	97aa                	add	a5,a5,a0
ffffffffc02018f8:	078e                	slli	a5,a5,0x3
ffffffffc02018fa:	00010517          	auipc	a0,0x10
ffffffffc02018fe:	c2e53503          	ld	a0,-978(a0) # ffffffffc0211528 <pages>
ffffffffc0201902:	953e                	add	a0,a0,a5
ffffffffc0201904:	0141                	addi	sp,sp,16
ffffffffc0201906:	8082                	ret
ffffffffc0201908:	c71ff0ef          	jal	ra,ffffffffc0201578 <pa2page.part.0>

ffffffffc020190c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020190c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020190e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201910:	ec06                	sd	ra,24(sp)
ffffffffc0201912:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201914:	da9ff0ef          	jal	ra,ffffffffc02016bc <get_pte>
    if (ptep != NULL) {
ffffffffc0201918:	c511                	beqz	a0,ffffffffc0201924 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020191a:	611c                	ld	a5,0(a0)
ffffffffc020191c:	842a                	mv	s0,a0
ffffffffc020191e:	0017f713          	andi	a4,a5,1
ffffffffc0201922:	e709                	bnez	a4,ffffffffc020192c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201924:	60e2                	ld	ra,24(sp)
ffffffffc0201926:	6442                	ld	s0,16(sp)
ffffffffc0201928:	6105                	addi	sp,sp,32
ffffffffc020192a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020192c:	078a                	slli	a5,a5,0x2
ffffffffc020192e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201930:	00010717          	auipc	a4,0x10
ffffffffc0201934:	bf073703          	ld	a4,-1040(a4) # ffffffffc0211520 <npage>
ffffffffc0201938:	06e7f563          	bgeu	a5,a4,ffffffffc02019a2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020193c:	fff80737          	lui	a4,0xfff80
ffffffffc0201940:	97ba                	add	a5,a5,a4
ffffffffc0201942:	00379513          	slli	a0,a5,0x3
ffffffffc0201946:	97aa                	add	a5,a5,a0
ffffffffc0201948:	078e                	slli	a5,a5,0x3
ffffffffc020194a:	00010517          	auipc	a0,0x10
ffffffffc020194e:	bde53503          	ld	a0,-1058(a0) # ffffffffc0211528 <pages>
ffffffffc0201952:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201954:	411c                	lw	a5,0(a0)
ffffffffc0201956:	fff7871b          	addiw	a4,a5,-1
ffffffffc020195a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020195c:	cb09                	beqz	a4,ffffffffc020196e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020195e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201962:	12000073          	sfence.vma
}
ffffffffc0201966:	60e2                	ld	ra,24(sp)
ffffffffc0201968:	6442                	ld	s0,16(sp)
ffffffffc020196a:	6105                	addi	sp,sp,32
ffffffffc020196c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020196e:	100027f3          	csrr	a5,sstatus
ffffffffc0201972:	8b89                	andi	a5,a5,2
ffffffffc0201974:	eb89                	bnez	a5,ffffffffc0201986 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201976:	00010797          	auipc	a5,0x10
ffffffffc020197a:	bba7b783          	ld	a5,-1094(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020197e:	739c                	ld	a5,32(a5)
ffffffffc0201980:	4585                	li	a1,1
ffffffffc0201982:	9782                	jalr	a5
    if (flag) {
ffffffffc0201984:	bfe9                	j	ffffffffc020195e <page_remove+0x52>
        intr_disable();
ffffffffc0201986:	e42a                	sd	a0,8(sp)
ffffffffc0201988:	b67fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020198c:	00010797          	auipc	a5,0x10
ffffffffc0201990:	ba47b783          	ld	a5,-1116(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201994:	739c                	ld	a5,32(a5)
ffffffffc0201996:	6522                	ld	a0,8(sp)
ffffffffc0201998:	4585                	li	a1,1
ffffffffc020199a:	9782                	jalr	a5
        intr_enable();
ffffffffc020199c:	b4dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019a0:	bf7d                	j	ffffffffc020195e <page_remove+0x52>
ffffffffc02019a2:	bd7ff0ef          	jal	ra,ffffffffc0201578 <pa2page.part.0>

ffffffffc02019a6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019a6:	7179                	addi	sp,sp,-48
ffffffffc02019a8:	87b2                	mv	a5,a2
ffffffffc02019aa:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ac:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019ae:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019b0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019b2:	ec26                	sd	s1,24(sp)
ffffffffc02019b4:	f406                	sd	ra,40(sp)
ffffffffc02019b6:	e84a                	sd	s2,16(sp)
ffffffffc02019b8:	e44e                	sd	s3,8(sp)
ffffffffc02019ba:	e052                	sd	s4,0(sp)
ffffffffc02019bc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019be:	cffff0ef          	jal	ra,ffffffffc02016bc <get_pte>
    if (ptep == NULL) {
ffffffffc02019c2:	cd71                	beqz	a0,ffffffffc0201a9e <page_insert+0xf8>
    page->ref += 1;
ffffffffc02019c4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc02019c6:	611c                	ld	a5,0(a0)
ffffffffc02019c8:	89aa                	mv	s3,a0
ffffffffc02019ca:	0016871b          	addiw	a4,a3,1
ffffffffc02019ce:	c018                	sw	a4,0(s0)
ffffffffc02019d0:	0017f713          	andi	a4,a5,1
ffffffffc02019d4:	e331                	bnez	a4,ffffffffc0201a18 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02019d6:	00010797          	auipc	a5,0x10
ffffffffc02019da:	b527b783          	ld	a5,-1198(a5) # ffffffffc0211528 <pages>
ffffffffc02019de:	40f407b3          	sub	a5,s0,a5
ffffffffc02019e2:	878d                	srai	a5,a5,0x3
ffffffffc02019e4:	00004417          	auipc	s0,0x4
ffffffffc02019e8:	7cc43403          	ld	s0,1996(s0) # ffffffffc02061b0 <error_string+0x38>
ffffffffc02019ec:	028787b3          	mul	a5,a5,s0
ffffffffc02019f0:	00080437          	lui	s0,0x80
ffffffffc02019f4:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02019f6:	07aa                	slli	a5,a5,0xa
ffffffffc02019f8:	8cdd                	or	s1,s1,a5
ffffffffc02019fa:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02019fe:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a02:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a06:	4501                	li	a0,0
}
ffffffffc0201a08:	70a2                	ld	ra,40(sp)
ffffffffc0201a0a:	7402                	ld	s0,32(sp)
ffffffffc0201a0c:	64e2                	ld	s1,24(sp)
ffffffffc0201a0e:	6942                	ld	s2,16(sp)
ffffffffc0201a10:	69a2                	ld	s3,8(sp)
ffffffffc0201a12:	6a02                	ld	s4,0(sp)
ffffffffc0201a14:	6145                	addi	sp,sp,48
ffffffffc0201a16:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a18:	00279713          	slli	a4,a5,0x2
ffffffffc0201a1c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a1e:	00010797          	auipc	a5,0x10
ffffffffc0201a22:	b027b783          	ld	a5,-1278(a5) # ffffffffc0211520 <npage>
ffffffffc0201a26:	06f77e63          	bgeu	a4,a5,ffffffffc0201aa2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a2a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a2e:	973e                	add	a4,a4,a5
ffffffffc0201a30:	00010a17          	auipc	s4,0x10
ffffffffc0201a34:	af8a0a13          	addi	s4,s4,-1288 # ffffffffc0211528 <pages>
ffffffffc0201a38:	000a3783          	ld	a5,0(s4)
ffffffffc0201a3c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a40:	993a                	add	s2,s2,a4
ffffffffc0201a42:	090e                	slli	s2,s2,0x3
ffffffffc0201a44:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a46:	03240063          	beq	s0,s2,ffffffffc0201a66 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a4a:	00092783          	lw	a5,0(s2)
ffffffffc0201a4e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a52:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a56:	cb11                	beqz	a4,ffffffffc0201a6a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a58:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a5c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a60:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201a64:	bfad                	j	ffffffffc02019de <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201a66:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201a68:	bf9d                	j	ffffffffc02019de <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a6a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a6e:	8b89                	andi	a5,a5,2
ffffffffc0201a70:	eb91                	bnez	a5,ffffffffc0201a84 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201a72:	00010797          	auipc	a5,0x10
ffffffffc0201a76:	abe7b783          	ld	a5,-1346(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201a7a:	739c                	ld	a5,32(a5)
ffffffffc0201a7c:	4585                	li	a1,1
ffffffffc0201a7e:	854a                	mv	a0,s2
ffffffffc0201a80:	9782                	jalr	a5
    if (flag) {
ffffffffc0201a82:	bfd9                	j	ffffffffc0201a58 <page_insert+0xb2>
        intr_disable();
ffffffffc0201a84:	a6bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201a88:	00010797          	auipc	a5,0x10
ffffffffc0201a8c:	aa87b783          	ld	a5,-1368(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201a90:	739c                	ld	a5,32(a5)
ffffffffc0201a92:	4585                	li	a1,1
ffffffffc0201a94:	854a                	mv	a0,s2
ffffffffc0201a96:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a98:	a51fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201a9c:	bf75                	j	ffffffffc0201a58 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201a9e:	5571                	li	a0,-4
ffffffffc0201aa0:	b7a5                	j	ffffffffc0201a08 <page_insert+0x62>
ffffffffc0201aa2:	ad7ff0ef          	jal	ra,ffffffffc0201578 <pa2page.part.0>

ffffffffc0201aa6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201aa6:	00003797          	auipc	a5,0x3
ffffffffc0201aaa:	66278793          	addi	a5,a5,1634 # ffffffffc0205108 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201aae:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ab0:	7159                	addi	sp,sp,-112
ffffffffc0201ab2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ab4:	00003517          	auipc	a0,0x3
ffffffffc0201ab8:	71c50513          	addi	a0,a0,1820 # ffffffffc02051d0 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201abc:	00010b97          	auipc	s7,0x10
ffffffffc0201ac0:	a74b8b93          	addi	s7,s7,-1420 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ac4:	f486                	sd	ra,104(sp)
ffffffffc0201ac6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ac8:	eca6                	sd	s1,88(sp)
ffffffffc0201aca:	e8ca                	sd	s2,80(sp)
ffffffffc0201acc:	e4ce                	sd	s3,72(sp)
ffffffffc0201ace:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ad0:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201ad4:	e0d2                	sd	s4,64(sp)
ffffffffc0201ad6:	fc56                	sd	s5,56(sp)
ffffffffc0201ad8:	f062                	sd	s8,32(sp)
ffffffffc0201ada:	ec66                	sd	s9,24(sp)
ffffffffc0201adc:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ade:	8abfe0ef          	jal	ra,ffffffffc0200388 <cprintf>
    pmm_manager->init();
ffffffffc0201ae2:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ae6:	4445                	li	s0,17
ffffffffc0201ae8:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201aec:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201aee:	00010997          	auipc	s3,0x10
ffffffffc0201af2:	a4a98993          	addi	s3,s3,-1462 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201af6:	00010497          	auipc	s1,0x10
ffffffffc0201afa:	a2a48493          	addi	s1,s1,-1494 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201afe:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b00:	57f5                	li	a5,-3
ffffffffc0201b02:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b04:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b08:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b0c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b10:	00003517          	auipc	a0,0x3
ffffffffc0201b14:	6d850513          	addi	a0,a0,1752 # ffffffffc02051e8 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b18:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b1c:	86dfe0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b20:	00003517          	auipc	a0,0x3
ffffffffc0201b24:	6f850513          	addi	a0,a0,1784 # ffffffffc0205218 <default_pmm_manager+0x110>
ffffffffc0201b28:	861fe0ef          	jal	ra,ffffffffc0200388 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b2c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b30:	16fd                	addi	a3,a3,-1
ffffffffc0201b32:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b36:	01591613          	slli	a2,s2,0x15
ffffffffc0201b3a:	00003517          	auipc	a0,0x3
ffffffffc0201b3e:	6f650513          	addi	a0,a0,1782 # ffffffffc0205230 <default_pmm_manager+0x128>
ffffffffc0201b42:	847fe0ef          	jal	ra,ffffffffc0200388 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b46:	777d                	lui	a4,0xfffff
ffffffffc0201b48:	00011797          	auipc	a5,0x11
ffffffffc0201b4c:	a2378793          	addi	a5,a5,-1501 # ffffffffc021256b <end+0xfff>
ffffffffc0201b50:	8ff9                	and	a5,a5,a4
ffffffffc0201b52:	00010b17          	auipc	s6,0x10
ffffffffc0201b56:	9d6b0b13          	addi	s6,s6,-1578 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b5a:	00088737          	lui	a4,0x88
ffffffffc0201b5e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b60:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b64:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b66:	4701                	li	a4,0
ffffffffc0201b68:	4505                	li	a0,1
ffffffffc0201b6a:	fff805b7          	lui	a1,0xfff80
ffffffffc0201b6e:	a019                	j	ffffffffc0201b74 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201b70:	000b3783          	ld	a5,0(s6)
ffffffffc0201b74:	97b6                	add	a5,a5,a3
ffffffffc0201b76:	07a1                	addi	a5,a5,8
ffffffffc0201b78:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b7c:	609c                	ld	a5,0(s1)
ffffffffc0201b7e:	0705                	addi	a4,a4,1
ffffffffc0201b80:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201b84:	00b78633          	add	a2,a5,a1
ffffffffc0201b88:	fec764e3          	bltu	a4,a2,ffffffffc0201b70 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b8c:	000b3503          	ld	a0,0(s6)
ffffffffc0201b90:	00379693          	slli	a3,a5,0x3
ffffffffc0201b94:	96be                	add	a3,a3,a5
ffffffffc0201b96:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201b9a:	972a                	add	a4,a4,a0
ffffffffc0201b9c:	068e                	slli	a3,a3,0x3
ffffffffc0201b9e:	96ba                	add	a3,a3,a4
ffffffffc0201ba0:	c0200737          	lui	a4,0xc0200
ffffffffc0201ba4:	64e6e463          	bltu	a3,a4,ffffffffc02021ec <pmm_init+0x746>
ffffffffc0201ba8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bac:	4645                	li	a2,17
ffffffffc0201bae:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bb0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201bb2:	4ec6e263          	bltu	a3,a2,ffffffffc0202096 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bb6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bba:	00010917          	auipc	s2,0x10
ffffffffc0201bbe:	95e90913          	addi	s2,s2,-1698 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bc2:	7b9c                	ld	a5,48(a5)
ffffffffc0201bc4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201bc6:	00003517          	auipc	a0,0x3
ffffffffc0201bca:	6ba50513          	addi	a0,a0,1722 # ffffffffc0205280 <default_pmm_manager+0x178>
ffffffffc0201bce:	fbafe0ef          	jal	ra,ffffffffc0200388 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bd2:	00007697          	auipc	a3,0x7
ffffffffc0201bd6:	42e68693          	addi	a3,a3,1070 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201bda:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201bde:	c02007b7          	lui	a5,0xc0200
ffffffffc0201be2:	62f6e163          	bltu	a3,a5,ffffffffc0202204 <pmm_init+0x75e>
ffffffffc0201be6:	0009b783          	ld	a5,0(s3)
ffffffffc0201bea:	8e9d                	sub	a3,a3,a5
ffffffffc0201bec:	00010797          	auipc	a5,0x10
ffffffffc0201bf0:	92d7b223          	sd	a3,-1756(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bf4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bf8:	8b89                	andi	a5,a5,2
ffffffffc0201bfa:	4c079763          	bnez	a5,ffffffffc02020c8 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201bfe:	000bb783          	ld	a5,0(s7)
ffffffffc0201c02:	779c                	ld	a5,40(a5)
ffffffffc0201c04:	9782                	jalr	a5
ffffffffc0201c06:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c08:	6098                	ld	a4,0(s1)
ffffffffc0201c0a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c0e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c10:	62e7e663          	bltu	a5,a4,ffffffffc020223c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c14:	00093503          	ld	a0,0(s2)
ffffffffc0201c18:	60050263          	beqz	a0,ffffffffc020221c <pmm_init+0x776>
ffffffffc0201c1c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c20:	5e079e63          	bnez	a5,ffffffffc020221c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c24:	4601                	li	a2,0
ffffffffc0201c26:	4581                	li	a1,0
ffffffffc0201c28:	c8bff0ef          	jal	ra,ffffffffc02018b2 <get_page>
ffffffffc0201c2c:	66051a63          	bnez	a0,ffffffffc02022a0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c30:	4505                	li	a0,1
ffffffffc0201c32:	97fff0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201c36:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c38:	00093503          	ld	a0,0(s2)
ffffffffc0201c3c:	4681                	li	a3,0
ffffffffc0201c3e:	4601                	li	a2,0
ffffffffc0201c40:	85d2                	mv	a1,s4
ffffffffc0201c42:	d65ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc0201c46:	62051d63          	bnez	a0,ffffffffc0202280 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c4a:	00093503          	ld	a0,0(s2)
ffffffffc0201c4e:	4601                	li	a2,0
ffffffffc0201c50:	4581                	li	a1,0
ffffffffc0201c52:	a6bff0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc0201c56:	60050563          	beqz	a0,ffffffffc0202260 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c5a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c5c:	0017f713          	andi	a4,a5,1
ffffffffc0201c60:	5e070e63          	beqz	a4,ffffffffc020225c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201c64:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c66:	078a                	slli	a5,a5,0x2
ffffffffc0201c68:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c6a:	56c7ff63          	bgeu	a5,a2,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c6e:	fff80737          	lui	a4,0xfff80
ffffffffc0201c72:	97ba                	add	a5,a5,a4
ffffffffc0201c74:	000b3683          	ld	a3,0(s6)
ffffffffc0201c78:	00379713          	slli	a4,a5,0x3
ffffffffc0201c7c:	97ba                	add	a5,a5,a4
ffffffffc0201c7e:	078e                	slli	a5,a5,0x3
ffffffffc0201c80:	97b6                	add	a5,a5,a3
ffffffffc0201c82:	14fa18e3          	bne	s4,a5,ffffffffc02025d2 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201c86:	000a2703          	lw	a4,0(s4)
ffffffffc0201c8a:	4785                	li	a5,1
ffffffffc0201c8c:	16f71fe3          	bne	a4,a5,ffffffffc020260a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201c90:	00093503          	ld	a0,0(s2)
ffffffffc0201c94:	77fd                	lui	a5,0xfffff
ffffffffc0201c96:	6114                	ld	a3,0(a0)
ffffffffc0201c98:	068a                	slli	a3,a3,0x2
ffffffffc0201c9a:	8efd                	and	a3,a3,a5
ffffffffc0201c9c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201ca0:	14c779e3          	bgeu	a4,a2,ffffffffc02025f2 <pmm_init+0xb4c>
ffffffffc0201ca4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ca8:	96e2                	add	a3,a3,s8
ffffffffc0201caa:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cae:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cb0:	00fafab3          	and	s5,s5,a5
ffffffffc0201cb4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cb8:	66c7f463          	bgeu	a5,a2,ffffffffc0202320 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cbc:	4601                	li	a2,0
ffffffffc0201cbe:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cc0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cc2:	9fbff0ef          	jal	ra,ffffffffc02016bc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cc6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cc8:	63551c63          	bne	a0,s5,ffffffffc0202300 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201ccc:	4505                	li	a0,1
ffffffffc0201cce:	8e3ff0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201cd2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201cd4:	00093503          	ld	a0,0(s2)
ffffffffc0201cd8:	46d1                	li	a3,20
ffffffffc0201cda:	6605                	lui	a2,0x1
ffffffffc0201cdc:	85d6                	mv	a1,s5
ffffffffc0201cde:	cc9ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc0201ce2:	5c051f63          	bnez	a0,ffffffffc02022c0 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201ce6:	00093503          	ld	a0,0(s2)
ffffffffc0201cea:	4601                	li	a2,0
ffffffffc0201cec:	6585                	lui	a1,0x1
ffffffffc0201cee:	9cfff0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc0201cf2:	12050ce3          	beqz	a0,ffffffffc020262a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201cf6:	611c                	ld	a5,0(a0)
ffffffffc0201cf8:	0107f713          	andi	a4,a5,16
ffffffffc0201cfc:	72070f63          	beqz	a4,ffffffffc020243a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d00:	8b91                	andi	a5,a5,4
ffffffffc0201d02:	6e078c63          	beqz	a5,ffffffffc02023fa <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d06:	00093503          	ld	a0,0(s2)
ffffffffc0201d0a:	611c                	ld	a5,0(a0)
ffffffffc0201d0c:	8bc1                	andi	a5,a5,16
ffffffffc0201d0e:	6c078663          	beqz	a5,ffffffffc02023da <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d12:	000aa703          	lw	a4,0(s5)
ffffffffc0201d16:	4785                	li	a5,1
ffffffffc0201d18:	5cf71463          	bne	a4,a5,ffffffffc02022e0 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d1c:	4681                	li	a3,0
ffffffffc0201d1e:	6605                	lui	a2,0x1
ffffffffc0201d20:	85d2                	mv	a1,s4
ffffffffc0201d22:	c85ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc0201d26:	66051a63          	bnez	a0,ffffffffc020239a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d2a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d2e:	4789                	li	a5,2
ffffffffc0201d30:	64f71563          	bne	a4,a5,ffffffffc020237a <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d34:	000aa783          	lw	a5,0(s5)
ffffffffc0201d38:	62079163          	bnez	a5,ffffffffc020235a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d3c:	00093503          	ld	a0,0(s2)
ffffffffc0201d40:	4601                	li	a2,0
ffffffffc0201d42:	6585                	lui	a1,0x1
ffffffffc0201d44:	979ff0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc0201d48:	5e050963          	beqz	a0,ffffffffc020233a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d4c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d4e:	00177793          	andi	a5,a4,1
ffffffffc0201d52:	50078563          	beqz	a5,ffffffffc020225c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d56:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d58:	00271793          	slli	a5,a4,0x2
ffffffffc0201d5c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d5e:	48d7f563          	bgeu	a5,a3,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d62:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d66:	97b6                	add	a5,a5,a3
ffffffffc0201d68:	000b3603          	ld	a2,0(s6)
ffffffffc0201d6c:	00379693          	slli	a3,a5,0x3
ffffffffc0201d70:	97b6                	add	a5,a5,a3
ffffffffc0201d72:	078e                	slli	a5,a5,0x3
ffffffffc0201d74:	97b2                	add	a5,a5,a2
ffffffffc0201d76:	72fa1263          	bne	s4,a5,ffffffffc020249a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d7a:	8b41                	andi	a4,a4,16
ffffffffc0201d7c:	6e071f63          	bnez	a4,ffffffffc020247a <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201d80:	00093503          	ld	a0,0(s2)
ffffffffc0201d84:	4581                	li	a1,0
ffffffffc0201d86:	b87ff0ef          	jal	ra,ffffffffc020190c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201d8a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d8e:	4785                	li	a5,1
ffffffffc0201d90:	6cf71563          	bne	a4,a5,ffffffffc020245a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201d94:	000aa783          	lw	a5,0(s5)
ffffffffc0201d98:	78079d63          	bnez	a5,ffffffffc0202532 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201d9c:	00093503          	ld	a0,0(s2)
ffffffffc0201da0:	6585                	lui	a1,0x1
ffffffffc0201da2:	b6bff0ef          	jal	ra,ffffffffc020190c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201da6:	000a2783          	lw	a5,0(s4)
ffffffffc0201daa:	76079463          	bnez	a5,ffffffffc0202512 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201dae:	000aa783          	lw	a5,0(s5)
ffffffffc0201db2:	74079063          	bnez	a5,ffffffffc02024f2 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201db6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dba:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dbc:	000a3783          	ld	a5,0(s4)
ffffffffc0201dc0:	078a                	slli	a5,a5,0x2
ffffffffc0201dc2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dc4:	42c7f263          	bgeu	a5,a2,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dc8:	fff80737          	lui	a4,0xfff80
ffffffffc0201dcc:	973e                	add	a4,a4,a5
ffffffffc0201dce:	00371793          	slli	a5,a4,0x3
ffffffffc0201dd2:	000b3503          	ld	a0,0(s6)
ffffffffc0201dd6:	97ba                	add	a5,a5,a4
ffffffffc0201dd8:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201dda:	00f50733          	add	a4,a0,a5
ffffffffc0201dde:	4314                	lw	a3,0(a4)
ffffffffc0201de0:	4705                	li	a4,1
ffffffffc0201de2:	6ee69863          	bne	a3,a4,ffffffffc02024d2 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201de6:	4037d693          	srai	a3,a5,0x3
ffffffffc0201dea:	00004c97          	auipc	s9,0x4
ffffffffc0201dee:	3c6cbc83          	ld	s9,966(s9) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0201df2:	039686b3          	mul	a3,a3,s9
ffffffffc0201df6:	000805b7          	lui	a1,0x80
ffffffffc0201dfa:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201dfc:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e00:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e02:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e04:	6ac77b63          	bgeu	a4,a2,ffffffffc02024ba <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e08:	0009b703          	ld	a4,0(s3)
ffffffffc0201e0c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e0e:	629c                	ld	a5,0(a3)
ffffffffc0201e10:	078a                	slli	a5,a5,0x2
ffffffffc0201e12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e14:	3cc7fa63          	bgeu	a5,a2,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e18:	8f8d                	sub	a5,a5,a1
ffffffffc0201e1a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e1e:	97ba                	add	a5,a5,a4
ffffffffc0201e20:	078e                	slli	a5,a5,0x3
ffffffffc0201e22:	953e                	add	a0,a0,a5
ffffffffc0201e24:	100027f3          	csrr	a5,sstatus
ffffffffc0201e28:	8b89                	andi	a5,a5,2
ffffffffc0201e2a:	2e079963          	bnez	a5,ffffffffc020211c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e2e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e32:	4585                	li	a1,1
ffffffffc0201e34:	739c                	ld	a5,32(a5)
ffffffffc0201e36:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e38:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e3c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e3e:	078a                	slli	a5,a5,0x2
ffffffffc0201e40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e42:	3ae7f363          	bgeu	a5,a4,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e46:	fff80737          	lui	a4,0xfff80
ffffffffc0201e4a:	97ba                	add	a5,a5,a4
ffffffffc0201e4c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e50:	00379713          	slli	a4,a5,0x3
ffffffffc0201e54:	97ba                	add	a5,a5,a4
ffffffffc0201e56:	078e                	slli	a5,a5,0x3
ffffffffc0201e58:	953e                	add	a0,a0,a5
ffffffffc0201e5a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e5e:	8b89                	andi	a5,a5,2
ffffffffc0201e60:	2a079263          	bnez	a5,ffffffffc0202104 <pmm_init+0x65e>
ffffffffc0201e64:	000bb783          	ld	a5,0(s7)
ffffffffc0201e68:	4585                	li	a1,1
ffffffffc0201e6a:	739c                	ld	a5,32(a5)
ffffffffc0201e6c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201e6e:	00093783          	ld	a5,0(s2)
ffffffffc0201e72:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201e76:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7a:	8b89                	andi	a5,a5,2
ffffffffc0201e7c:	26079a63          	bnez	a5,ffffffffc02020f0 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201e80:	000bb783          	ld	a5,0(s7)
ffffffffc0201e84:	779c                	ld	a5,40(a5)
ffffffffc0201e86:	9782                	jalr	a5
ffffffffc0201e88:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e8a:	73441463          	bne	s0,s4,ffffffffc02025b2 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e8e:	00003517          	auipc	a0,0x3
ffffffffc0201e92:	6da50513          	addi	a0,a0,1754 # ffffffffc0205568 <default_pmm_manager+0x460>
ffffffffc0201e96:	cf2fe0ef          	jal	ra,ffffffffc0200388 <cprintf>
ffffffffc0201e9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9e:	8b89                	andi	a5,a5,2
ffffffffc0201ea0:	22079e63          	bnez	a5,ffffffffc02020dc <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ea4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea8:	779c                	ld	a5,40(a5)
ffffffffc0201eaa:	9782                	jalr	a5
ffffffffc0201eac:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eae:	6098                	ld	a4,0(s1)
ffffffffc0201eb0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201eb4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eb6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201eba:	6a05                	lui	s4,0x1
ffffffffc0201ebc:	02f47c63          	bgeu	s0,a5,ffffffffc0201ef4 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ec0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ec4:	00093503          	ld	a0,0(s2)
ffffffffc0201ec8:	30e7f363          	bgeu	a5,a4,ffffffffc02021ce <pmm_init+0x728>
ffffffffc0201ecc:	0009b583          	ld	a1,0(s3)
ffffffffc0201ed0:	4601                	li	a2,0
ffffffffc0201ed2:	95a2                	add	a1,a1,s0
ffffffffc0201ed4:	fe8ff0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc0201ed8:	2c050b63          	beqz	a0,ffffffffc02021ae <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201edc:	611c                	ld	a5,0(a0)
ffffffffc0201ede:	078a                	slli	a5,a5,0x2
ffffffffc0201ee0:	0157f7b3          	and	a5,a5,s5
ffffffffc0201ee4:	2a879563          	bne	a5,s0,ffffffffc020218e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ee8:	6098                	ld	a4,0(s1)
ffffffffc0201eea:	9452                	add	s0,s0,s4
ffffffffc0201eec:	00c71793          	slli	a5,a4,0xc
ffffffffc0201ef0:	fcf468e3          	bltu	s0,a5,ffffffffc0201ec0 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201ef4:	00093783          	ld	a5,0(s2)
ffffffffc0201ef8:	639c                	ld	a5,0(a5)
ffffffffc0201efa:	68079c63          	bnez	a5,ffffffffc0202592 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201efe:	4505                	li	a0,1
ffffffffc0201f00:	eb0ff0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0201f04:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f06:	00093503          	ld	a0,0(s2)
ffffffffc0201f0a:	4699                	li	a3,6
ffffffffc0201f0c:	10000613          	li	a2,256
ffffffffc0201f10:	85d6                	mv	a1,s5
ffffffffc0201f12:	a95ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc0201f16:	64051e63          	bnez	a0,ffffffffc0202572 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f1a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201f1e:	4785                	li	a5,1
ffffffffc0201f20:	62f71963          	bne	a4,a5,ffffffffc0202552 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f24:	00093503          	ld	a0,0(s2)
ffffffffc0201f28:	6405                	lui	s0,0x1
ffffffffc0201f2a:	4699                	li	a3,6
ffffffffc0201f2c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f30:	85d6                	mv	a1,s5
ffffffffc0201f32:	a75ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc0201f36:	48051263          	bnez	a0,ffffffffc02023ba <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f3a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f3e:	4789                	li	a5,2
ffffffffc0201f40:	74f71563          	bne	a4,a5,ffffffffc020268a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f44:	00003597          	auipc	a1,0x3
ffffffffc0201f48:	75c58593          	addi	a1,a1,1884 # ffffffffc02056a0 <default_pmm_manager+0x598>
ffffffffc0201f4c:	10000513          	li	a0,256
ffffffffc0201f50:	408020ef          	jal	ra,ffffffffc0204358 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f54:	10040593          	addi	a1,s0,256
ffffffffc0201f58:	10000513          	li	a0,256
ffffffffc0201f5c:	40e020ef          	jal	ra,ffffffffc020436a <strcmp>
ffffffffc0201f60:	70051563          	bnez	a0,ffffffffc020266a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f64:	000b3683          	ld	a3,0(s6)
ffffffffc0201f68:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f6c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f6e:	40da86b3          	sub	a3,s5,a3
ffffffffc0201f72:	868d                	srai	a3,a3,0x3
ffffffffc0201f74:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f78:	609c                	ld	a5,0(s1)
ffffffffc0201f7a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f7c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f7e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f82:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f84:	52f77b63          	bgeu	a4,a5,ffffffffc02024ba <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f88:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f8c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f90:	96be                	add	a3,a3,a5
ffffffffc0201f92:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb94>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f96:	38c020ef          	jal	ra,ffffffffc0204322 <strlen>
ffffffffc0201f9a:	6a051863          	bnez	a0,ffffffffc020264a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f9e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fa2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fa4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fa8:	078a                	slli	a5,a5,0x2
ffffffffc0201faa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fac:	22e7fe63          	bgeu	a5,a4,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fb0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201fb4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fb8:	96be                	add	a3,a3,a5
ffffffffc0201fba:	03968cb3          	mul	s9,a3,s9
ffffffffc0201fbe:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc6:	4ee47a63          	bgeu	s0,a4,ffffffffc02024ba <pmm_init+0xa14>
ffffffffc0201fca:	0009b403          	ld	s0,0(s3)
ffffffffc0201fce:	9436                	add	s0,s0,a3
ffffffffc0201fd0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fd4:	8b89                	andi	a5,a5,2
ffffffffc0201fd6:	1a079163          	bnez	a5,ffffffffc0202178 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201fda:	000bb783          	ld	a5,0(s7)
ffffffffc0201fde:	4585                	li	a1,1
ffffffffc0201fe0:	8556                	mv	a0,s5
ffffffffc0201fe2:	739c                	ld	a5,32(a5)
ffffffffc0201fe4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fe8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fea:	078a                	slli	a5,a5,0x2
ffffffffc0201fec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fee:	1ee7fd63          	bgeu	a5,a4,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff2:	fff80737          	lui	a4,0xfff80
ffffffffc0201ff6:	97ba                	add	a5,a5,a4
ffffffffc0201ff8:	000b3503          	ld	a0,0(s6)
ffffffffc0201ffc:	00379713          	slli	a4,a5,0x3
ffffffffc0202000:	97ba                	add	a5,a5,a4
ffffffffc0202002:	078e                	slli	a5,a5,0x3
ffffffffc0202004:	953e                	add	a0,a0,a5
ffffffffc0202006:	100027f3          	csrr	a5,sstatus
ffffffffc020200a:	8b89                	andi	a5,a5,2
ffffffffc020200c:	14079a63          	bnez	a5,ffffffffc0202160 <pmm_init+0x6ba>
ffffffffc0202010:	000bb783          	ld	a5,0(s7)
ffffffffc0202014:	4585                	li	a1,1
ffffffffc0202016:	739c                	ld	a5,32(a5)
ffffffffc0202018:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020201a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020201e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202020:	078a                	slli	a5,a5,0x2
ffffffffc0202022:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202024:	1ce7f263          	bgeu	a5,a4,ffffffffc02021e8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202028:	fff80737          	lui	a4,0xfff80
ffffffffc020202c:	97ba                	add	a5,a5,a4
ffffffffc020202e:	000b3503          	ld	a0,0(s6)
ffffffffc0202032:	00379713          	slli	a4,a5,0x3
ffffffffc0202036:	97ba                	add	a5,a5,a4
ffffffffc0202038:	078e                	slli	a5,a5,0x3
ffffffffc020203a:	953e                	add	a0,a0,a5
ffffffffc020203c:	100027f3          	csrr	a5,sstatus
ffffffffc0202040:	8b89                	andi	a5,a5,2
ffffffffc0202042:	10079363          	bnez	a5,ffffffffc0202148 <pmm_init+0x6a2>
ffffffffc0202046:	000bb783          	ld	a5,0(s7)
ffffffffc020204a:	4585                	li	a1,1
ffffffffc020204c:	739c                	ld	a5,32(a5)
ffffffffc020204e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202050:	00093783          	ld	a5,0(s2)
ffffffffc0202054:	0007b023          	sd	zero,0(a5)
ffffffffc0202058:	100027f3          	csrr	a5,sstatus
ffffffffc020205c:	8b89                	andi	a5,a5,2
ffffffffc020205e:	0c079b63          	bnez	a5,ffffffffc0202134 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202062:	000bb783          	ld	a5,0(s7)
ffffffffc0202066:	779c                	ld	a5,40(a5)
ffffffffc0202068:	9782                	jalr	a5
ffffffffc020206a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020206c:	3a8c1763          	bne	s8,s0,ffffffffc020241a <pmm_init+0x974>
}
ffffffffc0202070:	7406                	ld	s0,96(sp)
ffffffffc0202072:	70a6                	ld	ra,104(sp)
ffffffffc0202074:	64e6                	ld	s1,88(sp)
ffffffffc0202076:	6946                	ld	s2,80(sp)
ffffffffc0202078:	69a6                	ld	s3,72(sp)
ffffffffc020207a:	6a06                	ld	s4,64(sp)
ffffffffc020207c:	7ae2                	ld	s5,56(sp)
ffffffffc020207e:	7b42                	ld	s6,48(sp)
ffffffffc0202080:	7ba2                	ld	s7,40(sp)
ffffffffc0202082:	7c02                	ld	s8,32(sp)
ffffffffc0202084:	6ce2                	ld	s9,24(sp)
ffffffffc0202086:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202088:	00003517          	auipc	a0,0x3
ffffffffc020208c:	69050513          	addi	a0,a0,1680 # ffffffffc0205718 <default_pmm_manager+0x610>
}
ffffffffc0202090:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202092:	af6fe06f          	j	ffffffffc0200388 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202096:	6705                	lui	a4,0x1
ffffffffc0202098:	177d                	addi	a4,a4,-1
ffffffffc020209a:	96ba                	add	a3,a3,a4
ffffffffc020209c:	777d                	lui	a4,0xfffff
ffffffffc020209e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020a0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020a4:	14f6f263          	bgeu	a3,a5,ffffffffc02021e8 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020a8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020ac:	95b6                	add	a1,a1,a3
ffffffffc02020ae:	00359793          	slli	a5,a1,0x3
ffffffffc02020b2:	97ae                	add	a5,a5,a1
ffffffffc02020b4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020b8:	40e60733          	sub	a4,a2,a4
ffffffffc02020bc:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020be:	00c75593          	srli	a1,a4,0xc
ffffffffc02020c2:	953e                	add	a0,a0,a5
ffffffffc02020c4:	9682                	jalr	a3
}
ffffffffc02020c6:	bcc5                	j	ffffffffc0201bb6 <pmm_init+0x110>
        intr_disable();
ffffffffc02020c8:	c26fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020cc:	000bb783          	ld	a5,0(s7)
ffffffffc02020d0:	779c                	ld	a5,40(a5)
ffffffffc02020d2:	9782                	jalr	a5
ffffffffc02020d4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02020d6:	c12fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020da:	b63d                	j	ffffffffc0201c08 <pmm_init+0x162>
        intr_disable();
ffffffffc02020dc:	c12fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02020e0:	000bb783          	ld	a5,0(s7)
ffffffffc02020e4:	779c                	ld	a5,40(a5)
ffffffffc02020e6:	9782                	jalr	a5
ffffffffc02020e8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02020ea:	bfefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020ee:	b3c1                	j	ffffffffc0201eae <pmm_init+0x408>
        intr_disable();
ffffffffc02020f0:	bfefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02020f4:	000bb783          	ld	a5,0(s7)
ffffffffc02020f8:	779c                	ld	a5,40(a5)
ffffffffc02020fa:	9782                	jalr	a5
ffffffffc02020fc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02020fe:	beafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202102:	b361                	j	ffffffffc0201e8a <pmm_init+0x3e4>
ffffffffc0202104:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202106:	be8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020210a:	000bb783          	ld	a5,0(s7)
ffffffffc020210e:	6522                	ld	a0,8(sp)
ffffffffc0202110:	4585                	li	a1,1
ffffffffc0202112:	739c                	ld	a5,32(a5)
ffffffffc0202114:	9782                	jalr	a5
        intr_enable();
ffffffffc0202116:	bd2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020211a:	bb91                	j	ffffffffc0201e6e <pmm_init+0x3c8>
ffffffffc020211c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020211e:	bd0fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202122:	000bb783          	ld	a5,0(s7)
ffffffffc0202126:	6522                	ld	a0,8(sp)
ffffffffc0202128:	4585                	li	a1,1
ffffffffc020212a:	739c                	ld	a5,32(a5)
ffffffffc020212c:	9782                	jalr	a5
        intr_enable();
ffffffffc020212e:	bbafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202132:	b319                	j	ffffffffc0201e38 <pmm_init+0x392>
        intr_disable();
ffffffffc0202134:	bbafe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202138:	000bb783          	ld	a5,0(s7)
ffffffffc020213c:	779c                	ld	a5,40(a5)
ffffffffc020213e:	9782                	jalr	a5
ffffffffc0202140:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202142:	ba6fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202146:	b71d                	j	ffffffffc020206c <pmm_init+0x5c6>
ffffffffc0202148:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020214a:	ba4fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020214e:	000bb783          	ld	a5,0(s7)
ffffffffc0202152:	6522                	ld	a0,8(sp)
ffffffffc0202154:	4585                	li	a1,1
ffffffffc0202156:	739c                	ld	a5,32(a5)
ffffffffc0202158:	9782                	jalr	a5
        intr_enable();
ffffffffc020215a:	b8efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020215e:	bdcd                	j	ffffffffc0202050 <pmm_init+0x5aa>
ffffffffc0202160:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202162:	b8cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202166:	000bb783          	ld	a5,0(s7)
ffffffffc020216a:	6522                	ld	a0,8(sp)
ffffffffc020216c:	4585                	li	a1,1
ffffffffc020216e:	739c                	ld	a5,32(a5)
ffffffffc0202170:	9782                	jalr	a5
        intr_enable();
ffffffffc0202172:	b76fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202176:	b555                	j	ffffffffc020201a <pmm_init+0x574>
        intr_disable();
ffffffffc0202178:	b76fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020217c:	000bb783          	ld	a5,0(s7)
ffffffffc0202180:	4585                	li	a1,1
ffffffffc0202182:	8556                	mv	a0,s5
ffffffffc0202184:	739c                	ld	a5,32(a5)
ffffffffc0202186:	9782                	jalr	a5
        intr_enable();
ffffffffc0202188:	b60fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020218c:	bda9                	j	ffffffffc0201fe6 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020218e:	00003697          	auipc	a3,0x3
ffffffffc0202192:	43a68693          	addi	a3,a3,1082 # ffffffffc02055c8 <default_pmm_manager+0x4c0>
ffffffffc0202196:	00003617          	auipc	a2,0x3
ffffffffc020219a:	bc260613          	addi	a2,a2,-1086 # ffffffffc0204d58 <commands+0x738>
ffffffffc020219e:	1ce00593          	li	a1,462
ffffffffc02021a2:	00003517          	auipc	a0,0x3
ffffffffc02021a6:	01e50513          	addi	a0,a0,30 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02021aa:	948fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021ae:	00003697          	auipc	a3,0x3
ffffffffc02021b2:	3da68693          	addi	a3,a3,986 # ffffffffc0205588 <default_pmm_manager+0x480>
ffffffffc02021b6:	00003617          	auipc	a2,0x3
ffffffffc02021ba:	ba260613          	addi	a2,a2,-1118 # ffffffffc0204d58 <commands+0x738>
ffffffffc02021be:	1cd00593          	li	a1,461
ffffffffc02021c2:	00003517          	auipc	a0,0x3
ffffffffc02021c6:	ffe50513          	addi	a0,a0,-2 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02021ca:	928fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc02021ce:	86a2                	mv	a3,s0
ffffffffc02021d0:	00003617          	auipc	a2,0x3
ffffffffc02021d4:	fc860613          	addi	a2,a2,-56 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc02021d8:	1cd00593          	li	a1,461
ffffffffc02021dc:	00003517          	auipc	a0,0x3
ffffffffc02021e0:	fe450513          	addi	a0,a0,-28 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02021e4:	90efe0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc02021e8:	b90ff0ef          	jal	ra,ffffffffc0201578 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021ec:	00003617          	auipc	a2,0x3
ffffffffc02021f0:	06c60613          	addi	a2,a2,108 # ffffffffc0205258 <default_pmm_manager+0x150>
ffffffffc02021f4:	07700593          	li	a1,119
ffffffffc02021f8:	00003517          	auipc	a0,0x3
ffffffffc02021fc:	fc850513          	addi	a0,a0,-56 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202200:	8f2fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202204:	00003617          	auipc	a2,0x3
ffffffffc0202208:	05460613          	addi	a2,a2,84 # ffffffffc0205258 <default_pmm_manager+0x150>
ffffffffc020220c:	0bd00593          	li	a1,189
ffffffffc0202210:	00003517          	auipc	a0,0x3
ffffffffc0202214:	fb050513          	addi	a0,a0,-80 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202218:	8dafe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020221c:	00003697          	auipc	a3,0x3
ffffffffc0202220:	0a468693          	addi	a3,a3,164 # ffffffffc02052c0 <default_pmm_manager+0x1b8>
ffffffffc0202224:	00003617          	auipc	a2,0x3
ffffffffc0202228:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d58 <commands+0x738>
ffffffffc020222c:	19300593          	li	a1,403
ffffffffc0202230:	00003517          	auipc	a0,0x3
ffffffffc0202234:	f9050513          	addi	a0,a0,-112 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202238:	8bafe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020223c:	00003697          	auipc	a3,0x3
ffffffffc0202240:	06468693          	addi	a3,a3,100 # ffffffffc02052a0 <default_pmm_manager+0x198>
ffffffffc0202244:	00003617          	auipc	a2,0x3
ffffffffc0202248:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d58 <commands+0x738>
ffffffffc020224c:	19200593          	li	a1,402
ffffffffc0202250:	00003517          	auipc	a0,0x3
ffffffffc0202254:	f7050513          	addi	a0,a0,-144 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202258:	89afe0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc020225c:	b38ff0ef          	jal	ra,ffffffffc0201594 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	0f068693          	addi	a3,a3,240 # ffffffffc0205350 <default_pmm_manager+0x248>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	af060613          	addi	a2,a2,-1296 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202270:	19a00593          	li	a1,410
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	f4c50513          	addi	a0,a0,-180 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020227c:	876fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	0a068693          	addi	a3,a3,160 # ffffffffc0205320 <default_pmm_manager+0x218>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202290:	19800593          	li	a1,408
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	f2c50513          	addi	a0,a0,-212 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020229c:	856fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	05868693          	addi	a3,a3,88 # ffffffffc02052f8 <default_pmm_manager+0x1f0>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204d58 <commands+0x738>
ffffffffc02022b0:	19400593          	li	a1,404
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	f0c50513          	addi	a0,a0,-244 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02022bc:	836fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	11868693          	addi	a3,a3,280 # ffffffffc02053d8 <default_pmm_manager+0x2d0>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204d58 <commands+0x738>
ffffffffc02022d0:	1a300593          	li	a1,419
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	eec50513          	addi	a0,a0,-276 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02022dc:	816fe0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	19868693          	addi	a3,a3,408 # ffffffffc0205478 <default_pmm_manager+0x370>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204d58 <commands+0x738>
ffffffffc02022f0:	1a800593          	li	a1,424
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	ecc50513          	addi	a0,a0,-308 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02022fc:	ff7fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	0b068693          	addi	a3,a3,176 # ffffffffc02053b0 <default_pmm_manager+0x2a8>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202310:	1a000593          	li	a1,416
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	eac50513          	addi	a0,a0,-340 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020231c:	fd7fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202320:	86d6                	mv	a3,s5
ffffffffc0202322:	00003617          	auipc	a2,0x3
ffffffffc0202326:	e7660613          	addi	a2,a2,-394 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc020232a:	19f00593          	li	a1,415
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	e9250513          	addi	a0,a0,-366 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202336:	fbdfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	0d668693          	addi	a3,a3,214 # ffffffffc0205410 <default_pmm_manager+0x308>
ffffffffc0202342:	00003617          	auipc	a2,0x3
ffffffffc0202346:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204d58 <commands+0x738>
ffffffffc020234a:	1ad00593          	li	a1,429
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	e7250513          	addi	a0,a0,-398 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202356:	f9dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	17e68693          	addi	a3,a3,382 # ffffffffc02054d8 <default_pmm_manager+0x3d0>
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	9f660613          	addi	a2,a2,-1546 # ffffffffc0204d58 <commands+0x738>
ffffffffc020236a:	1ac00593          	li	a1,428
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	e5250513          	addi	a0,a0,-430 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202376:	f7dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	14668693          	addi	a3,a3,326 # ffffffffc02054c0 <default_pmm_manager+0x3b8>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	9d660613          	addi	a2,a2,-1578 # ffffffffc0204d58 <commands+0x738>
ffffffffc020238a:	1ab00593          	li	a1,427
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	e3250513          	addi	a0,a0,-462 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202396:	f5dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	0f668693          	addi	a3,a3,246 # ffffffffc0205490 <default_pmm_manager+0x388>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	9b660613          	addi	a2,a2,-1610 # ffffffffc0204d58 <commands+0x738>
ffffffffc02023aa:	1aa00593          	li	a1,426
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	e1250513          	addi	a0,a0,-494 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02023b6:	f3dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	28e68693          	addi	a3,a3,654 # ffffffffc0205648 <default_pmm_manager+0x540>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	99660613          	addi	a2,a2,-1642 # ffffffffc0204d58 <commands+0x738>
ffffffffc02023ca:	1d800593          	li	a1,472
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	df250513          	addi	a0,a0,-526 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02023d6:	f1dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	08668693          	addi	a3,a3,134 # ffffffffc0205460 <default_pmm_manager+0x358>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	97660613          	addi	a2,a2,-1674 # ffffffffc0204d58 <commands+0x738>
ffffffffc02023ea:	1a700593          	li	a1,423
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	dd250513          	addi	a0,a0,-558 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02023f6:	efdfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	05668693          	addi	a3,a3,86 # ffffffffc0205450 <default_pmm_manager+0x348>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	95660613          	addi	a2,a2,-1706 # ffffffffc0204d58 <commands+0x738>
ffffffffc020240a:	1a600593          	li	a1,422
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	db250513          	addi	a0,a0,-590 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202416:	eddfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	12e68693          	addi	a3,a3,302 # ffffffffc0205548 <default_pmm_manager+0x440>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	93660613          	addi	a2,a2,-1738 # ffffffffc0204d58 <commands+0x738>
ffffffffc020242a:	1e800593          	li	a1,488
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	d9250513          	addi	a0,a0,-622 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202436:	ebdfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	00668693          	addi	a3,a3,6 # ffffffffc0205440 <default_pmm_manager+0x338>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	91660613          	addi	a2,a2,-1770 # ffffffffc0204d58 <commands+0x738>
ffffffffc020244a:	1a500593          	li	a1,421
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	d7250513          	addi	a0,a0,-654 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202456:	e9dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	f3e68693          	addi	a3,a3,-194 # ffffffffc0205398 <default_pmm_manager+0x290>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204d58 <commands+0x738>
ffffffffc020246a:	1b200593          	li	a1,434
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	d5250513          	addi	a0,a0,-686 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202476:	e7dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	07668693          	addi	a3,a3,118 # ffffffffc02054f0 <default_pmm_manager+0x3e8>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204d58 <commands+0x738>
ffffffffc020248a:	1af00593          	li	a1,431
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	d3250513          	addi	a0,a0,-718 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202496:	e5dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	ee668693          	addi	a3,a3,-282 # ffffffffc0205380 <default_pmm_manager+0x278>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204d58 <commands+0x738>
ffffffffc02024aa:	1ae00593          	li	a1,430
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	d1250513          	addi	a0,a0,-750 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02024b6:	e3dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024ba:	00003617          	auipc	a2,0x3
ffffffffc02024be:	cde60613          	addi	a2,a2,-802 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc02024c2:	06a00593          	li	a1,106
ffffffffc02024c6:	00003517          	auipc	a0,0x3
ffffffffc02024ca:	c9a50513          	addi	a0,a0,-870 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc02024ce:	e25fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024d2:	00003697          	auipc	a3,0x3
ffffffffc02024d6:	04e68693          	addi	a3,a3,78 # ffffffffc0205520 <default_pmm_manager+0x418>
ffffffffc02024da:	00003617          	auipc	a2,0x3
ffffffffc02024de:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204d58 <commands+0x738>
ffffffffc02024e2:	1b900593          	li	a1,441
ffffffffc02024e6:	00003517          	auipc	a0,0x3
ffffffffc02024ea:	cda50513          	addi	a0,a0,-806 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02024ee:	e05fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024f2:	00003697          	auipc	a3,0x3
ffffffffc02024f6:	fe668693          	addi	a3,a3,-26 # ffffffffc02054d8 <default_pmm_manager+0x3d0>
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202502:	1b700593          	li	a1,439
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	cba50513          	addi	a0,a0,-838 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020250e:	de5fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202512:	00003697          	auipc	a3,0x3
ffffffffc0202516:	ff668693          	addi	a3,a3,-10 # ffffffffc0205508 <default_pmm_manager+0x400>
ffffffffc020251a:	00003617          	auipc	a2,0x3
ffffffffc020251e:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202522:	1b600593          	li	a1,438
ffffffffc0202526:	00003517          	auipc	a0,0x3
ffffffffc020252a:	c9a50513          	addi	a0,a0,-870 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020252e:	dc5fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202532:	00003697          	auipc	a3,0x3
ffffffffc0202536:	fa668693          	addi	a3,a3,-90 # ffffffffc02054d8 <default_pmm_manager+0x3d0>
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202542:	1b300593          	li	a1,435
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020254e:	da5fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	0de68693          	addi	a3,a3,222 # ffffffffc0205630 <default_pmm_manager+0x528>
ffffffffc020255a:	00002617          	auipc	a2,0x2
ffffffffc020255e:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202562:	1d700593          	li	a1,471
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020256e:	d85fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	08668693          	addi	a3,a3,134 # ffffffffc02055f8 <default_pmm_manager+0x4f0>
ffffffffc020257a:	00002617          	auipc	a2,0x2
ffffffffc020257e:	7de60613          	addi	a2,a2,2014 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202582:	1d600593          	li	a1,470
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020258e:	d65fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	04e68693          	addi	a3,a3,78 # ffffffffc02055e0 <default_pmm_manager+0x4d8>
ffffffffc020259a:	00002617          	auipc	a2,0x2
ffffffffc020259e:	7be60613          	addi	a2,a2,1982 # ffffffffc0204d58 <commands+0x738>
ffffffffc02025a2:	1d200593          	li	a1,466
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	c1a50513          	addi	a0,a0,-998 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02025ae:	d45fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	f9668693          	addi	a3,a3,-106 # ffffffffc0205548 <default_pmm_manager+0x440>
ffffffffc02025ba:	00002617          	auipc	a2,0x2
ffffffffc02025be:	79e60613          	addi	a2,a2,1950 # ffffffffc0204d58 <commands+0x738>
ffffffffc02025c2:	1c000593          	li	a1,448
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02025ce:	d25fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	dae68693          	addi	a3,a3,-594 # ffffffffc0205380 <default_pmm_manager+0x278>
ffffffffc02025da:	00002617          	auipc	a2,0x2
ffffffffc02025de:	77e60613          	addi	a2,a2,1918 # ffffffffc0204d58 <commands+0x738>
ffffffffc02025e2:	19b00593          	li	a1,411
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	bda50513          	addi	a0,a0,-1062 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02025ee:	d05fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02025f2:	00003617          	auipc	a2,0x3
ffffffffc02025f6:	ba660613          	addi	a2,a2,-1114 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc02025fa:	19e00593          	li	a1,414
ffffffffc02025fe:	00003517          	auipc	a0,0x3
ffffffffc0202602:	bc250513          	addi	a0,a0,-1086 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202606:	cedfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020260a:	00003697          	auipc	a3,0x3
ffffffffc020260e:	d8e68693          	addi	a3,a3,-626 # ffffffffc0205398 <default_pmm_manager+0x290>
ffffffffc0202612:	00002617          	auipc	a2,0x2
ffffffffc0202616:	74660613          	addi	a2,a2,1862 # ffffffffc0204d58 <commands+0x738>
ffffffffc020261a:	19c00593          	li	a1,412
ffffffffc020261e:	00003517          	auipc	a0,0x3
ffffffffc0202622:	ba250513          	addi	a0,a0,-1118 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202626:	ccdfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020262a:	00003697          	auipc	a3,0x3
ffffffffc020262e:	de668693          	addi	a3,a3,-538 # ffffffffc0205410 <default_pmm_manager+0x308>
ffffffffc0202632:	00002617          	auipc	a2,0x2
ffffffffc0202636:	72660613          	addi	a2,a2,1830 # ffffffffc0204d58 <commands+0x738>
ffffffffc020263a:	1a400593          	li	a1,420
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	b8250513          	addi	a0,a0,-1150 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202646:	cadfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	0a668693          	addi	a3,a3,166 # ffffffffc02056f0 <default_pmm_manager+0x5e8>
ffffffffc0202652:	00002617          	auipc	a2,0x2
ffffffffc0202656:	70660613          	addi	a2,a2,1798 # ffffffffc0204d58 <commands+0x738>
ffffffffc020265a:	1e000593          	li	a1,480
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	b6250513          	addi	a0,a0,-1182 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202666:	c8dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020266a:	00003697          	auipc	a3,0x3
ffffffffc020266e:	04e68693          	addi	a3,a3,78 # ffffffffc02056b8 <default_pmm_manager+0x5b0>
ffffffffc0202672:	00002617          	auipc	a2,0x2
ffffffffc0202676:	6e660613          	addi	a2,a2,1766 # ffffffffc0204d58 <commands+0x738>
ffffffffc020267a:	1dd00593          	li	a1,477
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	b4250513          	addi	a0,a0,-1214 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202686:	c6dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020268a:	00003697          	auipc	a3,0x3
ffffffffc020268e:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205688 <default_pmm_manager+0x580>
ffffffffc0202692:	00002617          	auipc	a2,0x2
ffffffffc0202696:	6c660613          	addi	a2,a2,1734 # ffffffffc0204d58 <commands+0x738>
ffffffffc020269a:	1d900593          	li	a1,473
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	b2250513          	addi	a0,a0,-1246 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02026a6:	c4dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02026aa <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026aa:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026ae:	8082                	ret

ffffffffc02026b0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026b0:	7179                	addi	sp,sp,-48
ffffffffc02026b2:	e84a                	sd	s2,16(sp)
ffffffffc02026b4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026b6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026b8:	f022                	sd	s0,32(sp)
ffffffffc02026ba:	ec26                	sd	s1,24(sp)
ffffffffc02026bc:	e44e                	sd	s3,8(sp)
ffffffffc02026be:	f406                	sd	ra,40(sp)
ffffffffc02026c0:	84ae                	mv	s1,a1
ffffffffc02026c2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02026c4:	eedfe0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc02026c8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02026ca:	cd09                	beqz	a0,ffffffffc02026e4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02026cc:	85aa                	mv	a1,a0
ffffffffc02026ce:	86ce                	mv	a3,s3
ffffffffc02026d0:	8626                	mv	a2,s1
ffffffffc02026d2:	854a                	mv	a0,s2
ffffffffc02026d4:	ad2ff0ef          	jal	ra,ffffffffc02019a6 <page_insert>
ffffffffc02026d8:	ed21                	bnez	a0,ffffffffc0202730 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc02026da:	0000f797          	auipc	a5,0xf
ffffffffc02026de:	e767a783          	lw	a5,-394(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02026e2:	eb89                	bnez	a5,ffffffffc02026f4 <pgdir_alloc_page+0x44>
}
ffffffffc02026e4:	70a2                	ld	ra,40(sp)
ffffffffc02026e6:	8522                	mv	a0,s0
ffffffffc02026e8:	7402                	ld	s0,32(sp)
ffffffffc02026ea:	64e2                	ld	s1,24(sp)
ffffffffc02026ec:	6942                	ld	s2,16(sp)
ffffffffc02026ee:	69a2                	ld	s3,8(sp)
ffffffffc02026f0:	6145                	addi	sp,sp,48
ffffffffc02026f2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02026f4:	4681                	li	a3,0
ffffffffc02026f6:	8622                	mv	a2,s0
ffffffffc02026f8:	85a6                	mv	a1,s1
ffffffffc02026fa:	0000f517          	auipc	a0,0xf
ffffffffc02026fe:	e6653503          	ld	a0,-410(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0202702:	07f000ef          	jal	ra,ffffffffc0202f80 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202706:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202708:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020270a:	4785                	li	a5,1
ffffffffc020270c:	fcf70ce3          	beq	a4,a5,ffffffffc02026e4 <pgdir_alloc_page+0x34>
ffffffffc0202710:	00003697          	auipc	a3,0x3
ffffffffc0202714:	02868693          	addi	a3,a3,40 # ffffffffc0205738 <default_pmm_manager+0x630>
ffffffffc0202718:	00002617          	auipc	a2,0x2
ffffffffc020271c:	64060613          	addi	a2,a2,1600 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202720:	17a00593          	li	a1,378
ffffffffc0202724:	00003517          	auipc	a0,0x3
ffffffffc0202728:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020272c:	bc7fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202730:	100027f3          	csrr	a5,sstatus
ffffffffc0202734:	8b89                	andi	a5,a5,2
ffffffffc0202736:	eb99                	bnez	a5,ffffffffc020274c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202738:	0000f797          	auipc	a5,0xf
ffffffffc020273c:	df87b783          	ld	a5,-520(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202740:	739c                	ld	a5,32(a5)
ffffffffc0202742:	8522                	mv	a0,s0
ffffffffc0202744:	4585                	li	a1,1
ffffffffc0202746:	9782                	jalr	a5
            return NULL;
ffffffffc0202748:	4401                	li	s0,0
ffffffffc020274a:	bf69                	j	ffffffffc02026e4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020274c:	da3fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202750:	0000f797          	auipc	a5,0xf
ffffffffc0202754:	de07b783          	ld	a5,-544(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202758:	739c                	ld	a5,32(a5)
ffffffffc020275a:	8522                	mv	a0,s0
ffffffffc020275c:	4585                	li	a1,1
ffffffffc020275e:	9782                	jalr	a5
            return NULL;
ffffffffc0202760:	4401                	li	s0,0
        intr_enable();
ffffffffc0202762:	d87fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202766:	bfbd                	j	ffffffffc02026e4 <pgdir_alloc_page+0x34>

ffffffffc0202768 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0202768:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020276a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020276c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020276e:	fff50713          	addi	a4,a0,-1
ffffffffc0202772:	17f9                	addi	a5,a5,-2
ffffffffc0202774:	04e7ea63          	bltu	a5,a4,ffffffffc02027c8 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202778:	6785                	lui	a5,0x1
ffffffffc020277a:	17fd                	addi	a5,a5,-1
ffffffffc020277c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc020277e:	8131                	srli	a0,a0,0xc
ffffffffc0202780:	e31fe0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
    assert(base != NULL);
ffffffffc0202784:	cd3d                	beqz	a0,ffffffffc0202802 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202786:	0000f797          	auipc	a5,0xf
ffffffffc020278a:	da27b783          	ld	a5,-606(a5) # ffffffffc0211528 <pages>
ffffffffc020278e:	8d1d                	sub	a0,a0,a5
ffffffffc0202790:	00004697          	auipc	a3,0x4
ffffffffc0202794:	a206b683          	ld	a3,-1504(a3) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0202798:	850d                	srai	a0,a0,0x3
ffffffffc020279a:	02d50533          	mul	a0,a0,a3
ffffffffc020279e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027a2:	0000f717          	auipc	a4,0xf
ffffffffc02027a6:	d7e73703          	ld	a4,-642(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027aa:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027ac:	00c51793          	slli	a5,a0,0xc
ffffffffc02027b0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027b2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027b4:	02e7fa63          	bgeu	a5,a4,ffffffffc02027e8 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027b8:	60a2                	ld	ra,8(sp)
ffffffffc02027ba:	0000f797          	auipc	a5,0xf
ffffffffc02027be:	d7e7b783          	ld	a5,-642(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc02027c2:	953e                	add	a0,a0,a5
ffffffffc02027c4:	0141                	addi	sp,sp,16
ffffffffc02027c6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027c8:	00003697          	auipc	a3,0x3
ffffffffc02027cc:	f8868693          	addi	a3,a3,-120 # ffffffffc0205750 <default_pmm_manager+0x648>
ffffffffc02027d0:	00002617          	auipc	a2,0x2
ffffffffc02027d4:	58860613          	addi	a2,a2,1416 # ffffffffc0204d58 <commands+0x738>
ffffffffc02027d8:	1f000593          	li	a1,496
ffffffffc02027dc:	00003517          	auipc	a0,0x3
ffffffffc02027e0:	9e450513          	addi	a0,a0,-1564 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02027e4:	b0ffd0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc02027e8:	86aa                	mv	a3,a0
ffffffffc02027ea:	00003617          	auipc	a2,0x3
ffffffffc02027ee:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc02027f2:	06a00593          	li	a1,106
ffffffffc02027f6:	00003517          	auipc	a0,0x3
ffffffffc02027fa:	96a50513          	addi	a0,a0,-1686 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc02027fe:	af5fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(base != NULL);
ffffffffc0202802:	00003697          	auipc	a3,0x3
ffffffffc0202806:	f6e68693          	addi	a3,a3,-146 # ffffffffc0205770 <default_pmm_manager+0x668>
ffffffffc020280a:	00002617          	auipc	a2,0x2
ffffffffc020280e:	54e60613          	addi	a2,a2,1358 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202812:	1f300593          	li	a1,499
ffffffffc0202816:	00003517          	auipc	a0,0x3
ffffffffc020281a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc020281e:	ad5fd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0202822 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202822:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202824:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202826:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202828:	fff58713          	addi	a4,a1,-1
ffffffffc020282c:	17f9                	addi	a5,a5,-2
ffffffffc020282e:	0ae7ee63          	bltu	a5,a4,ffffffffc02028ea <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202832:	cd41                	beqz	a0,ffffffffc02028ca <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202834:	6785                	lui	a5,0x1
ffffffffc0202836:	17fd                	addi	a5,a5,-1
ffffffffc0202838:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020283a:	c02007b7          	lui	a5,0xc0200
ffffffffc020283e:	81b1                	srli	a1,a1,0xc
ffffffffc0202840:	06f56863          	bltu	a0,a5,ffffffffc02028b0 <kfree+0x8e>
ffffffffc0202844:	0000f697          	auipc	a3,0xf
ffffffffc0202848:	cf46b683          	ld	a3,-780(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc020284c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020284e:	8131                	srli	a0,a0,0xc
ffffffffc0202850:	0000f797          	auipc	a5,0xf
ffffffffc0202854:	cd07b783          	ld	a5,-816(a5) # ffffffffc0211520 <npage>
ffffffffc0202858:	04f57a63          	bgeu	a0,a5,ffffffffc02028ac <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020285c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202860:	9536                	add	a0,a0,a3
ffffffffc0202862:	00351793          	slli	a5,a0,0x3
ffffffffc0202866:	953e                	add	a0,a0,a5
ffffffffc0202868:	050e                	slli	a0,a0,0x3
ffffffffc020286a:	0000f797          	auipc	a5,0xf
ffffffffc020286e:	cbe7b783          	ld	a5,-834(a5) # ffffffffc0211528 <pages>
ffffffffc0202872:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202874:	100027f3          	csrr	a5,sstatus
ffffffffc0202878:	8b89                	andi	a5,a5,2
ffffffffc020287a:	eb89                	bnez	a5,ffffffffc020288c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020287c:	0000f797          	auipc	a5,0xf
ffffffffc0202880:	cb47b783          	ld	a5,-844(a5) # ffffffffc0211530 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202884:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202886:	739c                	ld	a5,32(a5)
}
ffffffffc0202888:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020288a:	8782                	jr	a5
        intr_disable();
ffffffffc020288c:	e42a                	sd	a0,8(sp)
ffffffffc020288e:	e02e                	sd	a1,0(sp)
ffffffffc0202890:	c5ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202894:	0000f797          	auipc	a5,0xf
ffffffffc0202898:	c9c7b783          	ld	a5,-868(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020289c:	6582                	ld	a1,0(sp)
ffffffffc020289e:	6522                	ld	a0,8(sp)
ffffffffc02028a0:	739c                	ld	a5,32(a5)
ffffffffc02028a2:	9782                	jalr	a5
}
ffffffffc02028a4:	60e2                	ld	ra,24(sp)
ffffffffc02028a6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028a8:	c41fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028ac:	ccdfe0ef          	jal	ra,ffffffffc0201578 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028b0:	86aa                	mv	a3,a0
ffffffffc02028b2:	00003617          	auipc	a2,0x3
ffffffffc02028b6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205258 <default_pmm_manager+0x150>
ffffffffc02028ba:	06c00593          	li	a1,108
ffffffffc02028be:	00003517          	auipc	a0,0x3
ffffffffc02028c2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc02028c6:	a2dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(ptr != NULL);
ffffffffc02028ca:	00003697          	auipc	a3,0x3
ffffffffc02028ce:	eb668693          	addi	a3,a3,-330 # ffffffffc0205780 <default_pmm_manager+0x678>
ffffffffc02028d2:	00002617          	auipc	a2,0x2
ffffffffc02028d6:	48660613          	addi	a2,a2,1158 # ffffffffc0204d58 <commands+0x738>
ffffffffc02028da:	1fa00593          	li	a1,506
ffffffffc02028de:	00003517          	auipc	a0,0x3
ffffffffc02028e2:	8e250513          	addi	a0,a0,-1822 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc02028e6:	a0dfd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028ea:	00003697          	auipc	a3,0x3
ffffffffc02028ee:	e6668693          	addi	a3,a3,-410 # ffffffffc0205750 <default_pmm_manager+0x648>
ffffffffc02028f2:	00002617          	auipc	a2,0x2
ffffffffc02028f6:	46660613          	addi	a2,a2,1126 # ffffffffc0204d58 <commands+0x738>
ffffffffc02028fa:	1f900593          	li	a1,505
ffffffffc02028fe:	00003517          	auipc	a0,0x3
ffffffffc0202902:	8c250513          	addi	a0,a0,-1854 # ffffffffc02051c0 <default_pmm_manager+0xb8>
ffffffffc0202906:	9edfd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc020290a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020290a:	7135                	addi	sp,sp,-160
ffffffffc020290c:	ed06                	sd	ra,152(sp)
ffffffffc020290e:	e922                	sd	s0,144(sp)
ffffffffc0202910:	e526                	sd	s1,136(sp)
ffffffffc0202912:	e14a                	sd	s2,128(sp)
ffffffffc0202914:	fcce                	sd	s3,120(sp)
ffffffffc0202916:	f8d2                	sd	s4,112(sp)
ffffffffc0202918:	f4d6                	sd	s5,104(sp)
ffffffffc020291a:	f0da                	sd	s6,96(sp)
ffffffffc020291c:	ecde                	sd	s7,88(sp)
ffffffffc020291e:	e8e2                	sd	s8,80(sp)
ffffffffc0202920:	e4e6                	sd	s9,72(sp)
ffffffffc0202922:	e0ea                	sd	s10,64(sp)
ffffffffc0202924:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202926:	3ee010ef          	jal	ra,ffffffffc0203d14 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020292a:	0000f697          	auipc	a3,0xf
ffffffffc020292e:	c166b683          	ld	a3,-1002(a3) # ffffffffc0211540 <max_swap_offset>
ffffffffc0202932:	010007b7          	lui	a5,0x1000
ffffffffc0202936:	ff968713          	addi	a4,a3,-7
ffffffffc020293a:	17e1                	addi	a5,a5,-8
ffffffffc020293c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d1c <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202940:	00007797          	auipc	a5,0x7
ffffffffc0202944:	6c078793          	addi	a5,a5,1728 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0202948:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020294a:	0000fb17          	auipc	s6,0xf
ffffffffc020294e:	bfeb0b13          	addi	s6,s6,-1026 # ffffffffc0211548 <sm>
ffffffffc0202952:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202956:	9702                	jalr	a4
ffffffffc0202958:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc020295a:	c10d                	beqz	a0,ffffffffc020297c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020295c:	60ea                	ld	ra,152(sp)
ffffffffc020295e:	644a                	ld	s0,144(sp)
ffffffffc0202960:	64aa                	ld	s1,136(sp)
ffffffffc0202962:	690a                	ld	s2,128(sp)
ffffffffc0202964:	7a46                	ld	s4,112(sp)
ffffffffc0202966:	7aa6                	ld	s5,104(sp)
ffffffffc0202968:	7b06                	ld	s6,96(sp)
ffffffffc020296a:	6be6                	ld	s7,88(sp)
ffffffffc020296c:	6c46                	ld	s8,80(sp)
ffffffffc020296e:	6ca6                	ld	s9,72(sp)
ffffffffc0202970:	6d06                	ld	s10,64(sp)
ffffffffc0202972:	7de2                	ld	s11,56(sp)
ffffffffc0202974:	854e                	mv	a0,s3
ffffffffc0202976:	79e6                	ld	s3,120(sp)
ffffffffc0202978:	610d                	addi	sp,sp,160
ffffffffc020297a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020297c:	000b3783          	ld	a5,0(s6)
ffffffffc0202980:	00003517          	auipc	a0,0x3
ffffffffc0202984:	e4050513          	addi	a0,a0,-448 # ffffffffc02057c0 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc0202988:	0000e497          	auipc	s1,0xe
ffffffffc020298c:	6b848493          	addi	s1,s1,1720 # ffffffffc0211040 <free_area>
ffffffffc0202990:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202992:	4785                	li	a5,1
ffffffffc0202994:	0000f717          	auipc	a4,0xf
ffffffffc0202998:	baf72e23          	sw	a5,-1092(a4) # ffffffffc0211550 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020299c:	9edfd0ef          	jal	ra,ffffffffc0200388 <cprintf>
ffffffffc02029a0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029a2:	4401                	li	s0,0
ffffffffc02029a4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029a6:	2c978163          	beq	a5,s1,ffffffffc0202c68 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029aa:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029ae:	8b09                	andi	a4,a4,2
ffffffffc02029b0:	2a070e63          	beqz	a4,ffffffffc0202c6c <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02029b4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029b8:	679c                	ld	a5,8(a5)
ffffffffc02029ba:	2d05                	addiw	s10,s10,1
ffffffffc02029bc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029be:	fe9796e3          	bne	a5,s1,ffffffffc02029aa <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02029c2:	8922                	mv	s2,s0
ffffffffc02029c4:	cbffe0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc02029c8:	47251663          	bne	a0,s2,ffffffffc0202e34 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02029cc:	8622                	mv	a2,s0
ffffffffc02029ce:	85ea                	mv	a1,s10
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	e0850513          	addi	a0,a0,-504 # ffffffffc02057d8 <default_pmm_manager+0x6d0>
ffffffffc02029d8:	9b1fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02029dc:	2d7000ef          	jal	ra,ffffffffc02034b2 <mm_create>
ffffffffc02029e0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02029e2:	52050963          	beqz	a0,ffffffffc0202f14 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02029e6:	0000f797          	auipc	a5,0xf
ffffffffc02029ea:	b7a78793          	addi	a5,a5,-1158 # ffffffffc0211560 <check_mm_struct>
ffffffffc02029ee:	6398                	ld	a4,0(a5)
ffffffffc02029f0:	54071263          	bnez	a4,ffffffffc0202f34 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029f4:	0000fb97          	auipc	s7,0xf
ffffffffc02029f8:	b24bbb83          	ld	s7,-1244(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc02029fc:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a00:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a02:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a06:	3c071763          	bnez	a4,ffffffffc0202dd4 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a0a:	6599                	lui	a1,0x6
ffffffffc0202a0c:	460d                	li	a2,3
ffffffffc0202a0e:	6505                	lui	a0,0x1
ffffffffc0202a10:	2eb000ef          	jal	ra,ffffffffc02034fa <vma_create>
ffffffffc0202a14:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a16:	3c050f63          	beqz	a0,ffffffffc0202df4 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a1a:	8556                	mv	a0,s5
ffffffffc0202a1c:	34d000ef          	jal	ra,ffffffffc0203568 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a20:	00003517          	auipc	a0,0x3
ffffffffc0202a24:	e2850513          	addi	a0,a0,-472 # ffffffffc0205848 <default_pmm_manager+0x740>
ffffffffc0202a28:	961fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a2c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a30:	4605                	li	a2,1
ffffffffc0202a32:	6585                	lui	a1,0x1
ffffffffc0202a34:	c89fe0ef          	jal	ra,ffffffffc02016bc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202a38:	3c050e63          	beqz	a0,ffffffffc0202e14 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a3c:	00003517          	auipc	a0,0x3
ffffffffc0202a40:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205898 <default_pmm_manager+0x790>
ffffffffc0202a44:	0000e917          	auipc	s2,0xe
ffffffffc0202a48:	63490913          	addi	s2,s2,1588 # ffffffffc0211078 <check_rp>
ffffffffc0202a4c:	93dfd0ef          	jal	ra,ffffffffc0200388 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a50:	0000ea17          	auipc	s4,0xe
ffffffffc0202a54:	648a0a13          	addi	s4,s4,1608 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a58:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202a5a:	4505                	li	a0,1
ffffffffc0202a5c:	b55fe0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
ffffffffc0202a60:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202a64:	28050c63          	beqz	a0,ffffffffc0202cfc <swap_init+0x3f2>
ffffffffc0202a68:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a6a:	8b89                	andi	a5,a5,2
ffffffffc0202a6c:	26079863          	bnez	a5,ffffffffc0202cdc <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a70:	0c21                	addi	s8,s8,8
ffffffffc0202a72:	ff4c14e3          	bne	s8,s4,ffffffffc0202a5a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a76:	609c                	ld	a5,0(s1)
ffffffffc0202a78:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202a7c:	e084                	sd	s1,0(s1)
ffffffffc0202a7e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202a80:	489c                	lw	a5,16(s1)
ffffffffc0202a82:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202a84:	0000ec17          	auipc	s8,0xe
ffffffffc0202a88:	5f4c0c13          	addi	s8,s8,1524 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202a8c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202a8e:	0000e797          	auipc	a5,0xe
ffffffffc0202a92:	5c07a123          	sw	zero,1474(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a96:	000c3503          	ld	a0,0(s8)
ffffffffc0202a9a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a9c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202a9e:	ba5fe0ef          	jal	ra,ffffffffc0201642 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202aa2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202a96 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202aa6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202aaa:	4791                	li	a5,4
ffffffffc0202aac:	4afc1463          	bne	s8,a5,ffffffffc0202f54 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ab0:	00003517          	auipc	a0,0x3
ffffffffc0202ab4:	e7050513          	addi	a0,a0,-400 # ffffffffc0205920 <default_pmm_manager+0x818>
ffffffffc0202ab8:	8d1fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202abc:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202abe:	0000f797          	auipc	a5,0xf
ffffffffc0202ac2:	aa07a523          	sw	zero,-1366(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ac6:	4529                	li	a0,10
ffffffffc0202ac8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202acc:	0000f597          	auipc	a1,0xf
ffffffffc0202ad0:	a9c5a583          	lw	a1,-1380(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202ad4:	4805                	li	a6,1
ffffffffc0202ad6:	0000f797          	auipc	a5,0xf
ffffffffc0202ada:	a9278793          	addi	a5,a5,-1390 # ffffffffc0211568 <pgfault_num>
ffffffffc0202ade:	3f059b63          	bne	a1,a6,ffffffffc0202ed4 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202ae2:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202ae6:	4390                	lw	a2,0(a5)
ffffffffc0202ae8:	2601                	sext.w	a2,a2
ffffffffc0202aea:	40b61563          	bne	a2,a1,ffffffffc0202ef4 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202aee:	6589                	lui	a1,0x2
ffffffffc0202af0:	452d                	li	a0,11
ffffffffc0202af2:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202af6:	4390                	lw	a2,0(a5)
ffffffffc0202af8:	4809                	li	a6,2
ffffffffc0202afa:	2601                	sext.w	a2,a2
ffffffffc0202afc:	35061c63          	bne	a2,a6,ffffffffc0202e54 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b00:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202b04:	438c                	lw	a1,0(a5)
ffffffffc0202b06:	2581                	sext.w	a1,a1
ffffffffc0202b08:	36c59663          	bne	a1,a2,ffffffffc0202e74 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b0c:	658d                	lui	a1,0x3
ffffffffc0202b0e:	4531                	li	a0,12
ffffffffc0202b10:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b14:	4390                	lw	a2,0(a5)
ffffffffc0202b16:	480d                	li	a6,3
ffffffffc0202b18:	2601                	sext.w	a2,a2
ffffffffc0202b1a:	37061d63          	bne	a2,a6,ffffffffc0202e94 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b1e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b22:	438c                	lw	a1,0(a5)
ffffffffc0202b24:	2581                	sext.w	a1,a1
ffffffffc0202b26:	38c59763          	bne	a1,a2,ffffffffc0202eb4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b2a:	6591                	lui	a1,0x4
ffffffffc0202b2c:	4535                	li	a0,13
ffffffffc0202b2e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202b32:	4390                	lw	a2,0(a5)
ffffffffc0202b34:	2601                	sext.w	a2,a2
ffffffffc0202b36:	21861f63          	bne	a2,s8,ffffffffc0202d54 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b3a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202b3e:	439c                	lw	a5,0(a5)
ffffffffc0202b40:	2781                	sext.w	a5,a5
ffffffffc0202b42:	22c79963          	bne	a5,a2,ffffffffc0202d74 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202b46:	489c                	lw	a5,16(s1)
ffffffffc0202b48:	24079663          	bnez	a5,ffffffffc0202d94 <swap_init+0x48a>
ffffffffc0202b4c:	0000e797          	auipc	a5,0xe
ffffffffc0202b50:	54c78793          	addi	a5,a5,1356 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b54:	0000e617          	auipc	a2,0xe
ffffffffc0202b58:	56c60613          	addi	a2,a2,1388 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b5c:	0000e517          	auipc	a0,0xe
ffffffffc0202b60:	56450513          	addi	a0,a0,1380 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202b64:	55fd                	li	a1,-1
ffffffffc0202b66:	c38c                	sw	a1,0(a5)
ffffffffc0202b68:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b6a:	0791                	addi	a5,a5,4
ffffffffc0202b6c:	0611                	addi	a2,a2,4
ffffffffc0202b6e:	fef51ce3          	bne	a0,a5,ffffffffc0202b66 <swap_init+0x25c>
ffffffffc0202b72:	0000e817          	auipc	a6,0xe
ffffffffc0202b76:	4e680813          	addi	a6,a6,1254 # ffffffffc0211058 <check_ptep>
ffffffffc0202b7a:	0000e897          	auipc	a7,0xe
ffffffffc0202b7e:	4fe88893          	addi	a7,a7,1278 # ffffffffc0211078 <check_rp>
ffffffffc0202b82:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202b84:	0000fc97          	auipc	s9,0xf
ffffffffc0202b88:	9a4c8c93          	addi	s9,s9,-1628 # ffffffffc0211528 <pages>
ffffffffc0202b8c:	00003c17          	auipc	s8,0x3
ffffffffc0202b90:	62cc0c13          	addi	s8,s8,1580 # ffffffffc02061b8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202b94:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b98:	4601                	li	a2,0
ffffffffc0202b9a:	855e                	mv	a0,s7
ffffffffc0202b9c:	ec46                	sd	a7,24(sp)
ffffffffc0202b9e:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202ba0:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ba2:	b1bfe0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc0202ba6:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ba8:	65c2                	ld	a1,16(sp)
ffffffffc0202baa:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bac:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202bb0:	0000f317          	auipc	t1,0xf
ffffffffc0202bb4:	97030313          	addi	t1,t1,-1680 # ffffffffc0211520 <npage>
ffffffffc0202bb8:	16050e63          	beqz	a0,ffffffffc0202d34 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bbc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bbe:	0017f613          	andi	a2,a5,1
ffffffffc0202bc2:	0e060563          	beqz	a2,ffffffffc0202cac <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202bc6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bca:	078a                	slli	a5,a5,0x2
ffffffffc0202bcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bce:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202cc4 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bd2:	000c3603          	ld	a2,0(s8)
ffffffffc0202bd6:	000cb503          	ld	a0,0(s9)
ffffffffc0202bda:	0008bf03          	ld	t5,0(a7)
ffffffffc0202bde:	8f91                	sub	a5,a5,a2
ffffffffc0202be0:	00379613          	slli	a2,a5,0x3
ffffffffc0202be4:	97b2                	add	a5,a5,a2
ffffffffc0202be6:	078e                	slli	a5,a5,0x3
ffffffffc0202be8:	97aa                	add	a5,a5,a0
ffffffffc0202bea:	0aff1163          	bne	t5,a5,ffffffffc0202c8c <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bee:	6785                	lui	a5,0x1
ffffffffc0202bf0:	95be                	add	a1,a1,a5
ffffffffc0202bf2:	6795                	lui	a5,0x5
ffffffffc0202bf4:	0821                	addi	a6,a6,8
ffffffffc0202bf6:	08a1                	addi	a7,a7,8
ffffffffc0202bf8:	f8f59ee3          	bne	a1,a5,ffffffffc0202b94 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202bfc:	00003517          	auipc	a0,0x3
ffffffffc0202c00:	dcc50513          	addi	a0,a0,-564 # ffffffffc02059c8 <default_pmm_manager+0x8c0>
ffffffffc0202c04:	f84fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c08:	000b3783          	ld	a5,0(s6)
ffffffffc0202c0c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c0e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c10:	1a051263          	bnez	a0,ffffffffc0202db4 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c14:	00093503          	ld	a0,0(s2)
ffffffffc0202c18:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c1a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202c1c:	a27fe0ef          	jal	ra,ffffffffc0201642 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c20:	ff491ae3          	bne	s2,s4,ffffffffc0202c14 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c24:	8556                	mv	a0,s5
ffffffffc0202c26:	213000ef          	jal	ra,ffffffffc0203638 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c2a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c2c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c30:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c32:	7782                	ld	a5,32(sp)
ffffffffc0202c34:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c36:	009d8a63          	beq	s11,s1,ffffffffc0202c4a <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202c3a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c3e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c42:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c44:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c46:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c3a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202c4a:	8622                	mv	a2,s0
ffffffffc0202c4c:	85ea                	mv	a1,s10
ffffffffc0202c4e:	00003517          	auipc	a0,0x3
ffffffffc0202c52:	daa50513          	addi	a0,a0,-598 # ffffffffc02059f8 <default_pmm_manager+0x8f0>
ffffffffc0202c56:	f32fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202c5a:	00003517          	auipc	a0,0x3
ffffffffc0202c5e:	dbe50513          	addi	a0,a0,-578 # ffffffffc0205a18 <default_pmm_manager+0x910>
ffffffffc0202c62:	f26fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
}
ffffffffc0202c66:	b9dd                	j	ffffffffc020295c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c68:	4901                	li	s2,0
ffffffffc0202c6a:	bba9                	j	ffffffffc02029c4 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202c6c:	00002697          	auipc	a3,0x2
ffffffffc0202c70:	0dc68693          	addi	a3,a3,220 # ffffffffc0204d48 <commands+0x728>
ffffffffc0202c74:	00002617          	auipc	a2,0x2
ffffffffc0202c78:	0e460613          	addi	a2,a2,228 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202c7c:	0ba00593          	li	a1,186
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	b3050513          	addi	a0,a0,-1232 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202c88:	e6afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c8c:	00003697          	auipc	a3,0x3
ffffffffc0202c90:	d1468693          	addi	a3,a3,-748 # ffffffffc02059a0 <default_pmm_manager+0x898>
ffffffffc0202c94:	00002617          	auipc	a2,0x2
ffffffffc0202c98:	0c460613          	addi	a2,a2,196 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202c9c:	0fa00593          	li	a1,250
ffffffffc0202ca0:	00003517          	auipc	a0,0x3
ffffffffc0202ca4:	b1050513          	addi	a0,a0,-1264 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202ca8:	e4afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cac:	00002617          	auipc	a2,0x2
ffffffffc0202cb0:	4c460613          	addi	a2,a2,1220 # ffffffffc0205170 <default_pmm_manager+0x68>
ffffffffc0202cb4:	07000593          	li	a1,112
ffffffffc0202cb8:	00002517          	auipc	a0,0x2
ffffffffc0202cbc:	4a850513          	addi	a0,a0,1192 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc0202cc0:	e32fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	47c60613          	addi	a2,a2,1148 # ffffffffc0205140 <default_pmm_manager+0x38>
ffffffffc0202ccc:	06500593          	li	a1,101
ffffffffc0202cd0:	00002517          	auipc	a0,0x2
ffffffffc0202cd4:	49050513          	addi	a0,a0,1168 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc0202cd8:	e1afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	bfc68693          	addi	a3,a3,-1028 # ffffffffc02058d8 <default_pmm_manager+0x7d0>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	07460613          	addi	a2,a2,116 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202cec:	0db00593          	li	a1,219
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	ac050513          	addi	a0,a0,-1344 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202cf8:	dfafd0ef          	jal	ra,ffffffffc02002f2 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	bc468693          	addi	a3,a3,-1084 # ffffffffc02058c0 <default_pmm_manager+0x7b8>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	05460613          	addi	a2,a2,84 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202d0c:	0da00593          	li	a1,218
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	aa050513          	addi	a0,a0,-1376 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202d18:	ddafd0ef          	jal	ra,ffffffffc02002f2 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d1c:	00003617          	auipc	a2,0x3
ffffffffc0202d20:	a7460613          	addi	a2,a2,-1420 # ffffffffc0205790 <default_pmm_manager+0x688>
ffffffffc0202d24:	02700593          	li	a1,39
ffffffffc0202d28:	00003517          	auipc	a0,0x3
ffffffffc0202d2c:	a8850513          	addi	a0,a0,-1400 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202d30:	dc2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202d34:	00003697          	auipc	a3,0x3
ffffffffc0202d38:	c5468693          	addi	a3,a3,-940 # ffffffffc0205988 <default_pmm_manager+0x880>
ffffffffc0202d3c:	00002617          	auipc	a2,0x2
ffffffffc0202d40:	01c60613          	addi	a2,a2,28 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202d44:	0f900593          	li	a1,249
ffffffffc0202d48:	00003517          	auipc	a0,0x3
ffffffffc0202d4c:	a6850513          	addi	a0,a0,-1432 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202d50:	da2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d54:	00003697          	auipc	a3,0x3
ffffffffc0202d58:	c2468693          	addi	a3,a3,-988 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0202d5c:	00002617          	auipc	a2,0x2
ffffffffc0202d60:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202d64:	09d00593          	li	a1,157
ffffffffc0202d68:	00003517          	auipc	a0,0x3
ffffffffc0202d6c:	a4850513          	addi	a0,a0,-1464 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202d70:	d82fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d74:	00003697          	auipc	a3,0x3
ffffffffc0202d78:	c0468693          	addi	a3,a3,-1020 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0202d7c:	00002617          	auipc	a2,0x2
ffffffffc0202d80:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202d84:	09f00593          	li	a1,159
ffffffffc0202d88:	00003517          	auipc	a0,0x3
ffffffffc0202d8c:	a2850513          	addi	a0,a0,-1496 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202d90:	d62fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert( nr_free == 0);         
ffffffffc0202d94:	00002697          	auipc	a3,0x2
ffffffffc0202d98:	19c68693          	addi	a3,a3,412 # ffffffffc0204f30 <commands+0x910>
ffffffffc0202d9c:	00002617          	auipc	a2,0x2
ffffffffc0202da0:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202da4:	0f100593          	li	a1,241
ffffffffc0202da8:	00003517          	auipc	a0,0x3
ffffffffc0202dac:	a0850513          	addi	a0,a0,-1528 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202db0:	d42fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(ret==0);
ffffffffc0202db4:	00003697          	auipc	a3,0x3
ffffffffc0202db8:	c3c68693          	addi	a3,a3,-964 # ffffffffc02059f0 <default_pmm_manager+0x8e8>
ffffffffc0202dbc:	00002617          	auipc	a2,0x2
ffffffffc0202dc0:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202dc4:	10000593          	li	a1,256
ffffffffc0202dc8:	00003517          	auipc	a0,0x3
ffffffffc0202dcc:	9e850513          	addi	a0,a0,-1560 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202dd0:	d22fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202dd4:	00003697          	auipc	a3,0x3
ffffffffc0202dd8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205828 <default_pmm_manager+0x720>
ffffffffc0202ddc:	00002617          	auipc	a2,0x2
ffffffffc0202de0:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202de4:	0ca00593          	li	a1,202
ffffffffc0202de8:	00003517          	auipc	a0,0x3
ffffffffc0202dec:	9c850513          	addi	a0,a0,-1592 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202df0:	d02fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(vma != NULL);
ffffffffc0202df4:	00003697          	auipc	a3,0x3
ffffffffc0202df8:	a4468693          	addi	a3,a3,-1468 # ffffffffc0205838 <default_pmm_manager+0x730>
ffffffffc0202dfc:	00002617          	auipc	a2,0x2
ffffffffc0202e00:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202e04:	0cd00593          	li	a1,205
ffffffffc0202e08:	00003517          	auipc	a0,0x3
ffffffffc0202e0c:	9a850513          	addi	a0,a0,-1624 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202e10:	ce2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202e14:	00003697          	auipc	a3,0x3
ffffffffc0202e18:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205880 <default_pmm_manager+0x778>
ffffffffc0202e1c:	00002617          	auipc	a2,0x2
ffffffffc0202e20:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202e24:	0d500593          	li	a1,213
ffffffffc0202e28:	00003517          	auipc	a0,0x3
ffffffffc0202e2c:	98850513          	addi	a0,a0,-1656 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202e30:	cc2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e34:	00002697          	auipc	a3,0x2
ffffffffc0202e38:	f5468693          	addi	a3,a3,-172 # ffffffffc0204d88 <commands+0x768>
ffffffffc0202e3c:	00002617          	auipc	a2,0x2
ffffffffc0202e40:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202e44:	0bd00593          	li	a1,189
ffffffffc0202e48:	00003517          	auipc	a0,0x3
ffffffffc0202e4c:	96850513          	addi	a0,a0,-1688 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202e50:	ca2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e54:	00003697          	auipc	a3,0x3
ffffffffc0202e58:	b0468693          	addi	a3,a3,-1276 # ffffffffc0205958 <default_pmm_manager+0x850>
ffffffffc0202e5c:	00002617          	auipc	a2,0x2
ffffffffc0202e60:	efc60613          	addi	a2,a2,-260 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202e64:	09500593          	li	a1,149
ffffffffc0202e68:	00003517          	auipc	a0,0x3
ffffffffc0202e6c:	94850513          	addi	a0,a0,-1720 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202e70:	c82fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e74:	00003697          	auipc	a3,0x3
ffffffffc0202e78:	ae468693          	addi	a3,a3,-1308 # ffffffffc0205958 <default_pmm_manager+0x850>
ffffffffc0202e7c:	00002617          	auipc	a2,0x2
ffffffffc0202e80:	edc60613          	addi	a2,a2,-292 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202e84:	09700593          	li	a1,151
ffffffffc0202e88:	00003517          	auipc	a0,0x3
ffffffffc0202e8c:	92850513          	addi	a0,a0,-1752 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202e90:	c62fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==3);
ffffffffc0202e94:	00003697          	auipc	a3,0x3
ffffffffc0202e98:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205968 <default_pmm_manager+0x860>
ffffffffc0202e9c:	00002617          	auipc	a2,0x2
ffffffffc0202ea0:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202ea4:	09900593          	li	a1,153
ffffffffc0202ea8:	00003517          	auipc	a0,0x3
ffffffffc0202eac:	90850513          	addi	a0,a0,-1784 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202eb0:	c42fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==3);
ffffffffc0202eb4:	00003697          	auipc	a3,0x3
ffffffffc0202eb8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0205968 <default_pmm_manager+0x860>
ffffffffc0202ebc:	00002617          	auipc	a2,0x2
ffffffffc0202ec0:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202ec4:	09b00593          	li	a1,155
ffffffffc0202ec8:	00003517          	auipc	a0,0x3
ffffffffc0202ecc:	8e850513          	addi	a0,a0,-1816 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202ed0:	c22fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==1);
ffffffffc0202ed4:	00003697          	auipc	a3,0x3
ffffffffc0202ed8:	a7468693          	addi	a3,a3,-1420 # ffffffffc0205948 <default_pmm_manager+0x840>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202ee4:	09100593          	li	a1,145
ffffffffc0202ee8:	00003517          	auipc	a0,0x3
ffffffffc0202eec:	8c850513          	addi	a0,a0,-1848 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202ef0:	c02fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(pgfault_num==1);
ffffffffc0202ef4:	00003697          	auipc	a3,0x3
ffffffffc0202ef8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205948 <default_pmm_manager+0x840>
ffffffffc0202efc:	00002617          	auipc	a2,0x2
ffffffffc0202f00:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202f04:	09300593          	li	a1,147
ffffffffc0202f08:	00003517          	auipc	a0,0x3
ffffffffc0202f0c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202f10:	be2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(mm != NULL);
ffffffffc0202f14:	00003697          	auipc	a3,0x3
ffffffffc0202f18:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0205800 <default_pmm_manager+0x6f8>
ffffffffc0202f1c:	00002617          	auipc	a2,0x2
ffffffffc0202f20:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202f24:	0c200593          	li	a1,194
ffffffffc0202f28:	00003517          	auipc	a0,0x3
ffffffffc0202f2c:	88850513          	addi	a0,a0,-1912 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202f30:	bc2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f34:	00003697          	auipc	a3,0x3
ffffffffc0202f38:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0205810 <default_pmm_manager+0x708>
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	e1c60613          	addi	a2,a2,-484 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202f44:	0c500593          	li	a1,197
ffffffffc0202f48:	00003517          	auipc	a0,0x3
ffffffffc0202f4c:	86850513          	addi	a0,a0,-1944 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202f50:	ba2fd0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	9a468693          	addi	a3,a3,-1628 # ffffffffc02058f8 <default_pmm_manager+0x7f0>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204d58 <commands+0x738>
ffffffffc0202f64:	0e800593          	li	a1,232
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	84850513          	addi	a0,a0,-1976 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0202f70:	b82fd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0202f74 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f74:	0000e797          	auipc	a5,0xe
ffffffffc0202f78:	5d47b783          	ld	a5,1492(a5) # ffffffffc0211548 <sm>
ffffffffc0202f7c:	6b9c                	ld	a5,16(a5)
ffffffffc0202f7e:	8782                	jr	a5

ffffffffc0202f80 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f80:	0000e797          	auipc	a5,0xe
ffffffffc0202f84:	5c87b783          	ld	a5,1480(a5) # ffffffffc0211548 <sm>
ffffffffc0202f88:	739c                	ld	a5,32(a5)
ffffffffc0202f8a:	8782                	jr	a5

ffffffffc0202f8c <swap_out>:
{
ffffffffc0202f8c:	711d                	addi	sp,sp,-96
ffffffffc0202f8e:	ec86                	sd	ra,88(sp)
ffffffffc0202f90:	e8a2                	sd	s0,80(sp)
ffffffffc0202f92:	e4a6                	sd	s1,72(sp)
ffffffffc0202f94:	e0ca                	sd	s2,64(sp)
ffffffffc0202f96:	fc4e                	sd	s3,56(sp)
ffffffffc0202f98:	f852                	sd	s4,48(sp)
ffffffffc0202f9a:	f456                	sd	s5,40(sp)
ffffffffc0202f9c:	f05a                	sd	s6,32(sp)
ffffffffc0202f9e:	ec5e                	sd	s7,24(sp)
ffffffffc0202fa0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202fa2:	cde9                	beqz	a1,ffffffffc020307c <swap_out+0xf0>
ffffffffc0202fa4:	8a2e                	mv	s4,a1
ffffffffc0202fa6:	892a                	mv	s2,a0
ffffffffc0202fa8:	8ab2                	mv	s5,a2
ffffffffc0202faa:	4401                	li	s0,0
ffffffffc0202fac:	0000e997          	auipc	s3,0xe
ffffffffc0202fb0:	59c98993          	addi	s3,s3,1436 # ffffffffc0211548 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fb4:	00003b17          	auipc	s6,0x3
ffffffffc0202fb8:	ae4b0b13          	addi	s6,s6,-1308 # ffffffffc0205a98 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fbc:	00003b97          	auipc	s7,0x3
ffffffffc0202fc0:	ac4b8b93          	addi	s7,s7,-1340 # ffffffffc0205a80 <default_pmm_manager+0x978>
ffffffffc0202fc4:	a825                	j	ffffffffc0202ffc <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fc6:	67a2                	ld	a5,8(sp)
ffffffffc0202fc8:	8626                	mv	a2,s1
ffffffffc0202fca:	85a2                	mv	a1,s0
ffffffffc0202fcc:	63b4                	ld	a3,64(a5)
ffffffffc0202fce:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202fd0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fd2:	82b1                	srli	a3,a3,0xc
ffffffffc0202fd4:	0685                	addi	a3,a3,1
ffffffffc0202fd6:	bb2fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202fda:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202fdc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202fde:	613c                	ld	a5,64(a0)
ffffffffc0202fe0:	83b1                	srli	a5,a5,0xc
ffffffffc0202fe2:	0785                	addi	a5,a5,1
ffffffffc0202fe4:	07a2                	slli	a5,a5,0x8
ffffffffc0202fe6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202fea:	e58fe0ef          	jal	ra,ffffffffc0201642 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202fee:	01893503          	ld	a0,24(s2)
ffffffffc0202ff2:	85a6                	mv	a1,s1
ffffffffc0202ff4:	eb6ff0ef          	jal	ra,ffffffffc02026aa <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202ff8:	048a0d63          	beq	s4,s0,ffffffffc0203052 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202ffc:	0009b783          	ld	a5,0(s3)
ffffffffc0203000:	8656                	mv	a2,s5
ffffffffc0203002:	002c                	addi	a1,sp,8
ffffffffc0203004:	7b9c                	ld	a5,48(a5)
ffffffffc0203006:	854a                	mv	a0,s2
ffffffffc0203008:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020300a:	e12d                	bnez	a0,ffffffffc020306c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020300c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020300e:	01893503          	ld	a0,24(s2)
ffffffffc0203012:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203014:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203016:	85a6                	mv	a1,s1
ffffffffc0203018:	ea4fe0ef          	jal	ra,ffffffffc02016bc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020301c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020301e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203020:	8b85                	andi	a5,a5,1
ffffffffc0203022:	cfb9                	beqz	a5,ffffffffc0203080 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203024:	65a2                	ld	a1,8(sp)
ffffffffc0203026:	61bc                	ld	a5,64(a1)
ffffffffc0203028:	83b1                	srli	a5,a5,0xc
ffffffffc020302a:	0785                	addi	a5,a5,1
ffffffffc020302c:	00879513          	slli	a0,a5,0x8
ffffffffc0203030:	5b7000ef          	jal	ra,ffffffffc0203de6 <swapfs_write>
ffffffffc0203034:	d949                	beqz	a0,ffffffffc0202fc6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203036:	855e                	mv	a0,s7
ffffffffc0203038:	b50fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020303c:	0009b783          	ld	a5,0(s3)
ffffffffc0203040:	6622                	ld	a2,8(sp)
ffffffffc0203042:	4681                	li	a3,0
ffffffffc0203044:	739c                	ld	a5,32(a5)
ffffffffc0203046:	85a6                	mv	a1,s1
ffffffffc0203048:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020304a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020304c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020304e:	fa8a17e3          	bne	s4,s0,ffffffffc0202ffc <swap_out+0x70>
}
ffffffffc0203052:	60e6                	ld	ra,88(sp)
ffffffffc0203054:	8522                	mv	a0,s0
ffffffffc0203056:	6446                	ld	s0,80(sp)
ffffffffc0203058:	64a6                	ld	s1,72(sp)
ffffffffc020305a:	6906                	ld	s2,64(sp)
ffffffffc020305c:	79e2                	ld	s3,56(sp)
ffffffffc020305e:	7a42                	ld	s4,48(sp)
ffffffffc0203060:	7aa2                	ld	s5,40(sp)
ffffffffc0203062:	7b02                	ld	s6,32(sp)
ffffffffc0203064:	6be2                	ld	s7,24(sp)
ffffffffc0203066:	6c42                	ld	s8,16(sp)
ffffffffc0203068:	6125                	addi	sp,sp,96
ffffffffc020306a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020306c:	85a2                	mv	a1,s0
ffffffffc020306e:	00003517          	auipc	a0,0x3
ffffffffc0203072:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205a38 <default_pmm_manager+0x930>
ffffffffc0203076:	b12fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
                  break;
ffffffffc020307a:	bfe1                	j	ffffffffc0203052 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020307c:	4401                	li	s0,0
ffffffffc020307e:	bfd1                	j	ffffffffc0203052 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203080:	00003697          	auipc	a3,0x3
ffffffffc0203084:	9e868693          	addi	a3,a3,-1560 # ffffffffc0205a68 <default_pmm_manager+0x960>
ffffffffc0203088:	00002617          	auipc	a2,0x2
ffffffffc020308c:	cd060613          	addi	a2,a2,-816 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203090:	06600593          	li	a1,102
ffffffffc0203094:	00002517          	auipc	a0,0x2
ffffffffc0203098:	71c50513          	addi	a0,a0,1820 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc020309c:	a56fd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02030a0 <swap_in>:
{
ffffffffc02030a0:	7179                	addi	sp,sp,-48
ffffffffc02030a2:	e84a                	sd	s2,16(sp)
ffffffffc02030a4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030a6:	4505                	li	a0,1
{
ffffffffc02030a8:	ec26                	sd	s1,24(sp)
ffffffffc02030aa:	e44e                	sd	s3,8(sp)
ffffffffc02030ac:	f406                	sd	ra,40(sp)
ffffffffc02030ae:	f022                	sd	s0,32(sp)
ffffffffc02030b0:	84ae                	mv	s1,a1
ffffffffc02030b2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030b4:	cfcfe0ef          	jal	ra,ffffffffc02015b0 <alloc_pages>
     assert(result!=NULL);
ffffffffc02030b8:	c129                	beqz	a0,ffffffffc02030fa <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030ba:	842a                	mv	s0,a0
ffffffffc02030bc:	01893503          	ld	a0,24(s2)
ffffffffc02030c0:	4601                	li	a2,0
ffffffffc02030c2:	85a6                	mv	a1,s1
ffffffffc02030c4:	df8fe0ef          	jal	ra,ffffffffc02016bc <get_pte>
ffffffffc02030c8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02030ca:	6108                	ld	a0,0(a0)
ffffffffc02030cc:	85a2                	mv	a1,s0
ffffffffc02030ce:	47f000ef          	jal	ra,ffffffffc0203d4c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02030d2:	00093583          	ld	a1,0(s2)
ffffffffc02030d6:	8626                	mv	a2,s1
ffffffffc02030d8:	00003517          	auipc	a0,0x3
ffffffffc02030dc:	a1050513          	addi	a0,a0,-1520 # ffffffffc0205ae8 <default_pmm_manager+0x9e0>
ffffffffc02030e0:	81a1                	srli	a1,a1,0x8
ffffffffc02030e2:	aa6fd0ef          	jal	ra,ffffffffc0200388 <cprintf>
}
ffffffffc02030e6:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02030e8:	0089b023          	sd	s0,0(s3)
}
ffffffffc02030ec:	7402                	ld	s0,32(sp)
ffffffffc02030ee:	64e2                	ld	s1,24(sp)
ffffffffc02030f0:	6942                	ld	s2,16(sp)
ffffffffc02030f2:	69a2                	ld	s3,8(sp)
ffffffffc02030f4:	4501                	li	a0,0
ffffffffc02030f6:	6145                	addi	sp,sp,48
ffffffffc02030f8:	8082                	ret
     assert(result!=NULL);
ffffffffc02030fa:	00003697          	auipc	a3,0x3
ffffffffc02030fe:	9de68693          	addi	a3,a3,-1570 # ffffffffc0205ad8 <default_pmm_manager+0x9d0>
ffffffffc0203102:	00002617          	auipc	a2,0x2
ffffffffc0203106:	c5660613          	addi	a2,a2,-938 # ffffffffc0204d58 <commands+0x738>
ffffffffc020310a:	07c00593          	li	a1,124
ffffffffc020310e:	00002517          	auipc	a0,0x2
ffffffffc0203112:	6a250513          	addi	a0,a0,1698 # ffffffffc02057b0 <default_pmm_manager+0x6a8>
ffffffffc0203116:	9dcfd0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc020311a <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020311a:	0000e797          	auipc	a5,0xe
ffffffffc020311e:	fce78793          	addi	a5,a5,-50 # ffffffffc02110e8 <pra_list_head>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
ffffffffc0203122:	f51c                	sd	a5,40(a0)
ffffffffc0203124:	e79c                	sd	a5,8(a5)
ffffffffc0203126:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0203128:	0000e717          	auipc	a4,0xe
ffffffffc020312c:	42f73823          	sd	a5,1072(a4) # ffffffffc0211558 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203130:	4501                	li	a0,0
ffffffffc0203132:	8082                	ret

ffffffffc0203134 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203134:	4501                	li	a0,0
ffffffffc0203136:	8082                	ret

ffffffffc0203138 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203138:	4501                	li	a0,0
ffffffffc020313a:	8082                	ret

ffffffffc020313c <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020313c:	4501                	li	a0,0
ffffffffc020313e:	8082                	ret

ffffffffc0203140 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203140:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203142:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203144:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203146:	678d                	lui	a5,0x3
ffffffffc0203148:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc020314c:	0000e697          	auipc	a3,0xe
ffffffffc0203150:	41c6a683          	lw	a3,1052(a3) # ffffffffc0211568 <pgfault_num>
ffffffffc0203154:	4711                	li	a4,4
ffffffffc0203156:	0ae69363          	bne	a3,a4,ffffffffc02031fc <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020315a:	6705                	lui	a4,0x1
ffffffffc020315c:	4629                	li	a2,10
ffffffffc020315e:	0000e797          	auipc	a5,0xe
ffffffffc0203162:	40a78793          	addi	a5,a5,1034 # ffffffffc0211568 <pgfault_num>
ffffffffc0203166:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020316a:	4398                	lw	a4,0(a5)
ffffffffc020316c:	2701                	sext.w	a4,a4
ffffffffc020316e:	20d71763          	bne	a4,a3,ffffffffc020337c <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203172:	6691                	lui	a3,0x4
ffffffffc0203174:	4635                	li	a2,13
ffffffffc0203176:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020317a:	4394                	lw	a3,0(a5)
ffffffffc020317c:	2681                	sext.w	a3,a3
ffffffffc020317e:	1ce69f63          	bne	a3,a4,ffffffffc020335c <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203182:	6709                	lui	a4,0x2
ffffffffc0203184:	462d                	li	a2,11
ffffffffc0203186:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020318a:	4398                	lw	a4,0(a5)
ffffffffc020318c:	2701                	sext.w	a4,a4
ffffffffc020318e:	1ad71763          	bne	a4,a3,ffffffffc020333c <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203192:	6715                	lui	a4,0x5
ffffffffc0203194:	46b9                	li	a3,14
ffffffffc0203196:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020319a:	4398                	lw	a4,0(a5)
ffffffffc020319c:	4695                	li	a3,5
ffffffffc020319e:	2701                	sext.w	a4,a4
ffffffffc02031a0:	16d71e63          	bne	a4,a3,ffffffffc020331c <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02031a4:	4394                	lw	a3,0(a5)
ffffffffc02031a6:	2681                	sext.w	a3,a3
ffffffffc02031a8:	14e69a63          	bne	a3,a4,ffffffffc02032fc <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02031ac:	4398                	lw	a4,0(a5)
ffffffffc02031ae:	2701                	sext.w	a4,a4
ffffffffc02031b0:	12d71663          	bne	a4,a3,ffffffffc02032dc <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02031b4:	4394                	lw	a3,0(a5)
ffffffffc02031b6:	2681                	sext.w	a3,a3
ffffffffc02031b8:	10e69263          	bne	a3,a4,ffffffffc02032bc <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02031bc:	4398                	lw	a4,0(a5)
ffffffffc02031be:	2701                	sext.w	a4,a4
ffffffffc02031c0:	0cd71e63          	bne	a4,a3,ffffffffc020329c <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02031c4:	4394                	lw	a3,0(a5)
ffffffffc02031c6:	2681                	sext.w	a3,a3
ffffffffc02031c8:	0ae69a63          	bne	a3,a4,ffffffffc020327c <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02031cc:	6715                	lui	a4,0x5
ffffffffc02031ce:	46b9                	li	a3,14
ffffffffc02031d0:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02031d4:	4398                	lw	a4,0(a5)
ffffffffc02031d6:	4695                	li	a3,5
ffffffffc02031d8:	2701                	sext.w	a4,a4
ffffffffc02031da:	08d71163          	bne	a4,a3,ffffffffc020325c <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031de:	6705                	lui	a4,0x1
ffffffffc02031e0:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02031e4:	4729                	li	a4,10
ffffffffc02031e6:	04e69b63          	bne	a3,a4,ffffffffc020323c <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc02031ea:	439c                	lw	a5,0(a5)
ffffffffc02031ec:	4719                	li	a4,6
ffffffffc02031ee:	2781                	sext.w	a5,a5
ffffffffc02031f0:	02e79663          	bne	a5,a4,ffffffffc020321c <_clock_check_swap+0xdc>
}
ffffffffc02031f4:	60a2                	ld	ra,8(sp)
ffffffffc02031f6:	4501                	li	a0,0
ffffffffc02031f8:	0141                	addi	sp,sp,16
ffffffffc02031fa:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02031fc:	00002697          	auipc	a3,0x2
ffffffffc0203200:	77c68693          	addi	a3,a3,1916 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0203204:	00002617          	auipc	a2,0x2
ffffffffc0203208:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204d58 <commands+0x738>
ffffffffc020320c:	08c00593          	li	a1,140
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	91850513          	addi	a0,a0,-1768 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203218:	8dafd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==6);
ffffffffc020321c:	00003697          	auipc	a3,0x3
ffffffffc0203220:	95c68693          	addi	a3,a3,-1700 # ffffffffc0205b78 <default_pmm_manager+0xa70>
ffffffffc0203224:	00002617          	auipc	a2,0x2
ffffffffc0203228:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d58 <commands+0x738>
ffffffffc020322c:	0a300593          	li	a1,163
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203238:	8bafd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020323c:	00003697          	auipc	a3,0x3
ffffffffc0203240:	91468693          	addi	a3,a3,-1772 # ffffffffc0205b50 <default_pmm_manager+0xa48>
ffffffffc0203244:	00002617          	auipc	a2,0x2
ffffffffc0203248:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d58 <commands+0x738>
ffffffffc020324c:	0a100593          	li	a1,161
ffffffffc0203250:	00003517          	auipc	a0,0x3
ffffffffc0203254:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203258:	89afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc020325c:	00003697          	auipc	a3,0x3
ffffffffc0203260:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc0203264:	00002617          	auipc	a2,0x2
ffffffffc0203268:	af460613          	addi	a2,a2,-1292 # ffffffffc0204d58 <commands+0x738>
ffffffffc020326c:	0a000593          	li	a1,160
ffffffffc0203270:	00003517          	auipc	a0,0x3
ffffffffc0203274:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203278:	87afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc020327c:	00003697          	auipc	a3,0x3
ffffffffc0203280:	8c468693          	addi	a3,a3,-1852 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc0203284:	00002617          	auipc	a2,0x2
ffffffffc0203288:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204d58 <commands+0x738>
ffffffffc020328c:	09e00593          	li	a1,158
ffffffffc0203290:	00003517          	auipc	a0,0x3
ffffffffc0203294:	89850513          	addi	a0,a0,-1896 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203298:	85afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc020329c:	00003697          	auipc	a3,0x3
ffffffffc02032a0:	8a468693          	addi	a3,a3,-1884 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc02032a4:	00002617          	auipc	a2,0x2
ffffffffc02032a8:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204d58 <commands+0x738>
ffffffffc02032ac:	09c00593          	li	a1,156
ffffffffc02032b0:	00003517          	auipc	a0,0x3
ffffffffc02032b4:	87850513          	addi	a0,a0,-1928 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc02032b8:	83afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc02032bc:	00003697          	auipc	a3,0x3
ffffffffc02032c0:	88468693          	addi	a3,a3,-1916 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc02032c4:	00002617          	auipc	a2,0x2
ffffffffc02032c8:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204d58 <commands+0x738>
ffffffffc02032cc:	09a00593          	li	a1,154
ffffffffc02032d0:	00003517          	auipc	a0,0x3
ffffffffc02032d4:	85850513          	addi	a0,a0,-1960 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc02032d8:	81afd0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc02032dc:	00003697          	auipc	a3,0x3
ffffffffc02032e0:	86468693          	addi	a3,a3,-1948 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc02032e4:	00002617          	auipc	a2,0x2
ffffffffc02032e8:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204d58 <commands+0x738>
ffffffffc02032ec:	09800593          	li	a1,152
ffffffffc02032f0:	00003517          	auipc	a0,0x3
ffffffffc02032f4:	83850513          	addi	a0,a0,-1992 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc02032f8:	ffbfc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc02032fc:	00003697          	auipc	a3,0x3
ffffffffc0203300:	84468693          	addi	a3,a3,-1980 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc0203304:	00002617          	auipc	a2,0x2
ffffffffc0203308:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204d58 <commands+0x738>
ffffffffc020330c:	09600593          	li	a1,150
ffffffffc0203310:	00003517          	auipc	a0,0x3
ffffffffc0203314:	81850513          	addi	a0,a0,-2024 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203318:	fdbfc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==5);
ffffffffc020331c:	00003697          	auipc	a3,0x3
ffffffffc0203320:	82468693          	addi	a3,a3,-2012 # ffffffffc0205b40 <default_pmm_manager+0xa38>
ffffffffc0203324:	00002617          	auipc	a2,0x2
ffffffffc0203328:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204d58 <commands+0x738>
ffffffffc020332c:	09400593          	li	a1,148
ffffffffc0203330:	00002517          	auipc	a0,0x2
ffffffffc0203334:	7f850513          	addi	a0,a0,2040 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203338:	fbbfc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==4);
ffffffffc020333c:	00002697          	auipc	a3,0x2
ffffffffc0203340:	63c68693          	addi	a3,a3,1596 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204d58 <commands+0x738>
ffffffffc020334c:	09200593          	li	a1,146
ffffffffc0203350:	00002517          	auipc	a0,0x2
ffffffffc0203354:	7d850513          	addi	a0,a0,2008 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203358:	f9bfc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==4);
ffffffffc020335c:	00002697          	auipc	a3,0x2
ffffffffc0203360:	61c68693          	addi	a3,a3,1564 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0203364:	00002617          	auipc	a2,0x2
ffffffffc0203368:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204d58 <commands+0x738>
ffffffffc020336c:	09000593          	li	a1,144
ffffffffc0203370:	00002517          	auipc	a0,0x2
ffffffffc0203374:	7b850513          	addi	a0,a0,1976 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203378:	f7bfc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgfault_num==4);
ffffffffc020337c:	00002697          	auipc	a3,0x2
ffffffffc0203380:	5fc68693          	addi	a3,a3,1532 # ffffffffc0205978 <default_pmm_manager+0x870>
ffffffffc0203384:	00002617          	auipc	a2,0x2
ffffffffc0203388:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204d58 <commands+0x738>
ffffffffc020338c:	08e00593          	li	a1,142
ffffffffc0203390:	00002517          	auipc	a0,0x2
ffffffffc0203394:	79850513          	addi	a0,a0,1944 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203398:	f5bfc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc020339c <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020339c:	7514                	ld	a3,40(a0)
{
ffffffffc020339e:	1141                	addi	sp,sp,-16
ffffffffc02033a0:	e406                	sd	ra,8(sp)
ffffffffc02033a2:	e022                	sd	s0,0(sp)
         assert(head != NULL);
ffffffffc02033a4:	c2ad                	beqz	a3,ffffffffc0203406 <_clock_swap_out_victim+0x6a>
     assert(in_tick==0);
ffffffffc02033a6:	e241                	bnez	a2,ffffffffc0203426 <_clock_swap_out_victim+0x8a>
ffffffffc02033a8:	0000e417          	auipc	s0,0xe
ffffffffc02033ac:	1b040413          	addi	s0,s0,432 # ffffffffc0211558 <curr_ptr>
ffffffffc02033b0:	852e                	mv	a0,a1
ffffffffc02033b2:	600c                	ld	a1,0(s0)
ffffffffc02033b4:	4701                	li	a4,0
    return listelm->next;
ffffffffc02033b6:	4605                	li	a2,1
        if (curr_ptr == head){  // 由于是将页面page插入到页面链表pra_list_head的末尾，所以pra_list_head制起标识头部的作用，跳过
ffffffffc02033b8:	00d58c63          	beq	a1,a3,ffffffffc02033d0 <_clock_swap_out_victim+0x34>
        if (curr_page->visited != 1){
ffffffffc02033bc:	fe05b783          	ld	a5,-32(a1) # fe0 <kern_entry-0xffffffffc01ff020>
ffffffffc02033c0:	00c79e63          	bne	a5,a2,ffffffffc02033dc <_clock_swap_out_victim+0x40>
            curr_page->visited = 0;
ffffffffc02033c4:	fe05b023          	sd	zero,-32(a1)
ffffffffc02033c8:	658c                	ld	a1,8(a1)
        if (curr_ptr == head){  // 由于是将页面page插入到页面链表pra_list_head的末尾，所以pra_list_head制起标识头部的作用，跳过
ffffffffc02033ca:	4705                	li	a4,1
ffffffffc02033cc:	fed598e3          	bne	a1,a3,ffffffffc02033bc <_clock_swap_out_victim+0x20>
ffffffffc02033d0:	658c                	ld	a1,8(a1)
ffffffffc02033d2:	4705                	li	a4,1
        if (curr_page->visited != 1){
ffffffffc02033d4:	fe05b783          	ld	a5,-32(a1)
ffffffffc02033d8:	fec786e3          	beq	a5,a2,ffffffffc02033c4 <_clock_swap_out_victim+0x28>
ffffffffc02033dc:	c311                	beqz	a4,ffffffffc02033e0 <_clock_swap_out_victim+0x44>
ffffffffc02033de:	e00c                	sd	a1,0(s0)
        curr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02033e0:	fd058793          	addi	a5,a1,-48
            *ptr_page = curr_page;
ffffffffc02033e4:	e11c                	sd	a5,0(a0)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc02033e6:	00002517          	auipc	a0,0x2
ffffffffc02033ea:	7c250513          	addi	a0,a0,1986 # ffffffffc0205ba8 <default_pmm_manager+0xaa0>
ffffffffc02033ee:	f9bfc0ef          	jal	ra,ffffffffc0200388 <cprintf>
            list_del(curr_ptr);
ffffffffc02033f2:	601c                	ld	a5,0(s0)
}
ffffffffc02033f4:	60a2                	ld	ra,8(sp)
ffffffffc02033f6:	6402                	ld	s0,0(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033f8:	6398                	ld	a4,0(a5)
ffffffffc02033fa:	679c                	ld	a5,8(a5)
ffffffffc02033fc:	4501                	li	a0,0
    prev->next = next;
ffffffffc02033fe:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203400:	e398                	sd	a4,0(a5)
ffffffffc0203402:	0141                	addi	sp,sp,16
ffffffffc0203404:	8082                	ret
         assert(head != NULL);
ffffffffc0203406:	00002697          	auipc	a3,0x2
ffffffffc020340a:	78268693          	addi	a3,a3,1922 # ffffffffc0205b88 <default_pmm_manager+0xa80>
ffffffffc020340e:	00002617          	auipc	a2,0x2
ffffffffc0203412:	94a60613          	addi	a2,a2,-1718 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203416:	04900593          	li	a1,73
ffffffffc020341a:	00002517          	auipc	a0,0x2
ffffffffc020341e:	70e50513          	addi	a0,a0,1806 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203422:	ed1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
     assert(in_tick==0);
ffffffffc0203426:	00002697          	auipc	a3,0x2
ffffffffc020342a:	77268693          	addi	a3,a3,1906 # ffffffffc0205b98 <default_pmm_manager+0xa90>
ffffffffc020342e:	00002617          	auipc	a2,0x2
ffffffffc0203432:	92a60613          	addi	a2,a2,-1750 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203436:	04a00593          	li	a1,74
ffffffffc020343a:	00002517          	auipc	a0,0x2
ffffffffc020343e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0205b28 <default_pmm_manager+0xa20>
ffffffffc0203442:	eb1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203446 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203446:	0000e797          	auipc	a5,0xe
ffffffffc020344a:	1127b783          	ld	a5,274(a5) # ffffffffc0211558 <curr_ptr>
ffffffffc020344e:	cf91                	beqz	a5,ffffffffc020346a <_clock_map_swappable+0x24>
    list_add(head->prev, entry);
ffffffffc0203450:	751c                	ld	a5,40(a0)
ffffffffc0203452:	03060713          	addi	a4,a2,48
}
ffffffffc0203456:	4501                	li	a0,0
    list_add(head->prev, entry);
ffffffffc0203458:	639c                	ld	a5,0(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc020345a:	6794                	ld	a3,8(a5)
    prev->next = next->prev = elm;
ffffffffc020345c:	e298                	sd	a4,0(a3)
ffffffffc020345e:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203460:	fa1c                	sd	a5,48(a2)
    page->visited  = 1;
ffffffffc0203462:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203464:	fe14                	sd	a3,56(a2)
ffffffffc0203466:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203468:	8082                	ret
{
ffffffffc020346a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020346c:	00002697          	auipc	a3,0x2
ffffffffc0203470:	74c68693          	addi	a3,a3,1868 # ffffffffc0205bb8 <default_pmm_manager+0xab0>
ffffffffc0203474:	00002617          	auipc	a2,0x2
ffffffffc0203478:	8e460613          	addi	a2,a2,-1820 # ffffffffc0204d58 <commands+0x738>
ffffffffc020347c:	03600593          	li	a1,54
ffffffffc0203480:	00002517          	auipc	a0,0x2
ffffffffc0203484:	6a850513          	addi	a0,a0,1704 # ffffffffc0205b28 <default_pmm_manager+0xa20>
{
ffffffffc0203488:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020348a:	e69fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc020348e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020348e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203490:	00002697          	auipc	a3,0x2
ffffffffc0203494:	76868693          	addi	a3,a3,1896 # ffffffffc0205bf8 <default_pmm_manager+0xaf0>
ffffffffc0203498:	00002617          	auipc	a2,0x2
ffffffffc020349c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204d58 <commands+0x738>
ffffffffc02034a0:	07d00593          	li	a1,125
ffffffffc02034a4:	00002517          	auipc	a0,0x2
ffffffffc02034a8:	77450513          	addi	a0,a0,1908 # ffffffffc0205c18 <default_pmm_manager+0xb10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02034ac:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02034ae:	e45fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc02034b2 <mm_create>:
mm_create(void) {
ffffffffc02034b2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02034b4:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02034b8:	e022                	sd	s0,0(sp)
ffffffffc02034ba:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02034bc:	aacff0ef          	jal	ra,ffffffffc0202768 <kmalloc>
ffffffffc02034c0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02034c2:	c105                	beqz	a0,ffffffffc02034e2 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02034c4:	e408                	sd	a0,8(s0)
ffffffffc02034c6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02034c8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02034cc:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02034d0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034d4:	0000e797          	auipc	a5,0xe
ffffffffc02034d8:	07c7a783          	lw	a5,124(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02034dc:	eb81                	bnez	a5,ffffffffc02034ec <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02034de:	02053423          	sd	zero,40(a0)
}
ffffffffc02034e2:	60a2                	ld	ra,8(sp)
ffffffffc02034e4:	8522                	mv	a0,s0
ffffffffc02034e6:	6402                	ld	s0,0(sp)
ffffffffc02034e8:	0141                	addi	sp,sp,16
ffffffffc02034ea:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034ec:	a89ff0ef          	jal	ra,ffffffffc0202f74 <swap_init_mm>
}
ffffffffc02034f0:	60a2                	ld	ra,8(sp)
ffffffffc02034f2:	8522                	mv	a0,s0
ffffffffc02034f4:	6402                	ld	s0,0(sp)
ffffffffc02034f6:	0141                	addi	sp,sp,16
ffffffffc02034f8:	8082                	ret

ffffffffc02034fa <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034fa:	1101                	addi	sp,sp,-32
ffffffffc02034fc:	e04a                	sd	s2,0(sp)
ffffffffc02034fe:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203500:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203504:	e822                	sd	s0,16(sp)
ffffffffc0203506:	e426                	sd	s1,8(sp)
ffffffffc0203508:	ec06                	sd	ra,24(sp)
ffffffffc020350a:	84ae                	mv	s1,a1
ffffffffc020350c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020350e:	a5aff0ef          	jal	ra,ffffffffc0202768 <kmalloc>
    if (vma != NULL) {
ffffffffc0203512:	c509                	beqz	a0,ffffffffc020351c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203514:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203518:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020351a:	ed00                	sd	s0,24(a0)
}
ffffffffc020351c:	60e2                	ld	ra,24(sp)
ffffffffc020351e:	6442                	ld	s0,16(sp)
ffffffffc0203520:	64a2                	ld	s1,8(sp)
ffffffffc0203522:	6902                	ld	s2,0(sp)
ffffffffc0203524:	6105                	addi	sp,sp,32
ffffffffc0203526:	8082                	ret

ffffffffc0203528 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203528:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020352a:	c505                	beqz	a0,ffffffffc0203552 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020352c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020352e:	c501                	beqz	a0,ffffffffc0203536 <find_vma+0xe>
ffffffffc0203530:	651c                	ld	a5,8(a0)
ffffffffc0203532:	02f5f263          	bgeu	a1,a5,ffffffffc0203556 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203536:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203538:	00f68d63          	beq	a3,a5,ffffffffc0203552 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020353c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203540:	00e5e663          	bltu	a1,a4,ffffffffc020354c <find_vma+0x24>
ffffffffc0203544:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203548:	00e5ec63          	bltu	a1,a4,ffffffffc0203560 <find_vma+0x38>
ffffffffc020354c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020354e:	fef697e3          	bne	a3,a5,ffffffffc020353c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203552:	4501                	li	a0,0
}
ffffffffc0203554:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203556:	691c                	ld	a5,16(a0)
ffffffffc0203558:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203536 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020355c:	ea88                	sd	a0,16(a3)
ffffffffc020355e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203560:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203564:	ea88                	sd	a0,16(a3)
ffffffffc0203566:	8082                	ret

ffffffffc0203568 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203568:	6590                	ld	a2,8(a1)
ffffffffc020356a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020356e:	1141                	addi	sp,sp,-16
ffffffffc0203570:	e406                	sd	ra,8(sp)
ffffffffc0203572:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203574:	01066763          	bltu	a2,a6,ffffffffc0203582 <insert_vma_struct+0x1a>
ffffffffc0203578:	a085                	j	ffffffffc02035d8 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020357a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020357e:	04e66863          	bltu	a2,a4,ffffffffc02035ce <insert_vma_struct+0x66>
ffffffffc0203582:	86be                	mv	a3,a5
ffffffffc0203584:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203586:	fef51ae3          	bne	a0,a5,ffffffffc020357a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020358a:	02a68463          	beq	a3,a0,ffffffffc02035b2 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020358e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203592:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203596:	08e8f163          	bgeu	a7,a4,ffffffffc0203618 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020359a:	04e66f63          	bltu	a2,a4,ffffffffc02035f8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020359e:	00f50a63          	beq	a0,a5,ffffffffc02035b2 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02035a2:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035a6:	05076963          	bltu	a4,a6,ffffffffc02035f8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02035aa:	ff07b603          	ld	a2,-16(a5)
ffffffffc02035ae:	02c77363          	bgeu	a4,a2,ffffffffc02035d4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02035b2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02035b4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02035b6:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02035ba:	e390                	sd	a2,0(a5)
ffffffffc02035bc:	e690                	sd	a2,8(a3)
}
ffffffffc02035be:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02035c0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02035c2:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02035c4:	0017079b          	addiw	a5,a4,1
ffffffffc02035c8:	d11c                	sw	a5,32(a0)
}
ffffffffc02035ca:	0141                	addi	sp,sp,16
ffffffffc02035cc:	8082                	ret
    if (le_prev != list) {
ffffffffc02035ce:	fca690e3          	bne	a3,a0,ffffffffc020358e <insert_vma_struct+0x26>
ffffffffc02035d2:	bfd1                	j	ffffffffc02035a6 <insert_vma_struct+0x3e>
ffffffffc02035d4:	ebbff0ef          	jal	ra,ffffffffc020348e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035d8:	00002697          	auipc	a3,0x2
ffffffffc02035dc:	65068693          	addi	a3,a3,1616 # ffffffffc0205c28 <default_pmm_manager+0xb20>
ffffffffc02035e0:	00001617          	auipc	a2,0x1
ffffffffc02035e4:	77860613          	addi	a2,a2,1912 # ffffffffc0204d58 <commands+0x738>
ffffffffc02035e8:	08400593          	li	a1,132
ffffffffc02035ec:	00002517          	auipc	a0,0x2
ffffffffc02035f0:	62c50513          	addi	a0,a0,1580 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc02035f4:	cfffc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035f8:	00002697          	auipc	a3,0x2
ffffffffc02035fc:	67068693          	addi	a3,a3,1648 # ffffffffc0205c68 <default_pmm_manager+0xb60>
ffffffffc0203600:	00001617          	auipc	a2,0x1
ffffffffc0203604:	75860613          	addi	a2,a2,1880 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203608:	07c00593          	li	a1,124
ffffffffc020360c:	00002517          	auipc	a0,0x2
ffffffffc0203610:	60c50513          	addi	a0,a0,1548 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203614:	cdffc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203618:	00002697          	auipc	a3,0x2
ffffffffc020361c:	63068693          	addi	a3,a3,1584 # ffffffffc0205c48 <default_pmm_manager+0xb40>
ffffffffc0203620:	00001617          	auipc	a2,0x1
ffffffffc0203624:	73860613          	addi	a2,a2,1848 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203628:	07b00593          	li	a1,123
ffffffffc020362c:	00002517          	auipc	a0,0x2
ffffffffc0203630:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203634:	cbffc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203638 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203638:	1141                	addi	sp,sp,-16
ffffffffc020363a:	e022                	sd	s0,0(sp)
ffffffffc020363c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020363e:	6508                	ld	a0,8(a0)
ffffffffc0203640:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203642:	00a40e63          	beq	s0,a0,ffffffffc020365e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203646:	6118                	ld	a4,0(a0)
ffffffffc0203648:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020364a:	03000593          	li	a1,48
ffffffffc020364e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203650:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203652:	e398                	sd	a4,0(a5)
ffffffffc0203654:	9ceff0ef          	jal	ra,ffffffffc0202822 <kfree>
    return listelm->next;
ffffffffc0203658:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020365a:	fea416e3          	bne	s0,a0,ffffffffc0203646 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020365e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203660:	6402                	ld	s0,0(sp)
ffffffffc0203662:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203664:	03000593          	li	a1,48
}
ffffffffc0203668:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020366a:	9b8ff06f          	j	ffffffffc0202822 <kfree>

ffffffffc020366e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020366e:	715d                	addi	sp,sp,-80
ffffffffc0203670:	e486                	sd	ra,72(sp)
ffffffffc0203672:	f44e                	sd	s3,40(sp)
ffffffffc0203674:	f052                	sd	s4,32(sp)
ffffffffc0203676:	e0a2                	sd	s0,64(sp)
ffffffffc0203678:	fc26                	sd	s1,56(sp)
ffffffffc020367a:	f84a                	sd	s2,48(sp)
ffffffffc020367c:	ec56                	sd	s5,24(sp)
ffffffffc020367e:	e85a                	sd	s6,16(sp)
ffffffffc0203680:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203682:	800fe0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc0203686:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203688:	ffbfd0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc020368c:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020368e:	03000513          	li	a0,48
ffffffffc0203692:	8d6ff0ef          	jal	ra,ffffffffc0202768 <kmalloc>
    if (mm != NULL) {
ffffffffc0203696:	56050863          	beqz	a0,ffffffffc0203c06 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc020369a:	e508                	sd	a0,8(a0)
ffffffffc020369c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020369e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036a2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036a6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02036aa:	0000e797          	auipc	a5,0xe
ffffffffc02036ae:	ea67a783          	lw	a5,-346(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02036b2:	84aa                	mv	s1,a0
ffffffffc02036b4:	e7b9                	bnez	a5,ffffffffc0203702 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02036b6:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02036ba:	03200413          	li	s0,50
ffffffffc02036be:	a811                	j	ffffffffc02036d2 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02036c0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02036c2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036c4:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02036c8:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02036ca:	8526                	mv	a0,s1
ffffffffc02036cc:	e9dff0ef          	jal	ra,ffffffffc0203568 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02036d0:	cc05                	beqz	s0,ffffffffc0203708 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036d2:	03000513          	li	a0,48
ffffffffc02036d6:	892ff0ef          	jal	ra,ffffffffc0202768 <kmalloc>
ffffffffc02036da:	85aa                	mv	a1,a0
ffffffffc02036dc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02036e0:	f165                	bnez	a0,ffffffffc02036c0 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02036e2:	00002697          	auipc	a3,0x2
ffffffffc02036e6:	15668693          	addi	a3,a3,342 # ffffffffc0205838 <default_pmm_manager+0x730>
ffffffffc02036ea:	00001617          	auipc	a2,0x1
ffffffffc02036ee:	66e60613          	addi	a2,a2,1646 # ffffffffc0204d58 <commands+0x738>
ffffffffc02036f2:	0ce00593          	li	a1,206
ffffffffc02036f6:	00002517          	auipc	a0,0x2
ffffffffc02036fa:	52250513          	addi	a0,a0,1314 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc02036fe:	bf5fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203702:	873ff0ef          	jal	ra,ffffffffc0202f74 <swap_init_mm>
ffffffffc0203706:	bf55                	j	ffffffffc02036ba <vmm_init+0x4c>
ffffffffc0203708:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020370c:	1f900913          	li	s2,505
ffffffffc0203710:	a819                	j	ffffffffc0203726 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0203712:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203714:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203716:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020371a:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020371c:	8526                	mv	a0,s1
ffffffffc020371e:	e4bff0ef          	jal	ra,ffffffffc0203568 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203722:	03240a63          	beq	s0,s2,ffffffffc0203756 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203726:	03000513          	li	a0,48
ffffffffc020372a:	83eff0ef          	jal	ra,ffffffffc0202768 <kmalloc>
ffffffffc020372e:	85aa                	mv	a1,a0
ffffffffc0203730:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203734:	fd79                	bnez	a0,ffffffffc0203712 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0203736:	00002697          	auipc	a3,0x2
ffffffffc020373a:	10268693          	addi	a3,a3,258 # ffffffffc0205838 <default_pmm_manager+0x730>
ffffffffc020373e:	00001617          	auipc	a2,0x1
ffffffffc0203742:	61a60613          	addi	a2,a2,1562 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203746:	0d400593          	li	a1,212
ffffffffc020374a:	00002517          	auipc	a0,0x2
ffffffffc020374e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203752:	ba1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    return listelm->next;
ffffffffc0203756:	649c                	ld	a5,8(s1)
ffffffffc0203758:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020375a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020375e:	2ef48463          	beq	s1,a5,ffffffffc0203a46 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203762:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203766:	ffe70693          	addi	a3,a4,-2
ffffffffc020376a:	26d61e63          	bne	a2,a3,ffffffffc02039e6 <vmm_init+0x378>
ffffffffc020376e:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203772:	26e69a63          	bne	a3,a4,ffffffffc02039e6 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203776:	0715                	addi	a4,a4,5
ffffffffc0203778:	679c                	ld	a5,8(a5)
ffffffffc020377a:	feb712e3          	bne	a4,a1,ffffffffc020375e <vmm_init+0xf0>
ffffffffc020377e:	4b1d                	li	s6,7
ffffffffc0203780:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203782:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203786:	85a2                	mv	a1,s0
ffffffffc0203788:	8526                	mv	a0,s1
ffffffffc020378a:	d9fff0ef          	jal	ra,ffffffffc0203528 <find_vma>
ffffffffc020378e:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203790:	2c050b63          	beqz	a0,ffffffffc0203a66 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203794:	00140593          	addi	a1,s0,1
ffffffffc0203798:	8526                	mv	a0,s1
ffffffffc020379a:	d8fff0ef          	jal	ra,ffffffffc0203528 <find_vma>
ffffffffc020379e:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02037a0:	2e050363          	beqz	a0,ffffffffc0203a86 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02037a4:	85da                	mv	a1,s6
ffffffffc02037a6:	8526                	mv	a0,s1
ffffffffc02037a8:	d81ff0ef          	jal	ra,ffffffffc0203528 <find_vma>
        assert(vma3 == NULL);
ffffffffc02037ac:	2e051d63          	bnez	a0,ffffffffc0203aa6 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02037b0:	00340593          	addi	a1,s0,3
ffffffffc02037b4:	8526                	mv	a0,s1
ffffffffc02037b6:	d73ff0ef          	jal	ra,ffffffffc0203528 <find_vma>
        assert(vma4 == NULL);
ffffffffc02037ba:	30051663          	bnez	a0,ffffffffc0203ac6 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02037be:	00440593          	addi	a1,s0,4
ffffffffc02037c2:	8526                	mv	a0,s1
ffffffffc02037c4:	d65ff0ef          	jal	ra,ffffffffc0203528 <find_vma>
        assert(vma5 == NULL);
ffffffffc02037c8:	30051f63          	bnez	a0,ffffffffc0203ae6 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02037cc:	00893783          	ld	a5,8(s2)
ffffffffc02037d0:	24879b63          	bne	a5,s0,ffffffffc0203a26 <vmm_init+0x3b8>
ffffffffc02037d4:	01093783          	ld	a5,16(s2)
ffffffffc02037d8:	25679763          	bne	a5,s6,ffffffffc0203a26 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02037dc:	008ab783          	ld	a5,8(s5)
ffffffffc02037e0:	22879363          	bne	a5,s0,ffffffffc0203a06 <vmm_init+0x398>
ffffffffc02037e4:	010ab783          	ld	a5,16(s5)
ffffffffc02037e8:	21679f63          	bne	a5,s6,ffffffffc0203a06 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02037ec:	0415                	addi	s0,s0,5
ffffffffc02037ee:	0b15                	addi	s6,s6,5
ffffffffc02037f0:	f9741be3          	bne	s0,s7,ffffffffc0203786 <vmm_init+0x118>
ffffffffc02037f4:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02037f6:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02037f8:	85a2                	mv	a1,s0
ffffffffc02037fa:	8526                	mv	a0,s1
ffffffffc02037fc:	d2dff0ef          	jal	ra,ffffffffc0203528 <find_vma>
ffffffffc0203800:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203804:	c90d                	beqz	a0,ffffffffc0203836 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203806:	6914                	ld	a3,16(a0)
ffffffffc0203808:	6510                	ld	a2,8(a0)
ffffffffc020380a:	00002517          	auipc	a0,0x2
ffffffffc020380e:	57e50513          	addi	a0,a0,1406 # ffffffffc0205d88 <default_pmm_manager+0xc80>
ffffffffc0203812:	b77fc0ef          	jal	ra,ffffffffc0200388 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203816:	00002697          	auipc	a3,0x2
ffffffffc020381a:	59a68693          	addi	a3,a3,1434 # ffffffffc0205db0 <default_pmm_manager+0xca8>
ffffffffc020381e:	00001617          	auipc	a2,0x1
ffffffffc0203822:	53a60613          	addi	a2,a2,1338 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203826:	0f600593          	li	a1,246
ffffffffc020382a:	00002517          	auipc	a0,0x2
ffffffffc020382e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203832:	ac1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203836:	147d                	addi	s0,s0,-1
ffffffffc0203838:	fd2410e3          	bne	s0,s2,ffffffffc02037f8 <vmm_init+0x18a>
ffffffffc020383c:	a811                	j	ffffffffc0203850 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020383e:	6118                	ld	a4,0(a0)
ffffffffc0203840:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203842:	03000593          	li	a1,48
ffffffffc0203846:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203848:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020384a:	e398                	sd	a4,0(a5)
ffffffffc020384c:	fd7fe0ef          	jal	ra,ffffffffc0202822 <kfree>
    return listelm->next;
ffffffffc0203850:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203852:	fea496e3          	bne	s1,a0,ffffffffc020383e <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203856:	03000593          	li	a1,48
ffffffffc020385a:	8526                	mv	a0,s1
ffffffffc020385c:	fc7fe0ef          	jal	ra,ffffffffc0202822 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203860:	e23fd0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc0203864:	3caa1163          	bne	s4,a0,ffffffffc0203c26 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203868:	00002517          	auipc	a0,0x2
ffffffffc020386c:	58850513          	addi	a0,a0,1416 # ffffffffc0205df0 <default_pmm_manager+0xce8>
ffffffffc0203870:	b19fc0ef          	jal	ra,ffffffffc0200388 <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203874:	e0ffd0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc0203878:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020387a:	03000513          	li	a0,48
ffffffffc020387e:	eebfe0ef          	jal	ra,ffffffffc0202768 <kmalloc>
ffffffffc0203882:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203884:	2a050163          	beqz	a0,ffffffffc0203b26 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203888:	0000e797          	auipc	a5,0xe
ffffffffc020388c:	cc87a783          	lw	a5,-824(a5) # ffffffffc0211550 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203890:	e508                	sd	a0,8(a0)
ffffffffc0203892:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203894:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203898:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020389c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038a0:	14079063          	bnez	a5,ffffffffc02039e0 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc02038a4:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038a8:	0000e917          	auipc	s2,0xe
ffffffffc02038ac:	c7093903          	ld	s2,-912(s2) # ffffffffc0211518 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02038b0:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02038b4:	0000e717          	auipc	a4,0xe
ffffffffc02038b8:	ca873623          	sd	s0,-852(a4) # ffffffffc0211560 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038bc:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02038c0:	24079363          	bnez	a5,ffffffffc0203b06 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038c4:	03000513          	li	a0,48
ffffffffc02038c8:	ea1fe0ef          	jal	ra,ffffffffc0202768 <kmalloc>
ffffffffc02038cc:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02038ce:	28050063          	beqz	a0,ffffffffc0203b4e <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02038d2:	002007b7          	lui	a5,0x200
ffffffffc02038d6:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02038da:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02038dc:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02038de:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02038e2:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02038e4:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02038e8:	c81ff0ef          	jal	ra,ffffffffc0203568 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02038ec:	10000593          	li	a1,256
ffffffffc02038f0:	8522                	mv	a0,s0
ffffffffc02038f2:	c37ff0ef          	jal	ra,ffffffffc0203528 <find_vma>
ffffffffc02038f6:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02038fa:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02038fe:	26aa1863          	bne	s4,a0,ffffffffc0203b6e <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203902:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203906:	0785                	addi	a5,a5,1
ffffffffc0203908:	fee79de3          	bne	a5,a4,ffffffffc0203902 <vmm_init+0x294>
        sum += i;
ffffffffc020390c:	6705                	lui	a4,0x1
ffffffffc020390e:	10000793          	li	a5,256
ffffffffc0203912:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203916:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020391a:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020391e:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203920:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203922:	fec79ce3          	bne	a5,a2,ffffffffc020391a <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203926:	26071463          	bnez	a4,ffffffffc0203b8e <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020392a:	4581                	li	a1,0
ffffffffc020392c:	854a                	mv	a0,s2
ffffffffc020392e:	fdffd0ef          	jal	ra,ffffffffc020190c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203932:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203936:	0000e717          	auipc	a4,0xe
ffffffffc020393a:	bea73703          	ld	a4,-1046(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc020393e:	078a                	slli	a5,a5,0x2
ffffffffc0203940:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203942:	26e7f663          	bgeu	a5,a4,ffffffffc0203bae <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203946:	00003717          	auipc	a4,0x3
ffffffffc020394a:	87273703          	ld	a4,-1934(a4) # ffffffffc02061b8 <nbase>
ffffffffc020394e:	8f99                	sub	a5,a5,a4
ffffffffc0203950:	00379713          	slli	a4,a5,0x3
ffffffffc0203954:	97ba                	add	a5,a5,a4
ffffffffc0203956:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203958:	0000e517          	auipc	a0,0xe
ffffffffc020395c:	bd053503          	ld	a0,-1072(a0) # ffffffffc0211528 <pages>
ffffffffc0203960:	953e                	add	a0,a0,a5
ffffffffc0203962:	4585                	li	a1,1
ffffffffc0203964:	cdffd0ef          	jal	ra,ffffffffc0201642 <free_pages>
    return listelm->next;
ffffffffc0203968:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc020396a:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc020396e:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203972:	00a40e63          	beq	s0,a0,ffffffffc020398e <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203976:	6118                	ld	a4,0(a0)
ffffffffc0203978:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020397a:	03000593          	li	a1,48
ffffffffc020397e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203980:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203982:	e398                	sd	a4,0(a5)
ffffffffc0203984:	e9ffe0ef          	jal	ra,ffffffffc0202822 <kfree>
    return listelm->next;
ffffffffc0203988:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020398a:	fea416e3          	bne	s0,a0,ffffffffc0203976 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020398e:	03000593          	li	a1,48
ffffffffc0203992:	8522                	mv	a0,s0
ffffffffc0203994:	e8ffe0ef          	jal	ra,ffffffffc0202822 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203998:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc020399a:	0000e797          	auipc	a5,0xe
ffffffffc020399e:	bc07b323          	sd	zero,-1082(a5) # ffffffffc0211560 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039a2:	ce1fd0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
ffffffffc02039a6:	22a49063          	bne	s1,a0,ffffffffc0203bc6 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02039aa:	00002517          	auipc	a0,0x2
ffffffffc02039ae:	49650513          	addi	a0,a0,1174 # ffffffffc0205e40 <default_pmm_manager+0xd38>
ffffffffc02039b2:	9d7fc0ef          	jal	ra,ffffffffc0200388 <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039b6:	ccdfd0ef          	jal	ra,ffffffffc0201682 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02039ba:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039bc:	22a99563          	bne	s3,a0,ffffffffc0203be6 <vmm_init+0x578>
}
ffffffffc02039c0:	6406                	ld	s0,64(sp)
ffffffffc02039c2:	60a6                	ld	ra,72(sp)
ffffffffc02039c4:	74e2                	ld	s1,56(sp)
ffffffffc02039c6:	7942                	ld	s2,48(sp)
ffffffffc02039c8:	79a2                	ld	s3,40(sp)
ffffffffc02039ca:	7a02                	ld	s4,32(sp)
ffffffffc02039cc:	6ae2                	ld	s5,24(sp)
ffffffffc02039ce:	6b42                	ld	s6,16(sp)
ffffffffc02039d0:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02039d2:	00002517          	auipc	a0,0x2
ffffffffc02039d6:	48e50513          	addi	a0,a0,1166 # ffffffffc0205e60 <default_pmm_manager+0xd58>
}
ffffffffc02039da:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02039dc:	9adfc06f          	j	ffffffffc0200388 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039e0:	d94ff0ef          	jal	ra,ffffffffc0202f74 <swap_init_mm>
ffffffffc02039e4:	b5d1                	j	ffffffffc02038a8 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02039e6:	00002697          	auipc	a3,0x2
ffffffffc02039ea:	2ba68693          	addi	a3,a3,698 # ffffffffc0205ca0 <default_pmm_manager+0xb98>
ffffffffc02039ee:	00001617          	auipc	a2,0x1
ffffffffc02039f2:	36a60613          	addi	a2,a2,874 # ffffffffc0204d58 <commands+0x738>
ffffffffc02039f6:	0dd00593          	li	a1,221
ffffffffc02039fa:	00002517          	auipc	a0,0x2
ffffffffc02039fe:	21e50513          	addi	a0,a0,542 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203a02:	8f1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203a06:	00002697          	auipc	a3,0x2
ffffffffc0203a0a:	35268693          	addi	a3,a3,850 # ffffffffc0205d58 <default_pmm_manager+0xc50>
ffffffffc0203a0e:	00001617          	auipc	a2,0x1
ffffffffc0203a12:	34a60613          	addi	a2,a2,842 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203a16:	0ee00593          	li	a1,238
ffffffffc0203a1a:	00002517          	auipc	a0,0x2
ffffffffc0203a1e:	1fe50513          	addi	a0,a0,510 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203a22:	8d1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203a26:	00002697          	auipc	a3,0x2
ffffffffc0203a2a:	30268693          	addi	a3,a3,770 # ffffffffc0205d28 <default_pmm_manager+0xc20>
ffffffffc0203a2e:	00001617          	auipc	a2,0x1
ffffffffc0203a32:	32a60613          	addi	a2,a2,810 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203a36:	0ed00593          	li	a1,237
ffffffffc0203a3a:	00002517          	auipc	a0,0x2
ffffffffc0203a3e:	1de50513          	addi	a0,a0,478 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203a42:	8b1fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203a46:	00002697          	auipc	a3,0x2
ffffffffc0203a4a:	24268693          	addi	a3,a3,578 # ffffffffc0205c88 <default_pmm_manager+0xb80>
ffffffffc0203a4e:	00001617          	auipc	a2,0x1
ffffffffc0203a52:	30a60613          	addi	a2,a2,778 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203a56:	0db00593          	li	a1,219
ffffffffc0203a5a:	00002517          	auipc	a0,0x2
ffffffffc0203a5e:	1be50513          	addi	a0,a0,446 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203a62:	891fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma1 != NULL);
ffffffffc0203a66:	00002697          	auipc	a3,0x2
ffffffffc0203a6a:	27268693          	addi	a3,a3,626 # ffffffffc0205cd8 <default_pmm_manager+0xbd0>
ffffffffc0203a6e:	00001617          	auipc	a2,0x1
ffffffffc0203a72:	2ea60613          	addi	a2,a2,746 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203a76:	0e300593          	li	a1,227
ffffffffc0203a7a:	00002517          	auipc	a0,0x2
ffffffffc0203a7e:	19e50513          	addi	a0,a0,414 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203a82:	871fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma2 != NULL);
ffffffffc0203a86:	00002697          	auipc	a3,0x2
ffffffffc0203a8a:	26268693          	addi	a3,a3,610 # ffffffffc0205ce8 <default_pmm_manager+0xbe0>
ffffffffc0203a8e:	00001617          	auipc	a2,0x1
ffffffffc0203a92:	2ca60613          	addi	a2,a2,714 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203a96:	0e500593          	li	a1,229
ffffffffc0203a9a:	00002517          	auipc	a0,0x2
ffffffffc0203a9e:	17e50513          	addi	a0,a0,382 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203aa2:	851fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma3 == NULL);
ffffffffc0203aa6:	00002697          	auipc	a3,0x2
ffffffffc0203aaa:	25268693          	addi	a3,a3,594 # ffffffffc0205cf8 <default_pmm_manager+0xbf0>
ffffffffc0203aae:	00001617          	auipc	a2,0x1
ffffffffc0203ab2:	2aa60613          	addi	a2,a2,682 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203ab6:	0e700593          	li	a1,231
ffffffffc0203aba:	00002517          	auipc	a0,0x2
ffffffffc0203abe:	15e50513          	addi	a0,a0,350 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203ac2:	831fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma4 == NULL);
ffffffffc0203ac6:	00002697          	auipc	a3,0x2
ffffffffc0203aca:	24268693          	addi	a3,a3,578 # ffffffffc0205d08 <default_pmm_manager+0xc00>
ffffffffc0203ace:	00001617          	auipc	a2,0x1
ffffffffc0203ad2:	28a60613          	addi	a2,a2,650 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203ad6:	0e900593          	li	a1,233
ffffffffc0203ada:	00002517          	auipc	a0,0x2
ffffffffc0203ade:	13e50513          	addi	a0,a0,318 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203ae2:	811fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        assert(vma5 == NULL);
ffffffffc0203ae6:	00002697          	auipc	a3,0x2
ffffffffc0203aea:	23268693          	addi	a3,a3,562 # ffffffffc0205d18 <default_pmm_manager+0xc10>
ffffffffc0203aee:	00001617          	auipc	a2,0x1
ffffffffc0203af2:	26a60613          	addi	a2,a2,618 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203af6:	0eb00593          	li	a1,235
ffffffffc0203afa:	00002517          	auipc	a0,0x2
ffffffffc0203afe:	11e50513          	addi	a0,a0,286 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203b02:	ff0fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b06:	00002697          	auipc	a3,0x2
ffffffffc0203b0a:	d2268693          	addi	a3,a3,-734 # ffffffffc0205828 <default_pmm_manager+0x720>
ffffffffc0203b0e:	00001617          	auipc	a2,0x1
ffffffffc0203b12:	24a60613          	addi	a2,a2,586 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203b16:	10d00593          	li	a1,269
ffffffffc0203b1a:	00002517          	auipc	a0,0x2
ffffffffc0203b1e:	0fe50513          	addi	a0,a0,254 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203b22:	fd0fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203b26:	00002697          	auipc	a3,0x2
ffffffffc0203b2a:	35268693          	addi	a3,a3,850 # ffffffffc0205e78 <default_pmm_manager+0xd70>
ffffffffc0203b2e:	00001617          	auipc	a2,0x1
ffffffffc0203b32:	22a60613          	addi	a2,a2,554 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203b36:	10a00593          	li	a1,266
ffffffffc0203b3a:	00002517          	auipc	a0,0x2
ffffffffc0203b3e:	0de50513          	addi	a0,a0,222 # ffffffffc0205c18 <default_pmm_manager+0xb10>
    check_mm_struct = mm_create();
ffffffffc0203b42:	0000e797          	auipc	a5,0xe
ffffffffc0203b46:	a007bf23          	sd	zero,-1506(a5) # ffffffffc0211560 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203b4a:	fa8fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(vma != NULL);
ffffffffc0203b4e:	00002697          	auipc	a3,0x2
ffffffffc0203b52:	cea68693          	addi	a3,a3,-790 # ffffffffc0205838 <default_pmm_manager+0x730>
ffffffffc0203b56:	00001617          	auipc	a2,0x1
ffffffffc0203b5a:	20260613          	addi	a2,a2,514 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203b5e:	11100593          	li	a1,273
ffffffffc0203b62:	00002517          	auipc	a0,0x2
ffffffffc0203b66:	0b650513          	addi	a0,a0,182 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203b6a:	f88fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b6e:	00002697          	auipc	a3,0x2
ffffffffc0203b72:	2a268693          	addi	a3,a3,674 # ffffffffc0205e10 <default_pmm_manager+0xd08>
ffffffffc0203b76:	00001617          	auipc	a2,0x1
ffffffffc0203b7a:	1e260613          	addi	a2,a2,482 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203b7e:	11600593          	li	a1,278
ffffffffc0203b82:	00002517          	auipc	a0,0x2
ffffffffc0203b86:	09650513          	addi	a0,a0,150 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203b8a:	f68fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(sum == 0);
ffffffffc0203b8e:	00002697          	auipc	a3,0x2
ffffffffc0203b92:	2a268693          	addi	a3,a3,674 # ffffffffc0205e30 <default_pmm_manager+0xd28>
ffffffffc0203b96:	00001617          	auipc	a2,0x1
ffffffffc0203b9a:	1c260613          	addi	a2,a2,450 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203b9e:	12000593          	li	a1,288
ffffffffc0203ba2:	00002517          	auipc	a0,0x2
ffffffffc0203ba6:	07650513          	addi	a0,a0,118 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203baa:	f48fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203bae:	00001617          	auipc	a2,0x1
ffffffffc0203bb2:	59260613          	addi	a2,a2,1426 # ffffffffc0205140 <default_pmm_manager+0x38>
ffffffffc0203bb6:	06500593          	li	a1,101
ffffffffc0203bba:	00001517          	auipc	a0,0x1
ffffffffc0203bbe:	5a650513          	addi	a0,a0,1446 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc0203bc2:	f30fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203bc6:	00002697          	auipc	a3,0x2
ffffffffc0203bca:	20268693          	addi	a3,a3,514 # ffffffffc0205dc8 <default_pmm_manager+0xcc0>
ffffffffc0203bce:	00001617          	auipc	a2,0x1
ffffffffc0203bd2:	18a60613          	addi	a2,a2,394 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203bd6:	12e00593          	li	a1,302
ffffffffc0203bda:	00002517          	auipc	a0,0x2
ffffffffc0203bde:	03e50513          	addi	a0,a0,62 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203be2:	f10fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203be6:	00002697          	auipc	a3,0x2
ffffffffc0203bea:	1e268693          	addi	a3,a3,482 # ffffffffc0205dc8 <default_pmm_manager+0xcc0>
ffffffffc0203bee:	00001617          	auipc	a2,0x1
ffffffffc0203bf2:	16a60613          	addi	a2,a2,362 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203bf6:	0bd00593          	li	a1,189
ffffffffc0203bfa:	00002517          	auipc	a0,0x2
ffffffffc0203bfe:	01e50513          	addi	a0,a0,30 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203c02:	ef0fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(mm != NULL);
ffffffffc0203c06:	00002697          	auipc	a3,0x2
ffffffffc0203c0a:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0205800 <default_pmm_manager+0x6f8>
ffffffffc0203c0e:	00001617          	auipc	a2,0x1
ffffffffc0203c12:	14a60613          	addi	a2,a2,330 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203c16:	0c700593          	li	a1,199
ffffffffc0203c1a:	00002517          	auipc	a0,0x2
ffffffffc0203c1e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203c22:	ed0fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c26:	00002697          	auipc	a3,0x2
ffffffffc0203c2a:	1a268693          	addi	a3,a3,418 # ffffffffc0205dc8 <default_pmm_manager+0xcc0>
ffffffffc0203c2e:	00001617          	auipc	a2,0x1
ffffffffc0203c32:	12a60613          	addi	a2,a2,298 # ffffffffc0204d58 <commands+0x738>
ffffffffc0203c36:	0fb00593          	li	a1,251
ffffffffc0203c3a:	00002517          	auipc	a0,0x2
ffffffffc0203c3e:	fde50513          	addi	a0,a0,-34 # ffffffffc0205c18 <default_pmm_manager+0xb10>
ffffffffc0203c42:	eb0fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203c46 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203c46:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203c48:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203c4a:	f022                	sd	s0,32(sp)
ffffffffc0203c4c:	ec26                	sd	s1,24(sp)
ffffffffc0203c4e:	f406                	sd	ra,40(sp)
ffffffffc0203c50:	e84a                	sd	s2,16(sp)
ffffffffc0203c52:	8432                	mv	s0,a2
ffffffffc0203c54:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203c56:	8d3ff0ef          	jal	ra,ffffffffc0203528 <find_vma>

    pgfault_num++;
ffffffffc0203c5a:	0000e797          	auipc	a5,0xe
ffffffffc0203c5e:	90e7a783          	lw	a5,-1778(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203c62:	2785                	addiw	a5,a5,1
ffffffffc0203c64:	0000e717          	auipc	a4,0xe
ffffffffc0203c68:	90f72223          	sw	a5,-1788(a4) # ffffffffc0211568 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203c6c:	c159                	beqz	a0,ffffffffc0203cf2 <do_pgfault+0xac>
ffffffffc0203c6e:	651c                	ld	a5,8(a0)
ffffffffc0203c70:	08f46163          	bltu	s0,a5,ffffffffc0203cf2 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203c74:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203c76:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203c78:	8b89                	andi	a5,a5,2
ffffffffc0203c7a:	ebb1                	bnez	a5,ffffffffc0203cce <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203c7c:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203c7e:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203c80:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203c82:	85a2                	mv	a1,s0
ffffffffc0203c84:	4605                	li	a2,1
ffffffffc0203c86:	a37fd0ef          	jal	ra,ffffffffc02016bc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203c8a:	610c                	ld	a1,0(a0)
ffffffffc0203c8c:	c1b9                	beqz	a1,ffffffffc0203cd2 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203c8e:	0000e797          	auipc	a5,0xe
ffffffffc0203c92:	8c27a783          	lw	a5,-1854(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203c96:	c7bd                	beqz	a5,ffffffffc0203d04 <do_pgfault+0xbe>
            //(3) make the page swappable.
            
            
            
            
            swap_in(mm, addr, &page);//分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203c98:	85a2                	mv	a1,s0
ffffffffc0203c9a:	0030                	addi	a2,sp,8
ffffffffc0203c9c:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203c9e:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);//分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203ca0:	c00ff0ef          	jal	ra,ffffffffc02030a0 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);//建立内存页 page 的物理地址和线性地址 addr 之间的映射
ffffffffc0203ca4:	65a2                	ld	a1,8(sp)
ffffffffc0203ca6:	6c88                	ld	a0,24(s1)
ffffffffc0203ca8:	86ca                	mv	a3,s2
ffffffffc0203caa:	8622                	mv	a2,s0
ffffffffc0203cac:	cfbfd0ef          	jal	ra,ffffffffc02019a6 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将页面标记为可交换
ffffffffc0203cb0:	6622                	ld	a2,8(sp)
ffffffffc0203cb2:	4685                	li	a3,1
ffffffffc0203cb4:	85a2                	mv	a1,s0
ffffffffc0203cb6:	8526                	mv	a0,s1
ffffffffc0203cb8:	ac8ff0ef          	jal	ra,ffffffffc0202f80 <swap_map_swappable>
            page->pra_vaddr = addr;//跟踪页面映射的线性地址
ffffffffc0203cbc:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203cbe:	4501                	li	a0,0
            page->pra_vaddr = addr;//跟踪页面映射的线性地址
ffffffffc0203cc0:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203cc2:	70a2                	ld	ra,40(sp)
ffffffffc0203cc4:	7402                	ld	s0,32(sp)
ffffffffc0203cc6:	64e2                	ld	s1,24(sp)
ffffffffc0203cc8:	6942                	ld	s2,16(sp)
ffffffffc0203cca:	6145                	addi	sp,sp,48
ffffffffc0203ccc:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203cce:	4959                	li	s2,22
ffffffffc0203cd0:	b775                	j	ffffffffc0203c7c <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203cd2:	6c88                	ld	a0,24(s1)
ffffffffc0203cd4:	864a                	mv	a2,s2
ffffffffc0203cd6:	85a2                	mv	a1,s0
ffffffffc0203cd8:	9d9fe0ef          	jal	ra,ffffffffc02026b0 <pgdir_alloc_page>
ffffffffc0203cdc:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203cde:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203ce0:	f3ed                	bnez	a5,ffffffffc0203cc2 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203ce2:	00002517          	auipc	a0,0x2
ffffffffc0203ce6:	1de50513          	addi	a0,a0,478 # ffffffffc0205ec0 <default_pmm_manager+0xdb8>
ffffffffc0203cea:	e9efc0ef          	jal	ra,ffffffffc0200388 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203cee:	5571                	li	a0,-4
            goto failed;
ffffffffc0203cf0:	bfc9                	j	ffffffffc0203cc2 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203cf2:	85a2                	mv	a1,s0
ffffffffc0203cf4:	00002517          	auipc	a0,0x2
ffffffffc0203cf8:	19c50513          	addi	a0,a0,412 # ffffffffc0205e90 <default_pmm_manager+0xd88>
ffffffffc0203cfc:	e8cfc0ef          	jal	ra,ffffffffc0200388 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203d00:	5575                	li	a0,-3
        goto failed;
ffffffffc0203d02:	b7c1                	j	ffffffffc0203cc2 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203d04:	00002517          	auipc	a0,0x2
ffffffffc0203d08:	1e450513          	addi	a0,a0,484 # ffffffffc0205ee8 <default_pmm_manager+0xde0>
ffffffffc0203d0c:	e7cfc0ef          	jal	ra,ffffffffc0200388 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d10:	5571                	li	a0,-4
            goto failed;
ffffffffc0203d12:	bf45                	j	ffffffffc0203cc2 <do_pgfault+0x7c>

ffffffffc0203d14 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203d14:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d16:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203d18:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d1a:	f7afc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203d1e:	cd01                	beqz	a0,ffffffffc0203d36 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d20:	4505                	li	a0,1
ffffffffc0203d22:	f78fc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203d26:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d28:	810d                	srli	a0,a0,0x3
ffffffffc0203d2a:	0000e797          	auipc	a5,0xe
ffffffffc0203d2e:	80a7bb23          	sd	a0,-2026(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203d32:	0141                	addi	sp,sp,16
ffffffffc0203d34:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203d36:	00002617          	auipc	a2,0x2
ffffffffc0203d3a:	1da60613          	addi	a2,a2,474 # ffffffffc0205f10 <default_pmm_manager+0xe08>
ffffffffc0203d3e:	45b5                	li	a1,13
ffffffffc0203d40:	00002517          	auipc	a0,0x2
ffffffffc0203d44:	1f050513          	addi	a0,a0,496 # ffffffffc0205f30 <default_pmm_manager+0xe28>
ffffffffc0203d48:	daafc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203d4c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203d4c:	1141                	addi	sp,sp,-16
ffffffffc0203d4e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d50:	00855793          	srli	a5,a0,0x8
ffffffffc0203d54:	c3a5                	beqz	a5,ffffffffc0203db4 <swapfs_read+0x68>
ffffffffc0203d56:	0000d717          	auipc	a4,0xd
ffffffffc0203d5a:	7ea73703          	ld	a4,2026(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203d5e:	04e7fb63          	bgeu	a5,a4,ffffffffc0203db4 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d62:	0000d617          	auipc	a2,0xd
ffffffffc0203d66:	7c663603          	ld	a2,1990(a2) # ffffffffc0211528 <pages>
ffffffffc0203d6a:	8d91                	sub	a1,a1,a2
ffffffffc0203d6c:	4035d613          	srai	a2,a1,0x3
ffffffffc0203d70:	00002597          	auipc	a1,0x2
ffffffffc0203d74:	4405b583          	ld	a1,1088(a1) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0203d78:	02b60633          	mul	a2,a2,a1
ffffffffc0203d7c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d80:	00002797          	auipc	a5,0x2
ffffffffc0203d84:	4387b783          	ld	a5,1080(a5) # ffffffffc02061b8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d88:	0000d717          	auipc	a4,0xd
ffffffffc0203d8c:	79873703          	ld	a4,1944(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d90:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d92:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d96:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d98:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d9a:	02e7f963          	bgeu	a5,a4,ffffffffc0203dcc <swapfs_read+0x80>
}
ffffffffc0203d9e:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203da0:	0000d797          	auipc	a5,0xd
ffffffffc0203da4:	7987b783          	ld	a5,1944(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203da8:	46a1                	li	a3,8
ffffffffc0203daa:	963e                	add	a2,a2,a5
ffffffffc0203dac:	4505                	li	a0,1
}
ffffffffc0203dae:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203db0:	ef0fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203db4:	86aa                	mv	a3,a0
ffffffffc0203db6:	00002617          	auipc	a2,0x2
ffffffffc0203dba:	19260613          	addi	a2,a2,402 # ffffffffc0205f48 <default_pmm_manager+0xe40>
ffffffffc0203dbe:	45d1                	li	a1,20
ffffffffc0203dc0:	00002517          	auipc	a0,0x2
ffffffffc0203dc4:	17050513          	addi	a0,a0,368 # ffffffffc0205f30 <default_pmm_manager+0xe28>
ffffffffc0203dc8:	d2afc0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc0203dcc:	86b2                	mv	a3,a2
ffffffffc0203dce:	06a00593          	li	a1,106
ffffffffc0203dd2:	00001617          	auipc	a2,0x1
ffffffffc0203dd6:	3c660613          	addi	a2,a2,966 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc0203dda:	00001517          	auipc	a0,0x1
ffffffffc0203dde:	38650513          	addi	a0,a0,902 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc0203de2:	d10fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203de6 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203de6:	1141                	addi	sp,sp,-16
ffffffffc0203de8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dea:	00855793          	srli	a5,a0,0x8
ffffffffc0203dee:	c3a5                	beqz	a5,ffffffffc0203e4e <swapfs_write+0x68>
ffffffffc0203df0:	0000d717          	auipc	a4,0xd
ffffffffc0203df4:	75073703          	ld	a4,1872(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203df8:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e4e <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dfc:	0000d617          	auipc	a2,0xd
ffffffffc0203e00:	72c63603          	ld	a2,1836(a2) # ffffffffc0211528 <pages>
ffffffffc0203e04:	8d91                	sub	a1,a1,a2
ffffffffc0203e06:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e0a:	00002597          	auipc	a1,0x2
ffffffffc0203e0e:	3a65b583          	ld	a1,934(a1) # ffffffffc02061b0 <error_string+0x38>
ffffffffc0203e12:	02b60633          	mul	a2,a2,a1
ffffffffc0203e16:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e1a:	00002797          	auipc	a5,0x2
ffffffffc0203e1e:	39e7b783          	ld	a5,926(a5) # ffffffffc02061b8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e22:	0000d717          	auipc	a4,0xd
ffffffffc0203e26:	6fe73703          	ld	a4,1790(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e2a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e2c:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e30:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e32:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e34:	02e7f963          	bgeu	a5,a4,ffffffffc0203e66 <swapfs_write+0x80>
}
ffffffffc0203e38:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e3a:	0000d797          	auipc	a5,0xd
ffffffffc0203e3e:	6fe7b783          	ld	a5,1790(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203e42:	46a1                	li	a3,8
ffffffffc0203e44:	963e                	add	a2,a2,a5
ffffffffc0203e46:	4505                	li	a0,1
}
ffffffffc0203e48:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e4a:	e7afc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203e4e:	86aa                	mv	a3,a0
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	0f860613          	addi	a2,a2,248 # ffffffffc0205f48 <default_pmm_manager+0xe40>
ffffffffc0203e58:	45e5                	li	a1,25
ffffffffc0203e5a:	00002517          	auipc	a0,0x2
ffffffffc0203e5e:	0d650513          	addi	a0,a0,214 # ffffffffc0205f30 <default_pmm_manager+0xe28>
ffffffffc0203e62:	c90fc0ef          	jal	ra,ffffffffc02002f2 <__panic>
ffffffffc0203e66:	86b2                	mv	a3,a2
ffffffffc0203e68:	06a00593          	li	a1,106
ffffffffc0203e6c:	00001617          	auipc	a2,0x1
ffffffffc0203e70:	32c60613          	addi	a2,a2,812 # ffffffffc0205198 <default_pmm_manager+0x90>
ffffffffc0203e74:	00001517          	auipc	a0,0x1
ffffffffc0203e78:	2ec50513          	addi	a0,a0,748 # ffffffffc0205160 <default_pmm_manager+0x58>
ffffffffc0203e7c:	c76fc0ef          	jal	ra,ffffffffc02002f2 <__panic>

ffffffffc0203e80 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e80:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e84:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e86:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e8a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e8c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e90:	f022                	sd	s0,32(sp)
ffffffffc0203e92:	ec26                	sd	s1,24(sp)
ffffffffc0203e94:	e84a                	sd	s2,16(sp)
ffffffffc0203e96:	f406                	sd	ra,40(sp)
ffffffffc0203e98:	e44e                	sd	s3,8(sp)
ffffffffc0203e9a:	84aa                	mv	s1,a0
ffffffffc0203e9c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e9e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203ea2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203ea4:	03067e63          	bgeu	a2,a6,ffffffffc0203ee0 <printnum+0x60>
ffffffffc0203ea8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203eaa:	00805763          	blez	s0,ffffffffc0203eb8 <printnum+0x38>
ffffffffc0203eae:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203eb0:	85ca                	mv	a1,s2
ffffffffc0203eb2:	854e                	mv	a0,s3
ffffffffc0203eb4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203eb6:	fc65                	bnez	s0,ffffffffc0203eae <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203eb8:	1a02                	slli	s4,s4,0x20
ffffffffc0203eba:	00002797          	auipc	a5,0x2
ffffffffc0203ebe:	0ae78793          	addi	a5,a5,174 # ffffffffc0205f68 <default_pmm_manager+0xe60>
ffffffffc0203ec2:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203ec6:	9a3e                	add	s4,s4,a5
}
ffffffffc0203ec8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203eca:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203ece:	70a2                	ld	ra,40(sp)
ffffffffc0203ed0:	69a2                	ld	s3,8(sp)
ffffffffc0203ed2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ed4:	85ca                	mv	a1,s2
ffffffffc0203ed6:	87a6                	mv	a5,s1
}
ffffffffc0203ed8:	6942                	ld	s2,16(sp)
ffffffffc0203eda:	64e2                	ld	s1,24(sp)
ffffffffc0203edc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ede:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203ee0:	03065633          	divu	a2,a2,a6
ffffffffc0203ee4:	8722                	mv	a4,s0
ffffffffc0203ee6:	f9bff0ef          	jal	ra,ffffffffc0203e80 <printnum>
ffffffffc0203eea:	b7f9                	j	ffffffffc0203eb8 <printnum+0x38>

ffffffffc0203eec <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203eec:	7119                	addi	sp,sp,-128
ffffffffc0203eee:	f4a6                	sd	s1,104(sp)
ffffffffc0203ef0:	f0ca                	sd	s2,96(sp)
ffffffffc0203ef2:	ecce                	sd	s3,88(sp)
ffffffffc0203ef4:	e8d2                	sd	s4,80(sp)
ffffffffc0203ef6:	e4d6                	sd	s5,72(sp)
ffffffffc0203ef8:	e0da                	sd	s6,64(sp)
ffffffffc0203efa:	fc5e                	sd	s7,56(sp)
ffffffffc0203efc:	f06a                	sd	s10,32(sp)
ffffffffc0203efe:	fc86                	sd	ra,120(sp)
ffffffffc0203f00:	f8a2                	sd	s0,112(sp)
ffffffffc0203f02:	f862                	sd	s8,48(sp)
ffffffffc0203f04:	f466                	sd	s9,40(sp)
ffffffffc0203f06:	ec6e                	sd	s11,24(sp)
ffffffffc0203f08:	892a                	mv	s2,a0
ffffffffc0203f0a:	84ae                	mv	s1,a1
ffffffffc0203f0c:	8d32                	mv	s10,a2
ffffffffc0203f0e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f10:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203f14:	5b7d                	li	s6,-1
ffffffffc0203f16:	00002a97          	auipc	s5,0x2
ffffffffc0203f1a:	086a8a93          	addi	s5,s5,134 # ffffffffc0205f9c <default_pmm_manager+0xe94>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f1e:	00002b97          	auipc	s7,0x2
ffffffffc0203f22:	25ab8b93          	addi	s7,s7,602 # ffffffffc0206178 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f26:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203f2a:	001d0413          	addi	s0,s10,1
ffffffffc0203f2e:	01350a63          	beq	a0,s3,ffffffffc0203f42 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203f32:	c121                	beqz	a0,ffffffffc0203f72 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203f34:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f36:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f38:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f3a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f3e:	ff351ae3          	bne	a0,s3,ffffffffc0203f32 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f42:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f46:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f4a:	4c81                	li	s9,0
ffffffffc0203f4c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203f4e:	5c7d                	li	s8,-1
ffffffffc0203f50:	5dfd                	li	s11,-1
ffffffffc0203f52:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203f56:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f58:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203f5c:	0ff5f593          	zext.b	a1,a1
ffffffffc0203f60:	00140d13          	addi	s10,s0,1
ffffffffc0203f64:	04b56263          	bltu	a0,a1,ffffffffc0203fa8 <vprintfmt+0xbc>
ffffffffc0203f68:	058a                	slli	a1,a1,0x2
ffffffffc0203f6a:	95d6                	add	a1,a1,s5
ffffffffc0203f6c:	4194                	lw	a3,0(a1)
ffffffffc0203f6e:	96d6                	add	a3,a3,s5
ffffffffc0203f70:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f72:	70e6                	ld	ra,120(sp)
ffffffffc0203f74:	7446                	ld	s0,112(sp)
ffffffffc0203f76:	74a6                	ld	s1,104(sp)
ffffffffc0203f78:	7906                	ld	s2,96(sp)
ffffffffc0203f7a:	69e6                	ld	s3,88(sp)
ffffffffc0203f7c:	6a46                	ld	s4,80(sp)
ffffffffc0203f7e:	6aa6                	ld	s5,72(sp)
ffffffffc0203f80:	6b06                	ld	s6,64(sp)
ffffffffc0203f82:	7be2                	ld	s7,56(sp)
ffffffffc0203f84:	7c42                	ld	s8,48(sp)
ffffffffc0203f86:	7ca2                	ld	s9,40(sp)
ffffffffc0203f88:	7d02                	ld	s10,32(sp)
ffffffffc0203f8a:	6de2                	ld	s11,24(sp)
ffffffffc0203f8c:	6109                	addi	sp,sp,128
ffffffffc0203f8e:	8082                	ret
            padc = '0';
ffffffffc0203f90:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203f92:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f96:	846a                	mv	s0,s10
ffffffffc0203f98:	00140d13          	addi	s10,s0,1
ffffffffc0203f9c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203fa0:	0ff5f593          	zext.b	a1,a1
ffffffffc0203fa4:	fcb572e3          	bgeu	a0,a1,ffffffffc0203f68 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203fa8:	85a6                	mv	a1,s1
ffffffffc0203faa:	02500513          	li	a0,37
ffffffffc0203fae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203fb0:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fb4:	8d22                	mv	s10,s0
ffffffffc0203fb6:	f73788e3          	beq	a5,s3,ffffffffc0203f26 <vprintfmt+0x3a>
ffffffffc0203fba:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203fbe:	1d7d                	addi	s10,s10,-1
ffffffffc0203fc0:	ff379de3          	bne	a5,s3,ffffffffc0203fba <vprintfmt+0xce>
ffffffffc0203fc4:	b78d                	j	ffffffffc0203f26 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203fc6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203fca:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fce:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203fd0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203fd4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203fd8:	02d86463          	bltu	a6,a3,ffffffffc0204000 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203fdc:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203fe0:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203fe4:	0186873b          	addw	a4,a3,s8
ffffffffc0203fe8:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203fec:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203fee:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203ff2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203ff4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203ff8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203ffc:	fed870e3          	bgeu	a6,a3,ffffffffc0203fdc <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204000:	f40ddce3          	bgez	s11,ffffffffc0203f58 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204004:	8de2                	mv	s11,s8
ffffffffc0204006:	5c7d                	li	s8,-1
ffffffffc0204008:	bf81                	j	ffffffffc0203f58 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020400a:	fffdc693          	not	a3,s11
ffffffffc020400e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204010:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204014:	00144603          	lbu	a2,1(s0)
ffffffffc0204018:	2d81                	sext.w	s11,s11
ffffffffc020401a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020401c:	bf35                	j	ffffffffc0203f58 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020401e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204022:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204026:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204028:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020402a:	bfd9                	j	ffffffffc0204000 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020402c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020402e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204032:	01174463          	blt	a4,a7,ffffffffc020403a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204036:	1a088e63          	beqz	a7,ffffffffc02041f2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020403a:	000a3603          	ld	a2,0(s4)
ffffffffc020403e:	46c1                	li	a3,16
ffffffffc0204040:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204042:	2781                	sext.w	a5,a5
ffffffffc0204044:	876e                	mv	a4,s11
ffffffffc0204046:	85a6                	mv	a1,s1
ffffffffc0204048:	854a                	mv	a0,s2
ffffffffc020404a:	e37ff0ef          	jal	ra,ffffffffc0203e80 <printnum>
            break;
ffffffffc020404e:	bde1                	j	ffffffffc0203f26 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204050:	000a2503          	lw	a0,0(s4)
ffffffffc0204054:	85a6                	mv	a1,s1
ffffffffc0204056:	0a21                	addi	s4,s4,8
ffffffffc0204058:	9902                	jalr	s2
            break;
ffffffffc020405a:	b5f1                	j	ffffffffc0203f26 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020405c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020405e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204062:	01174463          	blt	a4,a7,ffffffffc020406a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204066:	18088163          	beqz	a7,ffffffffc02041e8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020406a:	000a3603          	ld	a2,0(s4)
ffffffffc020406e:	46a9                	li	a3,10
ffffffffc0204070:	8a2e                	mv	s4,a1
ffffffffc0204072:	bfc1                	j	ffffffffc0204042 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204074:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204078:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020407a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020407c:	bdf1                	j	ffffffffc0203f58 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020407e:	85a6                	mv	a1,s1
ffffffffc0204080:	02500513          	li	a0,37
ffffffffc0204084:	9902                	jalr	s2
            break;
ffffffffc0204086:	b545                	j	ffffffffc0203f26 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204088:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020408c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020408e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204090:	b5e1                	j	ffffffffc0203f58 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204092:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204094:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204098:	01174463          	blt	a4,a7,ffffffffc02040a0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020409c:	14088163          	beqz	a7,ffffffffc02041de <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02040a0:	000a3603          	ld	a2,0(s4)
ffffffffc02040a4:	46a1                	li	a3,8
ffffffffc02040a6:	8a2e                	mv	s4,a1
ffffffffc02040a8:	bf69                	j	ffffffffc0204042 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02040aa:	03000513          	li	a0,48
ffffffffc02040ae:	85a6                	mv	a1,s1
ffffffffc02040b0:	e03e                	sd	a5,0(sp)
ffffffffc02040b2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02040b4:	85a6                	mv	a1,s1
ffffffffc02040b6:	07800513          	li	a0,120
ffffffffc02040ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02040bc:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02040be:	6782                	ld	a5,0(sp)
ffffffffc02040c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02040c2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02040c6:	bfb5                	j	ffffffffc0204042 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02040c8:	000a3403          	ld	s0,0(s4)
ffffffffc02040cc:	008a0713          	addi	a4,s4,8
ffffffffc02040d0:	e03a                	sd	a4,0(sp)
ffffffffc02040d2:	14040263          	beqz	s0,ffffffffc0204216 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02040d6:	0fb05763          	blez	s11,ffffffffc02041c4 <vprintfmt+0x2d8>
ffffffffc02040da:	02d00693          	li	a3,45
ffffffffc02040de:	0cd79163          	bne	a5,a3,ffffffffc02041a0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02040e2:	00044783          	lbu	a5,0(s0)
ffffffffc02040e6:	0007851b          	sext.w	a0,a5
ffffffffc02040ea:	cf85                	beqz	a5,ffffffffc0204122 <vprintfmt+0x236>
ffffffffc02040ec:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02040f0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02040f4:	000c4563          	bltz	s8,ffffffffc02040fe <vprintfmt+0x212>
ffffffffc02040f8:	3c7d                	addiw	s8,s8,-1
ffffffffc02040fa:	036c0263          	beq	s8,s6,ffffffffc020411e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02040fe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204100:	0e0c8e63          	beqz	s9,ffffffffc02041fc <vprintfmt+0x310>
ffffffffc0204104:	3781                	addiw	a5,a5,-32
ffffffffc0204106:	0ef47b63          	bgeu	s0,a5,ffffffffc02041fc <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020410a:	03f00513          	li	a0,63
ffffffffc020410e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204110:	000a4783          	lbu	a5,0(s4)
ffffffffc0204114:	3dfd                	addiw	s11,s11,-1
ffffffffc0204116:	0a05                	addi	s4,s4,1
ffffffffc0204118:	0007851b          	sext.w	a0,a5
ffffffffc020411c:	ffe1                	bnez	a5,ffffffffc02040f4 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020411e:	01b05963          	blez	s11,ffffffffc0204130 <vprintfmt+0x244>
ffffffffc0204122:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204124:	85a6                	mv	a1,s1
ffffffffc0204126:	02000513          	li	a0,32
ffffffffc020412a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020412c:	fe0d9be3          	bnez	s11,ffffffffc0204122 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204130:	6a02                	ld	s4,0(sp)
ffffffffc0204132:	bbd5                	j	ffffffffc0203f26 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204134:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204136:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020413a:	01174463          	blt	a4,a7,ffffffffc0204142 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020413e:	08088d63          	beqz	a7,ffffffffc02041d8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204142:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204146:	0a044d63          	bltz	s0,ffffffffc0204200 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020414a:	8622                	mv	a2,s0
ffffffffc020414c:	8a66                	mv	s4,s9
ffffffffc020414e:	46a9                	li	a3,10
ffffffffc0204150:	bdcd                	j	ffffffffc0204042 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204152:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204156:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204158:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020415a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020415e:	8fb5                	xor	a5,a5,a3
ffffffffc0204160:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204164:	02d74163          	blt	a4,a3,ffffffffc0204186 <vprintfmt+0x29a>
ffffffffc0204168:	00369793          	slli	a5,a3,0x3
ffffffffc020416c:	97de                	add	a5,a5,s7
ffffffffc020416e:	639c                	ld	a5,0(a5)
ffffffffc0204170:	cb99                	beqz	a5,ffffffffc0204186 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204172:	86be                	mv	a3,a5
ffffffffc0204174:	00002617          	auipc	a2,0x2
ffffffffc0204178:	e2460613          	addi	a2,a2,-476 # ffffffffc0205f98 <default_pmm_manager+0xe90>
ffffffffc020417c:	85a6                	mv	a1,s1
ffffffffc020417e:	854a                	mv	a0,s2
ffffffffc0204180:	0ce000ef          	jal	ra,ffffffffc020424e <printfmt>
ffffffffc0204184:	b34d                	j	ffffffffc0203f26 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204186:	00002617          	auipc	a2,0x2
ffffffffc020418a:	e0260613          	addi	a2,a2,-510 # ffffffffc0205f88 <default_pmm_manager+0xe80>
ffffffffc020418e:	85a6                	mv	a1,s1
ffffffffc0204190:	854a                	mv	a0,s2
ffffffffc0204192:	0bc000ef          	jal	ra,ffffffffc020424e <printfmt>
ffffffffc0204196:	bb41                	j	ffffffffc0203f26 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204198:	00002417          	auipc	s0,0x2
ffffffffc020419c:	de840413          	addi	s0,s0,-536 # ffffffffc0205f80 <default_pmm_manager+0xe78>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041a0:	85e2                	mv	a1,s8
ffffffffc02041a2:	8522                	mv	a0,s0
ffffffffc02041a4:	e43e                	sd	a5,8(sp)
ffffffffc02041a6:	196000ef          	jal	ra,ffffffffc020433c <strnlen>
ffffffffc02041aa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041ae:	01b05b63          	blez	s11,ffffffffc02041c4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02041b2:	67a2                	ld	a5,8(sp)
ffffffffc02041b4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041b8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02041ba:	85a6                	mv	a1,s1
ffffffffc02041bc:	8552                	mv	a0,s4
ffffffffc02041be:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041c0:	fe0d9ce3          	bnez	s11,ffffffffc02041b8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041c4:	00044783          	lbu	a5,0(s0)
ffffffffc02041c8:	00140a13          	addi	s4,s0,1
ffffffffc02041cc:	0007851b          	sext.w	a0,a5
ffffffffc02041d0:	d3a5                	beqz	a5,ffffffffc0204130 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041d2:	05e00413          	li	s0,94
ffffffffc02041d6:	bf39                	j	ffffffffc02040f4 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02041d8:	000a2403          	lw	s0,0(s4)
ffffffffc02041dc:	b7ad                	j	ffffffffc0204146 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02041de:	000a6603          	lwu	a2,0(s4)
ffffffffc02041e2:	46a1                	li	a3,8
ffffffffc02041e4:	8a2e                	mv	s4,a1
ffffffffc02041e6:	bdb1                	j	ffffffffc0204042 <vprintfmt+0x156>
ffffffffc02041e8:	000a6603          	lwu	a2,0(s4)
ffffffffc02041ec:	46a9                	li	a3,10
ffffffffc02041ee:	8a2e                	mv	s4,a1
ffffffffc02041f0:	bd89                	j	ffffffffc0204042 <vprintfmt+0x156>
ffffffffc02041f2:	000a6603          	lwu	a2,0(s4)
ffffffffc02041f6:	46c1                	li	a3,16
ffffffffc02041f8:	8a2e                	mv	s4,a1
ffffffffc02041fa:	b5a1                	j	ffffffffc0204042 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02041fc:	9902                	jalr	s2
ffffffffc02041fe:	bf09                	j	ffffffffc0204110 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204200:	85a6                	mv	a1,s1
ffffffffc0204202:	02d00513          	li	a0,45
ffffffffc0204206:	e03e                	sd	a5,0(sp)
ffffffffc0204208:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020420a:	6782                	ld	a5,0(sp)
ffffffffc020420c:	8a66                	mv	s4,s9
ffffffffc020420e:	40800633          	neg	a2,s0
ffffffffc0204212:	46a9                	li	a3,10
ffffffffc0204214:	b53d                	j	ffffffffc0204042 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204216:	03b05163          	blez	s11,ffffffffc0204238 <vprintfmt+0x34c>
ffffffffc020421a:	02d00693          	li	a3,45
ffffffffc020421e:	f6d79de3          	bne	a5,a3,ffffffffc0204198 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204222:	00002417          	auipc	s0,0x2
ffffffffc0204226:	d5e40413          	addi	s0,s0,-674 # ffffffffc0205f80 <default_pmm_manager+0xe78>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020422a:	02800793          	li	a5,40
ffffffffc020422e:	02800513          	li	a0,40
ffffffffc0204232:	00140a13          	addi	s4,s0,1
ffffffffc0204236:	bd6d                	j	ffffffffc02040f0 <vprintfmt+0x204>
ffffffffc0204238:	00002a17          	auipc	s4,0x2
ffffffffc020423c:	d49a0a13          	addi	s4,s4,-695 # ffffffffc0205f81 <default_pmm_manager+0xe79>
ffffffffc0204240:	02800513          	li	a0,40
ffffffffc0204244:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204248:	05e00413          	li	s0,94
ffffffffc020424c:	b565                	j	ffffffffc02040f4 <vprintfmt+0x208>

ffffffffc020424e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020424e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204250:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204254:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204256:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204258:	ec06                	sd	ra,24(sp)
ffffffffc020425a:	f83a                	sd	a4,48(sp)
ffffffffc020425c:	fc3e                	sd	a5,56(sp)
ffffffffc020425e:	e0c2                	sd	a6,64(sp)
ffffffffc0204260:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204262:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204264:	c89ff0ef          	jal	ra,ffffffffc0203eec <vprintfmt>
}
ffffffffc0204268:	60e2                	ld	ra,24(sp)
ffffffffc020426a:	6161                	addi	sp,sp,80
ffffffffc020426c:	8082                	ret

ffffffffc020426e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020426e:	715d                	addi	sp,sp,-80
ffffffffc0204270:	e486                	sd	ra,72(sp)
ffffffffc0204272:	e0a6                	sd	s1,64(sp)
ffffffffc0204274:	fc4a                	sd	s2,56(sp)
ffffffffc0204276:	f84e                	sd	s3,48(sp)
ffffffffc0204278:	f452                	sd	s4,40(sp)
ffffffffc020427a:	f056                	sd	s5,32(sp)
ffffffffc020427c:	ec5a                	sd	s6,24(sp)
ffffffffc020427e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204280:	c901                	beqz	a0,ffffffffc0204290 <readline+0x22>
ffffffffc0204282:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204284:	00002517          	auipc	a0,0x2
ffffffffc0204288:	d1450513          	addi	a0,a0,-748 # ffffffffc0205f98 <default_pmm_manager+0xe90>
ffffffffc020428c:	8fcfc0ef          	jal	ra,ffffffffc0200388 <cprintf>
readline(const char *prompt) {
ffffffffc0204290:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204292:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204294:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204296:	4aa9                	li	s5,10
ffffffffc0204298:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020429a:	0000db97          	auipc	s7,0xd
ffffffffc020429e:	e5eb8b93          	addi	s7,s7,-418 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042a2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02042a6:	91afc0ef          	jal	ra,ffffffffc02003c0 <getchar>
        if (c < 0) {
ffffffffc02042aa:	00054a63          	bltz	a0,ffffffffc02042be <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042ae:	00a95a63          	bge	s2,a0,ffffffffc02042c2 <readline+0x54>
ffffffffc02042b2:	029a5263          	bge	s4,s1,ffffffffc02042d6 <readline+0x68>
        c = getchar();
ffffffffc02042b6:	90afc0ef          	jal	ra,ffffffffc02003c0 <getchar>
        if (c < 0) {
ffffffffc02042ba:	fe055ae3          	bgez	a0,ffffffffc02042ae <readline+0x40>
            return NULL;
ffffffffc02042be:	4501                	li	a0,0
ffffffffc02042c0:	a091                	j	ffffffffc0204304 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02042c2:	03351463          	bne	a0,s3,ffffffffc02042ea <readline+0x7c>
ffffffffc02042c6:	e8a9                	bnez	s1,ffffffffc0204318 <readline+0xaa>
        c = getchar();
ffffffffc02042c8:	8f8fc0ef          	jal	ra,ffffffffc02003c0 <getchar>
        if (c < 0) {
ffffffffc02042cc:	fe0549e3          	bltz	a0,ffffffffc02042be <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042d0:	fea959e3          	bge	s2,a0,ffffffffc02042c2 <readline+0x54>
ffffffffc02042d4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02042d6:	e42a                	sd	a0,8(sp)
ffffffffc02042d8:	8e6fc0ef          	jal	ra,ffffffffc02003be <cputchar>
            buf[i ++] = c;
ffffffffc02042dc:	6522                	ld	a0,8(sp)
ffffffffc02042de:	009b87b3          	add	a5,s7,s1
ffffffffc02042e2:	2485                	addiw	s1,s1,1
ffffffffc02042e4:	00a78023          	sb	a0,0(a5)
ffffffffc02042e8:	bf7d                	j	ffffffffc02042a6 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02042ea:	01550463          	beq	a0,s5,ffffffffc02042f2 <readline+0x84>
ffffffffc02042ee:	fb651ce3          	bne	a0,s6,ffffffffc02042a6 <readline+0x38>
            cputchar(c);
ffffffffc02042f2:	8ccfc0ef          	jal	ra,ffffffffc02003be <cputchar>
            buf[i] = '\0';
ffffffffc02042f6:	0000d517          	auipc	a0,0xd
ffffffffc02042fa:	e0250513          	addi	a0,a0,-510 # ffffffffc02110f8 <buf>
ffffffffc02042fe:	94aa                	add	s1,s1,a0
ffffffffc0204300:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204304:	60a6                	ld	ra,72(sp)
ffffffffc0204306:	6486                	ld	s1,64(sp)
ffffffffc0204308:	7962                	ld	s2,56(sp)
ffffffffc020430a:	79c2                	ld	s3,48(sp)
ffffffffc020430c:	7a22                	ld	s4,40(sp)
ffffffffc020430e:	7a82                	ld	s5,32(sp)
ffffffffc0204310:	6b62                	ld	s6,24(sp)
ffffffffc0204312:	6bc2                	ld	s7,16(sp)
ffffffffc0204314:	6161                	addi	sp,sp,80
ffffffffc0204316:	8082                	ret
            cputchar(c);
ffffffffc0204318:	4521                	li	a0,8
ffffffffc020431a:	8a4fc0ef          	jal	ra,ffffffffc02003be <cputchar>
            i --;
ffffffffc020431e:	34fd                	addiw	s1,s1,-1
ffffffffc0204320:	b759                	j	ffffffffc02042a6 <readline+0x38>

ffffffffc0204322 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204322:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204326:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204328:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020432a:	cb81                	beqz	a5,ffffffffc020433a <strlen+0x18>
        cnt ++;
ffffffffc020432c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020432e:	00a707b3          	add	a5,a4,a0
ffffffffc0204332:	0007c783          	lbu	a5,0(a5)
ffffffffc0204336:	fbfd                	bnez	a5,ffffffffc020432c <strlen+0xa>
ffffffffc0204338:	8082                	ret
    }
    return cnt;
}
ffffffffc020433a:	8082                	ret

ffffffffc020433c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020433c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020433e:	e589                	bnez	a1,ffffffffc0204348 <strnlen+0xc>
ffffffffc0204340:	a811                	j	ffffffffc0204354 <strnlen+0x18>
        cnt ++;
ffffffffc0204342:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204344:	00f58863          	beq	a1,a5,ffffffffc0204354 <strnlen+0x18>
ffffffffc0204348:	00f50733          	add	a4,a0,a5
ffffffffc020434c:	00074703          	lbu	a4,0(a4)
ffffffffc0204350:	fb6d                	bnez	a4,ffffffffc0204342 <strnlen+0x6>
ffffffffc0204352:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204354:	852e                	mv	a0,a1
ffffffffc0204356:	8082                	ret

ffffffffc0204358 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204358:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020435a:	0005c703          	lbu	a4,0(a1)
ffffffffc020435e:	0785                	addi	a5,a5,1
ffffffffc0204360:	0585                	addi	a1,a1,1
ffffffffc0204362:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204366:	fb75                	bnez	a4,ffffffffc020435a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204368:	8082                	ret

ffffffffc020436a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020436a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020436e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204372:	cb89                	beqz	a5,ffffffffc0204384 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204374:	0505                	addi	a0,a0,1
ffffffffc0204376:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204378:	fee789e3          	beq	a5,a4,ffffffffc020436a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020437c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204380:	9d19                	subw	a0,a0,a4
ffffffffc0204382:	8082                	ret
ffffffffc0204384:	4501                	li	a0,0
ffffffffc0204386:	bfed                	j	ffffffffc0204380 <strcmp+0x16>

ffffffffc0204388 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204388:	00054783          	lbu	a5,0(a0)
ffffffffc020438c:	c799                	beqz	a5,ffffffffc020439a <strchr+0x12>
        if (*s == c) {
ffffffffc020438e:	00f58763          	beq	a1,a5,ffffffffc020439c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204392:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204396:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204398:	fbfd                	bnez	a5,ffffffffc020438e <strchr+0x6>
    }
    return NULL;
ffffffffc020439a:	4501                	li	a0,0
}
ffffffffc020439c:	8082                	ret

ffffffffc020439e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020439e:	ca01                	beqz	a2,ffffffffc02043ae <memset+0x10>
ffffffffc02043a0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02043a2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02043a4:	0785                	addi	a5,a5,1
ffffffffc02043a6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02043aa:	fec79de3          	bne	a5,a2,ffffffffc02043a4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02043ae:	8082                	ret

ffffffffc02043b0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02043b0:	ca19                	beqz	a2,ffffffffc02043c6 <memcpy+0x16>
ffffffffc02043b2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02043b4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02043b6:	0005c703          	lbu	a4,0(a1)
ffffffffc02043ba:	0585                	addi	a1,a1,1
ffffffffc02043bc:	0785                	addi	a5,a5,1
ffffffffc02043be:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02043c2:	fec59ae3          	bne	a1,a2,ffffffffc02043b6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02043c6:	8082                	ret

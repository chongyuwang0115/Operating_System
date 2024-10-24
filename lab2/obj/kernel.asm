
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	14f010ef          	jal	ra,ffffffffc0201998 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(NKUs.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	95e50513          	addi	a0,a0,-1698 # ffffffffc02019b0 <etext+0x6>
ffffffffc020005a:	35e000ef          	jal	ra,ffffffffc02003b8 <cputs>

    print_kerninfo();
ffffffffc020005e:	01a000ef          	jal	ra,ffffffffc0200078 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	25c010ef          	jal	ra,ffffffffc02012c2 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020007a:	00002517          	auipc	a0,0x2
ffffffffc020007e:	95650513          	addi	a0,a0,-1706 # ffffffffc02019d0 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200082:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200084:	2fc000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200088:	00000597          	auipc	a1,0x0
ffffffffc020008c:	faa58593          	addi	a1,a1,-86 # ffffffffc0200032 <kern_init>
ffffffffc0200090:	00002517          	auipc	a0,0x2
ffffffffc0200094:	96050513          	addi	a0,a0,-1696 # ffffffffc02019f0 <etext+0x46>
ffffffffc0200098:	2e8000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020009c:	00002597          	auipc	a1,0x2
ffffffffc02000a0:	90e58593          	addi	a1,a1,-1778 # ffffffffc02019aa <etext>
ffffffffc02000a4:	00002517          	auipc	a0,0x2
ffffffffc02000a8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201a10 <etext+0x66>
ffffffffc02000ac:	2d4000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02000b0:	00006597          	auipc	a1,0x6
ffffffffc02000b4:	f6058593          	addi	a1,a1,-160 # ffffffffc0206010 <free_area>
ffffffffc02000b8:	00002517          	auipc	a0,0x2
ffffffffc02000bc:	97850513          	addi	a0,a0,-1672 # ffffffffc0201a30 <etext+0x86>
ffffffffc02000c0:	2c0000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02000c4:	00006597          	auipc	a1,0x6
ffffffffc02000c8:	3ac58593          	addi	a1,a1,940 # ffffffffc0206470 <end>
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	98450513          	addi	a0,a0,-1660 # ffffffffc0201a50 <etext+0xa6>
ffffffffc02000d4:	2ac000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02000d8:	00006597          	auipc	a1,0x6
ffffffffc02000dc:	79758593          	addi	a1,a1,1943 # ffffffffc020686f <end+0x3ff>
ffffffffc02000e0:	00000797          	auipc	a5,0x0
ffffffffc02000e4:	f5278793          	addi	a5,a5,-174 # ffffffffc0200032 <kern_init>
ffffffffc02000e8:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000ec:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000f0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000f2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000f6:	95be                	add	a1,a1,a5
ffffffffc02000f8:	85a9                	srai	a1,a1,0xa
ffffffffc02000fa:	00002517          	auipc	a0,0x2
ffffffffc02000fe:	97650513          	addi	a0,a0,-1674 # ffffffffc0201a70 <etext+0xc6>
}
ffffffffc0200102:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200104:	acb5                	j	ffffffffc0200380 <cprintf>

ffffffffc0200106 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200108:	00002617          	auipc	a2,0x2
ffffffffc020010c:	99860613          	addi	a2,a2,-1640 # ffffffffc0201aa0 <etext+0xf6>
ffffffffc0200110:	04e00593          	li	a1,78
ffffffffc0200114:	00002517          	auipc	a0,0x2
ffffffffc0200118:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201ab8 <etext+0x10e>
void print_stackframe(void) {
ffffffffc020011c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020011e:	1cc000ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0200122 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200122:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200124:	00002617          	auipc	a2,0x2
ffffffffc0200128:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0201ad0 <etext+0x126>
ffffffffc020012c:	00002597          	auipc	a1,0x2
ffffffffc0200130:	9c458593          	addi	a1,a1,-1596 # ffffffffc0201af0 <etext+0x146>
ffffffffc0200134:	00002517          	auipc	a0,0x2
ffffffffc0200138:	9c450513          	addi	a0,a0,-1596 # ffffffffc0201af8 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020013c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020013e:	242000ef          	jal	ra,ffffffffc0200380 <cprintf>
ffffffffc0200142:	00002617          	auipc	a2,0x2
ffffffffc0200146:	9c660613          	addi	a2,a2,-1594 # ffffffffc0201b08 <etext+0x15e>
ffffffffc020014a:	00002597          	auipc	a1,0x2
ffffffffc020014e:	9e658593          	addi	a1,a1,-1562 # ffffffffc0201b30 <etext+0x186>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	9a650513          	addi	a0,a0,-1626 # ffffffffc0201af8 <etext+0x14e>
ffffffffc020015a:	226000ef          	jal	ra,ffffffffc0200380 <cprintf>
ffffffffc020015e:	00002617          	auipc	a2,0x2
ffffffffc0200162:	9e260613          	addi	a2,a2,-1566 # ffffffffc0201b40 <etext+0x196>
ffffffffc0200166:	00002597          	auipc	a1,0x2
ffffffffc020016a:	9fa58593          	addi	a1,a1,-1542 # ffffffffc0201b60 <etext+0x1b6>
ffffffffc020016e:	00002517          	auipc	a0,0x2
ffffffffc0200172:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201af8 <etext+0x14e>
ffffffffc0200176:	20a000ef          	jal	ra,ffffffffc0200380 <cprintf>
    }
    return 0;
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
ffffffffc020017c:	4501                	li	a0,0
ffffffffc020017e:	0141                	addi	sp,sp,16
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200182:	1141                	addi	sp,sp,-16
ffffffffc0200184:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200186:	ef3ff0ef          	jal	ra,ffffffffc0200078 <print_kerninfo>
    return 0;
}
ffffffffc020018a:	60a2                	ld	ra,8(sp)
ffffffffc020018c:	4501                	li	a0,0
ffffffffc020018e:	0141                	addi	sp,sp,16
ffffffffc0200190:	8082                	ret

ffffffffc0200192 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200192:	1141                	addi	sp,sp,-16
ffffffffc0200194:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200196:	f71ff0ef          	jal	ra,ffffffffc0200106 <print_stackframe>
    return 0;
}
ffffffffc020019a:	60a2                	ld	ra,8(sp)
ffffffffc020019c:	4501                	li	a0,0
ffffffffc020019e:	0141                	addi	sp,sp,16
ffffffffc02001a0:	8082                	ret

ffffffffc02001a2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02001a2:	7115                	addi	sp,sp,-224
ffffffffc02001a4:	ed5e                	sd	s7,152(sp)
ffffffffc02001a6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001a8:	00002517          	auipc	a0,0x2
ffffffffc02001ac:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201b70 <etext+0x1c6>
kmonitor(struct trapframe *tf) {
ffffffffc02001b0:	ed86                	sd	ra,216(sp)
ffffffffc02001b2:	e9a2                	sd	s0,208(sp)
ffffffffc02001b4:	e5a6                	sd	s1,200(sp)
ffffffffc02001b6:	e1ca                	sd	s2,192(sp)
ffffffffc02001b8:	fd4e                	sd	s3,184(sp)
ffffffffc02001ba:	f952                	sd	s4,176(sp)
ffffffffc02001bc:	f556                	sd	s5,168(sp)
ffffffffc02001be:	f15a                	sd	s6,160(sp)
ffffffffc02001c0:	e962                	sd	s8,144(sp)
ffffffffc02001c2:	e566                	sd	s9,136(sp)
ffffffffc02001c4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001c6:	1ba000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0201b98 <etext+0x1ee>
ffffffffc02001d2:	1ae000ef          	jal	ra,ffffffffc0200380 <cprintf>
    if (tf != NULL) {
ffffffffc02001d6:	000b8563          	beqz	s7,ffffffffc02001e0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02001da:	855e                	mv	a0,s7
ffffffffc02001dc:	466000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02001e0:	00002c17          	auipc	s8,0x2
ffffffffc02001e4:	a28c0c13          	addi	s8,s8,-1496 # ffffffffc0201c08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02001e8:	00002917          	auipc	s2,0x2
ffffffffc02001ec:	9d890913          	addi	s2,s2,-1576 # ffffffffc0201bc0 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02001f0:	00002497          	auipc	s1,0x2
ffffffffc02001f4:	9d848493          	addi	s1,s1,-1576 # ffffffffc0201bc8 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02001f8:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02001fa:	00002b17          	auipc	s6,0x2
ffffffffc02001fe:	9d6b0b13          	addi	s6,s6,-1578 # ffffffffc0201bd0 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc0200202:	00002a17          	auipc	s4,0x2
ffffffffc0200206:	8eea0a13          	addi	s4,s4,-1810 # ffffffffc0201af0 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020020a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020020c:	854a                	mv	a0,s2
ffffffffc020020e:	636010ef          	jal	ra,ffffffffc0201844 <readline>
ffffffffc0200212:	842a                	mv	s0,a0
ffffffffc0200214:	dd65                	beqz	a0,ffffffffc020020c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200216:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020021a:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020021c:	e1bd                	bnez	a1,ffffffffc0200282 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020021e:	fe0c87e3          	beqz	s9,ffffffffc020020c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200222:	6582                	ld	a1,0(sp)
ffffffffc0200224:	00002d17          	auipc	s10,0x2
ffffffffc0200228:	9e4d0d13          	addi	s10,s10,-1564 # ffffffffc0201c08 <commands>
        argv[argc ++] = buf;
ffffffffc020022c:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020022e:	4401                	li	s0,0
ffffffffc0200230:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200232:	732010ef          	jal	ra,ffffffffc0201964 <strcmp>
ffffffffc0200236:	c919                	beqz	a0,ffffffffc020024c <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200238:	2405                	addiw	s0,s0,1
ffffffffc020023a:	0b540063          	beq	s0,s5,ffffffffc02002da <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020023e:	000d3503          	ld	a0,0(s10)
ffffffffc0200242:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200244:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200246:	71e010ef          	jal	ra,ffffffffc0201964 <strcmp>
ffffffffc020024a:	f57d                	bnez	a0,ffffffffc0200238 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020024c:	00141793          	slli	a5,s0,0x1
ffffffffc0200250:	97a2                	add	a5,a5,s0
ffffffffc0200252:	078e                	slli	a5,a5,0x3
ffffffffc0200254:	97e2                	add	a5,a5,s8
ffffffffc0200256:	6b9c                	ld	a5,16(a5)
ffffffffc0200258:	865e                	mv	a2,s7
ffffffffc020025a:	002c                	addi	a1,sp,8
ffffffffc020025c:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200260:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200262:	fa0555e3          	bgez	a0,ffffffffc020020c <kmonitor+0x6a>
}
ffffffffc0200266:	60ee                	ld	ra,216(sp)
ffffffffc0200268:	644e                	ld	s0,208(sp)
ffffffffc020026a:	64ae                	ld	s1,200(sp)
ffffffffc020026c:	690e                	ld	s2,192(sp)
ffffffffc020026e:	79ea                	ld	s3,184(sp)
ffffffffc0200270:	7a4a                	ld	s4,176(sp)
ffffffffc0200272:	7aaa                	ld	s5,168(sp)
ffffffffc0200274:	7b0a                	ld	s6,160(sp)
ffffffffc0200276:	6bea                	ld	s7,152(sp)
ffffffffc0200278:	6c4a                	ld	s8,144(sp)
ffffffffc020027a:	6caa                	ld	s9,136(sp)
ffffffffc020027c:	6d0a                	ld	s10,128(sp)
ffffffffc020027e:	612d                	addi	sp,sp,224
ffffffffc0200280:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200282:	8526                	mv	a0,s1
ffffffffc0200284:	6fe010ef          	jal	ra,ffffffffc0201982 <strchr>
ffffffffc0200288:	c901                	beqz	a0,ffffffffc0200298 <kmonitor+0xf6>
ffffffffc020028a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020028e:	00040023          	sb	zero,0(s0)
ffffffffc0200292:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200294:	d5c9                	beqz	a1,ffffffffc020021e <kmonitor+0x7c>
ffffffffc0200296:	b7f5                	j	ffffffffc0200282 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200298:	00044783          	lbu	a5,0(s0)
ffffffffc020029c:	d3c9                	beqz	a5,ffffffffc020021e <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020029e:	033c8963          	beq	s9,s3,ffffffffc02002d0 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02002a2:	003c9793          	slli	a5,s9,0x3
ffffffffc02002a6:	0118                	addi	a4,sp,128
ffffffffc02002a8:	97ba                	add	a5,a5,a4
ffffffffc02002aa:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002ae:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02002b2:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002b4:	e591                	bnez	a1,ffffffffc02002c0 <kmonitor+0x11e>
ffffffffc02002b6:	b7b5                	j	ffffffffc0200222 <kmonitor+0x80>
ffffffffc02002b8:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02002bc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002be:	d1a5                	beqz	a1,ffffffffc020021e <kmonitor+0x7c>
ffffffffc02002c0:	8526                	mv	a0,s1
ffffffffc02002c2:	6c0010ef          	jal	ra,ffffffffc0201982 <strchr>
ffffffffc02002c6:	d96d                	beqz	a0,ffffffffc02002b8 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c8:	00044583          	lbu	a1,0(s0)
ffffffffc02002cc:	d9a9                	beqz	a1,ffffffffc020021e <kmonitor+0x7c>
ffffffffc02002ce:	bf55                	j	ffffffffc0200282 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002d0:	45c1                	li	a1,16
ffffffffc02002d2:	855a                	mv	a0,s6
ffffffffc02002d4:	0ac000ef          	jal	ra,ffffffffc0200380 <cprintf>
ffffffffc02002d8:	b7e9                	j	ffffffffc02002a2 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002da:	6582                	ld	a1,0(sp)
ffffffffc02002dc:	00002517          	auipc	a0,0x2
ffffffffc02002e0:	91450513          	addi	a0,a0,-1772 # ffffffffc0201bf0 <etext+0x246>
ffffffffc02002e4:	09c000ef          	jal	ra,ffffffffc0200380 <cprintf>
    return 0;
ffffffffc02002e8:	b715                	j	ffffffffc020020c <kmonitor+0x6a>

ffffffffc02002ea <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02002ea:	00006317          	auipc	t1,0x6
ffffffffc02002ee:	13e30313          	addi	t1,t1,318 # ffffffffc0206428 <is_panic>
ffffffffc02002f2:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02002f6:	715d                	addi	sp,sp,-80
ffffffffc02002f8:	ec06                	sd	ra,24(sp)
ffffffffc02002fa:	e822                	sd	s0,16(sp)
ffffffffc02002fc:	f436                	sd	a3,40(sp)
ffffffffc02002fe:	f83a                	sd	a4,48(sp)
ffffffffc0200300:	fc3e                	sd	a5,56(sp)
ffffffffc0200302:	e0c2                	sd	a6,64(sp)
ffffffffc0200304:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200306:	020e1a63          	bnez	t3,ffffffffc020033a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020030a:	4785                	li	a5,1
ffffffffc020030c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200310:	8432                	mv	s0,a2
ffffffffc0200312:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200314:	862e                	mv	a2,a1
ffffffffc0200316:	85aa                	mv	a1,a0
ffffffffc0200318:	00002517          	auipc	a0,0x2
ffffffffc020031c:	93850513          	addi	a0,a0,-1736 # ffffffffc0201c50 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200320:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200322:	05e000ef          	jal	ra,ffffffffc0200380 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200326:	65a2                	ld	a1,8(sp)
ffffffffc0200328:	8522                	mv	a0,s0
ffffffffc020032a:	036000ef          	jal	ra,ffffffffc0200360 <vcprintf>
    cprintf("\n");
ffffffffc020032e:	00001517          	auipc	a0,0x1
ffffffffc0200332:	76a50513          	addi	a0,a0,1898 # ffffffffc0201a98 <etext+0xee>
ffffffffc0200336:	04a000ef          	jal	ra,ffffffffc0200380 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020033a:	124000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020033e:	4501                	li	a0,0
ffffffffc0200340:	e63ff0ef          	jal	ra,ffffffffc02001a2 <kmonitor>
    while (1) {
ffffffffc0200344:	bfed                	j	ffffffffc020033e <__panic+0x54>

ffffffffc0200346 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200346:	1141                	addi	sp,sp,-16
ffffffffc0200348:	e022                	sd	s0,0(sp)
ffffffffc020034a:	e406                	sd	ra,8(sp)
ffffffffc020034c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020034e:	0fe000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200352:	401c                	lw	a5,0(s0)
}
ffffffffc0200354:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200356:	2785                	addiw	a5,a5,1
ffffffffc0200358:	c01c                	sw	a5,0(s0)
}
ffffffffc020035a:	6402                	ld	s0,0(sp)
ffffffffc020035c:	0141                	addi	sp,sp,16
ffffffffc020035e:	8082                	ret

ffffffffc0200360 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200360:	1101                	addi	sp,sp,-32
ffffffffc0200362:	862a                	mv	a2,a0
ffffffffc0200364:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200366:	00000517          	auipc	a0,0x0
ffffffffc020036a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200346 <cputch>
ffffffffc020036e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200370:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200372:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200374:	14e010ef          	jal	ra,ffffffffc02014c2 <vprintfmt>
    return cnt;
}
ffffffffc0200378:	60e2                	ld	ra,24(sp)
ffffffffc020037a:	4532                	lw	a0,12(sp)
ffffffffc020037c:	6105                	addi	sp,sp,32
ffffffffc020037e:	8082                	ret

ffffffffc0200380 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200380:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200382:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200386:	8e2a                	mv	t3,a0
ffffffffc0200388:	f42e                	sd	a1,40(sp)
ffffffffc020038a:	f832                	sd	a2,48(sp)
ffffffffc020038c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020038e:	00000517          	auipc	a0,0x0
ffffffffc0200392:	fb850513          	addi	a0,a0,-72 # ffffffffc0200346 <cputch>
ffffffffc0200396:	004c                	addi	a1,sp,4
ffffffffc0200398:	869a                	mv	a3,t1
ffffffffc020039a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020039c:	ec06                	sd	ra,24(sp)
ffffffffc020039e:	e0ba                	sd	a4,64(sp)
ffffffffc02003a0:	e4be                	sd	a5,72(sp)
ffffffffc02003a2:	e8c2                	sd	a6,80(sp)
ffffffffc02003a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02003a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02003a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02003aa:	118010ef          	jal	ra,ffffffffc02014c2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02003ae:	60e2                	ld	ra,24(sp)
ffffffffc02003b0:	4512                	lw	a0,4(sp)
ffffffffc02003b2:	6125                	addi	sp,sp,96
ffffffffc02003b4:	8082                	ret

ffffffffc02003b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02003b6:	a859                	j	ffffffffc020044c <cons_putc>

ffffffffc02003b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02003b8:	1101                	addi	sp,sp,-32
ffffffffc02003ba:	e822                	sd	s0,16(sp)
ffffffffc02003bc:	ec06                	sd	ra,24(sp)
ffffffffc02003be:	e426                	sd	s1,8(sp)
ffffffffc02003c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02003c2:	00054503          	lbu	a0,0(a0)
ffffffffc02003c6:	c51d                	beqz	a0,ffffffffc02003f4 <cputs+0x3c>
ffffffffc02003c8:	0405                	addi	s0,s0,1
ffffffffc02003ca:	4485                	li	s1,1
ffffffffc02003cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02003ce:	07e000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02003d2:	00044503          	lbu	a0,0(s0)
ffffffffc02003d6:	008487bb          	addw	a5,s1,s0
ffffffffc02003da:	0405                	addi	s0,s0,1
ffffffffc02003dc:	f96d                	bnez	a0,ffffffffc02003ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02003de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02003e2:	4529                	li	a0,10
ffffffffc02003e4:	068000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02003e8:	60e2                	ld	ra,24(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	6442                	ld	s0,16(sp)
ffffffffc02003ee:	64a2                	ld	s1,8(sp)
ffffffffc02003f0:	6105                	addi	sp,sp,32
ffffffffc02003f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02003f4:	4405                	li	s0,1
ffffffffc02003f6:	b7f5                	j	ffffffffc02003e2 <cputs+0x2a>

ffffffffc02003f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02003f8:	1141                	addi	sp,sp,-16
ffffffffc02003fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02003fc:	058000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200400:	dd75                	beqz	a0,ffffffffc02003fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200402:	60a2                	ld	ra,8(sp)
ffffffffc0200404:	0141                	addi	sp,sp,16
ffffffffc0200406:	8082                	ret

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	4f2010ef          	jal	ra,ffffffffc0201912 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	84250513          	addi	a0,a0,-1982 # ffffffffc0201c70 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b7a1                	j	ffffffffc0200380 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	4cc0106f          	j	ffffffffc0201912 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	4a80106f          	j	ffffffffc02018f8 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	4d80106f          	j	ffffffffc020192c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	81250513          	addi	a0,a0,-2030 # ffffffffc0201c90 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	ef9ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201ca8 <commands+0xa0>
ffffffffc0200496:	eebff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	82450513          	addi	a0,a0,-2012 # ffffffffc0201cc0 <commands+0xb8>
ffffffffc02004a4:	eddff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201cd8 <commands+0xd0>
ffffffffc02004b2:	ecfff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	83850513          	addi	a0,a0,-1992 # ffffffffc0201cf0 <commands+0xe8>
ffffffffc02004c0:	ec1ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	84250513          	addi	a0,a0,-1982 # ffffffffc0201d08 <commands+0x100>
ffffffffc02004ce:	eb3ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0201d20 <commands+0x118>
ffffffffc02004dc:	ea5ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	85650513          	addi	a0,a0,-1962 # ffffffffc0201d38 <commands+0x130>
ffffffffc02004ea:	e97ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	86050513          	addi	a0,a0,-1952 # ffffffffc0201d50 <commands+0x148>
ffffffffc02004f8:	e89ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	86a50513          	addi	a0,a0,-1942 # ffffffffc0201d68 <commands+0x160>
ffffffffc0200506:	e7bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	87450513          	addi	a0,a0,-1932 # ffffffffc0201d80 <commands+0x178>
ffffffffc0200514:	e6dff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0201d98 <commands+0x190>
ffffffffc0200522:	e5fff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	88850513          	addi	a0,a0,-1912 # ffffffffc0201db0 <commands+0x1a8>
ffffffffc0200530:	e51ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	89250513          	addi	a0,a0,-1902 # ffffffffc0201dc8 <commands+0x1c0>
ffffffffc020053e:	e43ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201de0 <commands+0x1d8>
ffffffffc020054c:	e35ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201df8 <commands+0x1f0>
ffffffffc020055a:	e27ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201e10 <commands+0x208>
ffffffffc0200568:	e19ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201e28 <commands+0x220>
ffffffffc0200576:	e0bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201e40 <commands+0x238>
ffffffffc0200584:	dfdff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201e58 <commands+0x250>
ffffffffc0200592:	defff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201e70 <commands+0x268>
ffffffffc02005a0:	de1ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201e88 <commands+0x280>
ffffffffc02005ae:	dd3ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201ea0 <commands+0x298>
ffffffffc02005bc:	dc5ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201eb8 <commands+0x2b0>
ffffffffc02005ca:	db7ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	90050513          	addi	a0,a0,-1792 # ffffffffc0201ed0 <commands+0x2c8>
ffffffffc02005d8:	da9ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ee8 <commands+0x2e0>
ffffffffc02005e6:	d9bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	91450513          	addi	a0,a0,-1772 # ffffffffc0201f00 <commands+0x2f8>
ffffffffc02005f4:	d8dff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201f18 <commands+0x310>
ffffffffc0200602:	d7fff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	92850513          	addi	a0,a0,-1752 # ffffffffc0201f30 <commands+0x328>
ffffffffc0200610:	d71ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	93250513          	addi	a0,a0,-1742 # ffffffffc0201f48 <commands+0x340>
ffffffffc020061e:	d63ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201f60 <commands+0x358>
ffffffffc020062c:	d55ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	94250513          	addi	a0,a0,-1726 # ffffffffc0201f78 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	b381                	j	ffffffffc0200380 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	94650513          	addi	a0,a0,-1722 # ffffffffc0201f90 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	d2dff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	94650513          	addi	a0,a0,-1722 # ffffffffc0201fa8 <commands+0x3a0>
ffffffffc020066a:	d17ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fc0 <commands+0x3b8>
ffffffffc020067a:	d07ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fd8 <commands+0x3d0>
ffffffffc020068a:	cf7ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201ff0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	b1c5                	j	ffffffffc0200380 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a2070713          	addi	a4,a4,-1504 # ffffffffc02020d0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202068 <commands+0x460>
ffffffffc02006ca:	b95d                	j	ffffffffc0200380 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0202048 <commands+0x440>
ffffffffc02006d4:	b175                	j	ffffffffc0200380 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	93250513          	addi	a0,a0,-1742 # ffffffffc0202008 <commands+0x400>
ffffffffc02006de:	b14d                	j	ffffffffc0200380 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0202088 <commands+0x480>
ffffffffc02006e8:	b961                	j	ffffffffc0200380 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9a050513          	addi	a0,a0,-1632 # ffffffffc02020b0 <commands+0x4a8>
ffffffffc0200718:	b1a5                	j	ffffffffc0200380 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0202028 <commands+0x420>
ffffffffc0200722:	b9b9                	j	ffffffffc0200380 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	97450513          	addi	a0,a0,-1676 # ffffffffc02020a0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	b1a9                	j	ffffffffc0200380 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020081e:	c14d                	beqz	a0,ffffffffc02008c0 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200820:	00005617          	auipc	a2,0x5
ffffffffc0200824:	7f060613          	addi	a2,a2,2032 # ffffffffc0206010 <free_area>
ffffffffc0200828:	01062803          	lw	a6,16(a2)
ffffffffc020082c:	86aa                	mv	a3,a0
ffffffffc020082e:	02081793          	slli	a5,a6,0x20
ffffffffc0200832:	9381                	srli	a5,a5,0x20
ffffffffc0200834:	08a7e463          	bltu	a5,a0,ffffffffc02008bc <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200838:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020083a:	0018059b          	addiw	a1,a6,1
ffffffffc020083e:	1582                	slli	a1,a1,0x20
ffffffffc0200840:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200842:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200844:	06c78b63          	beq	a5,a2,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) { // 如果当前的空闲块小于"最小量"
ffffffffc0200848:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020084c:	00d76763          	bltu	a4,a3,ffffffffc020085a <best_fit_alloc_pages+0x3c>
ffffffffc0200850:	00b77563          	bgeu	a4,a1,ffffffffc020085a <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200854:	fe878513          	addi	a0,a5,-24
ffffffffc0200858:	85ba                	mv	a1,a4
ffffffffc020085a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085c:	fec796e3          	bne	a5,a2,ffffffffc0200848 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200860:	cd29                	beqz	a0,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200862:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200864:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200866:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200868:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020086c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020086e:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200870:	02059793          	slli	a5,a1,0x20
ffffffffc0200874:	9381                	srli	a5,a5,0x20
ffffffffc0200876:	02f6f863          	bgeu	a3,a5,ffffffffc02008a6 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc020087a:	00269793          	slli	a5,a3,0x2
ffffffffc020087e:	97b6                	add	a5,a5,a3
ffffffffc0200880:	078e                	slli	a5,a5,0x3
ffffffffc0200882:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200884:	411585bb          	subw	a1,a1,a7
ffffffffc0200888:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088a:	4689                	li	a3,2
ffffffffc020088c:	00878593          	addi	a1,a5,8
ffffffffc0200890:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200894:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200896:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020089a:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc020089e:	e28c                	sd	a1,0(a3)
ffffffffc02008a0:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008a2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008a4:	ef98                	sd	a4,24(a5)
ffffffffc02008a6:	4118083b          	subw	a6,a6,a7
ffffffffc02008aa:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008ae:	57f5                	li	a5,-3
ffffffffc02008b0:	00850713          	addi	a4,a0,8
ffffffffc02008b4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008b8:	8082                	ret
}
ffffffffc02008ba:	8082                	ret
        return NULL;
ffffffffc02008bc:	4501                	li	a0,0
ffffffffc02008be:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008c0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008c2:	00002697          	auipc	a3,0x2
ffffffffc02008c6:	83e68693          	addi	a3,a3,-1986 # ffffffffc0202100 <commands+0x4f8>
ffffffffc02008ca:	00002617          	auipc	a2,0x2
ffffffffc02008ce:	83e60613          	addi	a2,a2,-1986 # ffffffffc0202108 <commands+0x500>
ffffffffc02008d2:	03a00593          	li	a1,58
ffffffffc02008d6:	00002517          	auipc	a0,0x2
ffffffffc02008da:	84a50513          	addi	a0,a0,-1974 # ffffffffc0202120 <commands+0x518>
best_fit_alloc_pages(size_t n) {
ffffffffc02008de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008e0:	a0bff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02008e4 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02008e4:	715d                	addi	sp,sp,-80
ffffffffc02008e6:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02008e8:	00005417          	auipc	s0,0x5
ffffffffc02008ec:	72840413          	addi	s0,s0,1832 # ffffffffc0206010 <free_area>
ffffffffc02008f0:	641c                	ld	a5,8(s0)
ffffffffc02008f2:	e486                	sd	ra,72(sp)
ffffffffc02008f4:	fc26                	sd	s1,56(sp)
ffffffffc02008f6:	f84a                	sd	s2,48(sp)
ffffffffc02008f8:	f44e                	sd	s3,40(sp)
ffffffffc02008fa:	f052                	sd	s4,32(sp)
ffffffffc02008fc:	ec56                	sd	s5,24(sp)
ffffffffc02008fe:	e85a                	sd	s6,16(sp)
ffffffffc0200900:	e45e                	sd	s7,8(sp)
ffffffffc0200902:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200904:	26878b63          	beq	a5,s0,ffffffffc0200b7a <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200908:	4481                	li	s1,0
ffffffffc020090a:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020090c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200910:	8b09                	andi	a4,a4,2
ffffffffc0200912:	26070863          	beqz	a4,ffffffffc0200b82 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200916:	ff87a703          	lw	a4,-8(a5)
ffffffffc020091a:	679c                	ld	a5,8(a5)
ffffffffc020091c:	2905                	addiw	s2,s2,1
ffffffffc020091e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200920:	fe8796e3          	bne	a5,s0,ffffffffc020090c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200924:	89a6                	mv	s3,s1
ffffffffc0200926:	163000ef          	jal	ra,ffffffffc0201288 <nr_free_pages>
ffffffffc020092a:	33351c63          	bne	a0,s3,ffffffffc0200c62 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020092e:	4505                	li	a0,1
ffffffffc0200930:	0db000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200934:	8a2a                	mv	s4,a0
ffffffffc0200936:	36050663          	beqz	a0,ffffffffc0200ca2 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020093a:	4505                	li	a0,1
ffffffffc020093c:	0cf000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200940:	89aa                	mv	s3,a0
ffffffffc0200942:	34050063          	beqz	a0,ffffffffc0200c82 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200946:	4505                	li	a0,1
ffffffffc0200948:	0c3000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc020094c:	8aaa                	mv	s5,a0
ffffffffc020094e:	2c050a63          	beqz	a0,ffffffffc0200c22 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200952:	253a0863          	beq	s4,s3,ffffffffc0200ba2 <best_fit_check+0x2be>
ffffffffc0200956:	24aa0663          	beq	s4,a0,ffffffffc0200ba2 <best_fit_check+0x2be>
ffffffffc020095a:	24a98463          	beq	s3,a0,ffffffffc0200ba2 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020095e:	000a2783          	lw	a5,0(s4)
ffffffffc0200962:	26079063          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
ffffffffc0200966:	0009a783          	lw	a5,0(s3)
ffffffffc020096a:	24079c63          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
ffffffffc020096e:	411c                	lw	a5,0(a0)
ffffffffc0200970:	24079963          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200974:	00006797          	auipc	a5,0x6
ffffffffc0200978:	acc7b783          	ld	a5,-1332(a5) # ffffffffc0206440 <pages>
ffffffffc020097c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200980:	870d                	srai	a4,a4,0x3
ffffffffc0200982:	00002597          	auipc	a1,0x2
ffffffffc0200986:	e6e5b583          	ld	a1,-402(a1) # ffffffffc02027f0 <error_string+0x38>
ffffffffc020098a:	02b70733          	mul	a4,a4,a1
ffffffffc020098e:	00002617          	auipc	a2,0x2
ffffffffc0200992:	e6a63603          	ld	a2,-406(a2) # ffffffffc02027f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200996:	00006697          	auipc	a3,0x6
ffffffffc020099a:	aa26b683          	ld	a3,-1374(a3) # ffffffffc0206438 <npage>
ffffffffc020099e:	06b2                	slli	a3,a3,0xc
ffffffffc02009a0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009a2:	0732                	slli	a4,a4,0xc
ffffffffc02009a4:	22d77f63          	bgeu	a4,a3,ffffffffc0200be2 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009a8:	40f98733          	sub	a4,s3,a5
ffffffffc02009ac:	870d                	srai	a4,a4,0x3
ffffffffc02009ae:	02b70733          	mul	a4,a4,a1
ffffffffc02009b2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009b4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009b6:	3ed77663          	bgeu	a4,a3,ffffffffc0200da2 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ba:	40f507b3          	sub	a5,a0,a5
ffffffffc02009be:	878d                	srai	a5,a5,0x3
ffffffffc02009c0:	02b787b3          	mul	a5,a5,a1
ffffffffc02009c4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009c6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009c8:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200d82 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc02009cc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009ce:	00043c03          	ld	s8,0(s0)
ffffffffc02009d2:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02009d6:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02009da:	e400                	sd	s0,8(s0)
ffffffffc02009dc:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02009de:	00005797          	auipc	a5,0x5
ffffffffc02009e2:	6407a123          	sw	zero,1602(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009e6:	025000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc02009ea:	36051c63          	bnez	a0,ffffffffc0200d62 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc02009ee:	4585                	li	a1,1
ffffffffc02009f0:	8552                	mv	a0,s4
ffffffffc02009f2:	057000ef          	jal	ra,ffffffffc0201248 <free_pages>
    free_page(p1);
ffffffffc02009f6:	4585                	li	a1,1
ffffffffc02009f8:	854e                	mv	a0,s3
ffffffffc02009fa:	04f000ef          	jal	ra,ffffffffc0201248 <free_pages>
    free_page(p2);
ffffffffc02009fe:	4585                	li	a1,1
ffffffffc0200a00:	8556                	mv	a0,s5
ffffffffc0200a02:	047000ef          	jal	ra,ffffffffc0201248 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a06:	4818                	lw	a4,16(s0)
ffffffffc0200a08:	478d                	li	a5,3
ffffffffc0200a0a:	32f71c63          	bne	a4,a5,ffffffffc0200d42 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a0e:	4505                	li	a0,1
ffffffffc0200a10:	7fa000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a14:	89aa                	mv	s3,a0
ffffffffc0200a16:	30050663          	beqz	a0,ffffffffc0200d22 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a1a:	4505                	li	a0,1
ffffffffc0200a1c:	7ee000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a20:	8aaa                	mv	s5,a0
ffffffffc0200a22:	2e050063          	beqz	a0,ffffffffc0200d02 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a26:	4505                	li	a0,1
ffffffffc0200a28:	7e2000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a2c:	8a2a                	mv	s4,a0
ffffffffc0200a2e:	2a050a63          	beqz	a0,ffffffffc0200ce2 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200a32:	4505                	li	a0,1
ffffffffc0200a34:	7d6000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a38:	28051563          	bnez	a0,ffffffffc0200cc2 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200a3c:	4585                	li	a1,1
ffffffffc0200a3e:	854e                	mv	a0,s3
ffffffffc0200a40:	009000ef          	jal	ra,ffffffffc0201248 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a44:	641c                	ld	a5,8(s0)
ffffffffc0200a46:	1a878e63          	beq	a5,s0,ffffffffc0200c02 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200a4a:	4505                	li	a0,1
ffffffffc0200a4c:	7be000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a50:	52a99963          	bne	s3,a0,ffffffffc0200f82 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200a54:	4505                	li	a0,1
ffffffffc0200a56:	7b4000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a5a:	50051463          	bnez	a0,ffffffffc0200f62 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200a5e:	481c                	lw	a5,16(s0)
ffffffffc0200a60:	4e079163          	bnez	a5,ffffffffc0200f42 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200a64:	854e                	mv	a0,s3
ffffffffc0200a66:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a68:	01843023          	sd	s8,0(s0)
ffffffffc0200a6c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a70:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a74:	7d4000ef          	jal	ra,ffffffffc0201248 <free_pages>
    free_page(p1);
ffffffffc0200a78:	4585                	li	a1,1
ffffffffc0200a7a:	8556                	mv	a0,s5
ffffffffc0200a7c:	7cc000ef          	jal	ra,ffffffffc0201248 <free_pages>
    free_page(p2);
ffffffffc0200a80:	4585                	li	a1,1
ffffffffc0200a82:	8552                	mv	a0,s4
ffffffffc0200a84:	7c4000ef          	jal	ra,ffffffffc0201248 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a88:	4515                	li	a0,5
ffffffffc0200a8a:	780000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200a8e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a90:	48050963          	beqz	a0,ffffffffc0200f22 <best_fit_check+0x63e>
ffffffffc0200a94:	651c                	ld	a5,8(a0)
ffffffffc0200a96:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a98:	8b85                	andi	a5,a5,1
ffffffffc0200a9a:	46079463          	bnez	a5,ffffffffc0200f02 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a9e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200aa0:	00043a83          	ld	s5,0(s0)
ffffffffc0200aa4:	00843a03          	ld	s4,8(s0)
ffffffffc0200aa8:	e000                	sd	s0,0(s0)
ffffffffc0200aaa:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200aac:	75e000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200ab0:	42051963          	bnez	a0,ffffffffc0200ee2 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200ab4:	4589                	li	a1,2
ffffffffc0200ab6:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200aba:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200abe:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200ac2:	00005797          	auipc	a5,0x5
ffffffffc0200ac6:	5407af23          	sw	zero,1374(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200aca:	77e000ef          	jal	ra,ffffffffc0201248 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200ace:	8562                	mv	a0,s8
ffffffffc0200ad0:	4585                	li	a1,1
ffffffffc0200ad2:	776000ef          	jal	ra,ffffffffc0201248 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ad6:	4511                	li	a0,4
ffffffffc0200ad8:	732000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200adc:	3e051363          	bnez	a0,ffffffffc0200ec2 <best_fit_check+0x5de>
ffffffffc0200ae0:	0309b783          	ld	a5,48(s3)
ffffffffc0200ae4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ae6:	8b85                	andi	a5,a5,1
ffffffffc0200ae8:	3a078d63          	beqz	a5,ffffffffc0200ea2 <best_fit_check+0x5be>
ffffffffc0200aec:	0389a703          	lw	a4,56(s3)
ffffffffc0200af0:	4789                	li	a5,2
ffffffffc0200af2:	3af71863          	bne	a4,a5,ffffffffc0200ea2 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200af6:	4505                	li	a0,1
ffffffffc0200af8:	712000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200afc:	8baa                	mv	s7,a0
ffffffffc0200afe:	38050263          	beqz	a0,ffffffffc0200e82 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b02:	4509                	li	a0,2
ffffffffc0200b04:	706000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200b08:	34050d63          	beqz	a0,ffffffffc0200e62 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200b0c:	337c1b63          	bne	s8,s7,ffffffffc0200e42 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b10:	854e                	mv	a0,s3
ffffffffc0200b12:	4595                	li	a1,5
ffffffffc0200b14:	734000ef          	jal	ra,ffffffffc0201248 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b18:	4515                	li	a0,5
ffffffffc0200b1a:	6f0000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200b1e:	89aa                	mv	s3,a0
ffffffffc0200b20:	30050163          	beqz	a0,ffffffffc0200e22 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200b24:	4505                	li	a0,1
ffffffffc0200b26:	6e4000ef          	jal	ra,ffffffffc020120a <alloc_pages>
ffffffffc0200b2a:	2c051c63          	bnez	a0,ffffffffc0200e02 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b2e:	481c                	lw	a5,16(s0)
ffffffffc0200b30:	2a079963          	bnez	a5,ffffffffc0200de2 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b34:	4595                	li	a1,5
ffffffffc0200b36:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b38:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b3c:	01543023          	sd	s5,0(s0)
ffffffffc0200b40:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b44:	704000ef          	jal	ra,ffffffffc0201248 <free_pages>
    return listelm->next;
ffffffffc0200b48:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4a:	00878963          	beq	a5,s0,ffffffffc0200b5c <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b4e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b52:	679c                	ld	a5,8(a5)
ffffffffc0200b54:	397d                	addiw	s2,s2,-1
ffffffffc0200b56:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b58:	fe879be3          	bne	a5,s0,ffffffffc0200b4e <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200b5c:	26091363          	bnez	s2,ffffffffc0200dc2 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200b60:	e0ed                	bnez	s1,ffffffffc0200c42 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b62:	60a6                	ld	ra,72(sp)
ffffffffc0200b64:	6406                	ld	s0,64(sp)
ffffffffc0200b66:	74e2                	ld	s1,56(sp)
ffffffffc0200b68:	7942                	ld	s2,48(sp)
ffffffffc0200b6a:	79a2                	ld	s3,40(sp)
ffffffffc0200b6c:	7a02                	ld	s4,32(sp)
ffffffffc0200b6e:	6ae2                	ld	s5,24(sp)
ffffffffc0200b70:	6b42                	ld	s6,16(sp)
ffffffffc0200b72:	6ba2                	ld	s7,8(sp)
ffffffffc0200b74:	6c02                	ld	s8,0(sp)
ffffffffc0200b76:	6161                	addi	sp,sp,80
ffffffffc0200b78:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b7a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b7c:	4481                	li	s1,0
ffffffffc0200b7e:	4901                	li	s2,0
ffffffffc0200b80:	b35d                	j	ffffffffc0200926 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b82:	00001697          	auipc	a3,0x1
ffffffffc0200b86:	5b668693          	addi	a3,a3,1462 # ffffffffc0202138 <commands+0x530>
ffffffffc0200b8a:	00001617          	auipc	a2,0x1
ffffffffc0200b8e:	57e60613          	addi	a2,a2,1406 # ffffffffc0202108 <commands+0x500>
ffffffffc0200b92:	0da00593          	li	a1,218
ffffffffc0200b96:	00001517          	auipc	a0,0x1
ffffffffc0200b9a:	58a50513          	addi	a0,a0,1418 # ffffffffc0202120 <commands+0x518>
ffffffffc0200b9e:	f4cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ba2:	00001697          	auipc	a3,0x1
ffffffffc0200ba6:	62668693          	addi	a3,a3,1574 # ffffffffc02021c8 <commands+0x5c0>
ffffffffc0200baa:	00001617          	auipc	a2,0x1
ffffffffc0200bae:	55e60613          	addi	a2,a2,1374 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bb2:	0a600593          	li	a1,166
ffffffffc0200bb6:	00001517          	auipc	a0,0x1
ffffffffc0200bba:	56a50513          	addi	a0,a0,1386 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bbe:	f2cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bc2:	00001697          	auipc	a3,0x1
ffffffffc0200bc6:	62e68693          	addi	a3,a3,1582 # ffffffffc02021f0 <commands+0x5e8>
ffffffffc0200bca:	00001617          	auipc	a2,0x1
ffffffffc0200bce:	53e60613          	addi	a2,a2,1342 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bd2:	0a700593          	li	a1,167
ffffffffc0200bd6:	00001517          	auipc	a0,0x1
ffffffffc0200bda:	54a50513          	addi	a0,a0,1354 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bde:	f0cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200be2:	00001697          	auipc	a3,0x1
ffffffffc0200be6:	64e68693          	addi	a3,a3,1614 # ffffffffc0202230 <commands+0x628>
ffffffffc0200bea:	00001617          	auipc	a2,0x1
ffffffffc0200bee:	51e60613          	addi	a2,a2,1310 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bf2:	0a900593          	li	a1,169
ffffffffc0200bf6:	00001517          	auipc	a0,0x1
ffffffffc0200bfa:	52a50513          	addi	a0,a0,1322 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bfe:	eecff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c02:	00001697          	auipc	a3,0x1
ffffffffc0200c06:	6b668693          	addi	a3,a3,1718 # ffffffffc02022b8 <commands+0x6b0>
ffffffffc0200c0a:	00001617          	auipc	a2,0x1
ffffffffc0200c0e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c12:	0c200593          	li	a1,194
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	50a50513          	addi	a0,a0,1290 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c1e:	eccff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c22:	00001697          	auipc	a3,0x1
ffffffffc0200c26:	58668693          	addi	a3,a3,1414 # ffffffffc02021a8 <commands+0x5a0>
ffffffffc0200c2a:	00001617          	auipc	a2,0x1
ffffffffc0200c2e:	4de60613          	addi	a2,a2,1246 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c32:	0a400593          	li	a1,164
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c3e:	eacff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == 0);
ffffffffc0200c42:	00001697          	auipc	a3,0x1
ffffffffc0200c46:	7a668693          	addi	a3,a3,1958 # ffffffffc02023e8 <commands+0x7e0>
ffffffffc0200c4a:	00001617          	auipc	a2,0x1
ffffffffc0200c4e:	4be60613          	addi	a2,a2,1214 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c52:	11c00593          	li	a1,284
ffffffffc0200c56:	00001517          	auipc	a0,0x1
ffffffffc0200c5a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c5e:	e8cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c62:	00001697          	auipc	a3,0x1
ffffffffc0200c66:	4e668693          	addi	a3,a3,1254 # ffffffffc0202148 <commands+0x540>
ffffffffc0200c6a:	00001617          	auipc	a2,0x1
ffffffffc0200c6e:	49e60613          	addi	a2,a2,1182 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c72:	0dd00593          	li	a1,221
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c7e:	e6cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c82:	00001697          	auipc	a3,0x1
ffffffffc0200c86:	50668693          	addi	a3,a3,1286 # ffffffffc0202188 <commands+0x580>
ffffffffc0200c8a:	00001617          	auipc	a2,0x1
ffffffffc0200c8e:	47e60613          	addi	a2,a2,1150 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c92:	0a300593          	li	a1,163
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	48a50513          	addi	a0,a0,1162 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c9e:	e4cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ca2:	00001697          	auipc	a3,0x1
ffffffffc0200ca6:	4c668693          	addi	a3,a3,1222 # ffffffffc0202168 <commands+0x560>
ffffffffc0200caa:	00001617          	auipc	a2,0x1
ffffffffc0200cae:	45e60613          	addi	a2,a2,1118 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cb2:	0a200593          	li	a1,162
ffffffffc0200cb6:	00001517          	auipc	a0,0x1
ffffffffc0200cba:	46a50513          	addi	a0,a0,1130 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cbe:	e2cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cc2:	00001697          	auipc	a3,0x1
ffffffffc0200cc6:	5ce68693          	addi	a3,a3,1486 # ffffffffc0202290 <commands+0x688>
ffffffffc0200cca:	00001617          	auipc	a2,0x1
ffffffffc0200cce:	43e60613          	addi	a2,a2,1086 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cd2:	0bf00593          	li	a1,191
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	44a50513          	addi	a0,a0,1098 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cde:	e0cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce2:	00001697          	auipc	a3,0x1
ffffffffc0200ce6:	4c668693          	addi	a3,a3,1222 # ffffffffc02021a8 <commands+0x5a0>
ffffffffc0200cea:	00001617          	auipc	a2,0x1
ffffffffc0200cee:	41e60613          	addi	a2,a2,1054 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cf2:	0bd00593          	li	a1,189
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	42a50513          	addi	a0,a0,1066 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cfe:	decff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d02:	00001697          	auipc	a3,0x1
ffffffffc0200d06:	48668693          	addi	a3,a3,1158 # ffffffffc0202188 <commands+0x580>
ffffffffc0200d0a:	00001617          	auipc	a2,0x1
ffffffffc0200d0e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d12:	0bc00593          	li	a1,188
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d1e:	dccff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d22:	00001697          	auipc	a3,0x1
ffffffffc0200d26:	44668693          	addi	a3,a3,1094 # ffffffffc0202168 <commands+0x560>
ffffffffc0200d2a:	00001617          	auipc	a2,0x1
ffffffffc0200d2e:	3de60613          	addi	a2,a2,990 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d32:	0bb00593          	li	a1,187
ffffffffc0200d36:	00001517          	auipc	a0,0x1
ffffffffc0200d3a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d3e:	dacff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 3);
ffffffffc0200d42:	00001697          	auipc	a3,0x1
ffffffffc0200d46:	56668693          	addi	a3,a3,1382 # ffffffffc02022a8 <commands+0x6a0>
ffffffffc0200d4a:	00001617          	auipc	a2,0x1
ffffffffc0200d4e:	3be60613          	addi	a2,a2,958 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d52:	0b900593          	li	a1,185
ffffffffc0200d56:	00001517          	auipc	a0,0x1
ffffffffc0200d5a:	3ca50513          	addi	a0,a0,970 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d5e:	d8cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	00001697          	auipc	a3,0x1
ffffffffc0200d66:	52e68693          	addi	a3,a3,1326 # ffffffffc0202290 <commands+0x688>
ffffffffc0200d6a:	00001617          	auipc	a2,0x1
ffffffffc0200d6e:	39e60613          	addi	a2,a2,926 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d72:	0b400593          	li	a1,180
ffffffffc0200d76:	00001517          	auipc	a0,0x1
ffffffffc0200d7a:	3aa50513          	addi	a0,a0,938 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d7e:	d6cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d82:	00001697          	auipc	a3,0x1
ffffffffc0200d86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202270 <commands+0x668>
ffffffffc0200d8a:	00001617          	auipc	a2,0x1
ffffffffc0200d8e:	37e60613          	addi	a2,a2,894 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d92:	0ab00593          	li	a1,171
ffffffffc0200d96:	00001517          	auipc	a0,0x1
ffffffffc0200d9a:	38a50513          	addi	a0,a0,906 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d9e:	d4cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200da2:	00001697          	auipc	a3,0x1
ffffffffc0200da6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0202250 <commands+0x648>
ffffffffc0200daa:	00001617          	auipc	a2,0x1
ffffffffc0200dae:	35e60613          	addi	a2,a2,862 # ffffffffc0202108 <commands+0x500>
ffffffffc0200db2:	0aa00593          	li	a1,170
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	36a50513          	addi	a0,a0,874 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dbe:	d2cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(count == 0);
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	61668693          	addi	a3,a3,1558 # ffffffffc02023d8 <commands+0x7d0>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	33e60613          	addi	a2,a2,830 # ffffffffc0202108 <commands+0x500>
ffffffffc0200dd2:	11b00593          	li	a1,283
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	34a50513          	addi	a0,a0,842 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dde:	d0cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	50e68693          	addi	a3,a3,1294 # ffffffffc02022f0 <commands+0x6e8>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	31e60613          	addi	a2,a2,798 # ffffffffc0202108 <commands+0x500>
ffffffffc0200df2:	11000593          	li	a1,272
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	32a50513          	addi	a0,a0,810 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dfe:	cecff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	48e68693          	addi	a3,a3,1166 # ffffffffc0202290 <commands+0x688>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	2fe60613          	addi	a2,a2,766 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e12:	10a00593          	li	a1,266
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	30a50513          	addi	a0,a0,778 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e1e:	cccff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e22:	00001697          	auipc	a3,0x1
ffffffffc0200e26:	59668693          	addi	a3,a3,1430 # ffffffffc02023b8 <commands+0x7b0>
ffffffffc0200e2a:	00001617          	auipc	a2,0x1
ffffffffc0200e2e:	2de60613          	addi	a2,a2,734 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e32:	10900593          	li	a1,265
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	2ea50513          	addi	a0,a0,746 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e3e:	cacff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	56668693          	addi	a3,a3,1382 # ffffffffc02023a8 <commands+0x7a0>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	2be60613          	addi	a2,a2,702 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e52:	10100593          	li	a1,257
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	2ca50513          	addi	a0,a0,714 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e5e:	c8cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e62:	00001697          	auipc	a3,0x1
ffffffffc0200e66:	52e68693          	addi	a3,a3,1326 # ffffffffc0202390 <commands+0x788>
ffffffffc0200e6a:	00001617          	auipc	a2,0x1
ffffffffc0200e6e:	29e60613          	addi	a2,a2,670 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e72:	10000593          	li	a1,256
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	2aa50513          	addi	a0,a0,682 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e7e:	c6cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e82:	00001697          	auipc	a3,0x1
ffffffffc0200e86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202370 <commands+0x768>
ffffffffc0200e8a:	00001617          	auipc	a2,0x1
ffffffffc0200e8e:	27e60613          	addi	a2,a2,638 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e92:	0ff00593          	li	a1,255
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	28a50513          	addi	a0,a0,650 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e9e:	c4cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ea2:	00001697          	auipc	a3,0x1
ffffffffc0200ea6:	49e68693          	addi	a3,a3,1182 # ffffffffc0202340 <commands+0x738>
ffffffffc0200eaa:	00001617          	auipc	a2,0x1
ffffffffc0200eae:	25e60613          	addi	a2,a2,606 # ffffffffc0202108 <commands+0x500>
ffffffffc0200eb2:	0fd00593          	li	a1,253
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	26a50513          	addi	a0,a0,618 # ffffffffc0202120 <commands+0x518>
ffffffffc0200ebe:	c2cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ec2:	00001697          	auipc	a3,0x1
ffffffffc0200ec6:	46668693          	addi	a3,a3,1126 # ffffffffc0202328 <commands+0x720>
ffffffffc0200eca:	00001617          	auipc	a2,0x1
ffffffffc0200ece:	23e60613          	addi	a2,a2,574 # ffffffffc0202108 <commands+0x500>
ffffffffc0200ed2:	0fc00593          	li	a1,252
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	24a50513          	addi	a0,a0,586 # ffffffffc0202120 <commands+0x518>
ffffffffc0200ede:	c0cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee2:	00001697          	auipc	a3,0x1
ffffffffc0200ee6:	3ae68693          	addi	a3,a3,942 # ffffffffc0202290 <commands+0x688>
ffffffffc0200eea:	00001617          	auipc	a2,0x1
ffffffffc0200eee:	21e60613          	addi	a2,a2,542 # ffffffffc0202108 <commands+0x500>
ffffffffc0200ef2:	0f000593          	li	a1,240
ffffffffc0200ef6:	00001517          	auipc	a0,0x1
ffffffffc0200efa:	22a50513          	addi	a0,a0,554 # ffffffffc0202120 <commands+0x518>
ffffffffc0200efe:	becff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f02:	00001697          	auipc	a3,0x1
ffffffffc0200f06:	40e68693          	addi	a3,a3,1038 # ffffffffc0202310 <commands+0x708>
ffffffffc0200f0a:	00001617          	auipc	a2,0x1
ffffffffc0200f0e:	1fe60613          	addi	a2,a2,510 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f12:	0e700593          	li	a1,231
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	20a50513          	addi	a0,a0,522 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f1e:	bccff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != NULL);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	3de68693          	addi	a3,a3,990 # ffffffffc0202300 <commands+0x6f8>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	1de60613          	addi	a2,a2,478 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f32:	0e600593          	li	a1,230
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	1ea50513          	addi	a0,a0,490 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f3e:	bacff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	3ae68693          	addi	a3,a3,942 # ffffffffc02022f0 <commands+0x6e8>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	1be60613          	addi	a2,a2,446 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f52:	0c800593          	li	a1,200
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	1ca50513          	addi	a0,a0,458 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f5e:	b8cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	32e68693          	addi	a3,a3,814 # ffffffffc0202290 <commands+0x688>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	19e60613          	addi	a2,a2,414 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f72:	0c600593          	li	a1,198
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	1aa50513          	addi	a0,a0,426 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f7e:	b6cff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	34e68693          	addi	a3,a3,846 # ffffffffc02022d0 <commands+0x6c8>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	17e60613          	addi	a2,a2,382 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f92:	0c500593          	li	a1,197
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	18a50513          	addi	a0,a0,394 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f9e:	b4cff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0200fa2 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fa2:	1141                	addi	sp,sp,-16
ffffffffc0200fa4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fa6:	14058a63          	beqz	a1,ffffffffc02010fa <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200faa:	00259693          	slli	a3,a1,0x2
ffffffffc0200fae:	96ae                	add	a3,a3,a1
ffffffffc0200fb0:	068e                	slli	a3,a3,0x3
ffffffffc0200fb2:	96aa                	add	a3,a3,a0
ffffffffc0200fb4:	87aa                	mv	a5,a0
ffffffffc0200fb6:	02d50263          	beq	a0,a3,ffffffffc0200fda <best_fit_free_pages+0x38>
ffffffffc0200fba:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fbc:	8b05                	andi	a4,a4,1
ffffffffc0200fbe:	10071e63          	bnez	a4,ffffffffc02010da <best_fit_free_pages+0x138>
ffffffffc0200fc2:	6798                	ld	a4,8(a5)
ffffffffc0200fc4:	8b09                	andi	a4,a4,2
ffffffffc0200fc6:	10071a63          	bnez	a4,ffffffffc02010da <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fca:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fd2:	02878793          	addi	a5,a5,40
ffffffffc0200fd6:	fed792e3          	bne	a5,a3,ffffffffc0200fba <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200fda:	2581                	sext.w	a1,a1
ffffffffc0200fdc:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200fde:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fe2:	4789                	li	a5,2
ffffffffc0200fe4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200fe8:	00005697          	auipc	a3,0x5
ffffffffc0200fec:	02868693          	addi	a3,a3,40 # ffffffffc0206010 <free_area>
ffffffffc0200ff0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200ff2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200ff4:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200ff8:	9db9                	addw	a1,a1,a4
ffffffffc0200ffa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200ffc:	0ad78863          	beq	a5,a3,ffffffffc02010ac <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201000:	fe878713          	addi	a4,a5,-24
ffffffffc0201004:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201008:	4581                	li	a1,0
            if (base < page) {
ffffffffc020100a:	00e56a63          	bltu	a0,a4,ffffffffc020101e <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020100e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201010:	06d70263          	beq	a4,a3,ffffffffc0201074 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201014:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201016:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020101a:	fee57ae3          	bgeu	a0,a4,ffffffffc020100e <best_fit_free_pages+0x6c>
ffffffffc020101e:	c199                	beqz	a1,ffffffffc0201024 <best_fit_free_pages+0x82>
ffffffffc0201020:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201024:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201026:	e390                	sd	a2,0(a5)
ffffffffc0201028:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020102a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020102c:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020102e:	02d70063          	beq	a4,a3,ffffffffc020104e <best_fit_free_pages+0xac>
        if (p + p->property == base){
ffffffffc0201032:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201036:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base){
ffffffffc020103a:	02081613          	slli	a2,a6,0x20
ffffffffc020103e:	9201                	srli	a2,a2,0x20
ffffffffc0201040:	00261793          	slli	a5,a2,0x2
ffffffffc0201044:	97b2                	add	a5,a5,a2
ffffffffc0201046:	078e                	slli	a5,a5,0x3
ffffffffc0201048:	97ae                	add	a5,a5,a1
ffffffffc020104a:	02f50f63          	beq	a0,a5,ffffffffc0201088 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc020104e:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201050:	00d70f63          	beq	a4,a3,ffffffffc020106e <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201054:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201056:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020105a:	02059613          	slli	a2,a1,0x20
ffffffffc020105e:	9201                	srli	a2,a2,0x20
ffffffffc0201060:	00261793          	slli	a5,a2,0x2
ffffffffc0201064:	97b2                	add	a5,a5,a2
ffffffffc0201066:	078e                	slli	a5,a5,0x3
ffffffffc0201068:	97aa                	add	a5,a5,a0
ffffffffc020106a:	04f68863          	beq	a3,a5,ffffffffc02010ba <best_fit_free_pages+0x118>
}
ffffffffc020106e:	60a2                	ld	ra,8(sp)
ffffffffc0201070:	0141                	addi	sp,sp,16
ffffffffc0201072:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201074:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201076:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201078:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020107a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020107c:	02d70563          	beq	a4,a3,ffffffffc02010a6 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201080:	8832                	mv	a6,a2
ffffffffc0201082:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201084:	87ba                	mv	a5,a4
ffffffffc0201086:	bf41                	j	ffffffffc0201016 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0201088:	491c                	lw	a5,16(a0)
ffffffffc020108a:	0107883b          	addw	a6,a5,a6
ffffffffc020108e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201092:	57f5                	li	a5,-3
ffffffffc0201094:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201098:	6d10                	ld	a2,24(a0)
ffffffffc020109a:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020109c:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020109e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010a0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010a2:	e390                	sd	a2,0(a5)
ffffffffc02010a4:	b775                	j	ffffffffc0201050 <best_fit_free_pages+0xae>
ffffffffc02010a6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010a8:	873e                	mv	a4,a5
ffffffffc02010aa:	b761                	j	ffffffffc0201032 <best_fit_free_pages+0x90>
}
ffffffffc02010ac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010ae:	e390                	sd	a2,0(a5)
ffffffffc02010b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010b4:	ed1c                	sd	a5,24(a0)
ffffffffc02010b6:	0141                	addi	sp,sp,16
ffffffffc02010b8:	8082                	ret
            base->property += p->property;
ffffffffc02010ba:	ff872783          	lw	a5,-8(a4)
ffffffffc02010be:	ff070693          	addi	a3,a4,-16
ffffffffc02010c2:	9dbd                	addw	a1,a1,a5
ffffffffc02010c4:	c90c                	sw	a1,16(a0)
ffffffffc02010c6:	57f5                	li	a5,-3
ffffffffc02010c8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010cc:	6314                	ld	a3,0(a4)
ffffffffc02010ce:	671c                	ld	a5,8(a4)
}
ffffffffc02010d0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010d2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010d4:	e394                	sd	a3,0(a5)
ffffffffc02010d6:	0141                	addi	sp,sp,16
ffffffffc02010d8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010da:	00001697          	auipc	a3,0x1
ffffffffc02010de:	31e68693          	addi	a3,a3,798 # ffffffffc02023f8 <commands+0x7f0>
ffffffffc02010e2:	00001617          	auipc	a2,0x1
ffffffffc02010e6:	02660613          	addi	a2,a2,38 # ffffffffc0202108 <commands+0x500>
ffffffffc02010ea:	06200593          	li	a1,98
ffffffffc02010ee:	00001517          	auipc	a0,0x1
ffffffffc02010f2:	03250513          	addi	a0,a0,50 # ffffffffc0202120 <commands+0x518>
ffffffffc02010f6:	9f4ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02010fa:	00001697          	auipc	a3,0x1
ffffffffc02010fe:	00668693          	addi	a3,a3,6 # ffffffffc0202100 <commands+0x4f8>
ffffffffc0201102:	00001617          	auipc	a2,0x1
ffffffffc0201106:	00660613          	addi	a2,a2,6 # ffffffffc0202108 <commands+0x500>
ffffffffc020110a:	05f00593          	li	a1,95
ffffffffc020110e:	00001517          	auipc	a0,0x1
ffffffffc0201112:	01250513          	addi	a0,a0,18 # ffffffffc0202120 <commands+0x518>
ffffffffc0201116:	9d4ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020111a <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020111a:	1141                	addi	sp,sp,-16
ffffffffc020111c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020111e:	c5f9                	beqz	a1,ffffffffc02011ec <best_fit_init_memmap+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201120:	00259693          	slli	a3,a1,0x2
ffffffffc0201124:	96ae                	add	a3,a3,a1
ffffffffc0201126:	068e                	slli	a3,a3,0x3
ffffffffc0201128:	96aa                	add	a3,a3,a0
ffffffffc020112a:	87aa                	mv	a5,a0
ffffffffc020112c:	00d50f63          	beq	a0,a3,ffffffffc020114a <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201130:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201132:	8b05                	andi	a4,a4,1
ffffffffc0201134:	cf49                	beqz	a4,ffffffffc02011ce <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201136:	0007a823          	sw	zero,16(a5)
ffffffffc020113a:	0007b423          	sd	zero,8(a5)
ffffffffc020113e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201142:	02878793          	addi	a5,a5,40
ffffffffc0201146:	fed795e3          	bne	a5,a3,ffffffffc0201130 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020114a:	2581                	sext.w	a1,a1
ffffffffc020114c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020114e:	4789                	li	a5,2
ffffffffc0201150:	00850713          	addi	a4,a0,8
ffffffffc0201154:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201158:	00005697          	auipc	a3,0x5
ffffffffc020115c:	eb868693          	addi	a3,a3,-328 # ffffffffc0206010 <free_area>
ffffffffc0201160:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201162:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201164:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201168:	9db9                	addw	a1,a1,a4
ffffffffc020116a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020116c:	04d78a63          	beq	a5,a3,ffffffffc02011c0 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201170:	fe878713          	addi	a4,a5,-24
ffffffffc0201174:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201178:	4581                	li	a1,0
            if (base < page){
ffffffffc020117a:	00e56a63          	bltu	a0,a4,ffffffffc020118e <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020117e:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list){
ffffffffc0201180:	02d70263          	beq	a4,a3,ffffffffc02011a4 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201184:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201186:	fe878713          	addi	a4,a5,-24
            if (base < page){
ffffffffc020118a:	fee57ae3          	bgeu	a0,a4,ffffffffc020117e <best_fit_init_memmap+0x64>
ffffffffc020118e:	c199                	beqz	a1,ffffffffc0201194 <best_fit_init_memmap+0x7a>
ffffffffc0201190:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201194:	6398                	ld	a4,0(a5)
}
ffffffffc0201196:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201198:	e390                	sd	a2,0(a5)
ffffffffc020119a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020119c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020119e:	ed18                	sd	a4,24(a0)
ffffffffc02011a0:	0141                	addi	sp,sp,16
ffffffffc02011a2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011a4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011a6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011a8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011aa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011ac:	00d70663          	beq	a4,a3,ffffffffc02011b8 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011b0:	8832                	mv	a6,a2
ffffffffc02011b2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011b4:	87ba                	mv	a5,a4
ffffffffc02011b6:	bfc1                	j	ffffffffc0201186 <best_fit_init_memmap+0x6c>
}
ffffffffc02011b8:	60a2                	ld	ra,8(sp)
ffffffffc02011ba:	e290                	sd	a2,0(a3)
ffffffffc02011bc:	0141                	addi	sp,sp,16
ffffffffc02011be:	8082                	ret
ffffffffc02011c0:	60a2                	ld	ra,8(sp)
ffffffffc02011c2:	e390                	sd	a2,0(a5)
ffffffffc02011c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011c8:	ed1c                	sd	a5,24(a0)
ffffffffc02011ca:	0141                	addi	sp,sp,16
ffffffffc02011cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011ce:	00001697          	auipc	a3,0x1
ffffffffc02011d2:	25268693          	addi	a3,a3,594 # ffffffffc0202420 <commands+0x818>
ffffffffc02011d6:	00001617          	auipc	a2,0x1
ffffffffc02011da:	f3260613          	addi	a2,a2,-206 # ffffffffc0202108 <commands+0x500>
ffffffffc02011de:	45dd                	li	a1,23
ffffffffc02011e0:	00001517          	auipc	a0,0x1
ffffffffc02011e4:	f4050513          	addi	a0,a0,-192 # ffffffffc0202120 <commands+0x518>
ffffffffc02011e8:	902ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02011ec:	00001697          	auipc	a3,0x1
ffffffffc02011f0:	f1468693          	addi	a3,a3,-236 # ffffffffc0202100 <commands+0x4f8>
ffffffffc02011f4:	00001617          	auipc	a2,0x1
ffffffffc02011f8:	f1460613          	addi	a2,a2,-236 # ffffffffc0202108 <commands+0x500>
ffffffffc02011fc:	45d1                	li	a1,20
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	f2250513          	addi	a0,a0,-222 # ffffffffc0202120 <commands+0x518>
ffffffffc0201206:	8e4ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020120a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020120a:	100027f3          	csrr	a5,sstatus
ffffffffc020120e:	8b89                	andi	a5,a5,2
ffffffffc0201210:	e799                	bnez	a5,ffffffffc020121e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201212:	00005797          	auipc	a5,0x5
ffffffffc0201216:	2367b783          	ld	a5,566(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020121a:	6f9c                	ld	a5,24(a5)
ffffffffc020121c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020121e:	1141                	addi	sp,sp,-16
ffffffffc0201220:	e406                	sd	ra,8(sp)
ffffffffc0201222:	e022                	sd	s0,0(sp)
ffffffffc0201224:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201226:	a38ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020122a:	00005797          	auipc	a5,0x5
ffffffffc020122e:	21e7b783          	ld	a5,542(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201232:	6f9c                	ld	a5,24(a5)
ffffffffc0201234:	8522                	mv	a0,s0
ffffffffc0201236:	9782                	jalr	a5
ffffffffc0201238:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020123a:	a1eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020123e:	60a2                	ld	ra,8(sp)
ffffffffc0201240:	8522                	mv	a0,s0
ffffffffc0201242:	6402                	ld	s0,0(sp)
ffffffffc0201244:	0141                	addi	sp,sp,16
ffffffffc0201246:	8082                	ret

ffffffffc0201248 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201248:	100027f3          	csrr	a5,sstatus
ffffffffc020124c:	8b89                	andi	a5,a5,2
ffffffffc020124e:	e799                	bnez	a5,ffffffffc020125c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201250:	00005797          	auipc	a5,0x5
ffffffffc0201254:	1f87b783          	ld	a5,504(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201258:	739c                	ld	a5,32(a5)
ffffffffc020125a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020125c:	1101                	addi	sp,sp,-32
ffffffffc020125e:	ec06                	sd	ra,24(sp)
ffffffffc0201260:	e822                	sd	s0,16(sp)
ffffffffc0201262:	e426                	sd	s1,8(sp)
ffffffffc0201264:	842a                	mv	s0,a0
ffffffffc0201266:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201268:	9f6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020126c:	00005797          	auipc	a5,0x5
ffffffffc0201270:	1dc7b783          	ld	a5,476(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201274:	739c                	ld	a5,32(a5)
ffffffffc0201276:	85a6                	mv	a1,s1
ffffffffc0201278:	8522                	mv	a0,s0
ffffffffc020127a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020127c:	6442                	ld	s0,16(sp)
ffffffffc020127e:	60e2                	ld	ra,24(sp)
ffffffffc0201280:	64a2                	ld	s1,8(sp)
ffffffffc0201282:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201284:	9d4ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201288 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201288:	100027f3          	csrr	a5,sstatus
ffffffffc020128c:	8b89                	andi	a5,a5,2
ffffffffc020128e:	e799                	bnez	a5,ffffffffc020129c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201290:	00005797          	auipc	a5,0x5
ffffffffc0201294:	1b87b783          	ld	a5,440(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201298:	779c                	ld	a5,40(a5)
ffffffffc020129a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020129c:	1141                	addi	sp,sp,-16
ffffffffc020129e:	e406                	sd	ra,8(sp)
ffffffffc02012a0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012a2:	9bcff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012a6:	00005797          	auipc	a5,0x5
ffffffffc02012aa:	1a27b783          	ld	a5,418(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012ae:	779c                	ld	a5,40(a5)
ffffffffc02012b0:	9782                	jalr	a5
ffffffffc02012b2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012b4:	9a4ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012b8:	60a2                	ld	ra,8(sp)
ffffffffc02012ba:	8522                	mv	a0,s0
ffffffffc02012bc:	6402                	ld	s0,0(sp)
ffffffffc02012be:	0141                	addi	sp,sp,16
ffffffffc02012c0:	8082                	ret

ffffffffc02012c2 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012c2:	00001797          	auipc	a5,0x1
ffffffffc02012c6:	18678793          	addi	a5,a5,390 # ffffffffc0202448 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ca:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012cc:	1101                	addi	sp,sp,-32
ffffffffc02012ce:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d0:	00001517          	auipc	a0,0x1
ffffffffc02012d4:	1b050513          	addi	a0,a0,432 # ffffffffc0202480 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012d8:	00005497          	auipc	s1,0x5
ffffffffc02012dc:	17048493          	addi	s1,s1,368 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02012e0:	ec06                	sd	ra,24(sp)
ffffffffc02012e2:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012e4:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012e6:	89aff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    pmm_manager->init();
ffffffffc02012ea:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012ec:	00005417          	auipc	s0,0x5
ffffffffc02012f0:	17440413          	addi	s0,s0,372 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02012f4:	679c                	ld	a5,8(a5)
ffffffffc02012f6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012f8:	57f5                	li	a5,-3
ffffffffc02012fa:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02012fc:	00001517          	auipc	a0,0x1
ffffffffc0201300:	19c50513          	addi	a0,a0,412 # ffffffffc0202498 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201304:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201306:	87aff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020130a:	46c5                	li	a3,17
ffffffffc020130c:	06ee                	slli	a3,a3,0x1b
ffffffffc020130e:	40100613          	li	a2,1025
ffffffffc0201312:	16fd                	addi	a3,a3,-1
ffffffffc0201314:	07e005b7          	lui	a1,0x7e00
ffffffffc0201318:	0656                	slli	a2,a2,0x15
ffffffffc020131a:	00001517          	auipc	a0,0x1
ffffffffc020131e:	19650513          	addi	a0,a0,406 # ffffffffc02024b0 <best_fit_pmm_manager+0x68>
ffffffffc0201322:	85eff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201326:	777d                	lui	a4,0xfffff
ffffffffc0201328:	00006797          	auipc	a5,0x6
ffffffffc020132c:	14778793          	addi	a5,a5,327 # ffffffffc020746f <end+0xfff>
ffffffffc0201330:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201332:	00005517          	auipc	a0,0x5
ffffffffc0201336:	10650513          	addi	a0,a0,262 # ffffffffc0206438 <npage>
ffffffffc020133a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020133e:	00005597          	auipc	a1,0x5
ffffffffc0201342:	10258593          	addi	a1,a1,258 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201346:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201348:	e19c                	sd	a5,0(a1)
ffffffffc020134a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020134c:	4701                	li	a4,0
ffffffffc020134e:	4885                	li	a7,1
ffffffffc0201350:	fff80837          	lui	a6,0xfff80
ffffffffc0201354:	a011                	j	ffffffffc0201358 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201356:	619c                	ld	a5,0(a1)
ffffffffc0201358:	97b6                	add	a5,a5,a3
ffffffffc020135a:	07a1                	addi	a5,a5,8
ffffffffc020135c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201360:	611c                	ld	a5,0(a0)
ffffffffc0201362:	0705                	addi	a4,a4,1
ffffffffc0201364:	02868693          	addi	a3,a3,40
ffffffffc0201368:	01078633          	add	a2,a5,a6
ffffffffc020136c:	fec765e3          	bltu	a4,a2,ffffffffc0201356 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201370:	6190                	ld	a2,0(a1)
ffffffffc0201372:	00279713          	slli	a4,a5,0x2
ffffffffc0201376:	973e                	add	a4,a4,a5
ffffffffc0201378:	fec006b7          	lui	a3,0xfec00
ffffffffc020137c:	070e                	slli	a4,a4,0x3
ffffffffc020137e:	96b2                	add	a3,a3,a2
ffffffffc0201380:	96ba                	add	a3,a3,a4
ffffffffc0201382:	c0200737          	lui	a4,0xc0200
ffffffffc0201386:	08e6ef63          	bltu	a3,a4,ffffffffc0201424 <pmm_init+0x162>
ffffffffc020138a:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020138c:	45c5                	li	a1,17
ffffffffc020138e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201390:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201392:	04b6e863          	bltu	a3,a1,ffffffffc02013e2 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201396:	609c                	ld	a5,0(s1)
ffffffffc0201398:	7b9c                	ld	a5,48(a5)
ffffffffc020139a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020139c:	00001517          	auipc	a0,0x1
ffffffffc02013a0:	1ac50513          	addi	a0,a0,428 # ffffffffc0202548 <best_fit_pmm_manager+0x100>
ffffffffc02013a4:	fddfe0ef          	jal	ra,ffffffffc0200380 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013a8:	00004597          	auipc	a1,0x4
ffffffffc02013ac:	c5858593          	addi	a1,a1,-936 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013b0:	00005797          	auipc	a5,0x5
ffffffffc02013b4:	0ab7b423          	sd	a1,168(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02013bc:	08f5e063          	bltu	a1,a5,ffffffffc020143c <pmm_init+0x17a>
ffffffffc02013c0:	6010                	ld	a2,0(s0)
}
ffffffffc02013c2:	6442                	ld	s0,16(sp)
ffffffffc02013c4:	60e2                	ld	ra,24(sp)
ffffffffc02013c6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013c8:	40c58633          	sub	a2,a1,a2
ffffffffc02013cc:	00005797          	auipc	a5,0x5
ffffffffc02013d0:	08c7b223          	sd	a2,132(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013d4:	00001517          	auipc	a0,0x1
ffffffffc02013d8:	19450513          	addi	a0,a0,404 # ffffffffc0202568 <best_fit_pmm_manager+0x120>
}
ffffffffc02013dc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013de:	fa3fe06f          	j	ffffffffc0200380 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013e2:	6705                	lui	a4,0x1
ffffffffc02013e4:	177d                	addi	a4,a4,-1
ffffffffc02013e6:	96ba                	add	a3,a3,a4
ffffffffc02013e8:	777d                	lui	a4,0xfffff
ffffffffc02013ea:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013ec:	00c6d513          	srli	a0,a3,0xc
ffffffffc02013f0:	00f57e63          	bgeu	a0,a5,ffffffffc020140c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02013f4:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02013f6:	982a                	add	a6,a6,a0
ffffffffc02013f8:	00281513          	slli	a0,a6,0x2
ffffffffc02013fc:	9542                	add	a0,a0,a6
ffffffffc02013fe:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201400:	8d95                	sub	a1,a1,a3
ffffffffc0201402:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201404:	81b1                	srli	a1,a1,0xc
ffffffffc0201406:	9532                	add	a0,a0,a2
ffffffffc0201408:	9782                	jalr	a5
}
ffffffffc020140a:	b771                	j	ffffffffc0201396 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020140c:	00001617          	auipc	a2,0x1
ffffffffc0201410:	10c60613          	addi	a2,a2,268 # ffffffffc0202518 <best_fit_pmm_manager+0xd0>
ffffffffc0201414:	06b00593          	li	a1,107
ffffffffc0201418:	00001517          	auipc	a0,0x1
ffffffffc020141c:	12050513          	addi	a0,a0,288 # ffffffffc0202538 <best_fit_pmm_manager+0xf0>
ffffffffc0201420:	ecbfe0ef          	jal	ra,ffffffffc02002ea <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201424:	00001617          	auipc	a2,0x1
ffffffffc0201428:	0bc60613          	addi	a2,a2,188 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc020142c:	06e00593          	li	a1,110
ffffffffc0201430:	00001517          	auipc	a0,0x1
ffffffffc0201434:	0d850513          	addi	a0,a0,216 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc0201438:	eb3fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020143c:	86ae                	mv	a3,a1
ffffffffc020143e:	00001617          	auipc	a2,0x1
ffffffffc0201442:	0a260613          	addi	a2,a2,162 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc0201446:	08900593          	li	a1,137
ffffffffc020144a:	00001517          	auipc	a0,0x1
ffffffffc020144e:	0be50513          	addi	a0,a0,190 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc0201452:	e99fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201456 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201456:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020145a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020145c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201460:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201462:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201466:	f022                	sd	s0,32(sp)
ffffffffc0201468:	ec26                	sd	s1,24(sp)
ffffffffc020146a:	e84a                	sd	s2,16(sp)
ffffffffc020146c:	f406                	sd	ra,40(sp)
ffffffffc020146e:	e44e                	sd	s3,8(sp)
ffffffffc0201470:	84aa                	mv	s1,a0
ffffffffc0201472:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201474:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201478:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020147a:	03067e63          	bgeu	a2,a6,ffffffffc02014b6 <printnum+0x60>
ffffffffc020147e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201480:	00805763          	blez	s0,ffffffffc020148e <printnum+0x38>
ffffffffc0201484:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201486:	85ca                	mv	a1,s2
ffffffffc0201488:	854e                	mv	a0,s3
ffffffffc020148a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020148c:	fc65                	bnez	s0,ffffffffc0201484 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020148e:	1a02                	slli	s4,s4,0x20
ffffffffc0201490:	00001797          	auipc	a5,0x1
ffffffffc0201494:	11878793          	addi	a5,a5,280 # ffffffffc02025a8 <best_fit_pmm_manager+0x160>
ffffffffc0201498:	020a5a13          	srli	s4,s4,0x20
ffffffffc020149c:	9a3e                	add	s4,s4,a5
}
ffffffffc020149e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014a4:	70a2                	ld	ra,40(sp)
ffffffffc02014a6:	69a2                	ld	s3,8(sp)
ffffffffc02014a8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014aa:	85ca                	mv	a1,s2
ffffffffc02014ac:	87a6                	mv	a5,s1
}
ffffffffc02014ae:	6942                	ld	s2,16(sp)
ffffffffc02014b0:	64e2                	ld	s1,24(sp)
ffffffffc02014b2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014b4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014b6:	03065633          	divu	a2,a2,a6
ffffffffc02014ba:	8722                	mv	a4,s0
ffffffffc02014bc:	f9bff0ef          	jal	ra,ffffffffc0201456 <printnum>
ffffffffc02014c0:	b7f9                	j	ffffffffc020148e <printnum+0x38>

ffffffffc02014c2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014c2:	7119                	addi	sp,sp,-128
ffffffffc02014c4:	f4a6                	sd	s1,104(sp)
ffffffffc02014c6:	f0ca                	sd	s2,96(sp)
ffffffffc02014c8:	ecce                	sd	s3,88(sp)
ffffffffc02014ca:	e8d2                	sd	s4,80(sp)
ffffffffc02014cc:	e4d6                	sd	s5,72(sp)
ffffffffc02014ce:	e0da                	sd	s6,64(sp)
ffffffffc02014d0:	fc5e                	sd	s7,56(sp)
ffffffffc02014d2:	f06a                	sd	s10,32(sp)
ffffffffc02014d4:	fc86                	sd	ra,120(sp)
ffffffffc02014d6:	f8a2                	sd	s0,112(sp)
ffffffffc02014d8:	f862                	sd	s8,48(sp)
ffffffffc02014da:	f466                	sd	s9,40(sp)
ffffffffc02014dc:	ec6e                	sd	s11,24(sp)
ffffffffc02014de:	892a                	mv	s2,a0
ffffffffc02014e0:	84ae                	mv	s1,a1
ffffffffc02014e2:	8d32                	mv	s10,a2
ffffffffc02014e4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014e6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02014ea:	5b7d                	li	s6,-1
ffffffffc02014ec:	00001a97          	auipc	s5,0x1
ffffffffc02014f0:	0f0a8a93          	addi	s5,s5,240 # ffffffffc02025dc <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014f4:	00001b97          	auipc	s7,0x1
ffffffffc02014f8:	2c4b8b93          	addi	s7,s7,708 # ffffffffc02027b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014fc:	000d4503          	lbu	a0,0(s10)
ffffffffc0201500:	001d0413          	addi	s0,s10,1
ffffffffc0201504:	01350a63          	beq	a0,s3,ffffffffc0201518 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201508:	c121                	beqz	a0,ffffffffc0201548 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020150a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020150c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020150e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201510:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201514:	ff351ae3          	bne	a0,s3,ffffffffc0201508 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201518:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020151c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201520:	4c81                	li	s9,0
ffffffffc0201522:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201524:	5c7d                	li	s8,-1
ffffffffc0201526:	5dfd                	li	s11,-1
ffffffffc0201528:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020152c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020152e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201532:	0ff5f593          	zext.b	a1,a1
ffffffffc0201536:	00140d13          	addi	s10,s0,1
ffffffffc020153a:	04b56263          	bltu	a0,a1,ffffffffc020157e <vprintfmt+0xbc>
ffffffffc020153e:	058a                	slli	a1,a1,0x2
ffffffffc0201540:	95d6                	add	a1,a1,s5
ffffffffc0201542:	4194                	lw	a3,0(a1)
ffffffffc0201544:	96d6                	add	a3,a3,s5
ffffffffc0201546:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201548:	70e6                	ld	ra,120(sp)
ffffffffc020154a:	7446                	ld	s0,112(sp)
ffffffffc020154c:	74a6                	ld	s1,104(sp)
ffffffffc020154e:	7906                	ld	s2,96(sp)
ffffffffc0201550:	69e6                	ld	s3,88(sp)
ffffffffc0201552:	6a46                	ld	s4,80(sp)
ffffffffc0201554:	6aa6                	ld	s5,72(sp)
ffffffffc0201556:	6b06                	ld	s6,64(sp)
ffffffffc0201558:	7be2                	ld	s7,56(sp)
ffffffffc020155a:	7c42                	ld	s8,48(sp)
ffffffffc020155c:	7ca2                	ld	s9,40(sp)
ffffffffc020155e:	7d02                	ld	s10,32(sp)
ffffffffc0201560:	6de2                	ld	s11,24(sp)
ffffffffc0201562:	6109                	addi	sp,sp,128
ffffffffc0201564:	8082                	ret
            padc = '0';
ffffffffc0201566:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201568:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020156c:	846a                	mv	s0,s10
ffffffffc020156e:	00140d13          	addi	s10,s0,1
ffffffffc0201572:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201576:	0ff5f593          	zext.b	a1,a1
ffffffffc020157a:	fcb572e3          	bgeu	a0,a1,ffffffffc020153e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020157e:	85a6                	mv	a1,s1
ffffffffc0201580:	02500513          	li	a0,37
ffffffffc0201584:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201586:	fff44783          	lbu	a5,-1(s0)
ffffffffc020158a:	8d22                	mv	s10,s0
ffffffffc020158c:	f73788e3          	beq	a5,s3,ffffffffc02014fc <vprintfmt+0x3a>
ffffffffc0201590:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201594:	1d7d                	addi	s10,s10,-1
ffffffffc0201596:	ff379de3          	bne	a5,s3,ffffffffc0201590 <vprintfmt+0xce>
ffffffffc020159a:	b78d                	j	ffffffffc02014fc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020159c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015a4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015a6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015aa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015ae:	02d86463          	bltu	a6,a3,ffffffffc02015d6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015b2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015b6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015ba:	0186873b          	addw	a4,a3,s8
ffffffffc02015be:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015c2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015c4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015c8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015ca:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015ce:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015d2:	fed870e3          	bgeu	a6,a3,ffffffffc02015b2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02015d6:	f40ddce3          	bgez	s11,ffffffffc020152e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02015da:	8de2                	mv	s11,s8
ffffffffc02015dc:	5c7d                	li	s8,-1
ffffffffc02015de:	bf81                	j	ffffffffc020152e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02015e0:	fffdc693          	not	a3,s11
ffffffffc02015e4:	96fd                	srai	a3,a3,0x3f
ffffffffc02015e6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ea:	00144603          	lbu	a2,1(s0)
ffffffffc02015ee:	2d81                	sext.w	s11,s11
ffffffffc02015f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015f2:	bf35                	j	ffffffffc020152e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02015f4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015fc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fe:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201600:	bfd9                	j	ffffffffc02015d6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201602:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201604:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201608:	01174463          	blt	a4,a7,ffffffffc0201610 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020160c:	1a088e63          	beqz	a7,ffffffffc02017c8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201610:	000a3603          	ld	a2,0(s4)
ffffffffc0201614:	46c1                	li	a3,16
ffffffffc0201616:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201618:	2781                	sext.w	a5,a5
ffffffffc020161a:	876e                	mv	a4,s11
ffffffffc020161c:	85a6                	mv	a1,s1
ffffffffc020161e:	854a                	mv	a0,s2
ffffffffc0201620:	e37ff0ef          	jal	ra,ffffffffc0201456 <printnum>
            break;
ffffffffc0201624:	bde1                	j	ffffffffc02014fc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201626:	000a2503          	lw	a0,0(s4)
ffffffffc020162a:	85a6                	mv	a1,s1
ffffffffc020162c:	0a21                	addi	s4,s4,8
ffffffffc020162e:	9902                	jalr	s2
            break;
ffffffffc0201630:	b5f1                	j	ffffffffc02014fc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201632:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201634:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201638:	01174463          	blt	a4,a7,ffffffffc0201640 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020163c:	18088163          	beqz	a7,ffffffffc02017be <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201640:	000a3603          	ld	a2,0(s4)
ffffffffc0201644:	46a9                	li	a3,10
ffffffffc0201646:	8a2e                	mv	s4,a1
ffffffffc0201648:	bfc1                	j	ffffffffc0201618 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020164e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201650:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201652:	bdf1                	j	ffffffffc020152e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201654:	85a6                	mv	a1,s1
ffffffffc0201656:	02500513          	li	a0,37
ffffffffc020165a:	9902                	jalr	s2
            break;
ffffffffc020165c:	b545                	j	ffffffffc02014fc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201662:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201664:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201666:	b5e1                	j	ffffffffc020152e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201668:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020166a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020166e:	01174463          	blt	a4,a7,ffffffffc0201676 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201672:	14088163          	beqz	a7,ffffffffc02017b4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201676:	000a3603          	ld	a2,0(s4)
ffffffffc020167a:	46a1                	li	a3,8
ffffffffc020167c:	8a2e                	mv	s4,a1
ffffffffc020167e:	bf69                	j	ffffffffc0201618 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201680:	03000513          	li	a0,48
ffffffffc0201684:	85a6                	mv	a1,s1
ffffffffc0201686:	e03e                	sd	a5,0(sp)
ffffffffc0201688:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020168a:	85a6                	mv	a1,s1
ffffffffc020168c:	07800513          	li	a0,120
ffffffffc0201690:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201692:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201694:	6782                	ld	a5,0(sp)
ffffffffc0201696:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201698:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020169c:	bfb5                	j	ffffffffc0201618 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020169e:	000a3403          	ld	s0,0(s4)
ffffffffc02016a2:	008a0713          	addi	a4,s4,8
ffffffffc02016a6:	e03a                	sd	a4,0(sp)
ffffffffc02016a8:	14040263          	beqz	s0,ffffffffc02017ec <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016ac:	0fb05763          	blez	s11,ffffffffc020179a <vprintfmt+0x2d8>
ffffffffc02016b0:	02d00693          	li	a3,45
ffffffffc02016b4:	0cd79163          	bne	a5,a3,ffffffffc0201776 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016b8:	00044783          	lbu	a5,0(s0)
ffffffffc02016bc:	0007851b          	sext.w	a0,a5
ffffffffc02016c0:	cf85                	beqz	a5,ffffffffc02016f8 <vprintfmt+0x236>
ffffffffc02016c2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016c6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ca:	000c4563          	bltz	s8,ffffffffc02016d4 <vprintfmt+0x212>
ffffffffc02016ce:	3c7d                	addiw	s8,s8,-1
ffffffffc02016d0:	036c0263          	beq	s8,s6,ffffffffc02016f4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02016d4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016d6:	0e0c8e63          	beqz	s9,ffffffffc02017d2 <vprintfmt+0x310>
ffffffffc02016da:	3781                	addiw	a5,a5,-32
ffffffffc02016dc:	0ef47b63          	bgeu	s0,a5,ffffffffc02017d2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02016e0:	03f00513          	li	a0,63
ffffffffc02016e4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016e6:	000a4783          	lbu	a5,0(s4)
ffffffffc02016ea:	3dfd                	addiw	s11,s11,-1
ffffffffc02016ec:	0a05                	addi	s4,s4,1
ffffffffc02016ee:	0007851b          	sext.w	a0,a5
ffffffffc02016f2:	ffe1                	bnez	a5,ffffffffc02016ca <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02016f4:	01b05963          	blez	s11,ffffffffc0201706 <vprintfmt+0x244>
ffffffffc02016f8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02016fa:	85a6                	mv	a1,s1
ffffffffc02016fc:	02000513          	li	a0,32
ffffffffc0201700:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201702:	fe0d9be3          	bnez	s11,ffffffffc02016f8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201706:	6a02                	ld	s4,0(sp)
ffffffffc0201708:	bbd5                	j	ffffffffc02014fc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020170a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020170c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201710:	01174463          	blt	a4,a7,ffffffffc0201718 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201714:	08088d63          	beqz	a7,ffffffffc02017ae <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201718:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020171c:	0a044d63          	bltz	s0,ffffffffc02017d6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201720:	8622                	mv	a2,s0
ffffffffc0201722:	8a66                	mv	s4,s9
ffffffffc0201724:	46a9                	li	a3,10
ffffffffc0201726:	bdcd                	j	ffffffffc0201618 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201728:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020172c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020172e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201730:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201734:	8fb5                	xor	a5,a5,a3
ffffffffc0201736:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020173a:	02d74163          	blt	a4,a3,ffffffffc020175c <vprintfmt+0x29a>
ffffffffc020173e:	00369793          	slli	a5,a3,0x3
ffffffffc0201742:	97de                	add	a5,a5,s7
ffffffffc0201744:	639c                	ld	a5,0(a5)
ffffffffc0201746:	cb99                	beqz	a5,ffffffffc020175c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201748:	86be                	mv	a3,a5
ffffffffc020174a:	00001617          	auipc	a2,0x1
ffffffffc020174e:	e8e60613          	addi	a2,a2,-370 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201752:	85a6                	mv	a1,s1
ffffffffc0201754:	854a                	mv	a0,s2
ffffffffc0201756:	0ce000ef          	jal	ra,ffffffffc0201824 <printfmt>
ffffffffc020175a:	b34d                	j	ffffffffc02014fc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020175c:	00001617          	auipc	a2,0x1
ffffffffc0201760:	e6c60613          	addi	a2,a2,-404 # ffffffffc02025c8 <best_fit_pmm_manager+0x180>
ffffffffc0201764:	85a6                	mv	a1,s1
ffffffffc0201766:	854a                	mv	a0,s2
ffffffffc0201768:	0bc000ef          	jal	ra,ffffffffc0201824 <printfmt>
ffffffffc020176c:	bb41                	j	ffffffffc02014fc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020176e:	00001417          	auipc	s0,0x1
ffffffffc0201772:	e5240413          	addi	s0,s0,-430 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201776:	85e2                	mv	a1,s8
ffffffffc0201778:	8522                	mv	a0,s0
ffffffffc020177a:	e43e                	sd	a5,8(sp)
ffffffffc020177c:	1cc000ef          	jal	ra,ffffffffc0201948 <strnlen>
ffffffffc0201780:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201784:	01b05b63          	blez	s11,ffffffffc020179a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201788:	67a2                	ld	a5,8(sp)
ffffffffc020178a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020178e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201790:	85a6                	mv	a1,s1
ffffffffc0201792:	8552                	mv	a0,s4
ffffffffc0201794:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201796:	fe0d9ce3          	bnez	s11,ffffffffc020178e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020179a:	00044783          	lbu	a5,0(s0)
ffffffffc020179e:	00140a13          	addi	s4,s0,1
ffffffffc02017a2:	0007851b          	sext.w	a0,a5
ffffffffc02017a6:	d3a5                	beqz	a5,ffffffffc0201706 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017a8:	05e00413          	li	s0,94
ffffffffc02017ac:	bf39                	j	ffffffffc02016ca <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017ae:	000a2403          	lw	s0,0(s4)
ffffffffc02017b2:	b7ad                	j	ffffffffc020171c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017b4:	000a6603          	lwu	a2,0(s4)
ffffffffc02017b8:	46a1                	li	a3,8
ffffffffc02017ba:	8a2e                	mv	s4,a1
ffffffffc02017bc:	bdb1                	j	ffffffffc0201618 <vprintfmt+0x156>
ffffffffc02017be:	000a6603          	lwu	a2,0(s4)
ffffffffc02017c2:	46a9                	li	a3,10
ffffffffc02017c4:	8a2e                	mv	s4,a1
ffffffffc02017c6:	bd89                	j	ffffffffc0201618 <vprintfmt+0x156>
ffffffffc02017c8:	000a6603          	lwu	a2,0(s4)
ffffffffc02017cc:	46c1                	li	a3,16
ffffffffc02017ce:	8a2e                	mv	s4,a1
ffffffffc02017d0:	b5a1                	j	ffffffffc0201618 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02017d2:	9902                	jalr	s2
ffffffffc02017d4:	bf09                	j	ffffffffc02016e6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02017d6:	85a6                	mv	a1,s1
ffffffffc02017d8:	02d00513          	li	a0,45
ffffffffc02017dc:	e03e                	sd	a5,0(sp)
ffffffffc02017de:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017e0:	6782                	ld	a5,0(sp)
ffffffffc02017e2:	8a66                	mv	s4,s9
ffffffffc02017e4:	40800633          	neg	a2,s0
ffffffffc02017e8:	46a9                	li	a3,10
ffffffffc02017ea:	b53d                	j	ffffffffc0201618 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02017ec:	03b05163          	blez	s11,ffffffffc020180e <vprintfmt+0x34c>
ffffffffc02017f0:	02d00693          	li	a3,45
ffffffffc02017f4:	f6d79de3          	bne	a5,a3,ffffffffc020176e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02017f8:	00001417          	auipc	s0,0x1
ffffffffc02017fc:	dc840413          	addi	s0,s0,-568 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201800:	02800793          	li	a5,40
ffffffffc0201804:	02800513          	li	a0,40
ffffffffc0201808:	00140a13          	addi	s4,s0,1
ffffffffc020180c:	bd6d                	j	ffffffffc02016c6 <vprintfmt+0x204>
ffffffffc020180e:	00001a17          	auipc	s4,0x1
ffffffffc0201812:	db3a0a13          	addi	s4,s4,-589 # ffffffffc02025c1 <best_fit_pmm_manager+0x179>
ffffffffc0201816:	02800513          	li	a0,40
ffffffffc020181a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020181e:	05e00413          	li	s0,94
ffffffffc0201822:	b565                	j	ffffffffc02016ca <vprintfmt+0x208>

ffffffffc0201824 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201824:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201826:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020182a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020182c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020182e:	ec06                	sd	ra,24(sp)
ffffffffc0201830:	f83a                	sd	a4,48(sp)
ffffffffc0201832:	fc3e                	sd	a5,56(sp)
ffffffffc0201834:	e0c2                	sd	a6,64(sp)
ffffffffc0201836:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201838:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020183a:	c89ff0ef          	jal	ra,ffffffffc02014c2 <vprintfmt>
}
ffffffffc020183e:	60e2                	ld	ra,24(sp)
ffffffffc0201840:	6161                	addi	sp,sp,80
ffffffffc0201842:	8082                	ret

ffffffffc0201844 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201844:	715d                	addi	sp,sp,-80
ffffffffc0201846:	e486                	sd	ra,72(sp)
ffffffffc0201848:	e0a6                	sd	s1,64(sp)
ffffffffc020184a:	fc4a                	sd	s2,56(sp)
ffffffffc020184c:	f84e                	sd	s3,48(sp)
ffffffffc020184e:	f452                	sd	s4,40(sp)
ffffffffc0201850:	f056                	sd	s5,32(sp)
ffffffffc0201852:	ec5a                	sd	s6,24(sp)
ffffffffc0201854:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201856:	c901                	beqz	a0,ffffffffc0201866 <readline+0x22>
ffffffffc0201858:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020185a:	00001517          	auipc	a0,0x1
ffffffffc020185e:	d7e50513          	addi	a0,a0,-642 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201862:	b1ffe0ef          	jal	ra,ffffffffc0200380 <cprintf>
readline(const char *prompt) {
ffffffffc0201866:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201868:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020186a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020186c:	4aa9                	li	s5,10
ffffffffc020186e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201870:	00004b97          	auipc	s7,0x4
ffffffffc0201874:	7b8b8b93          	addi	s7,s7,1976 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201878:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020187c:	b7dfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc0201880:	00054a63          	bltz	a0,ffffffffc0201894 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201884:	00a95a63          	bge	s2,a0,ffffffffc0201898 <readline+0x54>
ffffffffc0201888:	029a5263          	bge	s4,s1,ffffffffc02018ac <readline+0x68>
        c = getchar();
ffffffffc020188c:	b6dfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc0201890:	fe055ae3          	bgez	a0,ffffffffc0201884 <readline+0x40>
            return NULL;
ffffffffc0201894:	4501                	li	a0,0
ffffffffc0201896:	a091                	j	ffffffffc02018da <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201898:	03351463          	bne	a0,s3,ffffffffc02018c0 <readline+0x7c>
ffffffffc020189c:	e8a9                	bnez	s1,ffffffffc02018ee <readline+0xaa>
        c = getchar();
ffffffffc020189e:	b5bfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc02018a2:	fe0549e3          	bltz	a0,ffffffffc0201894 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018a6:	fea959e3          	bge	s2,a0,ffffffffc0201898 <readline+0x54>
ffffffffc02018aa:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018ac:	e42a                	sd	a0,8(sp)
ffffffffc02018ae:	b09fe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            buf[i ++] = c;
ffffffffc02018b2:	6522                	ld	a0,8(sp)
ffffffffc02018b4:	009b87b3          	add	a5,s7,s1
ffffffffc02018b8:	2485                	addiw	s1,s1,1
ffffffffc02018ba:	00a78023          	sb	a0,0(a5)
ffffffffc02018be:	bf7d                	j	ffffffffc020187c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018c0:	01550463          	beq	a0,s5,ffffffffc02018c8 <readline+0x84>
ffffffffc02018c4:	fb651ce3          	bne	a0,s6,ffffffffc020187c <readline+0x38>
            cputchar(c);
ffffffffc02018c8:	aeffe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            buf[i] = '\0';
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	75c50513          	addi	a0,a0,1884 # ffffffffc0206028 <buf>
ffffffffc02018d4:	94aa                	add	s1,s1,a0
ffffffffc02018d6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018da:	60a6                	ld	ra,72(sp)
ffffffffc02018dc:	6486                	ld	s1,64(sp)
ffffffffc02018de:	7962                	ld	s2,56(sp)
ffffffffc02018e0:	79c2                	ld	s3,48(sp)
ffffffffc02018e2:	7a22                	ld	s4,40(sp)
ffffffffc02018e4:	7a82                	ld	s5,32(sp)
ffffffffc02018e6:	6b62                	ld	s6,24(sp)
ffffffffc02018e8:	6bc2                	ld	s7,16(sp)
ffffffffc02018ea:	6161                	addi	sp,sp,80
ffffffffc02018ec:	8082                	ret
            cputchar(c);
ffffffffc02018ee:	4521                	li	a0,8
ffffffffc02018f0:	ac7fe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            i --;
ffffffffc02018f4:	34fd                	addiw	s1,s1,-1
ffffffffc02018f6:	b759                	j	ffffffffc020187c <readline+0x38>

ffffffffc02018f8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02018f8:	4781                	li	a5,0
ffffffffc02018fa:	00004717          	auipc	a4,0x4
ffffffffc02018fe:	70e73703          	ld	a4,1806(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201902:	88ba                	mv	a7,a4
ffffffffc0201904:	852a                	mv	a0,a0
ffffffffc0201906:	85be                	mv	a1,a5
ffffffffc0201908:	863e                	mv	a2,a5
ffffffffc020190a:	00000073          	ecall
ffffffffc020190e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201910:	8082                	ret

ffffffffc0201912 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201912:	4781                	li	a5,0
ffffffffc0201914:	00005717          	auipc	a4,0x5
ffffffffc0201918:	b5473703          	ld	a4,-1196(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc020191c:	88ba                	mv	a7,a4
ffffffffc020191e:	852a                	mv	a0,a0
ffffffffc0201920:	85be                	mv	a1,a5
ffffffffc0201922:	863e                	mv	a2,a5
ffffffffc0201924:	00000073          	ecall
ffffffffc0201928:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020192a:	8082                	ret

ffffffffc020192c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020192c:	4501                	li	a0,0
ffffffffc020192e:	00004797          	auipc	a5,0x4
ffffffffc0201932:	6d27b783          	ld	a5,1746(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201936:	88be                	mv	a7,a5
ffffffffc0201938:	852a                	mv	a0,a0
ffffffffc020193a:	85aa                	mv	a1,a0
ffffffffc020193c:	862a                	mv	a2,a0
ffffffffc020193e:	00000073          	ecall
ffffffffc0201942:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201944:	2501                	sext.w	a0,a0
ffffffffc0201946:	8082                	ret

ffffffffc0201948 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201948:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020194a:	e589                	bnez	a1,ffffffffc0201954 <strnlen+0xc>
ffffffffc020194c:	a811                	j	ffffffffc0201960 <strnlen+0x18>
        cnt ++;
ffffffffc020194e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201950:	00f58863          	beq	a1,a5,ffffffffc0201960 <strnlen+0x18>
ffffffffc0201954:	00f50733          	add	a4,a0,a5
ffffffffc0201958:	00074703          	lbu	a4,0(a4)
ffffffffc020195c:	fb6d                	bnez	a4,ffffffffc020194e <strnlen+0x6>
ffffffffc020195e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201960:	852e                	mv	a0,a1
ffffffffc0201962:	8082                	ret

ffffffffc0201964 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201964:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201968:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020196c:	cb89                	beqz	a5,ffffffffc020197e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020196e:	0505                	addi	a0,a0,1
ffffffffc0201970:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201972:	fee789e3          	beq	a5,a4,ffffffffc0201964 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201976:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020197a:	9d19                	subw	a0,a0,a4
ffffffffc020197c:	8082                	ret
ffffffffc020197e:	4501                	li	a0,0
ffffffffc0201980:	bfed                	j	ffffffffc020197a <strcmp+0x16>

ffffffffc0201982 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201982:	00054783          	lbu	a5,0(a0)
ffffffffc0201986:	c799                	beqz	a5,ffffffffc0201994 <strchr+0x12>
        if (*s == c) {
ffffffffc0201988:	00f58763          	beq	a1,a5,ffffffffc0201996 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020198c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201990:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201992:	fbfd                	bnez	a5,ffffffffc0201988 <strchr+0x6>
    }
    return NULL;
ffffffffc0201994:	4501                	li	a0,0
}
ffffffffc0201996:	8082                	ret

ffffffffc0201998 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201998:	ca01                	beqz	a2,ffffffffc02019a8 <memset+0x10>
ffffffffc020199a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020199c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020199e:	0785                	addi	a5,a5,1
ffffffffc02019a0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019a4:	fec79de3          	bne	a5,a2,ffffffffc020199e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019a8:	8082                	ret


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
ffffffffc020004a:	36f010ef          	jal	ra,ffffffffc0201bb8 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(NKUs.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0201bd0 <etext+0x6>
ffffffffc020005a:	35e000ef          	jal	ra,ffffffffc02003b8 <cputs>

    print_kerninfo();
ffffffffc020005e:	01a000ef          	jal	ra,ffffffffc0200078 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	47c010ef          	jal	ra,ffffffffc02014e2 <pmm_init>

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
ffffffffc020007e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0201bf0 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200082:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200084:	2fc000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200088:	00000597          	auipc	a1,0x0
ffffffffc020008c:	faa58593          	addi	a1,a1,-86 # ffffffffc0200032 <kern_init>
ffffffffc0200090:	00002517          	auipc	a0,0x2
ffffffffc0200094:	b8050513          	addi	a0,a0,-1152 # ffffffffc0201c10 <etext+0x46>
ffffffffc0200098:	2e8000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020009c:	00002597          	auipc	a1,0x2
ffffffffc02000a0:	b2e58593          	addi	a1,a1,-1234 # ffffffffc0201bca <etext>
ffffffffc02000a4:	00002517          	auipc	a0,0x2
ffffffffc02000a8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0201c30 <etext+0x66>
ffffffffc02000ac:	2d4000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02000b0:	00006597          	auipc	a1,0x6
ffffffffc02000b4:	f6058593          	addi	a1,a1,-160 # ffffffffc0206010 <free_area>
ffffffffc02000b8:	00002517          	auipc	a0,0x2
ffffffffc02000bc:	b9850513          	addi	a0,a0,-1128 # ffffffffc0201c50 <etext+0x86>
ffffffffc02000c0:	2c0000ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02000c4:	00006597          	auipc	a1,0x6
ffffffffc02000c8:	3ac58593          	addi	a1,a1,940 # ffffffffc0206470 <end>
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	ba450513          	addi	a0,a0,-1116 # ffffffffc0201c70 <etext+0xa6>
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
ffffffffc02000fe:	b9650513          	addi	a0,a0,-1130 # ffffffffc0201c90 <etext+0xc6>
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
ffffffffc020010c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0201cc0 <etext+0xf6>
ffffffffc0200110:	04e00593          	li	a1,78
ffffffffc0200114:	00002517          	auipc	a0,0x2
ffffffffc0200118:	bc450513          	addi	a0,a0,-1084 # ffffffffc0201cd8 <etext+0x10e>
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
ffffffffc0200128:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0201cf0 <etext+0x126>
ffffffffc020012c:	00002597          	auipc	a1,0x2
ffffffffc0200130:	be458593          	addi	a1,a1,-1052 # ffffffffc0201d10 <etext+0x146>
ffffffffc0200134:	00002517          	auipc	a0,0x2
ffffffffc0200138:	be450513          	addi	a0,a0,-1052 # ffffffffc0201d18 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020013c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020013e:	242000ef          	jal	ra,ffffffffc0200380 <cprintf>
ffffffffc0200142:	00002617          	auipc	a2,0x2
ffffffffc0200146:	be660613          	addi	a2,a2,-1050 # ffffffffc0201d28 <etext+0x15e>
ffffffffc020014a:	00002597          	auipc	a1,0x2
ffffffffc020014e:	c0658593          	addi	a1,a1,-1018 # ffffffffc0201d50 <etext+0x186>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	bc650513          	addi	a0,a0,-1082 # ffffffffc0201d18 <etext+0x14e>
ffffffffc020015a:	226000ef          	jal	ra,ffffffffc0200380 <cprintf>
ffffffffc020015e:	00002617          	auipc	a2,0x2
ffffffffc0200162:	c0260613          	addi	a2,a2,-1022 # ffffffffc0201d60 <etext+0x196>
ffffffffc0200166:	00002597          	auipc	a1,0x2
ffffffffc020016a:	c1a58593          	addi	a1,a1,-998 # ffffffffc0201d80 <etext+0x1b6>
ffffffffc020016e:	00002517          	auipc	a0,0x2
ffffffffc0200172:	baa50513          	addi	a0,a0,-1110 # ffffffffc0201d18 <etext+0x14e>
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
ffffffffc02001ac:	be850513          	addi	a0,a0,-1048 # ffffffffc0201d90 <etext+0x1c6>
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
ffffffffc02001ce:	bee50513          	addi	a0,a0,-1042 # ffffffffc0201db8 <etext+0x1ee>
ffffffffc02001d2:	1ae000ef          	jal	ra,ffffffffc0200380 <cprintf>
    if (tf != NULL) {
ffffffffc02001d6:	000b8563          	beqz	s7,ffffffffc02001e0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02001da:	855e                	mv	a0,s7
ffffffffc02001dc:	466000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02001e0:	00002c17          	auipc	s8,0x2
ffffffffc02001e4:	c48c0c13          	addi	s8,s8,-952 # ffffffffc0201e28 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02001e8:	00002917          	auipc	s2,0x2
ffffffffc02001ec:	bf890913          	addi	s2,s2,-1032 # ffffffffc0201de0 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02001f0:	00002497          	auipc	s1,0x2
ffffffffc02001f4:	bf848493          	addi	s1,s1,-1032 # ffffffffc0201de8 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02001f8:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02001fa:	00002b17          	auipc	s6,0x2
ffffffffc02001fe:	bf6b0b13          	addi	s6,s6,-1034 # ffffffffc0201df0 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc0200202:	00002a17          	auipc	s4,0x2
ffffffffc0200206:	b0ea0a13          	addi	s4,s4,-1266 # ffffffffc0201d10 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020020a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020020c:	854a                	mv	a0,s2
ffffffffc020020e:	057010ef          	jal	ra,ffffffffc0201a64 <readline>
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
ffffffffc0200228:	c04d0d13          	addi	s10,s10,-1020 # ffffffffc0201e28 <commands>
        argv[argc ++] = buf;
ffffffffc020022c:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020022e:	4401                	li	s0,0
ffffffffc0200230:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200232:	153010ef          	jal	ra,ffffffffc0201b84 <strcmp>
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
ffffffffc0200246:	13f010ef          	jal	ra,ffffffffc0201b84 <strcmp>
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
ffffffffc0200284:	11f010ef          	jal	ra,ffffffffc0201ba2 <strchr>
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
ffffffffc02002c2:	0e1010ef          	jal	ra,ffffffffc0201ba2 <strchr>
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
ffffffffc02002e0:	b3450513          	addi	a0,a0,-1228 # ffffffffc0201e10 <etext+0x246>
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
ffffffffc020031c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0201e70 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200320:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200322:	05e000ef          	jal	ra,ffffffffc0200380 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200326:	65a2                	ld	a1,8(sp)
ffffffffc0200328:	8522                	mv	a0,s0
ffffffffc020032a:	036000ef          	jal	ra,ffffffffc0200360 <vcprintf>
    cprintf("\n");
ffffffffc020032e:	00002517          	auipc	a0,0x2
ffffffffc0200332:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201cb8 <etext+0xee>
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
ffffffffc0200374:	36e010ef          	jal	ra,ffffffffc02016e2 <vprintfmt>
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
ffffffffc02003aa:	338010ef          	jal	ra,ffffffffc02016e2 <vprintfmt>
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
ffffffffc0200420:	712010ef          	jal	ra,ffffffffc0201b32 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201e90 <commands+0x68>
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
ffffffffc0200446:	6ec0106f          	j	ffffffffc0201b32 <sbi_set_timer>

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
ffffffffc0200450:	6c80106f          	j	ffffffffc0201b18 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	6f80106f          	j	ffffffffc0201b4c <sbi_console_getchar>

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
ffffffffc0200482:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201eb0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	ef9ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201ec8 <commands+0xa0>
ffffffffc0200496:	eebff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0201ee0 <commands+0xb8>
ffffffffc02004a4:	eddff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201ef8 <commands+0xd0>
ffffffffc02004b2:	ecfff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0201f10 <commands+0xe8>
ffffffffc02004c0:	ec1ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201f28 <commands+0x100>
ffffffffc02004ce:	eb3ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201f40 <commands+0x118>
ffffffffc02004dc:	ea5ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0201f58 <commands+0x130>
ffffffffc02004ea:	e97ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	a8050513          	addi	a0,a0,-1408 # ffffffffc0201f70 <commands+0x148>
ffffffffc02004f8:	e89ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201f88 <commands+0x160>
ffffffffc0200506:	e7bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201fa0 <commands+0x178>
ffffffffc0200514:	e6dff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201fb8 <commands+0x190>
ffffffffc0200522:	e5fff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	aa850513          	addi	a0,a0,-1368 # ffffffffc0201fd0 <commands+0x1a8>
ffffffffc0200530:	e51ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0201fe8 <commands+0x1c0>
ffffffffc020053e:	e43ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	abc50513          	addi	a0,a0,-1348 # ffffffffc0202000 <commands+0x1d8>
ffffffffc020054c:	e35ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	ac650513          	addi	a0,a0,-1338 # ffffffffc0202018 <commands+0x1f0>
ffffffffc020055a:	e27ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	ad050513          	addi	a0,a0,-1328 # ffffffffc0202030 <commands+0x208>
ffffffffc0200568:	e19ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	ada50513          	addi	a0,a0,-1318 # ffffffffc0202048 <commands+0x220>
ffffffffc0200576:	e0bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	ae450513          	addi	a0,a0,-1308 # ffffffffc0202060 <commands+0x238>
ffffffffc0200584:	dfdff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0202078 <commands+0x250>
ffffffffc0200592:	defff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	af850513          	addi	a0,a0,-1288 # ffffffffc0202090 <commands+0x268>
ffffffffc02005a0:	de1ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	b0250513          	addi	a0,a0,-1278 # ffffffffc02020a8 <commands+0x280>
ffffffffc02005ae:	dd3ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02020c0 <commands+0x298>
ffffffffc02005bc:	dc5ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	b1650513          	addi	a0,a0,-1258 # ffffffffc02020d8 <commands+0x2b0>
ffffffffc02005ca:	db7ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	b2050513          	addi	a0,a0,-1248 # ffffffffc02020f0 <commands+0x2c8>
ffffffffc02005d8:	da9ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0202108 <commands+0x2e0>
ffffffffc02005e6:	d9bff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b3450513          	addi	a0,a0,-1228 # ffffffffc0202120 <commands+0x2f8>
ffffffffc02005f4:	d8dff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0202138 <commands+0x310>
ffffffffc0200602:	d7fff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b4850513          	addi	a0,a0,-1208 # ffffffffc0202150 <commands+0x328>
ffffffffc0200610:	d71ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b5250513          	addi	a0,a0,-1198 # ffffffffc0202168 <commands+0x340>
ffffffffc020061e:	d63ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0202180 <commands+0x358>
ffffffffc020062c:	d55ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0202198 <commands+0x370>
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
ffffffffc020064e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021b0 <commands+0x388>
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
ffffffffc0200666:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021c8 <commands+0x3a0>
ffffffffc020066a:	d17ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02021e0 <commands+0x3b8>
ffffffffc020067a:	d07ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b7650513          	addi	a0,a0,-1162 # ffffffffc02021f8 <commands+0x3d0>
ffffffffc020068a:	cf7ff0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0202210 <commands+0x3e8>
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
ffffffffc02006b4:	c4070713          	addi	a4,a4,-960 # ffffffffc02022f0 <commands+0x4c8>
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
ffffffffc02006c6:	bc650513          	addi	a0,a0,-1082 # ffffffffc0202288 <commands+0x460>
ffffffffc02006ca:	b95d                	j	ffffffffc0200380 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0202268 <commands+0x440>
ffffffffc02006d4:	b175                	j	ffffffffc0200380 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	b5250513          	addi	a0,a0,-1198 # ffffffffc0202228 <commands+0x400>
ffffffffc02006de:	b14d                	j	ffffffffc0200380 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	bc850513          	addi	a0,a0,-1080 # ffffffffc02022a8 <commands+0x480>
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
ffffffffc0200714:	bc050513          	addi	a0,a0,-1088 # ffffffffc02022d0 <commands+0x4a8>
ffffffffc0200718:	b1a5                	j	ffffffffc0200380 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0202248 <commands+0x420>
ffffffffc0200722:	b9b9                	j	ffffffffc0200380 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	b9450513          	addi	a0,a0,-1132 # ffffffffc02022c0 <commands+0x498>
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
// 初始化内存管理器
static void
best_fit_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:

static size_t
best_fit_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_check>:
    free_page(p2);
}

static void
best_fit_check(void)
{
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005917          	auipc	s2,0x5
ffffffffc0200826:	7ee90913          	addi	s2,s2,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	00893783          	ld	a5,8(s2)
ffffffffc020082e:	e486                	sd	ra,72(sp)
ffffffffc0200830:	e0a2                	sd	s0,64(sp)
ffffffffc0200832:	fc26                	sd	s1,56(sp)
ffffffffc0200834:	f44e                	sd	s3,40(sp)
ffffffffc0200836:	f052                	sd	s4,32(sp)
ffffffffc0200838:	ec56                	sd	s5,24(sp)
ffffffffc020083a:	e85a                	sd	s6,16(sp)
ffffffffc020083c:	e45e                	sd	s7,8(sp)
ffffffffc020083e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200840:	33278b63          	beq	a5,s2,ffffffffc0200b76 <best_fit_check+0x358>
    int count = 0, total = 0;
ffffffffc0200844:	4401                	li	s0,0
ffffffffc0200846:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200848:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084c:	8b09                	andi	a4,a4,2
ffffffffc020084e:	34070863          	beqz	a4,ffffffffc0200b9e <best_fit_check+0x380>
        count++, total += p->property;
ffffffffc0200852:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200856:	679c                	ld	a5,8(a5)
ffffffffc0200858:	2485                	addiw	s1,s1,1
ffffffffc020085a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020085c:	ff2796e3          	bne	a5,s2,ffffffffc0200848 <best_fit_check+0x2a>
    }
    assert(total == nr_free_pages());
ffffffffc0200860:	89a2                	mv	s3,s0
ffffffffc0200862:	447000ef          	jal	ra,ffffffffc02014a8 <nr_free_pages>
ffffffffc0200866:	5b351c63          	bne	a0,s3,ffffffffc0200e1e <best_fit_check+0x600>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020086a:	4505                	li	a0,1
ffffffffc020086c:	3bf000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200870:	8aaa                	mv	s5,a0
ffffffffc0200872:	76050663          	beqz	a0,ffffffffc0200fde <best_fit_check+0x7c0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200876:	4505                	li	a0,1
ffffffffc0200878:	3b3000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc020087c:	8a2a                	mv	s4,a0
ffffffffc020087e:	74050063          	beqz	a0,ffffffffc0200fbe <best_fit_check+0x7a0>
    assert((p2 = alloc_page()) != NULL);// 通过断言确保每次调用该函数都返回一个有效的指针（即不为 NULL），这表明成功分配了页面。
ffffffffc0200882:	4505                	li	a0,1
ffffffffc0200884:	3a7000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200888:	89aa                	mv	s3,a0
ffffffffc020088a:	4c050a63          	beqz	a0,ffffffffc0200d5e <best_fit_check+0x540>
    assert(p0 != p1 && p0 != p2 && p1 != p2);//确保分配的三个页面是不同的，即每次分配的页面都是唯一的。
ffffffffc020088e:	7b4a8863          	beq	s5,s4,ffffffffc020103e <best_fit_check+0x820>
ffffffffc0200892:	7aaa8663          	beq	s5,a0,ffffffffc020103e <best_fit_check+0x820>
ffffffffc0200896:	7aaa0463          	beq	s4,a0,ffffffffc020103e <best_fit_check+0x820>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);//确保每个页面的引用计数都初始化为0。这通常意味着页面尚未被任何其他结构引用。
ffffffffc020089a:	000aa783          	lw	a5,0(s5)
ffffffffc020089e:	78079063          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
ffffffffc02008a2:	000a2783          	lw	a5,0(s4)
ffffffffc02008a6:	76079c63          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
ffffffffc02008aa:	411c                	lw	a5,0(a0)
ffffffffc02008ac:	76079963          	bnez	a5,ffffffffc020101e <best_fit_check+0x800>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008b0:	00006797          	auipc	a5,0x6
ffffffffc02008b4:	b907b783          	ld	a5,-1136(a5) # ffffffffc0206440 <pages>
ffffffffc02008b8:	40fa8733          	sub	a4,s5,a5
ffffffffc02008bc:	870d                	srai	a4,a4,0x3
ffffffffc02008be:	00002597          	auipc	a1,0x2
ffffffffc02008c2:	1b25b583          	ld	a1,434(a1) # ffffffffc0202a70 <error_string+0x38>
ffffffffc02008c6:	02b70733          	mul	a4,a4,a1
ffffffffc02008ca:	00002617          	auipc	a2,0x2
ffffffffc02008ce:	1ae63603          	ld	a2,430(a2) # ffffffffc0202a78 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d2:	00006697          	auipc	a3,0x6
ffffffffc02008d6:	b666b683          	ld	a3,-1178(a3) # ffffffffc0206438 <npage>
ffffffffc02008da:	06b2                	slli	a3,a3,0xc
ffffffffc02008dc:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008de:	0732                	slli	a4,a4,0xc
ffffffffc02008e0:	70d77f63          	bgeu	a4,a3,ffffffffc0200ffe <best_fit_check+0x7e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e4:	40fa0733          	sub	a4,s4,a5
ffffffffc02008e8:	870d                	srai	a4,a4,0x3
ffffffffc02008ea:	02b70733          	mul	a4,a4,a1
ffffffffc02008ee:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008f0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f2:	56d77663          	bgeu	a4,a3,ffffffffc0200e5e <best_fit_check+0x640>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f6:	40f507b3          	sub	a5,a0,a5
ffffffffc02008fa:	878d                	srai	a5,a5,0x3
ffffffffc02008fc:	02b787b3          	mul	a5,a5,a1
ffffffffc0200900:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200902:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);//检查每个页面的物理地址是否在有效范围内。确保地址小于总页数乘以每页大小。
ffffffffc0200904:	32d7fd63          	bgeu	a5,a3,ffffffffc0200c3e <best_fit_check+0x420>
    assert(alloc_page() == NULL);//由于没有可用的页面，分配页面应该返回 NULL
ffffffffc0200908:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020090a:	00093c03          	ld	s8,0(s2)
ffffffffc020090e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200912:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200916:	01293423          	sd	s2,8(s2)
ffffffffc020091a:	01293023          	sd	s2,0(s2)
    nr_free = 0;
ffffffffc020091e:	00005797          	auipc	a5,0x5
ffffffffc0200922:	7007a123          	sw	zero,1794(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);//由于没有可用的页面，分配页面应该返回 NULL
ffffffffc0200926:	305000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc020092a:	2e051a63          	bnez	a0,ffffffffc0200c1e <best_fit_check+0x400>
    free_page(p0);
ffffffffc020092e:	4585                	li	a1,1
ffffffffc0200930:	8556                	mv	a0,s5
ffffffffc0200932:	337000ef          	jal	ra,ffffffffc0201468 <free_pages>
    free_page(p1);
ffffffffc0200936:	4585                	li	a1,1
ffffffffc0200938:	8552                	mv	a0,s4
ffffffffc020093a:	32f000ef          	jal	ra,ffffffffc0201468 <free_pages>
    free_page(p2);
ffffffffc020093e:	4585                	li	a1,1
ffffffffc0200940:	854e                	mv	a0,s3
ffffffffc0200942:	327000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(nr_free == 3);//确保释放后，空闲页面数量正确
ffffffffc0200946:	01092703          	lw	a4,16(s2)
ffffffffc020094a:	478d                	li	a5,3
ffffffffc020094c:	2af71963          	bne	a4,a5,ffffffffc0200bfe <best_fit_check+0x3e0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200950:	4505                	li	a0,1
ffffffffc0200952:	2d9000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200956:	89aa                	mv	s3,a0
ffffffffc0200958:	28050363          	beqz	a0,ffffffffc0200bde <best_fit_check+0x3c0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020095c:	4505                	li	a0,1
ffffffffc020095e:	2cd000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200962:	8aaa                	mv	s5,a0
ffffffffc0200964:	30050d63          	beqz	a0,ffffffffc0200c7e <best_fit_check+0x460>
    assert((p2 = alloc_page()) != NULL);//再次尝试分配页面，检查是否能够成功分配并且返回的页面是否与之前释放的页面一致。
ffffffffc0200968:	4505                	li	a0,1
ffffffffc020096a:	2c1000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc020096e:	8a2a                	mv	s4,a0
ffffffffc0200970:	2e050763          	beqz	a0,ffffffffc0200c5e <best_fit_check+0x440>
    assert(alloc_page() == NULL);//当所有的页框都已分配后，调用 alloc_page() 应该返回 NULL
ffffffffc0200974:	4505                	li	a0,1
ffffffffc0200976:	2b5000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc020097a:	40051263          	bnez	a0,ffffffffc0200d7e <best_fit_check+0x560>
    free_page(p0);
ffffffffc020097e:	4585                	li	a1,1
ffffffffc0200980:	854e                	mv	a0,s3
ffffffffc0200982:	2e7000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(!list_empty(&free_list));//确保在释放 p0 后，空闲链表 free_list 不为空。因为刚刚释放了一个页框，所以空闲链表应该包含至少一个元素。
ffffffffc0200986:	00893783          	ld	a5,8(s2)
ffffffffc020098a:	23278a63          	beq	a5,s2,ffffffffc0200bbe <best_fit_check+0x3a0>
    assert((p = alloc_page()) == p0);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	29b000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200994:	36a99563          	bne	s3,a0,ffffffffc0200cfe <best_fit_check+0x4e0>
    assert(alloc_page() == NULL);//再次调用 alloc_page() 以分配内存。这里期望返回的页框是 p0，也就是说 p0 应该在释放后重新分配给我们。如果分配的页框不是 p0，则说明内存管理有问题，程序会抛出异常。
ffffffffc0200998:	4505                	li	a0,1
ffffffffc020099a:	291000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc020099e:	34051063          	bnez	a0,ffffffffc0200cde <best_fit_check+0x4c0>
    assert(nr_free == 0);
ffffffffc02009a2:	01092783          	lw	a5,16(s2)
ffffffffc02009a6:	30079c63          	bnez	a5,ffffffffc0200cbe <best_fit_check+0x4a0>
    free_page(p);
ffffffffc02009aa:	854e                	mv	a0,s3
ffffffffc02009ac:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009ae:	01893023          	sd	s8,0(s2)
ffffffffc02009b2:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;//将 free_list 恢复到测试开始之前的状态，意味着恢复之前的空闲链表。这是为了清理环境，以便后续的测试不会受到影响。
ffffffffc02009b6:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc02009ba:	2af000ef          	jal	ra,ffffffffc0201468 <free_pages>
    free_page(p1);
ffffffffc02009be:	4585                	li	a1,1
ffffffffc02009c0:	8556                	mv	a0,s5
ffffffffc02009c2:	2a7000ef          	jal	ra,ffffffffc0201468 <free_pages>
    free_page(p2);
ffffffffc02009c6:	4585                	li	a1,1
ffffffffc02009c8:	8552                	mv	a0,s4
ffffffffc02009ca:	29f000ef          	jal	ra,ffffffffc0201468 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(26), *p1;
ffffffffc02009ce:	4569                	li	a0,26
ffffffffc02009d0:	25b000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc02009d4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009d6:	2c050463          	beqz	a0,ffffffffc0200c9e <best_fit_check+0x480>
ffffffffc02009da:	651c                	ld	a5,8(a0)
ffffffffc02009dc:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009de:	8b85                	andi	a5,a5,1
ffffffffc02009e0:	34079f63          	bnez	a5,ffffffffc0200d3e <best_fit_check+0x520>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009e4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009e6:	00093a83          	ld	s5,0(s2)
ffffffffc02009ea:	00893a03          	ld	s4,8(s2)
ffffffffc02009ee:	01293023          	sd	s2,0(s2)
ffffffffc02009f2:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02009f6:	235000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc02009fa:	32051263          	bnez	a0,ffffffffc0200d1e <best_fit_check+0x500>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    //.........................................................
    // 先释放
    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
ffffffffc02009fe:	45e9                	li	a1,26
ffffffffc0200a00:	854e                	mv	a0,s3
    unsigned int nr_free_store = nr_free;
ffffffffc0200a02:	01092b03          	lw	s6,16(s2)
    nr_free = 0;
ffffffffc0200a06:	00005797          	auipc	a5,0x5
ffffffffc0200a0a:	6007ad23          	sw	zero,1562(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
ffffffffc0200a0e:	25b000ef          	jal	ra,ffffffffc0201468 <free_pages>
    // 首先检查是否对齐2
    p0 = alloc_pages(6);  // 8- 8+ 16+
ffffffffc0200a12:	4519                	li	a0,6
ffffffffc0200a14:	217000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200a18:	89aa                	mv	s3,a0
    p1 = alloc_pages(10); // 8- 8+ 16-
ffffffffc0200a1a:	4529                	li	a0,10
ffffffffc0200a1c:	20f000ef          	jal	ra,ffffffffc020142a <alloc_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a20:	1509ac03          	lw	s8,336(s3)
ffffffffc0200a24:	47a1                	li	a5,8
    p1 = alloc_pages(10); // 8- 8+ 16-
ffffffffc0200a26:	8baa                	mv	s7,a0
    assert((p0 + 8)->property == 8);
ffffffffc0200a28:	54fc1b63          	bne	s8,a5,ffffffffc0200f7e <best_fit_check+0x760>
    free_pages(p1, 10); // 8- 8+ 16+
ffffffffc0200a2c:	45a9                	li	a1,10
ffffffffc0200a2e:	23b000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a32:	1509a783          	lw	a5,336(s3)
ffffffffc0200a36:	53879463          	bne	a5,s8,ffffffffc0200f5e <best_fit_check+0x740>
    assert(p1->property == 16);
ffffffffc0200a3a:	010bac03          	lw	s8,16(s7)
ffffffffc0200a3e:	47c1                	li	a5,16
ffffffffc0200a40:	4efc1f63          	bne	s8,a5,ffffffffc0200f3e <best_fit_check+0x720>
    p1 = alloc_pages(16); // 8- 8+ 16-
ffffffffc0200a44:	4541                	li	a0,16
ffffffffc0200a46:	1e5000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200a4a:	8baa                	mv	s7,a0
    // 之后检查合并
    free_pages(p0, 6); // 16+ 16-
ffffffffc0200a4c:	4599                	li	a1,6
ffffffffc0200a4e:	854e                	mv	a0,s3
ffffffffc0200a50:	219000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(p0->property == 16);
ffffffffc0200a54:	0109a783          	lw	a5,16(s3)
ffffffffc0200a58:	4d879363          	bne	a5,s8,ffffffffc0200f1e <best_fit_check+0x700>
    free_pages(p1, 16); // 32+
ffffffffc0200a5c:	45c1                	li	a1,16
ffffffffc0200a5e:	855e                	mv	a0,s7
ffffffffc0200a60:	209000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(p0->property == 32);
ffffffffc0200a64:	0109ac03          	lw	s8,16(s3)
ffffffffc0200a68:	02000793          	li	a5,32
ffffffffc0200a6c:	48fc1963          	bne	s8,a5,ffffffffc0200efe <best_fit_check+0x6e0>

    p0 = alloc_pages(8); // 8- 8+ 16+
ffffffffc0200a70:	4521                	li	a0,8
ffffffffc0200a72:	1b9000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200a76:	89aa                	mv	s3,a0
    p1 = alloc_pages(9); // 8- 8+ 16-
ffffffffc0200a78:	4525                	li	a0,9
ffffffffc0200a7a:	1b1000ef          	jal	ra,ffffffffc020142a <alloc_pages>
    free_pages(p1, 9);   // 8- 8+ 16+
ffffffffc0200a7e:	45a5                	li	a1,9
    p1 = alloc_pages(9); // 8- 8+ 16-
ffffffffc0200a80:	8baa                	mv	s7,a0
    free_pages(p1, 9);   // 8- 8+ 16+
ffffffffc0200a82:	1e7000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(p1->property == 16);
ffffffffc0200a86:	010ba703          	lw	a4,16(s7)
ffffffffc0200a8a:	47c1                	li	a5,16
ffffffffc0200a8c:	44f71963          	bne	a4,a5,ffffffffc0200ede <best_fit_check+0x6c0>
    assert((p0 + 8)->property == 8);
ffffffffc0200a90:	1509a703          	lw	a4,336(s3)
ffffffffc0200a94:	47a1                	li	a5,8
ffffffffc0200a96:	42f71463          	bne	a4,a5,ffffffffc0200ebe <best_fit_check+0x6a0>
    free_pages(p0, 8); // 32+
ffffffffc0200a9a:	45a1                	li	a1,8
ffffffffc0200a9c:	854e                	mv	a0,s3
ffffffffc0200a9e:	1cb000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(p0->property == 32);
ffffffffc0200aa2:	0109a783          	lw	a5,16(s3)
ffffffffc0200aa6:	3f879c63          	bne	a5,s8,ffffffffc0200e9e <best_fit_check+0x680>
    // 检测链表顺序是否按照块的大小排序的
    p0 = alloc_pages(5);
ffffffffc0200aaa:	4515                	li	a0,5
ffffffffc0200aac:	17f000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200ab0:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200ab2:	4541                	li	a0,16
ffffffffc0200ab4:	177000ef          	jal	ra,ffffffffc020142a <alloc_pages>
    free_pages(p1, 16);
ffffffffc0200ab8:	45c1                	li	a1,16
    p1 = alloc_pages(16);
ffffffffc0200aba:	8baa                	mv	s7,a0
    free_pages(p1, 16);
ffffffffc0200abc:	1ad000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200ac0:	00893783          	ld	a5,8(s2)
ffffffffc0200ac4:	ed8b8b93          	addi	s7,s7,-296
ffffffffc0200ac8:	3b779b63          	bne	a5,s7,ffffffffc0200e7e <best_fit_check+0x660>
    free_pages(p0, 5);
ffffffffc0200acc:	854e                	mv	a0,s3
ffffffffc0200ace:	4595                	li	a1,5
ffffffffc0200ad0:	199000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200ad4:	00893783          	ld	a5,8(s2)
ffffffffc0200ad8:	09e1                	addi	s3,s3,24
ffffffffc0200ada:	31379263          	bne	a5,s3,ffffffffc0200dde <best_fit_check+0x5c0>

    p0 = alloc_pages(5);
ffffffffc0200ade:	4515                	li	a0,5
ffffffffc0200ae0:	14b000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200ae4:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200ae6:	4541                	li	a0,16
ffffffffc0200ae8:	143000ef          	jal	ra,ffffffffc020142a <alloc_pages>
ffffffffc0200aec:	8baa                	mv	s7,a0
    free_pages(p0, 5);
ffffffffc0200aee:	4595                	li	a1,5
ffffffffc0200af0:	854e                	mv	a0,s3
ffffffffc0200af2:	177000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200af6:	00893783          	ld	a5,8(s2)
ffffffffc0200afa:	09e1                	addi	s3,s3,24
ffffffffc0200afc:	2cf99163          	bne	s3,a5,ffffffffc0200dbe <best_fit_check+0x5a0>
    free_pages(p1, 16);
ffffffffc0200b00:	45c1                	li	a1,16
ffffffffc0200b02:	855e                	mv	a0,s7
ffffffffc0200b04:	165000ef          	jal	ra,ffffffffc0201468 <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200b08:	00893783          	ld	a5,8(s2)
ffffffffc0200b0c:	28f99963          	bne	s3,a5,ffffffffc0200d9e <best_fit_check+0x580>

    // 还原
    p0 = alloc_pages(26);
ffffffffc0200b10:	4569                	li	a0,26
ffffffffc0200b12:	119000ef          	jal	ra,ffffffffc020142a <alloc_pages>
    //.........................................................
    assert(nr_free == 0);
ffffffffc0200b16:	01092783          	lw	a5,16(s2)
ffffffffc0200b1a:	32079263          	bnez	a5,ffffffffc0200e3e <best_fit_check+0x620>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 26);
ffffffffc0200b1e:	45e9                	li	a1,26
    nr_free = nr_free_store;
ffffffffc0200b20:	01692823          	sw	s6,16(s2)
    free_list = free_list_store;
ffffffffc0200b24:	01593023          	sd	s5,0(s2)
ffffffffc0200b28:	01493423          	sd	s4,8(s2)
    free_pages(p0, 26);
ffffffffc0200b2c:	13d000ef          	jal	ra,ffffffffc0201468 <free_pages>
    return listelm->next;
ffffffffc0200b30:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b34:	03278163          	beq	a5,s2,ffffffffc0200b56 <best_fit_check+0x338>
    {
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200b38:	86be                	mv	a3,a5
ffffffffc0200b3a:	679c                	ld	a5,8(a5)
ffffffffc0200b3c:	6398                	ld	a4,0(a5)
ffffffffc0200b3e:	04d71063          	bne	a4,a3,ffffffffc0200b7e <best_fit_check+0x360>
ffffffffc0200b42:	6314                	ld	a3,0(a4)
ffffffffc0200b44:	6694                	ld	a3,8(a3)
ffffffffc0200b46:	02e69c63          	bne	a3,a4,ffffffffc0200b7e <best_fit_check+0x360>
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0200b4a:	ff86a703          	lw	a4,-8(a3)
ffffffffc0200b4e:	34fd                	addiw	s1,s1,-1
ffffffffc0200b50:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b52:	ff2793e3          	bne	a5,s2,ffffffffc0200b38 <best_fit_check+0x31a>
    }
    assert(count == 0);
ffffffffc0200b56:	44049463          	bnez	s1,ffffffffc0200f9e <best_fit_check+0x780>
    assert(total == 0);
ffffffffc0200b5a:	2a041263          	bnez	s0,ffffffffc0200dfe <best_fit_check+0x5e0>
}
ffffffffc0200b5e:	60a6                	ld	ra,72(sp)
ffffffffc0200b60:	6406                	ld	s0,64(sp)
ffffffffc0200b62:	74e2                	ld	s1,56(sp)
ffffffffc0200b64:	7942                	ld	s2,48(sp)
ffffffffc0200b66:	79a2                	ld	s3,40(sp)
ffffffffc0200b68:	7a02                	ld	s4,32(sp)
ffffffffc0200b6a:	6ae2                	ld	s5,24(sp)
ffffffffc0200b6c:	6b42                	ld	s6,16(sp)
ffffffffc0200b6e:	6ba2                	ld	s7,8(sp)
ffffffffc0200b70:	6c02                	ld	s8,0(sp)
ffffffffc0200b72:	6161                	addi	sp,sp,80
ffffffffc0200b74:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b76:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b78:	4401                	li	s0,0
ffffffffc0200b7a:	4481                	li	s1,0
ffffffffc0200b7c:	b1dd                	j	ffffffffc0200862 <best_fit_check+0x44>
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200b7e:	00002697          	auipc	a3,0x2
ffffffffc0200b82:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0202608 <commands+0x7e0>
ffffffffc0200b86:	00001617          	auipc	a2,0x1
ffffffffc0200b8a:	7aa60613          	addi	a2,a2,1962 # ffffffffc0202330 <commands+0x508>
ffffffffc0200b8e:	14e00593          	li	a1,334
ffffffffc0200b92:	00001517          	auipc	a0,0x1
ffffffffc0200b96:	7b650513          	addi	a0,a0,1974 # ffffffffc0202348 <commands+0x520>
ffffffffc0200b9a:	f50ff0ef          	jal	ra,ffffffffc02002ea <__panic>
        assert(PageProperty(p));
ffffffffc0200b9e:	00001697          	auipc	a3,0x1
ffffffffc0200ba2:	78268693          	addi	a3,a3,1922 # ffffffffc0202320 <commands+0x4f8>
ffffffffc0200ba6:	00001617          	auipc	a2,0x1
ffffffffc0200baa:	78a60613          	addi	a2,a2,1930 # ffffffffc0202330 <commands+0x508>
ffffffffc0200bae:	10900593          	li	a1,265
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	79650513          	addi	a0,a0,1942 # ffffffffc0202348 <commands+0x520>
ffffffffc0200bba:	f30ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!list_empty(&free_list));//确保在释放 p0 后，空闲链表 free_list 不为空。因为刚刚释放了一个页框，所以空闲链表应该包含至少一个元素。
ffffffffc0200bbe:	00002697          	auipc	a3,0x2
ffffffffc0200bc2:	91268693          	addi	a3,a3,-1774 # ffffffffc02024d0 <commands+0x6a8>
ffffffffc0200bc6:	00001617          	auipc	a2,0x1
ffffffffc0200bca:	76a60613          	addi	a2,a2,1898 # ffffffffc0202330 <commands+0x508>
ffffffffc0200bce:	0f200593          	li	a1,242
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	77650513          	addi	a0,a0,1910 # ffffffffc0202348 <commands+0x520>
ffffffffc0200bda:	f10ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bde:	00001697          	auipc	a3,0x1
ffffffffc0200be2:	7a268693          	addi	a3,a3,1954 # ffffffffc0202380 <commands+0x558>
ffffffffc0200be6:	00001617          	auipc	a2,0x1
ffffffffc0200bea:	74a60613          	addi	a2,a2,1866 # ffffffffc0202330 <commands+0x508>
ffffffffc0200bee:	0eb00593          	li	a1,235
ffffffffc0200bf2:	00001517          	auipc	a0,0x1
ffffffffc0200bf6:	75650513          	addi	a0,a0,1878 # ffffffffc0202348 <commands+0x520>
ffffffffc0200bfa:	ef0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 3);//确保释放后，空闲页面数量正确
ffffffffc0200bfe:	00002697          	auipc	a3,0x2
ffffffffc0200c02:	8c268693          	addi	a3,a3,-1854 # ffffffffc02024c0 <commands+0x698>
ffffffffc0200c06:	00001617          	auipc	a2,0x1
ffffffffc0200c0a:	72a60613          	addi	a2,a2,1834 # ffffffffc0202330 <commands+0x508>
ffffffffc0200c0e:	0e900593          	li	a1,233
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	73650513          	addi	a0,a0,1846 # ffffffffc0202348 <commands+0x520>
ffffffffc0200c1a:	ed0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);//由于没有可用的页面，分配页面应该返回 NULL
ffffffffc0200c1e:	00002697          	auipc	a3,0x2
ffffffffc0200c22:	88a68693          	addi	a3,a3,-1910 # ffffffffc02024a8 <commands+0x680>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	70a60613          	addi	a2,a2,1802 # ffffffffc0202330 <commands+0x508>
ffffffffc0200c2e:	0e400593          	li	a1,228
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	71650513          	addi	a0,a0,1814 # ffffffffc0202348 <commands+0x520>
ffffffffc0200c3a:	eb0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p2) < npage * PGSIZE);//检查每个页面的物理地址是否在有效范围内。确保地址小于总页数乘以每页大小。
ffffffffc0200c3e:	00002697          	auipc	a3,0x2
ffffffffc0200c42:	84a68693          	addi	a3,a3,-1974 # ffffffffc0202488 <commands+0x660>
ffffffffc0200c46:	00001617          	auipc	a2,0x1
ffffffffc0200c4a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0202330 <commands+0x508>
ffffffffc0200c4e:	0db00593          	li	a1,219
ffffffffc0200c52:	00001517          	auipc	a0,0x1
ffffffffc0200c56:	6f650513          	addi	a0,a0,1782 # ffffffffc0202348 <commands+0x520>
ffffffffc0200c5a:	e90ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);//再次尝试分配页面，检查是否能够成功分配并且返回的页面是否与之前释放的页面一致。
ffffffffc0200c5e:	00001697          	auipc	a3,0x1
ffffffffc0200c62:	76268693          	addi	a3,a3,1890 # ffffffffc02023c0 <commands+0x598>
ffffffffc0200c66:	00001617          	auipc	a2,0x1
ffffffffc0200c6a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0202330 <commands+0x508>
ffffffffc0200c6e:	0ed00593          	li	a1,237
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	6d650513          	addi	a0,a0,1750 # ffffffffc0202348 <commands+0x520>
ffffffffc0200c7a:	e70ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c7e:	00001697          	auipc	a3,0x1
ffffffffc0200c82:	72268693          	addi	a3,a3,1826 # ffffffffc02023a0 <commands+0x578>
ffffffffc0200c86:	00001617          	auipc	a2,0x1
ffffffffc0200c8a:	6aa60613          	addi	a2,a2,1706 # ffffffffc0202330 <commands+0x508>
ffffffffc0200c8e:	0ec00593          	li	a1,236
ffffffffc0200c92:	00001517          	auipc	a0,0x1
ffffffffc0200c96:	6b650513          	addi	a0,a0,1718 # ffffffffc0202348 <commands+0x520>
ffffffffc0200c9a:	e50ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != NULL);
ffffffffc0200c9e:	00002697          	auipc	a3,0x2
ffffffffc0200ca2:	87a68693          	addi	a3,a3,-1926 # ffffffffc0202518 <commands+0x6f0>
ffffffffc0200ca6:	00001617          	auipc	a2,0x1
ffffffffc0200caa:	68a60613          	addi	a2,a2,1674 # ffffffffc0202330 <commands+0x508>
ffffffffc0200cae:	11100593          	li	a1,273
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	69650513          	addi	a0,a0,1686 # ffffffffc0202348 <commands+0x520>
ffffffffc0200cba:	e30ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200cbe:	00002697          	auipc	a3,0x2
ffffffffc0200cc2:	84a68693          	addi	a3,a3,-1974 # ffffffffc0202508 <commands+0x6e0>
ffffffffc0200cc6:	00001617          	auipc	a2,0x1
ffffffffc0200cca:	66a60613          	addi	a2,a2,1642 # ffffffffc0202330 <commands+0x508>
ffffffffc0200cce:	0f800593          	li	a1,248
ffffffffc0200cd2:	00001517          	auipc	a0,0x1
ffffffffc0200cd6:	67650513          	addi	a0,a0,1654 # ffffffffc0202348 <commands+0x520>
ffffffffc0200cda:	e10ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);//再次调用 alloc_page() 以分配内存。这里期望返回的页框是 p0，也就是说 p0 应该在释放后重新分配给我们。如果分配的页框不是 p0，则说明内存管理有问题，程序会抛出异常。
ffffffffc0200cde:	00001697          	auipc	a3,0x1
ffffffffc0200ce2:	7ca68693          	addi	a3,a3,1994 # ffffffffc02024a8 <commands+0x680>
ffffffffc0200ce6:	00001617          	auipc	a2,0x1
ffffffffc0200cea:	64a60613          	addi	a2,a2,1610 # ffffffffc0202330 <commands+0x508>
ffffffffc0200cee:	0f600593          	li	a1,246
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	65650513          	addi	a0,a0,1622 # ffffffffc0202348 <commands+0x520>
ffffffffc0200cfa:	df0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200cfe:	00001697          	auipc	a3,0x1
ffffffffc0200d02:	7ea68693          	addi	a3,a3,2026 # ffffffffc02024e8 <commands+0x6c0>
ffffffffc0200d06:	00001617          	auipc	a2,0x1
ffffffffc0200d0a:	62a60613          	addi	a2,a2,1578 # ffffffffc0202330 <commands+0x508>
ffffffffc0200d0e:	0f500593          	li	a1,245
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	63650513          	addi	a0,a0,1590 # ffffffffc0202348 <commands+0x520>
ffffffffc0200d1a:	dd0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	78a68693          	addi	a3,a3,1930 # ffffffffc02024a8 <commands+0x680>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	60a60613          	addi	a2,a2,1546 # ffffffffc0202330 <commands+0x508>
ffffffffc0200d2e:	11700593          	li	a1,279
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	61650513          	addi	a0,a0,1558 # ffffffffc0202348 <commands+0x520>
ffffffffc0200d3a:	db0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!PageProperty(p0));
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	7ea68693          	addi	a3,a3,2026 # ffffffffc0202528 <commands+0x700>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	5ea60613          	addi	a2,a2,1514 # ffffffffc0202330 <commands+0x508>
ffffffffc0200d4e:	11200593          	li	a1,274
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	5f650513          	addi	a0,a0,1526 # ffffffffc0202348 <commands+0x520>
ffffffffc0200d5a:	d90ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);// 通过断言确保每次调用该函数都返回一个有效的指针（即不为 NULL），这表明成功分配了页面。
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	66268693          	addi	a3,a3,1634 # ffffffffc02023c0 <commands+0x598>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0202330 <commands+0x508>
ffffffffc0200d6e:	0d400593          	li	a1,212
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	5d650513          	addi	a0,a0,1494 # ffffffffc0202348 <commands+0x520>
ffffffffc0200d7a:	d70ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);//当所有的页框都已分配后，调用 alloc_page() 应该返回 NULL
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	72a68693          	addi	a3,a3,1834 # ffffffffc02024a8 <commands+0x680>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	5aa60613          	addi	a2,a2,1450 # ffffffffc0202330 <commands+0x508>
ffffffffc0200d8e:	0ef00593          	li	a1,239
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	5b650513          	addi	a0,a0,1462 # ffffffffc0202348 <commands+0x520>
ffffffffc0200d9a:	d50ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200d9e:	00002697          	auipc	a3,0x2
ffffffffc0200da2:	83a68693          	addi	a3,a3,-1990 # ffffffffc02025d8 <commands+0x7b0>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	58a60613          	addi	a2,a2,1418 # ffffffffc0202330 <commands+0x508>
ffffffffc0200dae:	14000593          	li	a1,320
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	59650513          	addi	a0,a0,1430 # ffffffffc0202348 <commands+0x520>
ffffffffc0200dba:	d30ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200dbe:	00002697          	auipc	a3,0x2
ffffffffc0200dc2:	81a68693          	addi	a3,a3,-2022 # ffffffffc02025d8 <commands+0x7b0>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	56a60613          	addi	a2,a2,1386 # ffffffffc0202330 <commands+0x508>
ffffffffc0200dce:	13e00593          	li	a1,318
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	57650513          	addi	a0,a0,1398 # ffffffffc0202348 <commands+0x520>
ffffffffc0200dda:	d10ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	7fa68693          	addi	a3,a3,2042 # ffffffffc02025d8 <commands+0x7b0>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	54a60613          	addi	a2,a2,1354 # ffffffffc0202330 <commands+0x508>
ffffffffc0200dee:	13900593          	li	a1,313
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	55650513          	addi	a0,a0,1366 # ffffffffc0202348 <commands+0x520>
ffffffffc0200dfa:	cf0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == 0);
ffffffffc0200dfe:	00002697          	auipc	a3,0x2
ffffffffc0200e02:	84a68693          	addi	a3,a3,-1974 # ffffffffc0202648 <commands+0x820>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	52a60613          	addi	a2,a2,1322 # ffffffffc0202330 <commands+0x508>
ffffffffc0200e0e:	15300593          	li	a1,339
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	53650513          	addi	a0,a0,1334 # ffffffffc0202348 <commands+0x520>
ffffffffc0200e1a:	cd0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	54268693          	addi	a3,a3,1346 # ffffffffc0202360 <commands+0x538>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	50a60613          	addi	a2,a2,1290 # ffffffffc0202330 <commands+0x508>
ffffffffc0200e2e:	10c00593          	li	a1,268
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	51650513          	addi	a0,a0,1302 # ffffffffc0202348 <commands+0x520>
ffffffffc0200e3a:	cb0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	6ca68693          	addi	a3,a3,1738 # ffffffffc0202508 <commands+0x6e0>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0202330 <commands+0x508>
ffffffffc0200e4e:	14500593          	li	a1,325
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	4f650513          	addi	a0,a0,1270 # ffffffffc0202348 <commands+0x520>
ffffffffc0200e5a:	c90ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	60a68693          	addi	a3,a3,1546 # ffffffffc0202468 <commands+0x640>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0202330 <commands+0x508>
ffffffffc0200e6e:	0da00593          	li	a1,218
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	4d650513          	addi	a0,a0,1238 # ffffffffc0202348 <commands+0x520>
ffffffffc0200e7a:	c70ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	72268693          	addi	a3,a3,1826 # ffffffffc02025a0 <commands+0x778>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	4aa60613          	addi	a2,a2,1194 # ffffffffc0202330 <commands+0x508>
ffffffffc0200e8e:	13700593          	li	a1,311
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	4b650513          	addi	a0,a0,1206 # ffffffffc0202348 <commands+0x520>
ffffffffc0200e9a:	c50ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 32);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	6ea68693          	addi	a3,a3,1770 # ffffffffc0202588 <commands+0x760>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	48a60613          	addi	a2,a2,1162 # ffffffffc0202330 <commands+0x508>
ffffffffc0200eae:	13200593          	li	a1,306
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	49650513          	addi	a0,a0,1174 # ffffffffc0202348 <commands+0x520>
ffffffffc0200eba:	c30ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	68268693          	addi	a3,a3,1666 # ffffffffc0202540 <commands+0x718>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	46a60613          	addi	a2,a2,1130 # ffffffffc0202330 <commands+0x508>
ffffffffc0200ece:	13000593          	li	a1,304
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	47650513          	addi	a0,a0,1142 # ffffffffc0202348 <commands+0x520>
ffffffffc0200eda:	c10ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p1->property == 16);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	67a68693          	addi	a3,a3,1658 # ffffffffc0202558 <commands+0x730>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	44a60613          	addi	a2,a2,1098 # ffffffffc0202330 <commands+0x508>
ffffffffc0200eee:	12f00593          	li	a1,303
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	45650513          	addi	a0,a0,1110 # ffffffffc0202348 <commands+0x520>
ffffffffc0200efa:	bf0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 32);
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	68a68693          	addi	a3,a3,1674 # ffffffffc0202588 <commands+0x760>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	42a60613          	addi	a2,a2,1066 # ffffffffc0202330 <commands+0x508>
ffffffffc0200f0e:	12a00593          	li	a1,298
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	43650513          	addi	a0,a0,1078 # ffffffffc0202348 <commands+0x520>
ffffffffc0200f1a:	bd0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 16);
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	65268693          	addi	a3,a3,1618 # ffffffffc0202570 <commands+0x748>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	40a60613          	addi	a2,a2,1034 # ffffffffc0202330 <commands+0x508>
ffffffffc0200f2e:	12800593          	li	a1,296
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	41650513          	addi	a0,a0,1046 # ffffffffc0202348 <commands+0x520>
ffffffffc0200f3a:	bb0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p1->property == 16);
ffffffffc0200f3e:	00001697          	auipc	a3,0x1
ffffffffc0200f42:	61a68693          	addi	a3,a3,1562 # ffffffffc0202558 <commands+0x730>
ffffffffc0200f46:	00001617          	auipc	a2,0x1
ffffffffc0200f4a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0202330 <commands+0x508>
ffffffffc0200f4e:	12400593          	li	a1,292
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	3f650513          	addi	a0,a0,1014 # ffffffffc0202348 <commands+0x520>
ffffffffc0200f5a:	b90ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200f5e:	00001697          	auipc	a3,0x1
ffffffffc0200f62:	5e268693          	addi	a3,a3,1506 # ffffffffc0202540 <commands+0x718>
ffffffffc0200f66:	00001617          	auipc	a2,0x1
ffffffffc0200f6a:	3ca60613          	addi	a2,a2,970 # ffffffffc0202330 <commands+0x508>
ffffffffc0200f6e:	12300593          	li	a1,291
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	3d650513          	addi	a0,a0,982 # ffffffffc0202348 <commands+0x520>
ffffffffc0200f7a:	b70ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200f7e:	00001697          	auipc	a3,0x1
ffffffffc0200f82:	5c268693          	addi	a3,a3,1474 # ffffffffc0202540 <commands+0x718>
ffffffffc0200f86:	00001617          	auipc	a2,0x1
ffffffffc0200f8a:	3aa60613          	addi	a2,a2,938 # ffffffffc0202330 <commands+0x508>
ffffffffc0200f8e:	12100593          	li	a1,289
ffffffffc0200f92:	00001517          	auipc	a0,0x1
ffffffffc0200f96:	3b650513          	addi	a0,a0,950 # ffffffffc0202348 <commands+0x520>
ffffffffc0200f9a:	b50ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(count == 0);
ffffffffc0200f9e:	00001697          	auipc	a3,0x1
ffffffffc0200fa2:	69a68693          	addi	a3,a3,1690 # ffffffffc0202638 <commands+0x810>
ffffffffc0200fa6:	00001617          	auipc	a2,0x1
ffffffffc0200faa:	38a60613          	addi	a2,a2,906 # ffffffffc0202330 <commands+0x508>
ffffffffc0200fae:	15200593          	li	a1,338
ffffffffc0200fb2:	00001517          	auipc	a0,0x1
ffffffffc0200fb6:	39650513          	addi	a0,a0,918 # ffffffffc0202348 <commands+0x520>
ffffffffc0200fba:	b30ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fbe:	00001697          	auipc	a3,0x1
ffffffffc0200fc2:	3e268693          	addi	a3,a3,994 # ffffffffc02023a0 <commands+0x578>
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	36a60613          	addi	a2,a2,874 # ffffffffc0202330 <commands+0x508>
ffffffffc0200fce:	0d300593          	li	a1,211
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	37650513          	addi	a0,a0,886 # ffffffffc0202348 <commands+0x520>
ffffffffc0200fda:	b10ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fde:	00001697          	auipc	a3,0x1
ffffffffc0200fe2:	3a268693          	addi	a3,a3,930 # ffffffffc0202380 <commands+0x558>
ffffffffc0200fe6:	00001617          	auipc	a2,0x1
ffffffffc0200fea:	34a60613          	addi	a2,a2,842 # ffffffffc0202330 <commands+0x508>
ffffffffc0200fee:	0d200593          	li	a1,210
ffffffffc0200ff2:	00001517          	auipc	a0,0x1
ffffffffc0200ff6:	35650513          	addi	a0,a0,854 # ffffffffc0202348 <commands+0x520>
ffffffffc0200ffa:	af0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ffe:	00001697          	auipc	a3,0x1
ffffffffc0201002:	44a68693          	addi	a3,a3,1098 # ffffffffc0202448 <commands+0x620>
ffffffffc0201006:	00001617          	auipc	a2,0x1
ffffffffc020100a:	32a60613          	addi	a2,a2,810 # ffffffffc0202330 <commands+0x508>
ffffffffc020100e:	0d900593          	li	a1,217
ffffffffc0201012:	00001517          	auipc	a0,0x1
ffffffffc0201016:	33650513          	addi	a0,a0,822 # ffffffffc0202348 <commands+0x520>
ffffffffc020101a:	ad0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);//确保每个页面的引用计数都初始化为0。这通常意味着页面尚未被任何其他结构引用。
ffffffffc020101e:	00001697          	auipc	a3,0x1
ffffffffc0201022:	3ea68693          	addi	a3,a3,1002 # ffffffffc0202408 <commands+0x5e0>
ffffffffc0201026:	00001617          	auipc	a2,0x1
ffffffffc020102a:	30a60613          	addi	a2,a2,778 # ffffffffc0202330 <commands+0x508>
ffffffffc020102e:	0d700593          	li	a1,215
ffffffffc0201032:	00001517          	auipc	a0,0x1
ffffffffc0201036:	31650513          	addi	a0,a0,790 # ffffffffc0202348 <commands+0x520>
ffffffffc020103a:	ab0ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);//确保分配的三个页面是不同的，即每次分配的页面都是唯一的。
ffffffffc020103e:	00001697          	auipc	a3,0x1
ffffffffc0201042:	3a268693          	addi	a3,a3,930 # ffffffffc02023e0 <commands+0x5b8>
ffffffffc0201046:	00001617          	auipc	a2,0x1
ffffffffc020104a:	2ea60613          	addi	a2,a2,746 # ffffffffc0202330 <commands+0x508>
ffffffffc020104e:	0d600593          	li	a1,214
ffffffffc0201052:	00001517          	auipc	a0,0x1
ffffffffc0201056:	2f650513          	addi	a0,a0,758 # ffffffffc0202348 <commands+0x520>
ffffffffc020105a:	a90ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020105e <best_fit_free_pages>:
{
ffffffffc020105e:	1141                	addi	sp,sp,-16
ffffffffc0201060:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201062:	18058a63          	beqz	a1,ffffffffc02011f6 <best_fit_free_pages+0x198>
    while (num > 1)
ffffffffc0201066:	4605                	li	a2,1
ffffffffc0201068:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc020106a:	4701                	li	a4,0
    while (num > 1)
ffffffffc020106c:	4685                	li	a3,1
ffffffffc020106e:	00c58d63          	beq	a1,a2,ffffffffc0201088 <best_fit_free_pages+0x2a>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0201072:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0201074:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc0201076:	fed79ee3          	bne	a5,a3,ffffffffc0201072 <best_fit_free_pages+0x14>
    return (size_t)(1 << exp);// 无符号整数类型
ffffffffc020107a:	4785                	li	a5,1
ffffffffc020107c:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc0201080:	00b77463          	bgeu	a4,a1,ffffffffc0201088 <best_fit_free_pages+0x2a>
        n = 2 * size;
ffffffffc0201084:	00171593          	slli	a1,a4,0x1
    for (; p != base + n; p++)
ffffffffc0201088:	00259693          	slli	a3,a1,0x2
ffffffffc020108c:	96ae                	add	a3,a3,a1
ffffffffc020108e:	068e                	slli	a3,a3,0x3
ffffffffc0201090:	96aa                	add	a3,a3,a0
ffffffffc0201092:	87aa                	mv	a5,a0
ffffffffc0201094:	02d50263          	beq	a0,a3,ffffffffc02010b8 <best_fit_free_pages+0x5a>
ffffffffc0201098:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020109a:	8b05                	andi	a4,a4,1
ffffffffc020109c:	12071d63          	bnez	a4,ffffffffc02011d6 <best_fit_free_pages+0x178>
ffffffffc02010a0:	6798                	ld	a4,8(a5)
ffffffffc02010a2:	8b09                	andi	a4,a4,2
ffffffffc02010a4:	12071963          	bnez	a4,ffffffffc02011d6 <best_fit_free_pages+0x178>
        p->flags = 0;
ffffffffc02010a8:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02010ac:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02010b0:	02878793          	addi	a5,a5,40
ffffffffc02010b4:	fed792e3          	bne	a5,a3,ffffffffc0201098 <best_fit_free_pages+0x3a>
    base->property = n;
ffffffffc02010b8:	2581                	sext.w	a1,a1
ffffffffc02010ba:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02010bc:	00850313          	addi	t1,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010c0:	4789                	li	a5,2
ffffffffc02010c2:	40f3302f          	amoor.d	zero,a5,(t1)
    nr_free += n;
ffffffffc02010c6:	00005817          	auipc	a6,0x5
ffffffffc02010ca:	f4a80813          	addi	a6,a6,-182 # ffffffffc0206010 <free_area>
ffffffffc02010ce:	01082703          	lw	a4,16(a6)
ffffffffc02010d2:	00883783          	ld	a5,8(a6)
ffffffffc02010d6:	9db9                	addw	a1,a1,a4
ffffffffc02010d8:	00b82823          	sw	a1,16(a6)
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc02010dc:	0f078b63          	beq	a5,a6,ffffffffc02011d2 <best_fit_free_pages+0x174>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc02010e0:	4910                	lw	a2,16(a0)
ffffffffc02010e2:	a021                	j	ffffffffc02010ea <best_fit_free_pages+0x8c>
ffffffffc02010e4:	679c                	ld	a5,8(a5)
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc02010e6:	01078c63          	beq	a5,a6,ffffffffc02010fe <best_fit_free_pages+0xa0>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc02010ea:	ff87a703          	lw	a4,-8(a5)
        p = le2page(le, page_link);
ffffffffc02010ee:	fe878693          	addi	a3,a5,-24
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc02010f2:	00e66663          	bltu	a2,a4,ffffffffc02010fe <best_fit_free_pages+0xa0>
ffffffffc02010f6:	fee617e3          	bne	a2,a4,ffffffffc02010e4 <best_fit_free_pages+0x86>
ffffffffc02010fa:	fed575e3          	bgeu	a0,a3,ffffffffc02010e4 <best_fit_free_pages+0x86>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010fe:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc0201100:	01850593          	addi	a1,a0,24
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0201104:	0106a883          	lw	a7,16(a3)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201108:	e38c                	sd	a1,0(a5)
ffffffffc020110a:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc020110c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020110e:	ed18                	sd	a4,24(a0)
ffffffffc0201110:	08c88963          	beq	a7,a2,ffffffffc02011a2 <best_fit_free_pages+0x144>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201114:	55f5                	li	a1,-3
    while (le != &free_list)
ffffffffc0201116:	01079863          	bne	a5,a6,ffffffffc0201126 <best_fit_free_pages+0xc8>
ffffffffc020111a:	a0b9                	j	ffffffffc0201168 <best_fit_free_pages+0x10a>
        else if (base->property < p->property)
ffffffffc020111c:	04e6e963          	bltu	a3,a4,ffffffffc020116e <best_fit_free_pages+0x110>
    return listelm->next;
ffffffffc0201120:	679c                	ld	a5,8(a5)
    while (le != &free_list)
ffffffffc0201122:	05078363          	beq	a5,a6,ffffffffc0201168 <best_fit_free_pages+0x10a>
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0201126:	ff87a703          	lw	a4,-8(a5)
ffffffffc020112a:	4914                	lw	a3,16(a0)
ffffffffc020112c:	fed718e3          	bne	a4,a3,ffffffffc020111c <best_fit_free_pages+0xbe>
ffffffffc0201130:	02071613          	slli	a2,a4,0x20
ffffffffc0201134:	9201                	srli	a2,a2,0x20
ffffffffc0201136:	00261693          	slli	a3,a2,0x2
ffffffffc020113a:	96b2                	add	a3,a3,a2
ffffffffc020113c:	068e                	slli	a3,a3,0x3
        p = le2page(le, page_link);
ffffffffc020113e:	fe878613          	addi	a2,a5,-24
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc0201142:	96aa                	add	a3,a3,a0
ffffffffc0201144:	fcd61ee3          	bne	a2,a3,ffffffffc0201120 <best_fit_free_pages+0xc2>
            base->property += p->property;
ffffffffc0201148:	0017171b          	slliw	a4,a4,0x1
ffffffffc020114c:	c918                	sw	a4,16(a0)
ffffffffc020114e:	ff078713          	addi	a4,a5,-16
ffffffffc0201152:	60b7302f          	amoand.d	zero,a1,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201156:	6394                	ld	a3,0(a5)
ffffffffc0201158:	6798                	ld	a4,8(a5)
            le = &(base->page_link);
ffffffffc020115a:	01850793          	addi	a5,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020115e:	e698                	sd	a4,8(a3)
    return listelm->next;
ffffffffc0201160:	679c                	ld	a5,8(a5)
    next->prev = prev;
ffffffffc0201162:	e314                	sd	a3,0(a4)
    while (le != &free_list)
ffffffffc0201164:	fd0791e3          	bne	a5,a6,ffffffffc0201126 <best_fit_free_pages+0xc8>
}
ffffffffc0201168:	60a2                	ld	ra,8(sp)
ffffffffc020116a:	0141                	addi	sp,sp,16
ffffffffc020116c:	8082                	ret
    return listelm->next;
ffffffffc020116e:	7110                	ld	a2,32(a0)
            while (le2page(targetLe, page_link)->property < base->property)
ffffffffc0201170:	ff862703          	lw	a4,-8(a2)
ffffffffc0201174:	87b2                	mv	a5,a2
ffffffffc0201176:	fed779e3          	bgeu	a4,a3,ffffffffc0201168 <best_fit_free_pages+0x10a>
ffffffffc020117a:	679c                	ld	a5,8(a5)
ffffffffc020117c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201180:	fed76de3          	bltu	a4,a3,ffffffffc020117a <best_fit_free_pages+0x11c>
            if (targetLe != list_next(&base->page_link))
ffffffffc0201184:	fef602e3          	beq	a2,a5,ffffffffc0201168 <best_fit_free_pages+0x10a>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201188:	6d18                	ld	a4,24(a0)
                list_add_before(targetLe, &(base->page_link));
ffffffffc020118a:	01850693          	addi	a3,a0,24
}
ffffffffc020118e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201190:	e710                	sd	a2,8(a4)
    next->prev = prev;
ffffffffc0201192:	e218                	sd	a4,0(a2)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201194:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201196:	e394                	sd	a3,0(a5)
ffffffffc0201198:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc020119a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020119c:	ed18                	sd	a4,24(a0)
ffffffffc020119e:	0141                	addi	sp,sp,16
ffffffffc02011a0:	8082                	ret
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc02011a2:	02061593          	slli	a1,a2,0x20
ffffffffc02011a6:	9181                	srli	a1,a1,0x20
ffffffffc02011a8:	00259713          	slli	a4,a1,0x2
ffffffffc02011ac:	972e                	add	a4,a4,a1
ffffffffc02011ae:	070e                	slli	a4,a4,0x3
ffffffffc02011b0:	9736                	add	a4,a4,a3
ffffffffc02011b2:	f6e511e3          	bne	a0,a4,ffffffffc0201114 <best_fit_free_pages+0xb6>
        p->property += base->property;
ffffffffc02011b6:	0016161b          	slliw	a2,a2,0x1
ffffffffc02011ba:	ca90                	sw	a2,16(a3)
ffffffffc02011bc:	57f5                	li	a5,-3
ffffffffc02011be:	60f3302f          	amoand.d	zero,a5,(t1)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011c2:	6d10                	ld	a2,24(a0)
ffffffffc02011c4:	7118                	ld	a4,32(a0)
        le = &(base->page_link);
ffffffffc02011c6:	01868793          	addi	a5,a3,24
ffffffffc02011ca:	8536                	mv	a0,a3
    prev->next = next;
ffffffffc02011cc:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02011ce:	e310                	sd	a2,0(a4)
ffffffffc02011d0:	b791                	j	ffffffffc0201114 <best_fit_free_pages+0xb6>
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc02011d2:	4910                	lw	a2,16(a0)
ffffffffc02011d4:	b72d                	j	ffffffffc02010fe <best_fit_free_pages+0xa0>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011d6:	00001697          	auipc	a3,0x1
ffffffffc02011da:	48a68693          	addi	a3,a3,1162 # ffffffffc0202660 <commands+0x838>
ffffffffc02011de:	00001617          	auipc	a2,0x1
ffffffffc02011e2:	15260613          	addi	a2,a2,338 # ffffffffc0202330 <commands+0x508>
ffffffffc02011e6:	08000593          	li	a1,128
ffffffffc02011ea:	00001517          	auipc	a0,0x1
ffffffffc02011ee:	15e50513          	addi	a0,a0,350 # ffffffffc0202348 <commands+0x520>
ffffffffc02011f2:	8f8ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02011f6:	00001697          	auipc	a3,0x1
ffffffffc02011fa:	46268693          	addi	a3,a3,1122 # ffffffffc0202658 <commands+0x830>
ffffffffc02011fe:	00001617          	auipc	a2,0x1
ffffffffc0201202:	13260613          	addi	a2,a2,306 # ffffffffc0202330 <commands+0x508>
ffffffffc0201206:	07800593          	li	a1,120
ffffffffc020120a:	00001517          	auipc	a0,0x1
ffffffffc020120e:	13e50513          	addi	a0,a0,318 # ffffffffc0202348 <commands+0x520>
ffffffffc0201212:	8d8ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201216 <best_fit_alloc_pages>:
{
ffffffffc0201216:	1141                	addi	sp,sp,-16
ffffffffc0201218:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020121a:	c96d                	beqz	a0,ffffffffc020130c <best_fit_alloc_pages+0xf6>
    while (num > 1)
ffffffffc020121c:	4585                	li	a1,1
ffffffffc020121e:	862a                	mv	a2,a0
ffffffffc0201220:	87aa                	mv	a5,a0
    size_t exp = 0;
ffffffffc0201222:	4701                	li	a4,0
    while (num > 1)
ffffffffc0201224:	4685                	li	a3,1
ffffffffc0201226:	00b50d63          	beq	a0,a1,ffffffffc0201240 <best_fit_alloc_pages+0x2a>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc020122a:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc020122c:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc020122e:	fed79ee3          	bne	a5,a3,ffffffffc020122a <best_fit_alloc_pages+0x14>
    return (size_t)(1 << exp);// 无符号整数类型
ffffffffc0201232:	4785                	li	a5,1
ffffffffc0201234:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc0201238:	00c77463          	bgeu	a4,a2,ffffffffc0201240 <best_fit_alloc_pages+0x2a>
        n = 2 * size;
ffffffffc020123c:	00171613          	slli	a2,a4,0x1
    if (n > nr_free)
ffffffffc0201240:	00005897          	auipc	a7,0x5
ffffffffc0201244:	dd088893          	addi	a7,a7,-560 # ffffffffc0206010 <free_area>
ffffffffc0201248:	0108a583          	lw	a1,16(a7)
ffffffffc020124c:	02059793          	slli	a5,a1,0x20
ffffffffc0201250:	9381                	srli	a5,a5,0x20
ffffffffc0201252:	00c7ee63          	bltu	a5,a2,ffffffffc020126e <best_fit_alloc_pages+0x58>
    list_entry_t *le = &free_list;
ffffffffc0201256:	8746                	mv	a4,a7
ffffffffc0201258:	a801                	j	ffffffffc0201268 <best_fit_alloc_pages+0x52>
        if (p->property >= n){
ffffffffc020125a:	ff872683          	lw	a3,-8(a4)
ffffffffc020125e:	02069793          	slli	a5,a3,0x20
ffffffffc0201262:	9381                	srli	a5,a5,0x20
ffffffffc0201264:	00c7f963          	bgeu	a5,a2,ffffffffc0201276 <best_fit_alloc_pages+0x60>
    return listelm->next;
ffffffffc0201268:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list)
ffffffffc020126a:	ff1718e3          	bne	a4,a7,ffffffffc020125a <best_fit_alloc_pages+0x44>
}
ffffffffc020126e:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc0201270:	4501                	li	a0,0
}
ffffffffc0201272:	0141                	addi	sp,sp,16
ffffffffc0201274:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201276:	fe870513          	addi	a0,a4,-24
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020127a:	4309                	li	t1,2
        while (page->property > n)
ffffffffc020127c:	04f67563          	bgeu	a2,a5,ffffffffc02012c6 <best_fit_alloc_pages+0xb0>
            page->property /= 2;
ffffffffc0201280:	0016d69b          	srliw	a3,a3,0x1
            struct Page *p = page + page->property;
ffffffffc0201284:	02069593          	slli	a1,a3,0x20
ffffffffc0201288:	9181                	srli	a1,a1,0x20
ffffffffc020128a:	00259793          	slli	a5,a1,0x2
ffffffffc020128e:	97ae                	add	a5,a5,a1
ffffffffc0201290:	078e                	slli	a5,a5,0x3
            page->property /= 2;
ffffffffc0201292:	fed72c23          	sw	a3,-8(a4)
            struct Page *p = page + page->property;
ffffffffc0201296:	97aa                	add	a5,a5,a0
            p->property = page->property;
ffffffffc0201298:	cb94                	sw	a3,16(a5)
ffffffffc020129a:	00878693          	addi	a3,a5,8
ffffffffc020129e:	4066b02f          	amoor.d	zero,t1,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02012a2:	670c                	ld	a1,8(a4)
        while (page->property > n)
ffffffffc02012a4:	ff872683          	lw	a3,-8(a4)
            list_add_after(&(page->page_link), &(p->page_link));
ffffffffc02012a8:	01878813          	addi	a6,a5,24
    prev->next = next->prev = elm;
ffffffffc02012ac:	0105b023          	sd	a6,0(a1)
ffffffffc02012b0:	01073423          	sd	a6,8(a4)
    elm->next = next;
ffffffffc02012b4:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc02012b6:	ef98                	sd	a4,24(a5)
        while (page->property > n)
ffffffffc02012b8:	02069793          	slli	a5,a3,0x20
ffffffffc02012bc:	9381                	srli	a5,a5,0x20
ffffffffc02012be:	fcf661e3          	bltu	a2,a5,ffffffffc0201280 <best_fit_alloc_pages+0x6a>
        nr_free -= n;
ffffffffc02012c2:	0108a583          	lw	a1,16(a7)
ffffffffc02012c6:	9d91                	subw	a1,a1,a2
ffffffffc02012c8:	00b8a823          	sw	a1,16(a7)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012cc:	57f5                	li	a5,-3
ffffffffc02012ce:	ff070693          	addi	a3,a4,-16
ffffffffc02012d2:	60f6b02f          	amoand.d	zero,a5,(a3)
        assert(page->property == n);
ffffffffc02012d6:	ff876783          	lwu	a5,-8(a4)
ffffffffc02012da:	00f61963          	bne	a2,a5,ffffffffc02012ec <best_fit_alloc_pages+0xd6>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012de:	6314                	ld	a3,0(a4)
ffffffffc02012e0:	671c                	ld	a5,8(a4)
}
ffffffffc02012e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02012e4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02012e6:	e394                	sd	a3,0(a5)
ffffffffc02012e8:	0141                	addi	sp,sp,16
ffffffffc02012ea:	8082                	ret
        assert(page->property == n);
ffffffffc02012ec:	00001697          	auipc	a3,0x1
ffffffffc02012f0:	39c68693          	addi	a3,a3,924 # ffffffffc0202688 <commands+0x860>
ffffffffc02012f4:	00001617          	auipc	a2,0x1
ffffffffc02012f8:	03c60613          	addi	a2,a2,60 # ffffffffc0202330 <commands+0x508>
ffffffffc02012fc:	06f00593          	li	a1,111
ffffffffc0201300:	00001517          	auipc	a0,0x1
ffffffffc0201304:	04850513          	addi	a0,a0,72 # ffffffffc0202348 <commands+0x520>
ffffffffc0201308:	fe3fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc020130c:	00001697          	auipc	a3,0x1
ffffffffc0201310:	34c68693          	addi	a3,a3,844 # ffffffffc0202658 <commands+0x830>
ffffffffc0201314:	00001617          	auipc	a2,0x1
ffffffffc0201318:	01c60613          	addi	a2,a2,28 # ffffffffc0202330 <commands+0x508>
ffffffffc020131c:	04c00593          	li	a1,76
ffffffffc0201320:	00001517          	auipc	a0,0x1
ffffffffc0201324:	02850513          	addi	a0,a0,40 # ffffffffc0202348 <commands+0x520>
ffffffffc0201328:	fc3fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020132c <best_fit_init_memmap>:
{
ffffffffc020132c:	1141                	addi	sp,sp,-16
ffffffffc020132e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201330:	cde9                	beqz	a1,ffffffffc020140a <best_fit_init_memmap+0xde>
    for (; p != base + n; p++)
ffffffffc0201332:	00259813          	slli	a6,a1,0x2
ffffffffc0201336:	982e                	add	a6,a6,a1
ffffffffc0201338:	080e                	slli	a6,a6,0x3
ffffffffc020133a:	982a                	add	a6,a6,a0
ffffffffc020133c:	01050f63          	beq	a0,a6,ffffffffc020135a <best_fit_init_memmap+0x2e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201340:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));// 确保页框是保留的
ffffffffc0201342:	8b85                	andi	a5,a5,1
ffffffffc0201344:	c3dd                	beqz	a5,ffffffffc02013ea <best_fit_init_memmap+0xbe>
        p->flags = p->property = 0;
ffffffffc0201346:	00052823          	sw	zero,16(a0)
ffffffffc020134a:	00053423          	sd	zero,8(a0)
ffffffffc020134e:	00052023          	sw	zero,0(a0)
    for (; p != base + n; p++)
ffffffffc0201352:	02850513          	addi	a0,a0,40
ffffffffc0201356:	ff0515e3          	bne	a0,a6,ffffffffc0201340 <best_fit_init_memmap+0x14>
    nr_free += n;
ffffffffc020135a:	00005517          	auipc	a0,0x5
ffffffffc020135e:	cb650513          	addi	a0,a0,-842 # ffffffffc0206010 <free_area>
ffffffffc0201362:	491c                	lw	a5,16(a0)
    while (num > 1)
ffffffffc0201364:	4885                	li	a7,1
    return (size_t)(1 << exp);// 无符号整数类型
ffffffffc0201366:	4e05                	li	t3,1
    nr_free += n;
ffffffffc0201368:	9fad                	addw	a5,a5,a1
ffffffffc020136a:	c91c                	sw	a5,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020136c:	4309                	li	t1,2
    while (num > 1)
ffffffffc020136e:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc0201370:	4701                	li	a4,0
    while (num > 1)
ffffffffc0201372:	07158763          	beq	a1,a7,ffffffffc02013e0 <best_fit_init_memmap+0xb4>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0201376:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0201378:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc020137a:	ff179ee3          	bne	a5,a7,ffffffffc0201376 <best_fit_init_memmap+0x4a>
    return (size_t)(1 << exp);// 无符号整数类型
ffffffffc020137e:	00ee163b          	sllw	a2,t3,a4
        base -= curr_n;
ffffffffc0201382:	00261793          	slli	a5,a2,0x2
ffffffffc0201386:	97b2                	add	a5,a5,a2
ffffffffc0201388:	078e                	slli	a5,a5,0x3
ffffffffc020138a:	40f007b3          	neg	a5,a5
        base->property = curr_n;
ffffffffc020138e:	8732                	mv	a4,a2
        base -= curr_n;
ffffffffc0201390:	983e                	add	a6,a6,a5
        base->property = curr_n;
ffffffffc0201392:	00e82823          	sw	a4,16(a6)
ffffffffc0201396:	00880793          	addi	a5,a6,8
ffffffffc020139a:	4067b02f          	amoor.d	zero,t1,(a5)
    return listelm->next;
ffffffffc020139e:	651c                	ld	a5,8(a0)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc02013a0:	02a78263          	beq	a5,a0,ffffffffc02013c4 <best_fit_init_memmap+0x98>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc02013a4:	01082683          	lw	a3,16(a6)
ffffffffc02013a8:	a021                	j	ffffffffc02013b0 <best_fit_init_memmap+0x84>
ffffffffc02013aa:	679c                	ld	a5,8(a5)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc02013ac:	00a78c63          	beq	a5,a0,ffffffffc02013c4 <best_fit_init_memmap+0x98>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc02013b0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013b4:	00e6e863          	bltu	a3,a4,ffffffffc02013c4 <best_fit_init_memmap+0x98>
ffffffffc02013b8:	fed719e3          	bne	a4,a3,ffffffffc02013aa <best_fit_init_memmap+0x7e>
            struct Page *page = le2page(le, page_link);//获取当前页框
ffffffffc02013bc:	fe878713          	addi	a4,a5,-24
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc02013c0:	fee875e3          	bgeu	a6,a4,ffffffffc02013aa <best_fit_init_memmap+0x7e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013c4:	6398                	ld	a4,0(a5)
        list_add_before(le, &(base->page_link));
ffffffffc02013c6:	01880693          	addi	a3,a6,24
    prev->next = next->prev = elm;
ffffffffc02013ca:	e394                	sd	a3,0(a5)
ffffffffc02013cc:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02013ce:	02f83023          	sd	a5,32(a6)
    elm->prev = prev;
ffffffffc02013d2:	00e83c23          	sd	a4,24(a6)
        n -= curr_n;
ffffffffc02013d6:	8d91                	sub	a1,a1,a2
    while (n != 0)
ffffffffc02013d8:	f9d9                	bnez	a1,ffffffffc020136e <best_fit_init_memmap+0x42>
}
ffffffffc02013da:	60a2                	ld	ra,8(sp)
ffffffffc02013dc:	0141                	addi	sp,sp,16
ffffffffc02013de:	8082                	ret
    while (num > 1)
ffffffffc02013e0:	4605                	li	a2,1
ffffffffc02013e2:	4705                	li	a4,1
ffffffffc02013e4:	fd800793          	li	a5,-40
ffffffffc02013e8:	b765                	j	ffffffffc0201390 <best_fit_init_memmap+0x64>
        assert(PageReserved(p));// 确保页框是保留的
ffffffffc02013ea:	00001697          	auipc	a3,0x1
ffffffffc02013ee:	2b668693          	addi	a3,a3,694 # ffffffffc02026a0 <commands+0x878>
ffffffffc02013f2:	00001617          	auipc	a2,0x1
ffffffffc02013f6:	f3e60613          	addi	a2,a2,-194 # ffffffffc0202330 <commands+0x508>
ffffffffc02013fa:	02900593          	li	a1,41
ffffffffc02013fe:	00001517          	auipc	a0,0x1
ffffffffc0201402:	f4a50513          	addi	a0,a0,-182 # ffffffffc0202348 <commands+0x520>
ffffffffc0201406:	ee5fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc020140a:	00001697          	auipc	a3,0x1
ffffffffc020140e:	24e68693          	addi	a3,a3,590 # ffffffffc0202658 <commands+0x830>
ffffffffc0201412:	00001617          	auipc	a2,0x1
ffffffffc0201416:	f1e60613          	addi	a2,a2,-226 # ffffffffc0202330 <commands+0x508>
ffffffffc020141a:	02500593          	li	a1,37
ffffffffc020141e:	00001517          	auipc	a0,0x1
ffffffffc0201422:	f2a50513          	addi	a0,a0,-214 # ffffffffc0202348 <commands+0x520>
ffffffffc0201426:	ec5fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020142a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020142a:	100027f3          	csrr	a5,sstatus
ffffffffc020142e:	8b89                	andi	a5,a5,2
ffffffffc0201430:	e799                	bnez	a5,ffffffffc020143e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201432:	00005797          	auipc	a5,0x5
ffffffffc0201436:	0167b783          	ld	a5,22(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020143a:	6f9c                	ld	a5,24(a5)
ffffffffc020143c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020143e:	1141                	addi	sp,sp,-16
ffffffffc0201440:	e406                	sd	ra,8(sp)
ffffffffc0201442:	e022                	sd	s0,0(sp)
ffffffffc0201444:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201446:	818ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020144a:	00005797          	auipc	a5,0x5
ffffffffc020144e:	ffe7b783          	ld	a5,-2(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201452:	6f9c                	ld	a5,24(a5)
ffffffffc0201454:	8522                	mv	a0,s0
ffffffffc0201456:	9782                	jalr	a5
ffffffffc0201458:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020145a:	ffffe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020145e:	60a2                	ld	ra,8(sp)
ffffffffc0201460:	8522                	mv	a0,s0
ffffffffc0201462:	6402                	ld	s0,0(sp)
ffffffffc0201464:	0141                	addi	sp,sp,16
ffffffffc0201466:	8082                	ret

ffffffffc0201468 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201468:	100027f3          	csrr	a5,sstatus
ffffffffc020146c:	8b89                	andi	a5,a5,2
ffffffffc020146e:	e799                	bnez	a5,ffffffffc020147c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201470:	00005797          	auipc	a5,0x5
ffffffffc0201474:	fd87b783          	ld	a5,-40(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201478:	739c                	ld	a5,32(a5)
ffffffffc020147a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020147c:	1101                	addi	sp,sp,-32
ffffffffc020147e:	ec06                	sd	ra,24(sp)
ffffffffc0201480:	e822                	sd	s0,16(sp)
ffffffffc0201482:	e426                	sd	s1,8(sp)
ffffffffc0201484:	842a                	mv	s0,a0
ffffffffc0201486:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201488:	fd7fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020148c:	00005797          	auipc	a5,0x5
ffffffffc0201490:	fbc7b783          	ld	a5,-68(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201494:	739c                	ld	a5,32(a5)
ffffffffc0201496:	85a6                	mv	a1,s1
ffffffffc0201498:	8522                	mv	a0,s0
ffffffffc020149a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020149c:	6442                	ld	s0,16(sp)
ffffffffc020149e:	60e2                	ld	ra,24(sp)
ffffffffc02014a0:	64a2                	ld	s1,8(sp)
ffffffffc02014a2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02014a4:	fb5fe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02014a8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014a8:	100027f3          	csrr	a5,sstatus
ffffffffc02014ac:	8b89                	andi	a5,a5,2
ffffffffc02014ae:	e799                	bnez	a5,ffffffffc02014bc <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02014b0:	00005797          	auipc	a5,0x5
ffffffffc02014b4:	f987b783          	ld	a5,-104(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02014b8:	779c                	ld	a5,40(a5)
ffffffffc02014ba:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02014bc:	1141                	addi	sp,sp,-16
ffffffffc02014be:	e406                	sd	ra,8(sp)
ffffffffc02014c0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02014c2:	f9dfe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02014c6:	00005797          	auipc	a5,0x5
ffffffffc02014ca:	f827b783          	ld	a5,-126(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02014ce:	779c                	ld	a5,40(a5)
ffffffffc02014d0:	9782                	jalr	a5
ffffffffc02014d2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02014d4:	f85fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02014d8:	60a2                	ld	ra,8(sp)
ffffffffc02014da:	8522                	mv	a0,s0
ffffffffc02014dc:	6402                	ld	s0,0(sp)
ffffffffc02014de:	0141                	addi	sp,sp,16
ffffffffc02014e0:	8082                	ret

ffffffffc02014e2 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02014e2:	00001797          	auipc	a5,0x1
ffffffffc02014e6:	1e678793          	addi	a5,a5,486 # ffffffffc02026c8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014ea:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02014ec:	1101                	addi	sp,sp,-32
ffffffffc02014ee:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014f0:	00001517          	auipc	a0,0x1
ffffffffc02014f4:	21050513          	addi	a0,a0,528 # ffffffffc0202700 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02014f8:	00005497          	auipc	s1,0x5
ffffffffc02014fc:	f5048493          	addi	s1,s1,-176 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc0201500:	ec06                	sd	ra,24(sp)
ffffffffc0201502:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201504:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201506:	e7bfe0ef          	jal	ra,ffffffffc0200380 <cprintf>
    pmm_manager->init();
ffffffffc020150a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020150c:	00005417          	auipc	s0,0x5
ffffffffc0201510:	f5440413          	addi	s0,s0,-172 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201514:	679c                	ld	a5,8(a5)
ffffffffc0201516:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201518:	57f5                	li	a5,-3
ffffffffc020151a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020151c:	00001517          	auipc	a0,0x1
ffffffffc0201520:	1fc50513          	addi	a0,a0,508 # ffffffffc0202718 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201524:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201526:	e5bfe0ef          	jal	ra,ffffffffc0200380 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020152a:	46c5                	li	a3,17
ffffffffc020152c:	06ee                	slli	a3,a3,0x1b
ffffffffc020152e:	40100613          	li	a2,1025
ffffffffc0201532:	16fd                	addi	a3,a3,-1
ffffffffc0201534:	07e005b7          	lui	a1,0x7e00
ffffffffc0201538:	0656                	slli	a2,a2,0x15
ffffffffc020153a:	00001517          	auipc	a0,0x1
ffffffffc020153e:	1f650513          	addi	a0,a0,502 # ffffffffc0202730 <best_fit_pmm_manager+0x68>
ffffffffc0201542:	e3ffe0ef          	jal	ra,ffffffffc0200380 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201546:	777d                	lui	a4,0xfffff
ffffffffc0201548:	00006797          	auipc	a5,0x6
ffffffffc020154c:	f2778793          	addi	a5,a5,-217 # ffffffffc020746f <end+0xfff>
ffffffffc0201550:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201552:	00005517          	auipc	a0,0x5
ffffffffc0201556:	ee650513          	addi	a0,a0,-282 # ffffffffc0206438 <npage>
ffffffffc020155a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020155e:	00005597          	auipc	a1,0x5
ffffffffc0201562:	ee258593          	addi	a1,a1,-286 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201566:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201568:	e19c                	sd	a5,0(a1)
ffffffffc020156a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020156c:	4701                	li	a4,0
ffffffffc020156e:	4885                	li	a7,1
ffffffffc0201570:	fff80837          	lui	a6,0xfff80
ffffffffc0201574:	a011                	j	ffffffffc0201578 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201576:	619c                	ld	a5,0(a1)
ffffffffc0201578:	97b6                	add	a5,a5,a3
ffffffffc020157a:	07a1                	addi	a5,a5,8
ffffffffc020157c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201580:	611c                	ld	a5,0(a0)
ffffffffc0201582:	0705                	addi	a4,a4,1
ffffffffc0201584:	02868693          	addi	a3,a3,40
ffffffffc0201588:	01078633          	add	a2,a5,a6
ffffffffc020158c:	fec765e3          	bltu	a4,a2,ffffffffc0201576 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201590:	6190                	ld	a2,0(a1)
ffffffffc0201592:	00279713          	slli	a4,a5,0x2
ffffffffc0201596:	973e                	add	a4,a4,a5
ffffffffc0201598:	fec006b7          	lui	a3,0xfec00
ffffffffc020159c:	070e                	slli	a4,a4,0x3
ffffffffc020159e:	96b2                	add	a3,a3,a2
ffffffffc02015a0:	96ba                	add	a3,a3,a4
ffffffffc02015a2:	c0200737          	lui	a4,0xc0200
ffffffffc02015a6:	08e6ef63          	bltu	a3,a4,ffffffffc0201644 <pmm_init+0x162>
ffffffffc02015aa:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02015ac:	45c5                	li	a1,17
ffffffffc02015ae:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015b0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02015b2:	04b6e863          	bltu	a3,a1,ffffffffc0201602 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02015b6:	609c                	ld	a5,0(s1)
ffffffffc02015b8:	7b9c                	ld	a5,48(a5)
ffffffffc02015ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02015bc:	00001517          	auipc	a0,0x1
ffffffffc02015c0:	20c50513          	addi	a0,a0,524 # ffffffffc02027c8 <best_fit_pmm_manager+0x100>
ffffffffc02015c4:	dbdfe0ef          	jal	ra,ffffffffc0200380 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02015c8:	00004597          	auipc	a1,0x4
ffffffffc02015cc:	a3858593          	addi	a1,a1,-1480 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02015d0:	00005797          	auipc	a5,0x5
ffffffffc02015d4:	e8b7b423          	sd	a1,-376(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02015dc:	08f5e063          	bltu	a1,a5,ffffffffc020165c <pmm_init+0x17a>
ffffffffc02015e0:	6010                	ld	a2,0(s0)
}
ffffffffc02015e2:	6442                	ld	s0,16(sp)
ffffffffc02015e4:	60e2                	ld	ra,24(sp)
ffffffffc02015e6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02015e8:	40c58633          	sub	a2,a1,a2
ffffffffc02015ec:	00005797          	auipc	a5,0x5
ffffffffc02015f0:	e6c7b223          	sd	a2,-412(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015f4:	00001517          	auipc	a0,0x1
ffffffffc02015f8:	1f450513          	addi	a0,a0,500 # ffffffffc02027e8 <best_fit_pmm_manager+0x120>
}
ffffffffc02015fc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015fe:	d83fe06f          	j	ffffffffc0200380 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201602:	6705                	lui	a4,0x1
ffffffffc0201604:	177d                	addi	a4,a4,-1
ffffffffc0201606:	96ba                	add	a3,a3,a4
ffffffffc0201608:	777d                	lui	a4,0xfffff
ffffffffc020160a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020160c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201610:	00f57e63          	bgeu	a0,a5,ffffffffc020162c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201614:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201616:	982a                	add	a6,a6,a0
ffffffffc0201618:	00281513          	slli	a0,a6,0x2
ffffffffc020161c:	9542                	add	a0,a0,a6
ffffffffc020161e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201620:	8d95                	sub	a1,a1,a3
ffffffffc0201622:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201624:	81b1                	srli	a1,a1,0xc
ffffffffc0201626:	9532                	add	a0,a0,a2
ffffffffc0201628:	9782                	jalr	a5
}
ffffffffc020162a:	b771                	j	ffffffffc02015b6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020162c:	00001617          	auipc	a2,0x1
ffffffffc0201630:	16c60613          	addi	a2,a2,364 # ffffffffc0202798 <best_fit_pmm_manager+0xd0>
ffffffffc0201634:	06b00593          	li	a1,107
ffffffffc0201638:	00001517          	auipc	a0,0x1
ffffffffc020163c:	18050513          	addi	a0,a0,384 # ffffffffc02027b8 <best_fit_pmm_manager+0xf0>
ffffffffc0201640:	cabfe0ef          	jal	ra,ffffffffc02002ea <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201644:	00001617          	auipc	a2,0x1
ffffffffc0201648:	11c60613          	addi	a2,a2,284 # ffffffffc0202760 <best_fit_pmm_manager+0x98>
ffffffffc020164c:	06e00593          	li	a1,110
ffffffffc0201650:	00001517          	auipc	a0,0x1
ffffffffc0201654:	13850513          	addi	a0,a0,312 # ffffffffc0202788 <best_fit_pmm_manager+0xc0>
ffffffffc0201658:	c93fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020165c:	86ae                	mv	a3,a1
ffffffffc020165e:	00001617          	auipc	a2,0x1
ffffffffc0201662:	10260613          	addi	a2,a2,258 # ffffffffc0202760 <best_fit_pmm_manager+0x98>
ffffffffc0201666:	08900593          	li	a1,137
ffffffffc020166a:	00001517          	auipc	a0,0x1
ffffffffc020166e:	11e50513          	addi	a0,a0,286 # ffffffffc0202788 <best_fit_pmm_manager+0xc0>
ffffffffc0201672:	c79fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201676 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201676:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020167a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020167c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201680:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201682:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201686:	f022                	sd	s0,32(sp)
ffffffffc0201688:	ec26                	sd	s1,24(sp)
ffffffffc020168a:	e84a                	sd	s2,16(sp)
ffffffffc020168c:	f406                	sd	ra,40(sp)
ffffffffc020168e:	e44e                	sd	s3,8(sp)
ffffffffc0201690:	84aa                	mv	s1,a0
ffffffffc0201692:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201694:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201698:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020169a:	03067e63          	bgeu	a2,a6,ffffffffc02016d6 <printnum+0x60>
ffffffffc020169e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02016a0:	00805763          	blez	s0,ffffffffc02016ae <printnum+0x38>
ffffffffc02016a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02016a6:	85ca                	mv	a1,s2
ffffffffc02016a8:	854e                	mv	a0,s3
ffffffffc02016aa:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02016ac:	fc65                	bnez	s0,ffffffffc02016a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ae:	1a02                	slli	s4,s4,0x20
ffffffffc02016b0:	00001797          	auipc	a5,0x1
ffffffffc02016b4:	17878793          	addi	a5,a5,376 # ffffffffc0202828 <best_fit_pmm_manager+0x160>
ffffffffc02016b8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016bc:	9a3e                	add	s4,s4,a5
}
ffffffffc02016be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016c0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016c4:	70a2                	ld	ra,40(sp)
ffffffffc02016c6:	69a2                	ld	s3,8(sp)
ffffffffc02016c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ca:	85ca                	mv	a1,s2
ffffffffc02016cc:	87a6                	mv	a5,s1
}
ffffffffc02016ce:	6942                	ld	s2,16(sp)
ffffffffc02016d0:	64e2                	ld	s1,24(sp)
ffffffffc02016d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016d4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016d6:	03065633          	divu	a2,a2,a6
ffffffffc02016da:	8722                	mv	a4,s0
ffffffffc02016dc:	f9bff0ef          	jal	ra,ffffffffc0201676 <printnum>
ffffffffc02016e0:	b7f9                	j	ffffffffc02016ae <printnum+0x38>

ffffffffc02016e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016e2:	7119                	addi	sp,sp,-128
ffffffffc02016e4:	f4a6                	sd	s1,104(sp)
ffffffffc02016e6:	f0ca                	sd	s2,96(sp)
ffffffffc02016e8:	ecce                	sd	s3,88(sp)
ffffffffc02016ea:	e8d2                	sd	s4,80(sp)
ffffffffc02016ec:	e4d6                	sd	s5,72(sp)
ffffffffc02016ee:	e0da                	sd	s6,64(sp)
ffffffffc02016f0:	fc5e                	sd	s7,56(sp)
ffffffffc02016f2:	f06a                	sd	s10,32(sp)
ffffffffc02016f4:	fc86                	sd	ra,120(sp)
ffffffffc02016f6:	f8a2                	sd	s0,112(sp)
ffffffffc02016f8:	f862                	sd	s8,48(sp)
ffffffffc02016fa:	f466                	sd	s9,40(sp)
ffffffffc02016fc:	ec6e                	sd	s11,24(sp)
ffffffffc02016fe:	892a                	mv	s2,a0
ffffffffc0201700:	84ae                	mv	s1,a1
ffffffffc0201702:	8d32                	mv	s10,a2
ffffffffc0201704:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201706:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020170a:	5b7d                	li	s6,-1
ffffffffc020170c:	00001a97          	auipc	s5,0x1
ffffffffc0201710:	150a8a93          	addi	s5,s5,336 # ffffffffc020285c <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201714:	00001b97          	auipc	s7,0x1
ffffffffc0201718:	324b8b93          	addi	s7,s7,804 # ffffffffc0202a38 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020171c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201720:	001d0413          	addi	s0,s10,1
ffffffffc0201724:	01350a63          	beq	a0,s3,ffffffffc0201738 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201728:	c121                	beqz	a0,ffffffffc0201768 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020172a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020172c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020172e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201730:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201734:	ff351ae3          	bne	a0,s3,ffffffffc0201728 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201738:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020173c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201740:	4c81                	li	s9,0
ffffffffc0201742:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201744:	5c7d                	li	s8,-1
ffffffffc0201746:	5dfd                	li	s11,-1
ffffffffc0201748:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020174c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020174e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201752:	0ff5f593          	zext.b	a1,a1
ffffffffc0201756:	00140d13          	addi	s10,s0,1
ffffffffc020175a:	04b56263          	bltu	a0,a1,ffffffffc020179e <vprintfmt+0xbc>
ffffffffc020175e:	058a                	slli	a1,a1,0x2
ffffffffc0201760:	95d6                	add	a1,a1,s5
ffffffffc0201762:	4194                	lw	a3,0(a1)
ffffffffc0201764:	96d6                	add	a3,a3,s5
ffffffffc0201766:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201768:	70e6                	ld	ra,120(sp)
ffffffffc020176a:	7446                	ld	s0,112(sp)
ffffffffc020176c:	74a6                	ld	s1,104(sp)
ffffffffc020176e:	7906                	ld	s2,96(sp)
ffffffffc0201770:	69e6                	ld	s3,88(sp)
ffffffffc0201772:	6a46                	ld	s4,80(sp)
ffffffffc0201774:	6aa6                	ld	s5,72(sp)
ffffffffc0201776:	6b06                	ld	s6,64(sp)
ffffffffc0201778:	7be2                	ld	s7,56(sp)
ffffffffc020177a:	7c42                	ld	s8,48(sp)
ffffffffc020177c:	7ca2                	ld	s9,40(sp)
ffffffffc020177e:	7d02                	ld	s10,32(sp)
ffffffffc0201780:	6de2                	ld	s11,24(sp)
ffffffffc0201782:	6109                	addi	sp,sp,128
ffffffffc0201784:	8082                	ret
            padc = '0';
ffffffffc0201786:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201788:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020178c:	846a                	mv	s0,s10
ffffffffc020178e:	00140d13          	addi	s10,s0,1
ffffffffc0201792:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201796:	0ff5f593          	zext.b	a1,a1
ffffffffc020179a:	fcb572e3          	bgeu	a0,a1,ffffffffc020175e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020179e:	85a6                	mv	a1,s1
ffffffffc02017a0:	02500513          	li	a0,37
ffffffffc02017a4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02017a6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017aa:	8d22                	mv	s10,s0
ffffffffc02017ac:	f73788e3          	beq	a5,s3,ffffffffc020171c <vprintfmt+0x3a>
ffffffffc02017b0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02017b4:	1d7d                	addi	s10,s10,-1
ffffffffc02017b6:	ff379de3          	bne	a5,s3,ffffffffc02017b0 <vprintfmt+0xce>
ffffffffc02017ba:	b78d                	j	ffffffffc020171c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02017bc:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02017c0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02017c6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02017ca:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017ce:	02d86463          	bltu	a6,a3,ffffffffc02017f6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02017d2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02017d6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02017da:	0186873b          	addw	a4,a3,s8
ffffffffc02017de:	0017171b          	slliw	a4,a4,0x1
ffffffffc02017e2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02017e4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02017e8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02017ea:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02017ee:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017f2:	fed870e3          	bgeu	a6,a3,ffffffffc02017d2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02017f6:	f40ddce3          	bgez	s11,ffffffffc020174e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02017fa:	8de2                	mv	s11,s8
ffffffffc02017fc:	5c7d                	li	s8,-1
ffffffffc02017fe:	bf81                	j	ffffffffc020174e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201800:	fffdc693          	not	a3,s11
ffffffffc0201804:	96fd                	srai	a3,a3,0x3f
ffffffffc0201806:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020180a:	00144603          	lbu	a2,1(s0)
ffffffffc020180e:	2d81                	sext.w	s11,s11
ffffffffc0201810:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201812:	bf35                	j	ffffffffc020174e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201814:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201818:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020181c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020181e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201820:	bfd9                	j	ffffffffc02017f6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201822:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201824:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201828:	01174463          	blt	a4,a7,ffffffffc0201830 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020182c:	1a088e63          	beqz	a7,ffffffffc02019e8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201830:	000a3603          	ld	a2,0(s4)
ffffffffc0201834:	46c1                	li	a3,16
ffffffffc0201836:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201838:	2781                	sext.w	a5,a5
ffffffffc020183a:	876e                	mv	a4,s11
ffffffffc020183c:	85a6                	mv	a1,s1
ffffffffc020183e:	854a                	mv	a0,s2
ffffffffc0201840:	e37ff0ef          	jal	ra,ffffffffc0201676 <printnum>
            break;
ffffffffc0201844:	bde1                	j	ffffffffc020171c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201846:	000a2503          	lw	a0,0(s4)
ffffffffc020184a:	85a6                	mv	a1,s1
ffffffffc020184c:	0a21                	addi	s4,s4,8
ffffffffc020184e:	9902                	jalr	s2
            break;
ffffffffc0201850:	b5f1                	j	ffffffffc020171c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201852:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201854:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201858:	01174463          	blt	a4,a7,ffffffffc0201860 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020185c:	18088163          	beqz	a7,ffffffffc02019de <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201860:	000a3603          	ld	a2,0(s4)
ffffffffc0201864:	46a9                	li	a3,10
ffffffffc0201866:	8a2e                	mv	s4,a1
ffffffffc0201868:	bfc1                	j	ffffffffc0201838 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020186e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201870:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201872:	bdf1                	j	ffffffffc020174e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201874:	85a6                	mv	a1,s1
ffffffffc0201876:	02500513          	li	a0,37
ffffffffc020187a:	9902                	jalr	s2
            break;
ffffffffc020187c:	b545                	j	ffffffffc020171c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020187e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201882:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201884:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201886:	b5e1                	j	ffffffffc020174e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201888:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020188a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020188e:	01174463          	blt	a4,a7,ffffffffc0201896 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201892:	14088163          	beqz	a7,ffffffffc02019d4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201896:	000a3603          	ld	a2,0(s4)
ffffffffc020189a:	46a1                	li	a3,8
ffffffffc020189c:	8a2e                	mv	s4,a1
ffffffffc020189e:	bf69                	j	ffffffffc0201838 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02018a0:	03000513          	li	a0,48
ffffffffc02018a4:	85a6                	mv	a1,s1
ffffffffc02018a6:	e03e                	sd	a5,0(sp)
ffffffffc02018a8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02018aa:	85a6                	mv	a1,s1
ffffffffc02018ac:	07800513          	li	a0,120
ffffffffc02018b0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018b2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02018b4:	6782                	ld	a5,0(sp)
ffffffffc02018b6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018b8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02018bc:	bfb5                	j	ffffffffc0201838 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018be:	000a3403          	ld	s0,0(s4)
ffffffffc02018c2:	008a0713          	addi	a4,s4,8
ffffffffc02018c6:	e03a                	sd	a4,0(sp)
ffffffffc02018c8:	14040263          	beqz	s0,ffffffffc0201a0c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02018cc:	0fb05763          	blez	s11,ffffffffc02019ba <vprintfmt+0x2d8>
ffffffffc02018d0:	02d00693          	li	a3,45
ffffffffc02018d4:	0cd79163          	bne	a5,a3,ffffffffc0201996 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018d8:	00044783          	lbu	a5,0(s0)
ffffffffc02018dc:	0007851b          	sext.w	a0,a5
ffffffffc02018e0:	cf85                	beqz	a5,ffffffffc0201918 <vprintfmt+0x236>
ffffffffc02018e2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018e6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018ea:	000c4563          	bltz	s8,ffffffffc02018f4 <vprintfmt+0x212>
ffffffffc02018ee:	3c7d                	addiw	s8,s8,-1
ffffffffc02018f0:	036c0263          	beq	s8,s6,ffffffffc0201914 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02018f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018f6:	0e0c8e63          	beqz	s9,ffffffffc02019f2 <vprintfmt+0x310>
ffffffffc02018fa:	3781                	addiw	a5,a5,-32
ffffffffc02018fc:	0ef47b63          	bgeu	s0,a5,ffffffffc02019f2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201900:	03f00513          	li	a0,63
ffffffffc0201904:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201906:	000a4783          	lbu	a5,0(s4)
ffffffffc020190a:	3dfd                	addiw	s11,s11,-1
ffffffffc020190c:	0a05                	addi	s4,s4,1
ffffffffc020190e:	0007851b          	sext.w	a0,a5
ffffffffc0201912:	ffe1                	bnez	a5,ffffffffc02018ea <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201914:	01b05963          	blez	s11,ffffffffc0201926 <vprintfmt+0x244>
ffffffffc0201918:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020191a:	85a6                	mv	a1,s1
ffffffffc020191c:	02000513          	li	a0,32
ffffffffc0201920:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201922:	fe0d9be3          	bnez	s11,ffffffffc0201918 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201926:	6a02                	ld	s4,0(sp)
ffffffffc0201928:	bbd5                	j	ffffffffc020171c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020192a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020192c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201930:	01174463          	blt	a4,a7,ffffffffc0201938 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201934:	08088d63          	beqz	a7,ffffffffc02019ce <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201938:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020193c:	0a044d63          	bltz	s0,ffffffffc02019f6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201940:	8622                	mv	a2,s0
ffffffffc0201942:	8a66                	mv	s4,s9
ffffffffc0201944:	46a9                	li	a3,10
ffffffffc0201946:	bdcd                	j	ffffffffc0201838 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201948:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020194c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020194e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201950:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201954:	8fb5                	xor	a5,a5,a3
ffffffffc0201956:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020195a:	02d74163          	blt	a4,a3,ffffffffc020197c <vprintfmt+0x29a>
ffffffffc020195e:	00369793          	slli	a5,a3,0x3
ffffffffc0201962:	97de                	add	a5,a5,s7
ffffffffc0201964:	639c                	ld	a5,0(a5)
ffffffffc0201966:	cb99                	beqz	a5,ffffffffc020197c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201968:	86be                	mv	a3,a5
ffffffffc020196a:	00001617          	auipc	a2,0x1
ffffffffc020196e:	eee60613          	addi	a2,a2,-274 # ffffffffc0202858 <best_fit_pmm_manager+0x190>
ffffffffc0201972:	85a6                	mv	a1,s1
ffffffffc0201974:	854a                	mv	a0,s2
ffffffffc0201976:	0ce000ef          	jal	ra,ffffffffc0201a44 <printfmt>
ffffffffc020197a:	b34d                	j	ffffffffc020171c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020197c:	00001617          	auipc	a2,0x1
ffffffffc0201980:	ecc60613          	addi	a2,a2,-308 # ffffffffc0202848 <best_fit_pmm_manager+0x180>
ffffffffc0201984:	85a6                	mv	a1,s1
ffffffffc0201986:	854a                	mv	a0,s2
ffffffffc0201988:	0bc000ef          	jal	ra,ffffffffc0201a44 <printfmt>
ffffffffc020198c:	bb41                	j	ffffffffc020171c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020198e:	00001417          	auipc	s0,0x1
ffffffffc0201992:	eb240413          	addi	s0,s0,-334 # ffffffffc0202840 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201996:	85e2                	mv	a1,s8
ffffffffc0201998:	8522                	mv	a0,s0
ffffffffc020199a:	e43e                	sd	a5,8(sp)
ffffffffc020199c:	1cc000ef          	jal	ra,ffffffffc0201b68 <strnlen>
ffffffffc02019a0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019a4:	01b05b63          	blez	s11,ffffffffc02019ba <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02019a8:	67a2                	ld	a5,8(sp)
ffffffffc02019aa:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019ae:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019b0:	85a6                	mv	a1,s1
ffffffffc02019b2:	8552                	mv	a0,s4
ffffffffc02019b4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019b6:	fe0d9ce3          	bnez	s11,ffffffffc02019ae <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019ba:	00044783          	lbu	a5,0(s0)
ffffffffc02019be:	00140a13          	addi	s4,s0,1
ffffffffc02019c2:	0007851b          	sext.w	a0,a5
ffffffffc02019c6:	d3a5                	beqz	a5,ffffffffc0201926 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019c8:	05e00413          	li	s0,94
ffffffffc02019cc:	bf39                	j	ffffffffc02018ea <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02019ce:	000a2403          	lw	s0,0(s4)
ffffffffc02019d2:	b7ad                	j	ffffffffc020193c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02019d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02019d8:	46a1                	li	a3,8
ffffffffc02019da:	8a2e                	mv	s4,a1
ffffffffc02019dc:	bdb1                	j	ffffffffc0201838 <vprintfmt+0x156>
ffffffffc02019de:	000a6603          	lwu	a2,0(s4)
ffffffffc02019e2:	46a9                	li	a3,10
ffffffffc02019e4:	8a2e                	mv	s4,a1
ffffffffc02019e6:	bd89                	j	ffffffffc0201838 <vprintfmt+0x156>
ffffffffc02019e8:	000a6603          	lwu	a2,0(s4)
ffffffffc02019ec:	46c1                	li	a3,16
ffffffffc02019ee:	8a2e                	mv	s4,a1
ffffffffc02019f0:	b5a1                	j	ffffffffc0201838 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02019f2:	9902                	jalr	s2
ffffffffc02019f4:	bf09                	j	ffffffffc0201906 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02019f6:	85a6                	mv	a1,s1
ffffffffc02019f8:	02d00513          	li	a0,45
ffffffffc02019fc:	e03e                	sd	a5,0(sp)
ffffffffc02019fe:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a00:	6782                	ld	a5,0(sp)
ffffffffc0201a02:	8a66                	mv	s4,s9
ffffffffc0201a04:	40800633          	neg	a2,s0
ffffffffc0201a08:	46a9                	li	a3,10
ffffffffc0201a0a:	b53d                	j	ffffffffc0201838 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201a0c:	03b05163          	blez	s11,ffffffffc0201a2e <vprintfmt+0x34c>
ffffffffc0201a10:	02d00693          	li	a3,45
ffffffffc0201a14:	f6d79de3          	bne	a5,a3,ffffffffc020198e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201a18:	00001417          	auipc	s0,0x1
ffffffffc0201a1c:	e2840413          	addi	s0,s0,-472 # ffffffffc0202840 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a20:	02800793          	li	a5,40
ffffffffc0201a24:	02800513          	li	a0,40
ffffffffc0201a28:	00140a13          	addi	s4,s0,1
ffffffffc0201a2c:	bd6d                	j	ffffffffc02018e6 <vprintfmt+0x204>
ffffffffc0201a2e:	00001a17          	auipc	s4,0x1
ffffffffc0201a32:	e13a0a13          	addi	s4,s4,-493 # ffffffffc0202841 <best_fit_pmm_manager+0x179>
ffffffffc0201a36:	02800513          	li	a0,40
ffffffffc0201a3a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a3e:	05e00413          	li	s0,94
ffffffffc0201a42:	b565                	j	ffffffffc02018ea <vprintfmt+0x208>

ffffffffc0201a44 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a44:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a46:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a4a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a4c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a4e:	ec06                	sd	ra,24(sp)
ffffffffc0201a50:	f83a                	sd	a4,48(sp)
ffffffffc0201a52:	fc3e                	sd	a5,56(sp)
ffffffffc0201a54:	e0c2                	sd	a6,64(sp)
ffffffffc0201a56:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a58:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a5a:	c89ff0ef          	jal	ra,ffffffffc02016e2 <vprintfmt>
}
ffffffffc0201a5e:	60e2                	ld	ra,24(sp)
ffffffffc0201a60:	6161                	addi	sp,sp,80
ffffffffc0201a62:	8082                	ret

ffffffffc0201a64 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a64:	715d                	addi	sp,sp,-80
ffffffffc0201a66:	e486                	sd	ra,72(sp)
ffffffffc0201a68:	e0a6                	sd	s1,64(sp)
ffffffffc0201a6a:	fc4a                	sd	s2,56(sp)
ffffffffc0201a6c:	f84e                	sd	s3,48(sp)
ffffffffc0201a6e:	f452                	sd	s4,40(sp)
ffffffffc0201a70:	f056                	sd	s5,32(sp)
ffffffffc0201a72:	ec5a                	sd	s6,24(sp)
ffffffffc0201a74:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201a76:	c901                	beqz	a0,ffffffffc0201a86 <readline+0x22>
ffffffffc0201a78:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201a7a:	00001517          	auipc	a0,0x1
ffffffffc0201a7e:	dde50513          	addi	a0,a0,-546 # ffffffffc0202858 <best_fit_pmm_manager+0x190>
ffffffffc0201a82:	8fffe0ef          	jal	ra,ffffffffc0200380 <cprintf>
readline(const char *prompt) {
ffffffffc0201a86:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a88:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a8a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a8c:	4aa9                	li	s5,10
ffffffffc0201a8e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a90:	00004b97          	auipc	s7,0x4
ffffffffc0201a94:	598b8b93          	addi	s7,s7,1432 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a98:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a9c:	95dfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc0201aa0:	00054a63          	bltz	a0,ffffffffc0201ab4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201aa4:	00a95a63          	bge	s2,a0,ffffffffc0201ab8 <readline+0x54>
ffffffffc0201aa8:	029a5263          	bge	s4,s1,ffffffffc0201acc <readline+0x68>
        c = getchar();
ffffffffc0201aac:	94dfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc0201ab0:	fe055ae3          	bgez	a0,ffffffffc0201aa4 <readline+0x40>
            return NULL;
ffffffffc0201ab4:	4501                	li	a0,0
ffffffffc0201ab6:	a091                	j	ffffffffc0201afa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201ab8:	03351463          	bne	a0,s3,ffffffffc0201ae0 <readline+0x7c>
ffffffffc0201abc:	e8a9                	bnez	s1,ffffffffc0201b0e <readline+0xaa>
        c = getchar();
ffffffffc0201abe:	93bfe0ef          	jal	ra,ffffffffc02003f8 <getchar>
        if (c < 0) {
ffffffffc0201ac2:	fe0549e3          	bltz	a0,ffffffffc0201ab4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ac6:	fea959e3          	bge	s2,a0,ffffffffc0201ab8 <readline+0x54>
ffffffffc0201aca:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201acc:	e42a                	sd	a0,8(sp)
ffffffffc0201ace:	8e9fe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            buf[i ++] = c;
ffffffffc0201ad2:	6522                	ld	a0,8(sp)
ffffffffc0201ad4:	009b87b3          	add	a5,s7,s1
ffffffffc0201ad8:	2485                	addiw	s1,s1,1
ffffffffc0201ada:	00a78023          	sb	a0,0(a5)
ffffffffc0201ade:	bf7d                	j	ffffffffc0201a9c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ae0:	01550463          	beq	a0,s5,ffffffffc0201ae8 <readline+0x84>
ffffffffc0201ae4:	fb651ce3          	bne	a0,s6,ffffffffc0201a9c <readline+0x38>
            cputchar(c);
ffffffffc0201ae8:	8cffe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            buf[i] = '\0';
ffffffffc0201aec:	00004517          	auipc	a0,0x4
ffffffffc0201af0:	53c50513          	addi	a0,a0,1340 # ffffffffc0206028 <buf>
ffffffffc0201af4:	94aa                	add	s1,s1,a0
ffffffffc0201af6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201afa:	60a6                	ld	ra,72(sp)
ffffffffc0201afc:	6486                	ld	s1,64(sp)
ffffffffc0201afe:	7962                	ld	s2,56(sp)
ffffffffc0201b00:	79c2                	ld	s3,48(sp)
ffffffffc0201b02:	7a22                	ld	s4,40(sp)
ffffffffc0201b04:	7a82                	ld	s5,32(sp)
ffffffffc0201b06:	6b62                	ld	s6,24(sp)
ffffffffc0201b08:	6bc2                	ld	s7,16(sp)
ffffffffc0201b0a:	6161                	addi	sp,sp,80
ffffffffc0201b0c:	8082                	ret
            cputchar(c);
ffffffffc0201b0e:	4521                	li	a0,8
ffffffffc0201b10:	8a7fe0ef          	jal	ra,ffffffffc02003b6 <cputchar>
            i --;
ffffffffc0201b14:	34fd                	addiw	s1,s1,-1
ffffffffc0201b16:	b759                	j	ffffffffc0201a9c <readline+0x38>

ffffffffc0201b18 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201b18:	4781                	li	a5,0
ffffffffc0201b1a:	00004717          	auipc	a4,0x4
ffffffffc0201b1e:	4ee73703          	ld	a4,1262(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201b22:	88ba                	mv	a7,a4
ffffffffc0201b24:	852a                	mv	a0,a0
ffffffffc0201b26:	85be                	mv	a1,a5
ffffffffc0201b28:	863e                	mv	a2,a5
ffffffffc0201b2a:	00000073          	ecall
ffffffffc0201b2e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201b30:	8082                	ret

ffffffffc0201b32 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201b32:	4781                	li	a5,0
ffffffffc0201b34:	00005717          	auipc	a4,0x5
ffffffffc0201b38:	93473703          	ld	a4,-1740(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201b3c:	88ba                	mv	a7,a4
ffffffffc0201b3e:	852a                	mv	a0,a0
ffffffffc0201b40:	85be                	mv	a1,a5
ffffffffc0201b42:	863e                	mv	a2,a5
ffffffffc0201b44:	00000073          	ecall
ffffffffc0201b48:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201b4a:	8082                	ret

ffffffffc0201b4c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201b4c:	4501                	li	a0,0
ffffffffc0201b4e:	00004797          	auipc	a5,0x4
ffffffffc0201b52:	4b27b783          	ld	a5,1202(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b56:	88be                	mv	a7,a5
ffffffffc0201b58:	852a                	mv	a0,a0
ffffffffc0201b5a:	85aa                	mv	a1,a0
ffffffffc0201b5c:	862a                	mv	a2,a0
ffffffffc0201b5e:	00000073          	ecall
ffffffffc0201b62:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b64:	2501                	sext.w	a0,a0
ffffffffc0201b66:	8082                	ret

ffffffffc0201b68 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201b68:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b6a:	e589                	bnez	a1,ffffffffc0201b74 <strnlen+0xc>
ffffffffc0201b6c:	a811                	j	ffffffffc0201b80 <strnlen+0x18>
        cnt ++;
ffffffffc0201b6e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b70:	00f58863          	beq	a1,a5,ffffffffc0201b80 <strnlen+0x18>
ffffffffc0201b74:	00f50733          	add	a4,a0,a5
ffffffffc0201b78:	00074703          	lbu	a4,0(a4)
ffffffffc0201b7c:	fb6d                	bnez	a4,ffffffffc0201b6e <strnlen+0x6>
ffffffffc0201b7e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201b80:	852e                	mv	a0,a1
ffffffffc0201b82:	8082                	ret

ffffffffc0201b84 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b84:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b88:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b8c:	cb89                	beqz	a5,ffffffffc0201b9e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201b8e:	0505                	addi	a0,a0,1
ffffffffc0201b90:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b92:	fee789e3          	beq	a5,a4,ffffffffc0201b84 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b96:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b9a:	9d19                	subw	a0,a0,a4
ffffffffc0201b9c:	8082                	ret
ffffffffc0201b9e:	4501                	li	a0,0
ffffffffc0201ba0:	bfed                	j	ffffffffc0201b9a <strcmp+0x16>

ffffffffc0201ba2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ba2:	00054783          	lbu	a5,0(a0)
ffffffffc0201ba6:	c799                	beqz	a5,ffffffffc0201bb4 <strchr+0x12>
        if (*s == c) {
ffffffffc0201ba8:	00f58763          	beq	a1,a5,ffffffffc0201bb6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201bac:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201bb0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201bb2:	fbfd                	bnez	a5,ffffffffc0201ba8 <strchr+0x6>
    }
    return NULL;
ffffffffc0201bb4:	4501                	li	a0,0
}
ffffffffc0201bb6:	8082                	ret

ffffffffc0201bb8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201bb8:	ca01                	beqz	a2,ffffffffc0201bc8 <memset+0x10>
ffffffffc0201bba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201bbc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201bbe:	0785                	addi	a5,a5,1
ffffffffc0201bc0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201bc4:	fec79de3          	bne	a5,a2,ffffffffc0201bbe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201bc8:	8082                	ret

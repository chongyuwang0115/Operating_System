# Lab 4

苏浩天 2213560 王崇宇 2210653 苟辉铭 2213042

## 实验要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 知识点整理：

**内核线程与用户进程的区别**

- 内核线程只运行在内核态
- 用户进程会在在用户态和内核态交替运行
- 所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间
- 而用户进程需要维护各自的用户内存空间

**进程与线程**

- 程序：源代码经过编译器变成的可执行文件
- 进程：程序装载进内存开始执行，包含程序内容，也包含“正在运行”的特性
- 线程：“正在运行”的部分(一个程序可以对应一个线程或多个线程)

> 这些线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体（因为操作系统分配网络等资源时往往是基于进程的），这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能

**为什么需要进程：**

（1）便于调度（否则所有的代码可能需要在操作系统编译的时候就打包在一块，安装软件将变成一件非常难的事情，这显然对于用户使用计算机是不利的）

（2）使用进程的概念有助于各个进程同时的利用CPU的各个核心，这是单进程系统往往做不到的。

（3）时间片轮转

## 练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

> 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

### 源代码

```c++
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Process
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        // 参考实验指导手册：alloc_proc函数获取一块内存作为第0个进程控制块，并初始化（大体是将成员变量清零）
        proc->state = PROC_UNINIT;  // 设置进程为“未初始化”状态——即第0个内核线程（空闲进程idleproc）
        proc->pid = -1;  // 设置进程PID为未初始化值，即-1
        proc->runs = 0;  // 根据提示可知该成员变量表示进程的运行时间，初始化为0
        proc->kstack = 0;  // 进程内核栈初始化为0【kstack记录了分配给该进程/线程的内核栈的位置】
        proc->need_resched = 0;  // 是否需要重新调度以释放 CPU？当然了，我们现在处于未初始化状态，不需要进行调度
        proc->parent = NULL;  // 父进程控制块指针，第0个进程控制块诶，它是始祖！
        proc->mm = NULL;  // 进程的内存管理字段:参见lab3练习一分析；对于内核进程而言，不存在虚拟内存管理
        memset(&(proc->context), 0, sizeof(struct context));  // 上下文，现在是源头，当然为空，发生切换时修改
        proc->tf = NULL;  // 进程中断帧，初始化为空，发生中断时修改
        proc->cr3 = boot_cr3;  // 页表基址初始化——在pmm_init中初始化页表基址，实际上是satp寄存器【X86历史残留，有点想改但是由于涉及文件相对较多，万一没修改完全就寄了，索性放弃】
        proc->flags = 0;  // 进程标志位，初始化为空
        memset(proc->name, 0, PROC_NAME_LEN);  // 进程名初始化为空
        // 【好好好！！！快写完了我才发现，这个函数在proc_init中有检测是否分配正确，也就是说我可以根据它的判断条件来编写初始化函数，也就是说可以偷懒却没发现...】
    }
    return proc;
}
```

当内存分配成功时，开始对 `proc_struct` 中的各个成员进行初始化。每个成员变量的初始化值具体含义如下：

- **`state`**:

  ```
  proc->state = PROC_UNINIT;
  ```

  - 初始化进程的状态为 `PROC_UNINIT`，表示进程尚未初始化（还没有进入系统调度）。

- **`pid`**:

  ```
  proc->pid = -1;
  ```

  - 设置进程的 PID 为 `-1`，表示这是一个未初始化的进程，尚没有分配有效的进程 ID。

- **`runs`**:

  ```
  proc->runs = 0;
  ```

  - 进程的运行次数，初始化为 `0`，表示进程尚未运行。

- **`kstack`**:

  ```
  proc->kstack = 0;
  ```

  - 内核栈的地址，初始化为 `0`，表示尚未为该进程分配内核栈。

- **`need_resched`**:

  ```
  proc->need_resched = 0;
  ```

  - `need_resched` 用于指示进程是否需要重新调度。初始化为 `0`，表示此时不需要调度。

- **`parent`**:

  ```
  proc->parent = NULL;
  ```

  - 父进程指针，初始化为 `NULL`，表示当前进程没有父进程。

- **`mm`**:

  ```
  proc->mm = NULL;
  ```

  - 进程的内存管理结构指针，初始化为 `NULL`。对于内核进程（如空闲进程）来说，通常没有虚拟内存管理。

- **`context`**:

  ```
  memset(&(proc->context), 0, sizeof(struct context));
  ```

  - `context` 保存进程切换时的上下文信息。使用 `memset` 将它初始化为 0，表示当前没有上下文信息。

- **`tf`**:

  ```
  proc->tf = NULL;
  ```

  - 进程的中断帧，初始化为 `NULL`。中断帧用于保存中断或系统调用时的上下文。

- **`cr3`**:

  ```
  proc->cr3 = boot_cr3;
  ```

  - 页表基址寄存器（CR3）的值，初始化为 `boot_cr3`，它指向系统启动时的页目录。这个字段通常用来管理进程的虚拟内存。

- **`flags`**:

  ```
  proc->flags = 0;
  ```

  - 进程的标志位，初始化为 `0`，表示没有设置任何特定标志。

- **`name`**:

  ```
  memset(proc->name, 0, PROC_NAME_LEN);
  ```

  - 进程名称，初始化为空字符串（`0`）。`PROC_NAME_LEN` 定义了进程名称的最大长度。

### 回答问题：

#### 1. **`struct context context`**

```c++
 struct context {
     uintptr_t ra;  // 返回地址
     uintptr_t sp;  // 栈指针
     uintptr_t s0;  // 以下均为保存寄存器
     uintptr_t s1;
     uintptr_t s2;
     uintptr_t s3;
     uintptr_t s4;
     uintptr_t s5;
     uintptr_t s6;
     uintptr_t s7;
     uintptr_t s8;
     uintptr_t s9;
     uintptr_t s10;
     uintptr_t s11;
 };
```

- **定义和含义**： `context` 代表进程的 **执行上下文**，它保存了进程切换时的寄存器状态。操作系统通过保存和恢复进程的上下文来实现 **进程切换**（即从一个进程切换到另一个进程）。

  具体来说，`struct context` 通常包含以下内容：

  - 通常是进程执行时的一些 CPU 寄存器的值，特别是程序计数器（PC）、栈指针（SP）等。
  - 当发生上下文切换时，操作系统需要保存当前进程的寄存器状态，并将它们存储到 `context` 结构中。切换到另一个进程时，操作系统会从该进程的 `context` 中恢复寄存器状态，使得进程可以从上次中断或调度时的地方继续执行。

  **在本实验中的作用**：

  - 在实验中，`context` 用于保存进程的 CPU 状态，特别是进程切换时的上下文。每个进程的执行状态（寄存器的内容）都保存在 `context` 中。
  - 操作系统通过切换进程时保存和恢复该结构体来实现进程间的调度。这通常发生在 **系统调用** 或 **中断** 发生时，或者在时间片用完时。
  - 进程切换的关键就是将当前进程的上下文保存到 `context` 中，然后加载下一个进程的上下文，从而使新进程得以恢复执行。

#### 2. **`struct trapframe *tf`**

```c++
struct trapframe {
    struct pushregs gpr;  // 通用寄存器
    uintptr_t status;  // 状态
    uintptr_t epc;  // pc值
    uintptr_t badvaddr;  // 发生错误的地址
    uintptr_t cause;  // 错误原因
};
```

- **定义和含义**： `trapframe` 是一个结构体，通常用于保存 **中断或异常处理过程中的寄存器状态**。它记录了发生中断或异常时 CPU 中的一些关键寄存器的状态，包括程序计数器（PC）、栈指针（SP）、标志寄存器等信息。

  中断或异常发生时，操作系统需要保存现场（即当前寄存器的状态）以便在处理完中断后恢复进程的执行。这个保存的现场信息一般会存储在 `trapframe` 中。

  **在本实验中的作用**：

  - 在本实验中，`tf` 用于保存进程在发生 **中断或系统调用** 时的状态。这些信息在中断或系统调用发生时被保存到 `tf` 中，以便在中断处理完成后恢复进程的执行。
  - 如果操作系统需要处理中断或异常，它会将当前的进程状态（包括程序计数器和栈指针等信息）保存在 `trapframe` 结构中，并转入中断处理程序。当中断处理程序执行完毕后，操作系统会从 `trapframe` 恢复进程的状态，继续执行中断发生时的代码。
  - `trapframe` 结构通常被用来在 **中断** 或 **系统调用** 中保存和恢复寄存器信息，因此它在进程调度和中断处理过程中至关重要。

## 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

### 源代码

```c++
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;  // 错误码：没有空闲进程
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {  // 如果进程数量已达到上限，返回错误码，此时错误码表示没有空闲进程
        goto fork_out;
    }
    ret = -E_NO_MEM;  // 错误码：没有可分配内存
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */
    /*
     * 一些有用的 宏、函数和定义，你可以在下面的实现中使用它们。
     * 宏或函数：
     * alloc_proc：创建一个 proc 结构和初始化字段（lab4:exercise1）
     * setup_kstack：分配大小为 KSTACKPAGE 的页面作为进程内核栈
     * copy_mm：根据 clone_flags 复制或共享进程 "proc "的 mm，如果 clone_flags & CLONE_VM，则 "共享"；否则 "复制"。
     * copy_thread：在进程的内核堆栈顶部设置陷阱框架，并设置进程的内核入口点和栈
     * hash_proc: 将进程添加到进程 hash_list 中
     * get_pid：为进程分配唯一的 pid
     * wakeup_proc: 设置 proc->state = PROC_RUNNABLE
     * 变量：
     * proc_list：进程列表
     * nr_process：进程的数量
     */
    //    1. call alloc_proc to allocate a proc_struct 调用 alloc_proc 分配一个 proc_struct
    // 分析练习1中我们实现的进程分配函数，当返回值为NULL时是由于kmalloc(sizeof(struct proc_struct));的返回值为NULL
    // 而kmalloc函数是用于分配内存的函数，其返回值为NULL表示内存分配失败，此时错误码应该时表示内存问题，与我们前面ret = -E_NO_MEM;  // 错误码：没有可分配内存的设置一致，直接返回错误码
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    proc->parent = current;  // 子进程的父进程是当前进程
    //    2. call setup_kstack to allocate a kernel stack for child process 调用 setup_kstack 为子进程分配内核栈
    if (setup_kstack(proc) == -E_NO_MEM) {  // 检查进程内核栈分配是否成功（实际上复制了父进程的内核栈），如果返回-E_NO_MEM表示由于内存不足分配失败，我们需要处理已分配的子进程
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag 调用 copy_mm，根据 clone_flag 复制或共享 mm
    if (copy_mm(clone_flags, proc) != 0) {  // 本次实验中没有具体实现该函数功能，仅仅使用assert做判断模拟该函数错误情况，如果没有错误返回值为0，有错误那么我们需要释放初始化的子进程内核栈
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct 调用 copy_thread 在 proc_struct 中设置 tf 和 context
    copy_thread(proc, stack, tf);  // stack父节点的用户栈指针。果 stack==0，则表示fork一个内核线程。那么和esp没啥区别了吧，另外在risc-v的代码里看到X86遗迹真的好丑陋，应该是sp寄存器
    //    5. insert proc_struct into hash_list && proc_list 将 proc_struct 插入 hash_list && proc_list
    // hash_proc(proc);
    // list_add(&proc_list, &(proc->list_link));
    bool interrupt_flag;  // 判断是否禁用中断
    local_intr_save(interrupt_flag);  // copy_thread函数中tf的实参 是tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;那么调用该函数将会禁用中断
    {  // 没别的意思，就是让下面这部分看起来更舒服，这是禁用中断后执行的一块代码
        proc->pid = get_pid();  // 获取当前pid
        hash_proc(proc);
        list_add(&proc_list, &proc->list_link);  // 这才是正确的打开方式（bushi）
        nr_process++;  // 更新进程数
    }
    local_intr_restore(interrupt_flag);  // 恢复之前的中断状态；有借有还呢
    //    6. call wakeup_proc to make the new child process RUNNABLE 调用 wakeup_proc 使新的子进程可运行
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid 使用子进程的 pid 设置 ret vaule
    ret = proc->pid;

    fork_out:
        return ret;  // 正确情况下返回子进程pid，否则返回错误码

    bad_fork_cleanup_kstack:
        put_kstack(proc);
    bad_fork_cleanup_proc:
        kfree(proc);
        goto fork_out;
}

```

### 回答问题

要回答ucore是否做到给每个新fork的线程一个唯一的id，我们来看看get_pid函数的实现：

```C
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);  // 用于在编译时检查 MAX_PID 是否大于 MAX_PROCESS，以确保 PID 的范围足够大以覆盖所有可能的进程。
    struct proc_struct *proc;  // 遍历进程链表时会使用的指针
    list_entry_t *list = &proc_list, *le;  // 遍历进程链表
    static int next_safe = MAX_PID, last_pid = MAX_PID;  // next_safe 用于保存下一个安全的 PID，last_pid 用于保存上一个分配的 PID。
    if (++ last_pid >= MAX_PID) {  // 如果递增后的 last_pid 超过或等于 MAX_PID，则将其重置为1，然后跳转到 inside 标签。
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {  // 如果 last_pid 大于等于 next_safe，则执行以下操作：
    inside:
        next_safe = MAX_PID;  // 将 next_safe 重置为 MAX_PID
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {  //  如果当前进程的 PID 等于 last_pid，表示该 PID 已经被使用。
                if (++ last_pid >= next_safe) {  // 如果递增后的 last_pid 超过或等于 next_safe，则执行以下操作：
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;  // 跳转到 repeat，重新检查进程链表
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {  // 如果当前进程的 PID 大于 last_pid 且小于 next_safe，则更新 next_safe 为当前进程的 PID
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

- 我们定义了一个可用的PID区间为 `[0, MAX_PID)`，其中 `MAX_PID` 等于 `2 * MAX_PROCESS`，确保线程数的一倍大小的PID区间能够满足需要。为了有效分配PID，我们使用了两个变量：`next_safe`（表示可用PID区间的右边界）和 `last_pid`（表示可用PID区间的左边界）。分配PID时，我们通过依次递增 `last_pid` 在区间 `[last_pid, next_safe)` 中进行操作，并动态调整该区间。具体操作过程如下：

  1. **初始操作**：

     - 每次分配PID时，首先检查 `last_pid` 是否已达到当前可用区间的右端点（`next_safe`）。如果是，表示区间已经用尽，这时将 `last_pid` 重置为 `1`，并开始在区间 `[1, MAX_PID)` 中查找可用的PID。

  2. **寻找可用PID**：

     - 在区间 `[1, MAX_PID)` 中，我们遍历进程链表，寻找第一个未被使用的PID。

     - 如果找到的PID与 last_pid

        相同，表示该PID已被使用。这时，我们需要判断 last_pid + 1

        是否超出了当前区间的右端点 next_safe

       - 如果超出右端点且 `last_pid` 已经无法继续递增，则将 `next_safe` 更新为 `MAX_PID`，重新进行遍历。
       - 如果没有超出右端点，则直接返回当前的 `last_pid`，即成功分配该PID。

  3. **更新区间**：

     - 如果在遍历过程中发现当前PID在可用区间 `[last_pid, next_safe)` 内，那么我们更新右端点 `next_safe` 为当前PID，缩小可用PID的范围。

  4. **判断可用区间**：

     - 如果在任何时候发现可用PID区间为空（即 `last_pid` 大于或等于 `next_safe`），则表示需要重新寻找可用的PID区间。此时，按照第二步和第三步的逻辑重新查找，并调整 `last_pid` 和 `next_safe`。

  5. **返回PID**：

     - 如果当前可用PID区间非空（即 `last_pid < next_safe`），则直接返回 `last_pid`，该变量即为当前分配的PID。

  通过这种方式，我们能够确保在PID分配过程中不会出现冲突，并且能够高效地管理PID的分配和回收。

## **练习3：编写proc_run 函数（需要编码）**

> proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
>
> - 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
> - 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
> - 切换当前进程为要运行的进程。
> - 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
> - 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
> - 允许中断。
>
> 请回答如下问题：
>
> - 在本实验的执行过程中，创建且运行了几个内核线程？

* 为了详细阐述该实验中ucore切换进程的原理，我们可以从proc_init()函数的执行过程入手，逐步解析其中的关键操作。
* 1.proc_init()函数
* proc_init()是操作系统初始化过程中非常关键的一部分，它负责进程管理的基本设置。该函数的作用是初始化内核中的进程管理结构，并启动第一个用户进程。在该函数中，我们可以看到如下步骤：
* 1.1创建并初始化idleproc进程
* 首先，proc_init()调用alloc_proc()函数来为idleproc（空闲进程）分配一个进程控制块（PCB，Process Control Block）。该进程控制块用于记录进程的状态、程序计数器、寄存器内容等信息。alloc_proc()函数执行以下操作：
   * 分配一个新的PCB。
   * 初始化该PCB的基本信息，比如进程状态（默认为PROC_SLEEPING）。
   * 由于idleproc是最初创建的进程，我们将need_resched字段设置为1，表示该进程需要被调度。
* 接下来，current指针被设置为idleproc的PCB。current是一个全局变量，指向当前正在运行的进程。此时，系统启动时，current指向的是idleproc进程。
* 1.2创建init内核线程
* 接着，proc_init()会通过调用kernel_thread()函数来创建init线程。kernel_thread()是一个内核线程的创建函数，其执行流程如下：
   * kernel_thread()内部首先会设置一个trapframe，即一个中断帧，用于记录进程在被中断前的状态。这个中断帧包含了CPU寄存器的内容，以及程序计数器（PC）等信息。它的作用是在进程被调度时恢复进程的执行状态。设置trapframe的过程在kernel_thread中非常巧妙，具体细节稍后分析。
   * 然后，kernel_thread()调用do_fork()来创建init进程。do_fork()函数负责分配新进程的PCB并进行初始化，它的工作在练习2中已有详细讲解。do_fork()函数会为新进程分配一个新的进程控制块（即init进程的PCB），并设置相关的资源，如内核栈、内核线程的上下文等。
* 1.3进程的trapframe和内核栈设置
* 为了创建init进程，do_fork()函数会调用copy_thread()来设置新进程的执行上下文。copy_thread()函数负责以下工作：
   * 设置trapframe： trapframe会被拷贝到新进程的内核栈上，trapframe用于保存进程的寄存器状态，确保进程能够从中断或系统调用中恢复执行。
   * 设置ra寄存器： ra（返回地址寄存器）是保存函数返回地址的寄存器。在copy_thread()中，ra被设置为forkret函数的地址，这意味着当init进程被调度执行时，它会从forkret函数开始执行。
   * 设置sp寄存器： sp（栈指针）指向进程的内核栈的顶部。在copy_thread()中，sp被设置为新进程的trapframe的地址，从而确保在进程调度时，内核能够正确恢复进程的状态。
   * 设置进程PID： 在copy_thread()函数中，init进程的PID会被设置为一个新的唯一值，这个值是系统为每个新进程分配的标识符。
* 1.4唤醒init进程
* 在新进程的内核栈、trapframe和上下文都设置完毕后，do_fork()调用了wakeup_proc()函数。wakeup_proc()的作用是将新进程的状态设置为PROC_RUNNABLE，表示该进程已经准备好被调度运行。
* 1.5设置进程名和PID校验
* 最后，do_fork()函数会设置init进程的名称（通常是init），并通过断言确保idleproc和init进程的PID是合理的，避免错误发生。idleproc的PID一般为0，而init进程的PID则通常为1。
* 2.总结
* 通过上述步骤，proc_init()函数不仅初始化了内核的进程管理结构，还成功创建了两个重要的内核线程：idle线程和init线程。
   * idleproc是一个空闲进程，它在系统空闲时运行，保持系统的空闲状态。
   * init进程是系统中的第一个用户进程，它负责启动其他进程，是操作系统进程调度的基础。
* 至此，proc_init函数的执行完成，内核线程的创建工作也基本完成。这为后续的进程调度和上下文切换奠定了基础。
* 在init.c中，kernel初始化时，一系列的初始化函数执行结束后，cpu_idle函数开始执行。该函数内容如下：

```C++

	void cpu_idle(void) {
	    while (1) {
	        if (current->need_resched) {
	            schedule();
	        }
	    }
	}

```

* 结合上述内容，可以进一步推理出进程调度的过程。在系统启动时，current指针指向的是idleproc进程，且该进程的PCB中的need_resched字段被设置为1，表示需要进行进程调度。因此，系统会调用schedule函数来进行调度。schedule函数的执行流程如下：
   * 设置need_resched为0： 在schedule函数中，首先会将idleproc进程的need_resched字段清除，避免该进程在后续的调度中再次被调度。
   * 寻找PROC_RUNNABLE进程： schedule函数接下来会遍历系统中所有的进程，查找状态为PROC_RUNNABLE的进程。PROC_RUNNABLE表示进程已经准备好被调度执行，可以进入就绪队列等待调度。
   * 执行就绪进程： 在前文中提到，do_fork函数通过wakeup_proc将init进程的状态设置为PROC_RUNNABLE，这意味着init进程已经准备好运行。当schedule找到init进程的状态是PROC_RUNNABLE时，便会通过proc_run函数将init进程加入到调度队列并开始执行。
* 因此，当调度发生时，idleproc和init进程都会得到执行。首先是idleproc被调度作为系统空闲进程运行，然后通过进程调度机制，init进程也被调度并开始执行。这样，系统在本实验的执行过程中，创建并成功运行了两个内核线程——idle线程和init线程，它们分别承担了系统空闲和初始化用户进程的任务。
* `proc_run`的具体实现如下：

```C++

	// proc_run - make process "proc" running on cpu
	// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
	void
	proc_run(struct proc_struct proc) {
	    if (proc != current) {
	        // LAB4:EXERCISE3 YOUR CODE
	        /*
	        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
	        * MACROs or Functions:
	        *   local_intr_save():        Disable interrupts
	        *   local_intr_restore():     Enable Interrupts
	        *   lcr3():                   Modify the value of CR3 register
	        *   switch_to():              Context switching between two processes
	        */
	        bool intr_flag;
	        struct proc_struct *prev = current, next = proc;
	        //禁用中断，保护进程切换不会被中断，以免进程切换时其他进程再进行调度
	        local_intr_save(intr_flag);{
	            //进程切换
	            current = proc;    //让current指向next内核线程initproc
	            lcr3(next->cr3);   //cr3寄存器改为需要运行进程的页目录表
	            switch_to(&(prev->context), &(next->context));//上下文切换 switch.s
	        }
	        //开中断
	        local_intr_restore(intr_flag);
	    }
	}

```

* 在进程切换的过程中，系统首先需要判断目标进程是否与当前正在运行的进程相同。如果目标进程与当前进程相同，则不需要进行任何操作，避免了不必要的切换。然而，如果目标进程不同，那么就需要进行实际的进程上下文切换。这个过程涉及几个重要的步骤，保证了切换的顺利完成。
* 1.判断目标进程与当前进程是否相同
* 进程调度时，系统会检查目标进程（即即将被调度的进程）与当前进程（由current指针指向）是否相同。如果目标进程与当前进程相同，那么就不需要进行上下文切换，直接返回即可。这个检查可以有效避免不必要的上下文切换，减少系统开销。
* 2.禁用中断
* 为了确保进程切换的过程能够顺利进行，系统会在切换前禁用中断。禁用中断的目的是防止在切换过程中发生中断，使得切换操作不被打断。因为上下文切换是一个非常关键且复杂的操作，中断可能导致系统状态的不一致或丢失。因此，通过禁用中断来确保整个过程是原子的。
* 3.更新current指针
* 一旦确定需要进行上下文切换，系统会将current指针指向新的目标进程的PCB（进程控制块）。current指针是一个全局变量，它指向当前正在执行的进程的PCB，通过更新current，系统明确了接下来要执行的进程。
* 4.更新cr3寄存器
* 接下来，系统会将cr3寄存器的值更新为目标进程的页目录表地址。cr3寄存器在x86架构中用于存储当前进程的页目录的物理地址。在进程切换时，操作系统需要切换到目标进程的虚拟地址空间，因此必须更新cr3寄存器，使其指向目标进程的页目录表。这样，新的进程可以访问自己独立的内存空间，确保进程间的内存隔离。
* 5.调用switch_to函数
* 此时，操作系统会调用switch_to函数完成实际的上下文切换。switch_to函数的主要任务是保存当前进程的寄存器状态（即当前进程的上下文），并加载目标进程的寄存器状态。具体来说，switch_to会执行以下操作：
   * 保存当前进程的上下文： 这包括保存当前进程的所有寄存器（包括程序计数器、堆栈指针等），以便下次该进程被调度时能够恢复其执行状态。
   * 加载目标进程的上下文： 加载目标进程的寄存器状态，将其恢复到目标进程的上下文中。此时，程序计数器会指向目标进程的下一个指令，堆栈指针会指向目标进程的栈。
* 6.恢复中断
* 完成上下文切换后，系统会恢复中断的允许状态，重新启用中断。这是因为进程切换已经完成，系统已经可以响应外部的中断请求。恢复中断后，新的进程可以继续执行，并且可以响应外部事件和系统调用。
* 7.总结
* 上下文切换是操作系统中非常重要的一部分，它保证了多任务操作的顺利进行。在进程切换过程中，操作系统会通过一系列步骤保证系统状态的一致性和稳定性：
   * 判断目标进程是否与当前进程相同。
   * 禁用中断，确保切换过程不被中断。
   * 更新current指针，指向目标进程的PCB。
   * 更新cr3寄存器，切换到目标进程的地址空间。
   * 调用switch_to函数，完成上下文的保存和恢复。
   * 恢复中断，允许系统响应外部事件。
* 通过这些操作，操作系统可以在多个进程之间切换，确保每个进程在CPU上的运行都得到适当的时间和资源，从而实现多任务的并发执行。

```Bash

	.globl switch_to
	switch_to:
	    # save from's registers
	    STORE ra, 0*REGBYTES(a0)
	    STORE sp, 1*REGBYTES(a0)
	    STORE s0, 2*REGBYTES(a0)
	    STORE s1, 3*REGBYTES(a0)
	    STORE s2, 4*REGBYTES(a0)
	    STORE s3, 5*REGBYTES(a0)
	    STORE s4, 6*REGBYTES(a0)
	    STORE s5, 7*REGBYTES(a0)
	    STORE s6, 8*REGBYTES(a0)
	    STORE s7, 9*REGBYTES(a0)
	    STORE s8, 10*REGBYTES(a0)
	    STORE s9, 11*REGBYTES(a0)
	    STORE s10, 12*REGBYTES(a0)
	    STORE s11, 13*REGBYTES(a0)
	    # restore to's registers
	    LOAD ra, 0*REGBYTES(a1)
	    LOAD sp, 1*REGBYTES(a1)
	    LOAD s0, 2*REGBYTES(a1)
	    LOAD s1, 3*REGBYTES(a1)
	    LOAD s2, 4*REGBYTES(a1)
	    LOAD s3, 5*REGBYTES(a1)
	    LOAD s4, 6*REGBYTES(a1)
	    LOAD s5, 7*REGBYTES(a1)
	    LOAD s6, 8*REGBYTES(a1)
	    LOAD s7, 9*REGBYTES(a1)
	    LOAD s8, 10*REGBYTES(a1)
	    LOAD s9, 11*REGBYTES(a1)
	    LOAD s10, 12*REGBYTES(a1)
	    LOAD s11, 13*REGBYTES(a1)
	    ret

```

* 在上下文切换时，switch_to函数首先将当前进程的ra、sp以及多个通用寄存器的值保存到prev进程的上下文中。
* 这些寄存器值包含了当前进程的执行状态，保证该进程在下次被调度时能够恢复到正确的状态。
* 然后，switch_to从next进程的上下文中获取这些寄存器的值，并将它们加载到CPU寄存器中，恢复目标进程的执行状态。
* 最后，通过执行ret指令，CPU会跳转到next进程的ra指定的地址，继续执行该进程。
* 在创建next进程（如init进程）时，系统通过copy_thread函数将目标进程的ra寄存器设置为forkret函数的地址，这意味着当init进程被调度执行时，它会从forkret函数开始执行。
* 这确保了init进程能够从正确的地方恢复执行，完成进程初始化。

```C++

	// proc.c中copy_thread函数
	proc->context.ra = (uintptr_t)forkret;
	//  proc.c中
	static void forkret(void) { forkrets(current->tf);}
	# trapentry.S中
	    .globl forkrets
	forkrets:
	    # set stack to this new process's trapframe
	    move sp, a0
	    j __trapret
	    .globl __trapret
	__trapret:
	    RESTORE_ALL
	    # go back from supervisor call
	    sret

```

* 在switch_to函数完成上下文交换之后，系统进入了目标进程的执行阶段。由于在创建next进程（如init进程）时，copy_thread函数将目标进程的ra寄存器设置为forkret函数的地址，因此，在切换到next进程时，程序会从forkret函数开始执行。具体流程如下：
* 1.设置sp为目标进程的中断帧
* 在switch_to函数中，切换完成后，目标进程（init进程）会从forkret函数开始执行。forkret函数的第一个操作是通过执行指令 move sp, a0 将寄存器a0的值赋给sp（栈指针）。
   * a0寄存器在copy_thread函数中被设置为目标进程的trapframe（即中断帧）的地址，trapframe保存了进程被中断前的寄存器状态和程序计数器等重要信息。
   * 通过将a0的值赋给sp，实际上是将当前进程的栈指针指向了目标进程的trapframe。这样，目标进程在被调度执行时，其栈指针就指向了进程的中断帧，确保进程能够恢复之前的执行状态。
* 2.恢复上下文
* 接下来，forkret函数会执行RESTORE_ALL宏，这是一个恢复进程上下文的操作。RESTORE_ALL宏会从目标进程的trapframe中恢复所有的寄存器状态。具体来说，它会将trapframe中的各个寄存器的值加载到CPU的对应寄存器中。包括：
   * 恢复程序计数器（PC）的值，使得目标进程能够从上次保存的地方继续执行。
   * 恢复其他寄存器的值，如ra、sp等，这些寄存器的状态是目标进程执行时的关键数据。
* 这个步骤确保了目标进程能够从切换前的状态无缝恢复，而不会丢失任何重要的执行信息。
* 3.返回到目标进程的程序计数器地址
* 最后，forkret函数会使用sret指令（在RISC-V架构中）来返回到目标进程的程序计数器（PC）。sret指令会根据当前trapframe中的PC值跳转到目标进程的下一个执行地址。
   * 在trapframe中，PC保存的是目标进程执行时的下一条指令的地址。执行sret指令后，CPU将跳转到该地址，目标进程将继续从它上次中断时停止的地方开始执行。
* 4.总结
* 在switch_to完成上下文切换后，forkret函数首先通过move sp, a0将目标进程的trapframe地址赋值给栈指针（sp），确保栈指针指向目标进程的中断帧。
* 然后，RESTORE_ALL宏恢复trapframe中的寄存器状态，恢复进程执行时的上下文。
* 最后，通过sret指令，目标进程会从其保存的程序计数器（PC）地址继续执行，完成进程的上下文切换和恢复。

```C++

	  // proc.c中kernel_thread函数
	  tf.epc = (uintptr_t)kernel_thread_entry;

```

* 我们可以看到，恢复tf上下文后，返回到`kernel_thread_entry`的地址。

```Bash

	# entry.S中
	.text
	.globl kernel_thread_entry
	kernel_thread_entry: # void kernel_thread(void)
	move a0, s1
	jalr s0
	jal do_exit
	  // proc.c中kernel_thread函数
	  int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
	  ……
	  tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数地址
	  tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数地址
	  ……
	  }
	  // proc.c中的的void proc_init(函数
	  int pid = kernel_thread(init_main, "Hello world!!", 0);

```

* 在kernel_thread_entry函数中，操作系统进行了一些准备工作，以便执行由kernel_thread函数传入的线程函数。具体过程如下：
* 1.将s1寄存器的值转移到a0寄存器
* 在kernel_thread_entry中，首先会将之前在tf（即进程的中断帧）中设置的参数从s1寄存器转移到a0寄存器。具体来说：
   * s1寄存器保存了线程函数所需要的参数。在kernel_thread创建线程时，通过copy_thread函数设置了tf，并将参数传递给了s1寄存器。
   * 在kernel_thread_entry中，通过move a0, s1指令，将s1寄存器的值（即传递给线程函数的参数）转移到a0寄存器，因为a0是RISC-V架构中传递函数参数的寄存器（函数的第一个参数存储在a0中）。
* 这样，目标线程函数（比如init_main）所需的参数就被准备好了，并存储在a0寄存器中。
* 2.跳转到s0寄存器指定的地址
* 接下来，kernel_thread_entry会跳转到s0寄存器指定的地址。s0寄存器在创建线程时被设置为kernel_thread函数传入的线程函数的地址，也就是目标函数的入口地址。
   * 在本例中，s0寄存器指向kernel_thread调用时传入的函数地址。对于init进程来说，这个函数就是init_main。
   * 通过jr s0指令，CPU会跳转到init_main函数的入口，开始执行目标线程的代码。
* 3.执行init_main函数
* 当CPU跳转到init_main函数时，a0寄存器中的参数（即"Hello world!!"）会被传递给init_main，使得init_main函数可以使用这个字符串作为其输入。
   * init_main函数可以访问并处理传递给它的参数，在这种情况下，"Hello world!!"是init_main的输入参数。
   * 此时，init_main函数开始执行其具体任务，例如打印出"Hello world!!"或者执行其他初始化操作。
* 4.总结
* 在kernel_thread_entry中，首先将s1寄存器中的参数值（即线程函数的输入参数）转移到a0寄存器。
* 然后，通过jr s0跳转到s0寄存器指向的地址，即目标线程函数的入口。对于init进程来说，目标函数是init_main。
* 在init_main函数中，a0寄存器中的参数（"Hello world!!"）将作为输入传递给init_main，开始执行目标线程的逻辑。
* 至此，成功完成了上下文的切换，`init`线程正确执行目标函数。
* 最终运行结果：

![image]



## **扩展练习 Challenge：**

- 说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

* 在操作系统中，为了确保某些关键代码段的执行不被中断打断，我们使用了一种技术叫做“屏蔽中断”（interrupt masking）。这项技术通过对中断进行优先级管理，允许处理器决定哪些中断可以被屏蔽（禁用），哪些中断可以继续处理。当中断被屏蔽时，处理器不会响应外部的中断信号，确保在关键的代码执行过程中不中断，避免了竞态条件和不一致的情况。
* 在这段代码中，local_intr_save(intr_flag)和local_intr_restore(intr_flag)函数通过屏蔽中断的方式，保证了在特定的代码段内不中断地执行关键操作。具体流程：
   *  local_intr_save(intr_flag)：此函数首先将当前的中断状态保存到变量intr_flag中。然后，禁用中断，即将处理器的中断使能状态设置为禁止。这意味着，之后发生的所有中断请求都不会被处理，处理器将忽略这些中断信号。这一过程有效地确保在随后的代码执行中，不会被任何中断打断，保证了代码段的原子性和一致性。特别是在进行进程切换、资源管理等关键操作时，中断屏蔽是必须的。
   *  local_intr_restore(intr_flag)：当关键代码段执行完毕后，调用此函数将之前保存的中断状态（保存在intr_flag中的值）恢复到处理器中。如果之前中断是启用的，这个函数会重新启用中断；如果之前中断是禁用的，则中断状态会保持不变。这样，程序恢复到原始的中断处理状态，允许处理器继续响应中断。
* 通过这种方式，开发者可以确保在处理敏感操作时不会受到外部中断的干扰。特别是在进程切换、资源访问、数据一致性检查等场景中，屏蔽中断是一种非常有效的同步机制。
* 本次实验中的具体实现在proc_run函数中:

```C++

	void proc_run(struct proc_struct *proc) {
	    if (proc != current) { 
	        bool intr_flag;//定义一个bool类型的变量intr_flag，用于保存当前中断状态
	        struct proc_struct *prev = current, *next = proc;
	        local_intr_save(intr_flag); //调用local_intr_save(intr_flag)函数，将当前中断状态保存到intr_flag中，并禁止中断。
	        {//进入一个代码块，使用花括号({})括起来的部分
	            current = proc; 
	            lcr3(next->cr3); 
	            switch_to(&(prev->context), &(next->context)); 
	        }
	    local_intr_restore(intr_flag);//根据intr_flag中保存的状态恢复中断。
	    }
	}

```

* 在这段代码中，proc_run函数用于将指定的进程（proc）调度为当前进程，并完成进程切换。它的基本操作是保存当前进程的上下文，加载新的进程上下文，并切换到新的进程。这个过程中涉及到了中断的禁用和恢复，以确保进程切换过程的原子性。以下是详细的解释：
* 1.检查是否是当前进程
   * 首先检查待调度的进程proc是否与当前正在执行的进程current相同。如果相同，表示不需要切换，直接跳过后续操作。
* 2.定义变量
   * intr_flag：定义一个布尔类型变量，用于保存当前中断状态，以便在切换过程中禁用中断，防止中断打断进程切换。
   * prev：指向当前进程，即切换前的进程。
   * next：指向要切换到的目标进程proc。
* 3.保存当前中断状态并禁用中断
   * 调用local_intr_save(intr_flag)宏，该宏会调用__intr_save函数，保存当前的中断状态，并禁用中断。禁用中断可以确保在进程切换过程中，不会被中断打断，从而保持操作的原子性。intr_flag保存了中断的原始状态，稍后将用于恢复中断。
* 4.进入进程切换的代码块
   * current = proc：将current指针指向目标进程proc，表示当前进程已经切换为proc。
   * lcr3(next->cr3)：切换页目录。next->cr3存储了目标进程的页目录表的物理地址，通过lcr3指令将其加载到CR3寄存器中，切换到目标进程的地址空间。这是因为不同进程可能有独立的虚拟地址空间。
   * switch_to(&(prev->context), &(next->context))：调用switch_to函数完成进程的上下文切换。它保存当前进程（prev）的上下文，加载目标进程（next）的上下文。此时，目标进程的寄存器状态（如程序计数器、栈指针等）被恢复，并开始执行目标进程。
* 5.恢复中断状态
   * 调用local_intr_restore(intr_flag)宏，恢复中断状态。它会检查intr_flag标志，如果值为1，表示中断在切换前是启用的，那么就调用intr_enable()恢复中断。如果intr_flag为0，则中断状态不变。
* 6.结束进程切换
   * 结束进程切换过程，恢复了目标进程的上下文，并完成了进程切换。
* 7.总结
* proc_run函数的作用是实现进程调度的核心逻辑，具体步骤如下：
   * 判断进程是否需要切换：如果目标进程proc与当前进程current相同，则无需切换，直接返回。
   * 保存当前中断状态并禁用中断：通过local_intr_save宏保存当前中断状态并禁用中断，确保进程切换期间不中断。
   * 切换进程：更新current指针指向目标进程，切换页目录表，调用switch_to函数切换进程上下文。
   * 恢复中断状态：通过local_intr_restore宏恢复之前保存的中断状态，重新允许中断或保持禁用状态。
* 这个过程中，通过禁用中断，保证了进程切换的原子性和一致性，避免了在切换过程中中断打断系统状态，导致不一致的情况。
* 其中local_intr_save和local_intr_restore在sync.h中定义实现：

```C++

	//一个同步机制相关的头文件，定义了一些用于中断保存和恢复的宏和内联函数
	#ifndef __KERN_SYNC_SYNC_H__
	#define __KERN_SYNC_SYNC_H__
	
	#include <defs.h>
	#include <intr.h>
	#include <riscv.h>
	
	static inline bool __intr_save(void) {//用于保存中断状态并禁用中断
	    if (read_csr(sstatus) & SSTATUS_SIE) {//首先检查当前的 sstatus 寄存器的值是否设置了 SIE（中断使能）位
	        intr_disable();
	        return 1;
	    }//如果是，则禁用中断，并返回1，表示中断被保存
	    return 0;
	}//否则，返回0，表示中断未保存。
	
	static inline void __intr_restore(bool flag) {//用于恢复中断状态
	    if (flag) {//如果之前的中断被保存了（即传入的 flag 为真），则调用 intr_enable 函数重新启用中断。
	        intr_enable();
	    }
	}
	
	//local_intr_save 宏用于保存中断状态，并将保存的结果存储在给定的变量 x 中。
	#define local_intr_save(x) \
	    do {                   \
	        x = __intr_save(); \
	    } while (0)
	#define local_intr_restore(x) __intr_restore(x);
	//local_intr_restore 宏用于恢复中断状态。
	#endif /* !__KERN_SYNC_SYNC_H__ */

```

* 这个头文件定义了与中断相关的同步机制，主要包括保存和恢复中断状态的宏和内联函数。它们帮助操作系统在需要临界区保护时，保存当前的中断状态，禁用中断以保护操作，最后恢复原有的中断状态。以下是对各部分代码的详细解释：
* 1.__intr_save函数
* 作用： 该内联函数用于保存当前的中断状态，并禁用中断。
   * read_csr(sstatus)：从当前进程的状态寄存器（sstatus）读取值，SSTATUS_SIE是该寄存器中表示中断使能（SIE, Supervisor Interrupt Enable）的位。此位若为1，表示当前处于可接受中断的状态。
   * intr_disable()：如果SIE位为1，则禁用中断（即通过控制中断相关寄存器，禁止后续中断的触发）。
   * 返回值： 如果中断原本是使能的（SIE位为1），则禁用中断并返回1；如果中断已经是禁用状态，则不做更改，返回0。
* 2.__intr_restore函数
* 作用： 该内联函数用于恢复中断状态。
   * flag：传入的flag表示是否需要恢复中断状态。如果flag为真，表示中断之前被禁用，函数将调用intr_enable()恢复中断，使能中断处理。
   * intr_enable()：恢复中断使能，即重新允许中断的触发。
* 3.local_intr_save宏
* 作用： local_intr_save宏将当前中断的状态保存到变量x中。
   * 宏内部调用了__intr_save()函数，并将返回值（表示中断是否被禁用）存储在变量x中。这个宏通常用于临界区前，用来保存中断状态。
   * do { ... } while(0)是一个常见的宏用法，保证宏内部代码块以单个语句形式执行，即使在多条语句中也能正确地作为一个原子操作。
* 4.local_intr_restore宏
* 作用： local_intr_restore宏用于恢复之前保存的中断状态。
   * 该宏接受x作为参数，x是在local_intr_save中保存的标志（表示是否保存了中断状态）。如果x为真，表示中断之前是启用的，那么就调用__intr_restore恢复中断。
* 5.总结
* 这个头文件提供了两个内联函数和两个宏，用于中断管理：
   * __intr_save：保存当前的中断状态并禁用中断，返回1表示中断被禁用，返回0表示中断已经被禁用。
   * __intr_restore：根据传入的标志恢复中断状态。
   * local_intr_save(x)：宏用于保存当前中断状态，并将其存储在变量x中。
   * local_intr_restore(x)：宏用于恢复先前保存的中断状态。
* 这些函数和宏通常用于临界区的保护，确保在操作共享资源时不会被中断打断，从而防止竞态条件和数据一致性问题。


相关定义如下：

```c

	static inline bool __intr_save(void) {
	    if (read_csr(sstatus) & SSTATUS_SIE) {
	        intr_disable();
	        return 1;
	    }
	    return 0;
	}

	static inline void __intr_restore(bool flag) {
	    if (flag) {
	        intr_enable();
	    }
	}
	
	#define local_intr_save(x) \
	    do {                   \
	        x = __intr_save(); \
	    } while (0)
	#define local_intr_restore(x) __intr_restore(x);

```

* 当调用`local_intr_save`时，会读取`sstatus`寄存器，判断`SIE`位的值。
   * 如果该位为1，则说明中断是能进行的，这时需要调用`intr_disable`将该位置0，并返回1，将`intr_flag`赋值为1；
   * 如果该位为0，则说明中断此时已经不能进行，则返回0，将`intr_flag`赋值为0。以此保证之后的代码执行时不会发生中断。
* 当需要恢复中断时，调用`local_intr_restore`，需要判断`intr_flag`的值，
   * 如果其值为1，则需要调用`intr_enable`将`sstatus`寄存器的`SIE`位置1；
   * 否则该位依然保持0。以此来恢复调用`local_intr_save`之前的`SIE`的值。
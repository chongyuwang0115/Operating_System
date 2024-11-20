# <center>操作系统第二次实验报告</center>
## <center>苏浩天 苟辉铭 王崇宇</center>
# 练习1：理解基于FIFO的页面替换算法（思考题）

> 描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
>
> - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

## 总体流程

### **页面换入阶段**

1. **swap_in**
   - **作用**: 触发页面换入流程，从交换区加载页面到内存。
   - **描述**: 主函数，用于从硬盘交换区加载目标页面到内存，完成物理页面的分配、数据加载以及虚拟地址与物理地址的关联。
1. **alloc_page**
   - **作用**: 分配一个新的物理页面。
   - **描述**: 从物理内存分配器中获取一个空闲页面。如果内存不足，可能触发页面换出（swap_out）以腾出空间。
1. **swapfs_read**
   - **作用**: 从交换区读取页面数据到内存。
   - **描述**: 使用底层硬盘读写接口（如ide_read_secs）从交换区中将页面数据加载到分配的物理内存页面中。
1. **page_insert**
   - **作用**: 建立虚拟地址和物理页面的映射关系。
   - **描述**: 将加载到内存的物理页面与对应的虚拟地址绑定，同时更新页表并设置必要的权限位。
1. **swap_map_swappable**
   - **作用**: 将页面标记为可置换并加入FIFO队列。
   - **描述**: 通过FIFO策略，将页面加入页面置换管理的队列（如pra_list_head），为后续可能的页面换出做好准备。
1. **get_pte**
   - **作用**: 获取或创建页表项。
   - **描述**: 确保目标虚拟地址的页表项存在。如果页表不存在且允许创建，分配新的页表页面并初始化。
1. **pte_create**
   - **作用**: 创建一个新的页表项。
   - **描述**: 根据物理页面号和权限标志，构造页表项，并将其填入页表中。
1. **KADDR**
   - **作用**: 将物理地址转换为内核虚拟地址。
   - **描述**: 确保可以通过内核虚拟地址访问已加载的物理页面内容。

------

### **页面换出阶段**

1. **swap_out**
   - **作用**: 启动页面换出流程。
   - **描述**: 主函数，用于协调页面换出操作，包括选择换出页面、写回交换区，以及释放相关资源。
1. **_fifo_swap_out_victim**
   - **作用**: 从FIFO队列中选择一个页面进行换出。
   - **描述**: 按FIFO策略，选择最早被加入队列的页面，将其从队列中移除，并交由后续逻辑处理。
1. **swapfs_write**
   - **作用**: 将页面数据写回交换区。
   - **描述**: 使用底层硬盘读写接口（如ide_write_secs），将待换出的页面数据写入交换区。
1. **free_page**
   - **作用**: 释放物理页面。
   - **描述**: 减少页面引用计数，当引用计数归零时，释放页面所占用的物理内存。
1. **page_remove_pte**
   - **作用**: 删除页表项。
   - **描述**: 清除虚拟地址与物理页面的映射，更新页表，并在必要时刷新TLB。
1. **tlb_invalidate**
   - **作用**: 刷新TLB。
   - **描述**: 页表更新后，确保TLB中的缓存条目无效化，以保证地址映射的正确性。

------

### **支持过程的辅助函数/宏**

1. **set_page_ref**
   - **作用**: 设置页面引用计数。
   - **描述**: 在页面分配、换入或换出时，调整页面的引用计数，跟踪页面的使用情况。
1. **PTE_ADDR**
   - **作用**: 提取页表项中的物理地址部分。
   - **描述**: 从页表项中清除标志位，只保留页面的物理地址。
1. **PADDR**
   - **作用**: 将虚拟地址转换为物理地址。
   - **描述**: 在页表项或物理页面操作中，用于物理地址访问的转换。
1. **swap_init**
   - **作用**: 初始化页面置换模块。
   - **描述**: 在系统启动时，配置页面置换管理器（如FIFO），并初始化相关数据结构（如FIFO队列）。
1. **list_add**
   - **作用**: 在FIFO队列中添加页面。
   - **描述**: 在页面换入时，将页面插入FIFO队列的尾部。
1. **list_del**
   - **作用**: 从FIFO队列中移除页面。
   - **描述**: 在页面换出时，从FIFO队列中移除目标页面。
1. **le2page**
   - **作用**: 从队列节点转换为页面结构。
   - **描述**: 在FIFO页面置换中，将FIFO队列的节点指针转换为对应的页面结构指针。

------

### **页面从换入到换出的完整流程示例**

一个页面从换入到换出的过程中，首先通过 swap_in 函数启动页面换入流程，系统调用 alloc_page 分配一个新的物理页面，如果内存不足时可能调用 swap_out 触发页面换出以释放内存空间。随后，swapfs_read 从交换区读取页面数据，将其加载到新分配的物理页面中。分配完成后，通过 page_insert 函数将加载的页面与对应的虚拟地址建立映射，同时使用 get_pte 查找或创建对应的页表项，并通过 pte_create 生成一个包含物理地址和权限信息的页表项填入页表。在完成映射后，swap_map_swappable 将页面标记为可置换并加入FIFO队列，FIFO队列通过 list_add 将页面链接到队列尾部管理其置换优先级。

当系统需要换出页面时，swap_out 函数启动页面换出流程，它调用 _fifo_swap_out_victim 按FIFO策略从队列头部选择最早进入队列的页面作为换出目标，并通过 list_del 从队列中移除该页面。接着，swapfs_write 将页面数据写回交换区，保证页面内容在换出后仍然可用。为了释放资源，free_page 减少页面引用计数，当计数归零时释放物理页面，同时调用 page_remove_pte 清除页表项并断开虚拟地址与物理页面的映射关系。最后，tlb_invalidate 刷新TLB以确保更新后的页表生效。在整个过程中，set_page_ref 用于维护页面的引用计数，KADDR 和 PADDR 宏则在物理地址和虚拟地址之间进行转换，le2page 用于从FIFO队列中获取页面的结构信息，确保置换管理的正确性和逻辑完整性。

------

### **总结：完整函数列表及其作用**

| **序号** | **函数/宏**           | **作用**                                         |
| -------- | --------------------- | ------------------------------------------------ |
| 1        | swap_in               | 从交换区加载页面到内存。                         |
| 2        | alloc_page            | 分配一个新的物理页面。                           |
| 3        | swapfs_read           | 从交换区读取页面数据到内存。                     |
| 4        | page_insert           | 建立虚拟地址与物理页面的映射。                   |
| 5        | swap_map_swappable    | 标记页面可置换，并加入FIFO队列。                 |
| 6        | get_pte               | 查找或创建页表项。                               |
| 7        | pte_create            | 构造页表项，并填入页表。                         |
| 8        | swap_out              | 启动页面换出流程。                               |
| 9        | _fifo_swap_out_victim | 按FIFO策略选择页面，并从队列中移除。             |
| 10       | swapfs_write          | 将待换出的页面写回交换区。                       |
| 11       | free_page             | 释放物理页面。                                   |
| 12       | page_remove_pte       | 删除页表项，解除映射关系。                       |
| 13       | tlb_invalidate        | 刷新TLB，确保地址转换正确。                      |
| 14       | set_page_ref          | 设置或更新页面的引用计数。                       |
| 15       | list_add              | 在FIFO队列中添加页面。                           |
| 16       | list_del              | 从FIFO队列中移除页面。                           |
| 17       | swap_init             | 初始化页面置换管理模块（如FIFO队列）。           |
| 18       | le2page               | 将FIFO队列节点转换为页面结构，用于管理置换页面。 |

通过这些函数和宏的紧密协作，完成了页面从换入到换出的整个生命周期管理。

# 练习2：深入理解不同分页模式的工作原理（思考题）

> get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
>
> - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
> - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

get_pte()函数的代码如下：

```C++
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
            struct Page *page;
            if (!create || (page = alloc_page()) == NULL) {
                    return NULL;
            }
            set_page_ref(page, 1);
            uintptr_t pa = page2pa(page);
            memset(KADDR(pa), 0, PGSIZE);
 //           memset(pa, 0, PGSIZE);
            *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```

## **（1）结合 sv32，sv39，sv48 的异同，解释这两段代码为什么如此相像**

### **代码分析**

`get_pte()` 函数的作用是通过多级页表查找或创建线性地址 `la` 对应的页表项。它会根据页表的层级逐步查找页目录项（如 `pdep1` 和 `pdep0`），并在缺失时分配页表页面。代码的两段相似部分分别用于处理一级页表和二级页表，它们的逻辑非常相似，因为分页机制中每一级页表的行为模式是一致的。

具体过程包括：

1. 一级页表项处理：
   - 从一级页表中通过 `PDX1(la)` 索引获取一级页表项 `pdep1`。
   - 检查一级页表项是否有效（`PTE_V` 标志）。
   - 如果无效，分配新的物理页面并初始化为一级页表。
1. 二级页表项处理：
   - 从一级页表项中提取对应的二级页表地址，找到二级页表。
   - 使用 `PDX0(la)` 从二级页表中找到对应的二级页表项 `pdep0`。
   - 检查二级页表项是否有效（`PTE_V` 标志）。
   - 如果无效，分配新的物理页面并初始化为二级页表。

代码中两段相似逻辑是递归式的，反映了多级页表机制的分级查找与创建行为。

------

### **sv32、sv39 和 sv48 的异同点**

| **特性**         | **sv32**                       | **sv39**                    | **sv48**                    |
| ---------------- | ------------------------------ | --------------------------- | --------------------------- |
| **支持架构**     | 32 位 RISC-V                   | 64 位 RISC-V                | 64 位 RISC-V                |
| **页表级别**     | 2                              | 3                           | 4                           |
| **页表项大小**   | 4 字节                         | 8 字节                      | 8 字节                      |
| **地址范围**     | 4 GB（32 位地址空间）          | 512 GB（39 位虚拟地址空间） | 256 TB（48 位虚拟地址空间） |
| **页表层级行为** | 每一级存储指向下一级页表的指针 | 类似 sv32，但增加了一个级别 | 类似 sv39，但增加了一个级别 |

### **原因分析**

尽管 sv32、sv39 和 sv48 在页表级别、页表项大小和地址范围上有所不同，但页表的基本工作原理和行为模式是相同的：

- 每一级页表存储指向下一级页表或页面的指针。
- 当页表项无效时，必须动态分配页表。
- 每一级页表使用类似的方法通过索引定位。

因此，无论是 sv32 的两级页表，还是 sv39 和 sv48 的三级或四级页表，代码中创建与查找的逻辑都高度相似。对于更高层次的页表（如 sv48 的第四级），只需进一步递归添加类似的逻辑。

------

## **（2）目前 `get_pte()` 函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？**

### **分析当前实现的优缺点**

1. **优点**：
   - 简化代码结构：将查找和分配逻辑合并，可以避免将代码拆分为多个函数，减少函数调用的复杂性，使代码结构更紧凑，便于维护。
   - 性能优化：查找和分配通常是紧密相关的操作。合并到同一个函数中，可以减少函数调用的开销，尤其是在频繁查找和分配页表项的场景中。
   - 逻辑一致性：合并逻辑可以确保查找与分配在同一上下文中执行，避免出现不一致的逻辑分支。
   - 代码复用性：由于页表层级的操作逻辑非常相似，统一在一个函数中处理可以减少重复代码，提高复用性。
1. **缺点**：
   - 模块化不足：查找和分配是两个功能不同的操作，合并到一个函数中可能降低代码的模块化程度。
   - 代码耦合性高：如果只需要查找而不需要分配页表项，那么函数内部的分配逻辑会被无谓地执行，增加了不必要的复杂性。
   - 测试和扩展难度：如果未来需要修改分配逻辑或优化查找逻辑，可能需要对整个函数进行调整，增加了测试和扩展的复杂度。

------

### **是否需要拆分？**

从代码实际需求出发，可以进行以下分析：

1. **当前实现是否合理？**
   - 当前代码中，查找和分配逻辑始终紧密结合，几乎没有单独查找的需求。
   - 分配逻辑仅在查找失败时触发，因此合并在一起并未增加显著的复杂性。
1. **是否需要拆分？**
   - 如果将查找和分配分为两个函数（如 `find_pte` 和 `create_pte`），虽然模块化程度更高，但也会带来额外的函数调用开销，降低代码性能。
   - 如果操作系统后续需要在多个场景中单独查找页表项，拆分可以提高灵活性。
   - 如果查找逻辑和分配逻辑在未来可能需要独立扩展（如支持更复杂的页表优化），拆分是有必要的。
1. **最终结论**：
   - 在目前的实现中，查找和分配始终紧密结合，且两段逻辑高度相似，**拆分的必要性较低**。
   - 如果在未来系统中需要频繁单独查找页表项，或者需要支持更复杂的多级页表扩展，可以考虑将这两个功能拆开。

------

### **总结建议**

1. **当前代码的优点**：
   - 简洁高效，适合多级页表的常规操作。
   - 性能优先，减少函数调用开销。
1. **改进建议**：
   - 如果需要更高的模块化，可以将 get_pte() 拆分为两个独立函数：
     - **`find_pte(pgdir, la)`**: 负责只查找页表项。
     - **`create_pte(pgdir, la)`**: 负责创建新的页表项。
1. **选择依据**：
   - 如果查找和分配逻辑总是一起使用，合并实现更合理。
   - 如果需要独立复用查找逻辑，则拆分功能更灵活。

目前情况下，**保留现有实现即可，拆分的必要性不大**。



| **模块**           | **文件**                                                     | **作用**                                                     | **与其他模块的关系**                                         |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **驱动模块**       | `clock.c/h`, `console.c/h`, `ide.c/h`, `intr.c/h`            | 提供硬件抽象，包括时钟、控制台、硬盘和中断管理。             | 支持文件系统、内存管理模块的 I/O 操作，与 Trap 模块协作处理中断。 |
| **文件系统模块**   | `fs.h`, `swapfs.c/h`                                         | 管理文件和交换区，提供页面换入换出的存储支持。               | 调用 IDE 驱动完成数据读写，与内存管理模块协作实现虚拟内存换入换出。 |
| **内存管理模块**   | `default_pmm.c/h`, `mmu.h`, `pmm.c/h`                        | 管理物理内存和虚拟内存，包括页面分配、释放和置换机制。       | 调用文件系统和驱动模块实现页面置换，向 Trap 模块提供内存异常处理支持。 |
| **中断与异常处理** | `trap.c/h`, `trapentry.S`                                    | 实现中断和异常的捕获与分发，包括时钟中断、I/O 中断和系统调用。 | 与驱动模块协作响应硬件中断，与内存管理模块协作处理缺页异常。 |
| **同步模块**       | `sync.h`                                                     | 提供锁和信号量等同步工具，保障并发环境下的资源安全。         | 支持 Trap 模块的中断处理和调度机制，防止竞争条件。           |
| **调试与错误处理** | `assert.h`, `kdebug.c/h`, `kmonitor.c/h`, `panic.c`, `stab.h` | 提供断言、内核监控器、符号解析等调试功能，支持错误捕获和分析。 | 与所有模块协作，帮助开发者定位和解决问题。例如通过 kmonitor 查看内存或中断状态，通过 panic 处理致命错误。 |
| **初始化模块**     | `entry.S`, `init.c`                                          | 完成系统启动和模块初始化，设置硬件环境并启动第一个进程。     | 负责引导系统各模块的启动，与驱动、内存管理等模块交互完成初始化。 |
| **通用库模块**     | `stdio.c`                                                    | 提供标准输入输出、字符串操作等通用功能。                     | 被多个模块调用，如内核日志打印、字符串操作等。               |

------

## **模块之间的关系图**

```
                  +------------------+
                  |    初始化模块     |
                  +------------------+
                          ↓
+-------------------+    +--------------------+     +--------------------+
|     驱动模块       | ←→ |  中断与异常处理模块    | ←→ |     同步模块        |
+-------------------+    +--------------------+     +--------------------+
         ↓                    ↓                              ↓
+-------------------+    +--------------------+     +--------------------+
|  文件系统模块       |    | 内存管理模块          | ←→ |  调试与错误处理模块   |
+-------------------+    +--------------------+     +--------------------+
                                              ↓
                                      +--------------------+
                                      |     通用库模块      |
                                      +--------------------+
```

# 练习3：给未被映射的地址映射上物理页（需要编程）

## 3-1实验要求

* 补充完成do_pgfault（mm/vmm.c）函数，**给未被映射的地址映射上物理页**。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
* 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
   * 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
   * 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
      * 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

## 3-2前期工作

### do_pgfault概述

* 在进行代码编写工作以前，我们需要首先分析已有的 do_pgfault 函数内容，进而方便后续的工作。
* do_pgfault 函数的主要功能是处理由缺页异常（Page Fault）引发的错误。当程序访问一个未映射到物理内存的虚拟地址时，CPU 会触发一个缺页异常，交由操作系统的 do_pgfault 函数进行处理。该函数的目标是为程序中无法访问的虚拟地址映射相应的物理内存页，或者进行页面置换，确保程序继续运行。
* 下面我们对于 do_pgfault 函数进行分析。
   * do_pgfault 函数接收三个参数：
      * mm：指向当前进程的内存管理结构（mm_struct）的指针。这个结构保存了进程的页表、虚拟内存区域（VMA）信息等。
      * error_code：错误代码，通常包含了访问该地址时的错误信息（如是否是读、写错误等）。
      * addr：发生缺页异常的虚拟地址（线性地址）。
   * do_pgfault 的主要功能是处理程序访问的虚拟地址没有对应的物理页面（即发生了缺页异常）。具体来说，do_pgfault 函数会尝试根据该地址查找对应的虚拟内存区域（VMA），根据 VMA 中的权限设置来决定是否可以映射新的物理页面，如果需要，还会从磁盘（交换空间）加载页面。

### 代码解读

* 查找虚拟内存区域：
   * 函数首先通过 find_vma 查找包含地址 addr 的虚拟内存区域（VMA）。虚拟内存区域是一个表示进程虚拟内存的一部分的数据结构，其中包含该区域的起始地址、结束地址以及访问权限（可读、可写等）。如果 vma 为 NULL，或者 vma->vm_start > addr（即地址不在 VMA 范围内），说明该地址无效。
   * 每次发生缺页异常时，全局变量 pgfault_num 会增加 1，用于统计缺页异常的数量。

```C++

	int
	do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
	    int ret = -E_INVAL;
	    //try to find a vma which include addr
	    struct vma_struct *vma = find_vma(mm, addr);
	
	    pgfault_num++;

```

* 地址合法性判断：
   * 接着判断地址是否有效（是否找到匹配的 `vma` 或是否 `addr` 超出了有效范围）。

```C++

	  //If the addr is in the range of a mm's vma?
	    if (vma == NULL || vma->vm_start > addr) {
	        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
	        goto failed;
	    }

```

* 检查访问权限：
   * 根据 VMA 的权限设置，构造该地址的访问权限 perm。如果 VM_WRITE 标志被设置，表示该区域是可写的，因此设置 PTE_R（可读）和 PTE_W（可写）。PTE_U 表示该页是用户可访问的。

```C++

	 uint32_t perm = PTE_U;
	    if (vma->vm_flags & VM_WRITE) {
	        perm |= (PTE_R | PTE_W);
	    }

```

* 地址对齐及页表项查找与分配：
   * 由于操作系统采用页面管理，因此虚拟地址 addr 会被向下对齐到页边界（即对齐到页面大小 PGSIZE），确保它指向页面的开始位置。
   * 通过 get_pte 获取该地址的页表项（PTE）。如果该页表项尚未分配（即 *ptep == 0），说明该地址没有映射到物理页面，需要进行分配。

```C++

	    addr = ROUNDDOWN(addr, PGSIZE);
	
	    ret = -E_NO_MEM;
	
	    pte_t *ptep=NULL;
	    
	    //获取页表项的指针，pgdir 是页目录的基址
	    ptep = get_pte(mm->pgdir, addr, 1); 

```

* 分配物理页面：
   * 如果页表项不存在，调用 pgdir_alloc_page 函数分配一个物理页面，并将该地址与物理内存页建立映射。如果分配失败，打印错误并跳转到 failed。
   * 若未启用则进入else分支，否则执行交换操作（练习3要实现的代码）。

```c++

	if (*ptep == 0) {
	    if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
	        cprintf("pgdir_alloc_page in do_pgfault failed\n");
	        goto failed;
	    }
	}

```

### 补充实现分析

* 在某些情况下，物理页面可能不在内存中，而是在交换空间（磁盘）上。这时需要从交换空间加载页面。根据提示，处理逻辑如下：
   * 1.检查交换初始化是否完成。
      * 如果交换初始化完成，说明系统可以从交换空间加载页面。
   * 2.从交换空间加载页面。
      * 使用 swap_in 从磁盘加载页面到内存中。page 是加载后的物理页面。
   * 3.建立虚拟地址和物理页面的映射。
      * 通过 page_insert 将加载的页面与虚拟地址 addr 建立映射。
   * 4.标记页面为可交换。
      * 将页面标记为可交换，意味着系统可以将该页面移回磁盘以腾出内存空间。
   * 5.跟踪虚拟地址。
      * 跟踪该页面的虚拟地址，方便后续操作。
   * 6.返回结果。
      * 如果处理成功，ret 被设置为 0。如果发生错误或无法处理缺页异常，跳转到 failed 标签并返回失败代码。
* do_pgfault 函数主要处理缺页异常，当程序访问一个未映射到物理内存的虚拟地址时，操作系统会调用该函数进行处理。具体的处理步骤包括：
   * 查找地址对应的虚拟内存区域（VMA）并检查访问权限；
   * 如果该地址没有映射到物理页面，则分配一个新的页面并建立映射；
   * 如果物理页面不在内存中，且交换空间可用，则从交换空间加载页面并建立映射；
   * 确保页面可以在需要时被交换出去。
* 该函数是虚拟内存管理中处理缺页异常的核心部分，确保了程序能够继续执行而不受内存访问错误的影响。

## 3-3代码实现

* 依据上述的分析，我们分块对其具体代码进行实现。
* 1.分配一个内存页并从磁盘上的交换文件加载数据到该内存页，参考`swap_in(mm, addr, &page)`函数；
   * 设计为：` swap_in(mm, addr, &page);`，从交换空间加载页面。
   * 使用 swap_in 从磁盘加载页面到内存中。page 是加载后的物理页面。
* 2.建立内存页 `page` 的物理地址和线性地址 `addr` 之间的映射，参考`page_insert)`函数：

```C++

	//kern/mm/pmm.c
	int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
	    pte_t *ptep = get_pte(pgdir, la, 1);
	    if (ptep == NULL) {
	        return -E_NO_MEM;
	    }
	    page_ref_inc(page);
	    if (*ptep & PTE_V) {
	        struct Page *p = pte2page(*ptep);
	        if (p == page) {
	            page_ref_dec(page);
	        } else {
	            page_remove_pte(pgdir, la, ptep);
	        }
	    }
	    *ptep = pte_create(page2ppn(page), PTE_V | perm);
	    tlb_invalidate(pgdir, la);
	    return 0;
	}

```

* 设计为：`page_insert（mm->pgdir,page,addr,perm);`，通过page_insert 将加载的页面与虚拟地址 addr 建立映射。
* 3.将页面标记为可交换，参考`swap_map_swappable`函数：

```C++

	//kern/mm/swap.c
	int
	swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
	{
	     return sm->map_swappable(mm, addr, page, swap_in);
	}

```

* 设计为：`swap_map_swappable(mm, addr, page, 0);`，将页面标记为可交换，意味着系统可以将该页面移回磁盘以腾出内存空间。
* 4.跟踪页面映射的线性地址：`page->pra_vaddr = addr;`：
* 检查页表项是否为空（PTE不存在）：
   * *ptep == 0 表示当前虚拟地址 addr 没有映射到任何物理页面，即该页表项（PTE）不存在。
   * 如果页表项不存在，说明该虚拟地址没有映射到物理内存，需要分配一个新的物理页面。
   * pgdir_alloc_page(mm->pgdir, addr, perm) 尝试为该地址分配一个新的物理页面，并将该页面映射到页表。如果分配失败，返回 NULL，程序会打印错误信息并跳转到 failed，表示分配物理内存失败。

```C++

	//kern/mm/vmm.c
	if (*ptep == 0) {
	    if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
	        cprintf("pgdir_alloc_page in do_pgfault failed\n");
	        goto failed;
	    }
	}

```

* 如果页表项已存在且启用了交换机制：
   * else 代码块：表示页表项 *ptep 已经存在，即该虚拟地址已经有一个物理页被映射。但是在这种情况下，可能需要从交换空间中加载页面，因为当前物理页面可能已经被交换到磁盘。
   * if (swap_init_ok)：检查是否启用了交换机制。如果启用了交换（swap_init_ok == true），则允许从交换空间加载页面。如果交换未初始化（swap_init_ok == false），则打印错误信息并跳转到 failed。

```C++

	//kern/mm/vmm.c
	} else {
	    if (swap_init_ok) {
	        struct Page *page = NULL;
	        // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
	        
	        swap_in(mm, addr, &page); // 分配一个内存页并从磁盘上的交换文件加载数据到该内存页
	        page_insert(mm->pgdir, page, addr, perm); // 建立内存页 page 的物理地址和线性地址 addr 之间的映射
	        swap_map_swappable(mm, addr, page, 1); // 将页面标记为可交换
	        page->pra_vaddr = addr; // 跟踪页面映射的线性地址
	        
	    } else {
	        cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
	        goto failed;
	    }
	}
    ret = 0;

```

## 3-4问题解答

### 问题一

* **（1）请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。**
* sv39的页目录表项和页表项结构相似，如下图所示，第 9-0 位共10位描述映射的状态信息：

![图片1](img/图片1.png)

* 其中:
   * - D：即 Dirty ，如果 D=1 表示自从上次 D 被清零后，有虚拟地址通过这个页表项进行写入。
   * - A，即 Accessed，如果 A=1 表示自从上次 A 被清零后，有虚拟地址通过这个页表项进行读、或者写、或者取指。
* 在 ucore 操作系统中，页目录项（PDE）和页表项（PTE）是管理虚拟内存和物理内存映射的关键数据结构。它们不仅帮助操作系统管理内存的分配与访问，还在实现页面替换算法（如 Clock 和 Enhanced Clock 算法）时起着至关重要的作用。
* 1.页目录项（Page Directory Entry，PDE）和页表项（Page Table Entry，PTE）
* 首先，回顾一下页目录项和页表项的基本作用和结构：
   * 页目录项（PDE）：每个页目录项指向一个页表。每个页目录项包含有关于该页表的信息（如物理地址、访问权限等），并用于管理 4KB 页的映射。
   * 页表项（PTE）：页表项指向一个具体的物理内存页，包含虚拟地址到物理地址的映射，并且包含了页面的访问权限、访问标志等信息。
* 2.PTE_A（Accessed）和 PTE_D（Dirty）在页表项中的作用:
   * PTE_A（Accessed）：该标志位表示该页面自上次清零以来是否被访问过。访问包括读取、写入或者执行指令。当操作系统访问页面时（无论是读还是写），都会将 PTE_A 置为 1。操作系统可以通过检测这个标志，判断页面是否被频繁访问。
   * PTE_D（Dirty）：该标志位表示页面是否自上次被写回磁盘以来发生了修改。如果该标志位为 1，说明自上次标记为“干净”后，页面内容已经被修改，可能需要在页面替换时写回磁盘，以确保数据一致性。如果该标志位为 0，说明页面没有被修改，可以跳过写回磁盘的操作。
* 3.PTE_A 和 PTE_D 对页替换算法的潜在用处:
   * 3.1 Clock 页替换算法
   * Clock 页替换算法基于“最近最少使用”（LRU）原理，并利用 PTE_A 来判断页面是否活跃。在此算法中，操作系统通过以下方式使用 PTE_A：
   * 当页面被访问时，操作系统会将 PTE_A 设置为 1。
   * 每次替换页面时，操作系统检查页面的 PTE_A 标志：
      * 如果 PTE_A = 1，说明页面最近被访问过，操作系统会将 PTE_A 清零，并继续检查下一个页面。
      * 如果 PTE_A = 0，说明该页面自上次清零以来没有被访问过，可以被认为是“冷页面”，准备进行页面置换。
   * 这种策略保证了最近访问过的页面优先被保留在内存中，从而避免频繁的内存访问错误（缺页异常）。
   * 3.2 Enhanced Clock 页替换算法
   * Enhanced Clock 算法是对 Clock 算法的扩展，不仅利用 PTE_A 来判断页面是否活跃，还结合 PTE_D 来优化页面置换的决策。通过同时检查 PTE_A 和 PTE_D，操作系统能够更智能地判断哪些页面应该被置换，哪些页面可以被优先保留。具体来说，PTE_A 和 PTE_D 组合使用可以优化替换策略如下：
      * PTE_A = 1 且 PTE_D = 1：该页面最近被访问并且已经被修改。操作系统会优先保留这类页面，直到它们被写回磁盘。修改过的页面在替换时必须写回磁盘，确保数据一致性。
      * PTE_A = 1 且 PTE_D = 0：页面虽然被访问过，但未被修改。对于这种页面，操作系统可以考虑替换，只要在替换前不会丢失重要的修改内容。
      * PTE_A = 0 且 PTE_D = 1：该页面未被访问过，但已被修改。此时，操作系统可能会延迟替换，以避免丢失修改的内容，必须在替换时将其写回磁盘。
      * PTE_A = 0 且 PTE_D = 0：该页面既未被访问过，也未被修改，是最适合替换的页面，因为它既不活跃，也不包含任何修改过的数据。
   * 通过这种方式，操作系统不仅考虑页面的访问情况（是否频繁被使用），还考虑页面是否需要写回磁盘（是否有未保存的修改）。这种策略比传统的 Clock 算法更精确，有助于减少不必要的磁盘写操作，提高系统的性能。
* 4.总结:
   * PTE_A 标志位可以帮助操作系统追踪页面的访问情况，支持 Clock 页替换算法，通过判断页面是否活跃，优先保留频繁访问的页面。
   * PTE_D 标志位则提供了页面是否被修改的状态，支持 Enhanced Clock 算法，优化了页面替换时的决策，特别是避免丢失修改过的数据，并减少不必要的磁盘写操作。
* 结合 PTE_A 和 PTE_D，操作系统能够更智能地进行页面替换，不仅考虑页面的访问频率，还考虑页面的修改状态，从而优化内存管理和页面替换过程，提高系统的整体性能。

### 问题二

* **（2）如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**
* 1.引发页访问异常（Page Fault）：页访问异常是由于访问一个未映射的虚拟地址或权限不允许的地址引起的。CPU 会通过以下方式处理：
   * 将异常的虚拟地址装入寄存器 CR2：
   * 在发生页访问异常时，CPU 会自动将引发异常的线性地址（虚拟地址）存储到寄存器 CR2 中。这是因为操作系统需要知道是哪一个具体的虚拟地址触发了页访问异常，进而采取相应的处理措施。
   * 设置错误代码 errorCode：
   * 错误代码 errorCode 是由 CPU 在发生页访问异常时设置的，它描述了引发异常的具体原因。该错误码包括如下信息：
      * Bit 0：表示访问的页面是 用户模式（0）还是 内核模式（1）。
      * Bit 1：表示是否是 写操作（1 表示写操作，0 表示读取操作）。
      * Bit 2：表示页面是否存在（1 表示缺页，0 表示页面已经存在）。
      * Bit 3：表示引发异常的页面是否是 用户页面（1 表示用户页，0 表示内核页）。
   * 通过错误代码，操作系统可以知道具体是哪个类型的页访问异常，并且根据这些信息来决定如何处理（比如是给页表添加映射，还是是访问权限问题等）。
* 2.触发 Page Fault 异常中断：当页访问异常发生时，CPU 会触发一个 中断，通常是 #PF (Page Fault) 异常，这个异常会被处理程序（也就是内核中的缺页异常处理例程）捕获。
   * 中断向量：CPU 会根据中断类型（在这个场景中是 Page Fault）跳转到预先定义的中断处理程序。在 x86 架构中，这个异常的中断向量通常是 14（即 0x0E）。
   * 保存现场：当 CPU 发生页访问异常时，CPU 会首先保存当前的程序执行状态，包括程序计数器（PC）和一些寄存器的内容，确保异常处理程序能够恢复执行时的环境。
   * 内核态切换：CPU 将从用户态切换到内核态，跳转到对应的缺页异常处理例程（在 ucore 中通常是 do_pgfault 函数）。
* 3.缺页异常处理程序（do_pgfault）：一旦 CPU 触发了页访问异常，内核会根据错误代码和 CR2 中的虚拟地址来处理异常。具体流程如下：
   * 查找虚拟内存区域（VMA）：内核首先需要根据异常的虚拟地址查找进程的虚拟内存区域（VMA），即判断该地址是否属于某个已映射的区域。
   * 检查页面权限和映射：内核会检查该地址是否在当前进程的虚拟地址空间中有对应的物理内存映射。如果没有映射，内核需要分配一个新的物理页并更新页表；如果有权限问题，内核需要进行适当的权限检查。
   * 分配新的物理页：如果是由于没有对应的物理页导致的缺页异常，内核将分配一个新的物理页，并将其映射到用户进程的虚拟地址空间中。
   * 处理分页/页面置换：如果物理内存不足，可能会触发页面置换（即将某些物理页写入磁盘或交换区）。内核需要使用页面置换算法（如 Clock 算法或 Enhanced Clock 算法）来决定哪些页面应该被交换出内存。
   * 恢复执行：在内核完成页表更新或页面置换后，内核会恢复程序的执行，重新加载对应的页表项或进行其他必要的设置。
* 4.返回用户态并继续执行：一旦缺页服务例程完成，操作系统将恢复程序的执行。此时，CPU 会根据更新的页表重新执行刚才产生异常的指令。由于此时虚拟地址到物理地址的映射已经更新，程序可以继续执行，不再产生页访问异常。
* 5.总结：硬件在页访问异常发生时要做的工作：
   * 将引起页访问异常的线性地址存入 CR2 寄存器。
   * 设置错误代码 errorCode，以便内核了解异常的具体情况。
   * 触发 Page Fault 中断，跳转到异常处理程序。
   * 保存当前的程序执行状态，进行内核态切换，进入缺页服务例程。
   * 在缺页服务例程中，内核会检查虚拟地址的映射，更新页表或进行页面置换等操作。

### 问题三

* **(3)数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？**

* 有关系。 在虚拟内存管理中，Page 结构表示实际的物理页面，而页目录项（PDE）和页表项（PTE）是管理这些物理页面的索引。具体关系如下：
   * Page 结构与页表项（PTE）关系：每个 Page 结构代表一个物理页面，与页表项（PTE）直接对应。每个页表项（PTE）存储了物理页面的地址（即页框号），并附带访问权限等信息。通过页表项可以找到具体的物理页面，并映射到虚拟地址。
   * Page 结构与页目录项（PDE）关系：页目录项（PDE）是管理一组页表的索引，每个PDE指向一个页表的起始地址。Page 结构本身并不直接存储页目录项的内容，但页目录项指向的页表间接管理着一系列 Page 结构。例如，一级页表的目录项（PDE）指向的页表包含多个二级页表项（PTE），而这些二级页表项映射到具体的 Page。
* 总结：Page 结构、PDE 和 PTE 之间的关系是层级嵌套的，通过页目录项和页表项来索引物理内存的 Page，实现虚拟地址到物理地址的映射。

# 练习4：补充完成Clock页替换算法（需要编程）

## 4-1实验要求

* 通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)
* 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
   * 比较Clock页替换算法和FIFO算法的不同。

## 4-2前期工作

* 我们在知识点整理中已经简单介绍了什么是时钟替换算法（即Clock页替换算法），其关键在于一个数据结构——循环链表；一个关键变量——访问位（visited）；一个指针——指向当前被检查页面的指针以及关键的替换策略。
* 循环链表与访问位：Clock算法通过维护一个循环链表来存储可替换页面，对于页面的数据结构Page中我们有一个关键变量visited（代表访问位）。访问位是用于表示此页表项对应的页当前是否被访问过。
* 替换策略：当进行页面替换时对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。
* 在实现 Clock 页替换算法 时，实验代码中已经实现了 FIFO 算法，而 Clock 算法 的实现可以在此基础上进行修改。以下是 Clock 算法的实现思路，参考了代码中的 pra_list_head（可交换页面链表头）和 curr_ptr（指向当前检查页面的指针）：
* 数据结构：
   * pra_list_head：用于管理所有可交换的页面，按时间顺序排列。
   * curr_ptr：指向当前被检查的页面，在遍历链表时充当“时钟指针”的角色。
* 替换过程：
   * 如果当前页面的访问位为 0，则可以选择该页面进行替换。
   * 如果当前页面的访问位为 1，则将其访问位清零，并将 curr_ptr 移动到下一个页面，继续检查。
* 伪代码：

```C

    // Clock 页替换算法
    void clock_page_replace() {
        while (true) {
            // 获取当前页面的访问位
            struct Page *page = curr_ptr;
            if (page->accessed == 0) {
                // 访问位为 0，替换该页面
                replace_page(page);
                break;
            } else {
                // 访问位为 1，清零并跳过该页面
                page->accessed = 0;
                curr_ptr = next_page(curr_ptr);  // 移动到下一个页面
            }
        }
    }

```

## 4-3代码实现

* **初始化函数**
* 这段代码实现了 _clock_init_mm 函数，该函数用于初始化 Clock 页替换算法的链表结构，使页面管理系统在内存管理结构中能够正确进行页面替换操作。
* list_init(&pra_list_head);
   * 该行代码使用 list_init 函数初始化 pra_list_head 链表头为空链表。
   * pra_list_head 是一个双向链表结构，它用于管理所有可替换页面在内存中的顺序。
* curr_ptr = &pra_list_head;
   * 初始化当前指针 curr_ptr 为 pra_list_head，这表示当前页面替换位置是链表头。
   * 在 Clock 算法中，curr_ptr 相当于一个“时钟指针”，在页面替换时会通过它遍历 pra_list_head 中的页面节点。
* mm->sm_priv = &pra_list_head;
   * 将 mm->sm_priv 指针指向 pra_list_head，让 mm_struct 结构的私有成员 sm_priv 记录 pra_list_head 的地址。
   * sm_priv 是 mm 中的一个私有成员，用于指向当前页面替换的链表头，确保替换算法可以通过 mm 访问到 pra_list_head。
* 返回值 0
   * 最后，函数返回 0，表示初始化成功。

```C

	static int
	_clock_init_mm(struct mm_struct *mm)
	{     
	     /*LAB3 EXERCISE 4: YOUR CODE*/ 
	     // 初始化pra_list_head为空链表
	     list_init(&pra_list_head);
	     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
	     curr_ptr = &pra_list_head;
	     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
	     mm->sm_priv = &pra_list_head;
	     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
	     return 0;
	}

```

* **页面访问检查与链表维护函数**
* 这段代码实现了 _clock_map_swappable 函数，它用于将一个页面标记为可交换，并将其添加到 Clock 页替换算法 的链表中。具体操作是将页面插入到链表的末尾，并标记该页面为已访问。
* list_entry_t *entry = &(page->pra_page_link);
   * 该行定义了一个指针 entry，指向页面 page 中的链表节点pra_page_link。该链表节点用于将页面插入到替换链表中，方便后续的页面替换操作。
* assert(entry != NULL && curr_ptr != NULL);
   * 这一行使用 assert 确保 entry 和 curr_ptr 都不为空。如果为空，则会触发断言失败，程序会中止。这里的断言确保了链表节点 entry 和 curr_ptr 都已正确初始化。
* list_entry_t *head = (list_entry_t*) mm->sm_priv;
   * 获取 mm->sm_priv，这是一个指向 pra_list_head 链表头的指针，表示当前进程的页面替换链表。
   * 将 sm_priv 转换为 list_entry_t* 类型，以便操作链表。
* list_add(head->prev, entry);
   * 使用 list_add 函数将 entry 插入到链表的末尾（即在 head->prev 之后插入）。这表示将页面 page 添加到可替换页面的队列中，并把它放在链表的末尾。
   * 这样操作的目的是确保该页面是最近访问的页面，并且根据 Clock 替换算法的逻辑，它在下一轮替换时会被检查。
* page->visited = 1;
   * 将页面的 visited 标志设置为 1，表示该页面已经被访问。
   * 这个标志在 Clock 算法中用来表示页面是否被访问过，如果在页面替换时发现 visited == 1，那么该页面将不会被立即淘汰，而是将其标志重置为 0 并继续向前遍历。
* 返回值 0
   * 最后，函数返回 0，表示操作成功完成。

```C

	static int
	_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, 	struct Page *page, int swap_in)
	{
	    list_entry_t *entry=&(page->pra_page_link);
	 
	    assert(entry != NULL && curr_ptr != NULL);
	    //record the page access situlation
	    /*LAB3 EXERCISE 4: YOUR CODE*/ 
	    // link the most recent arrival page at the back of the pra_list_head qeueue.
	    // 将页面page插入到页面链表pra_list_head的末尾
	    list_entry_t *head=(list_entry_t*) mm->sm_priv;
	    list_add(head->prev, entry);
	    // 将页面的visited标志置为1，表示该页面已被访问
	    page->visited  = 1;
	    return 0;
	}

```

* **页面替换函数**
* 这段代码实现了 _clock_swap_out_victim 函数，它用于选择并替换一个页面，将其从 Clock 替换算法的链表中移除，并将该页面的指针返回给调用者。具体来说，该函数会找到最早未被访问的页面，淘汰它并进行页面交换操作。
* list_entry_t *head = (list_entry_t*) mm->sm_priv;
   * 获取当前进程的页面替换链表头 head。sm_priv 指向 pra_list_head，即链表的头部，保存了所有可交换页面的信息。
* assert(head != NULL);
   * 通过 assert 检查 head 是否为空，确保 head 是有效的链表头。
* assert(in_tick == 0);
   * 通过 assert 确保 in_tick 为 0。in_tick 参数在此函数中没有被使用，应该始终为 0。
* struct Page *curr_page;
   * 声明一个指向 Page 结构的指针 curr_page，用于存放当前检查的页面。
* while (1)
   * 使用无限循环来遍历页面链表，直到找到符合条件的页面为止。
* if (curr_ptr == head) { curr_ptr = list_next(curr_ptr); }
   * 检查当前指针 curr_ptr 是否指向链表头部（即 pra_list_head）。如果是，跳过当前节点，移动指针到下一个页面。
   * 由于页面是从链表尾部插入的，head 起到标识头部的作用，跳过它本身。
* curr_page = le2page(curr_ptr, pra_page_link);
   * 使用 le2page 宏获取 curr_ptr 指向的链表节点的 Page 结构。pra_page_link 是页面链表中的节点，用来访问每个页面。
* if (curr_page->visited != 1)
   * 如果当前页面的 visited 标志为 0（表示未被访问），则选择该页面作为替换页面。
   * 将页面指针 *ptr_page 设置为当前页面 curr_page，即准备替换该页面。
   * 使用 list_del(curr_ptr) 将当前页面从链表中移除。
   * 退出循环，停止查找页面。
* if (curr_page->visited == 1) { curr_page->visited = 0; }
   * 如果当前页面已被访问（即 visited == 1），则将该页面的 visited 标志重置为 0。这表示该页面在本次扫描中重新被访问，因此需要继续检查下一个页面。
* curr_ptr = list_next(curr_ptr);
   * 移动 curr_ptr 到链表中的下一个页面节点，继续检查下一个页面。
* 返回值 0
   * 返回 0，表示操作成功完成。

```C

	static int
	_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
	{
	     list_entry_t *head=(list_entry_t*) mm->sm_priv;
	         assert(head != NULL);
	     assert(in_tick==0);
	     /* Select the victim */
	     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
	     //(2)  set the addr of addr of this page to ptr_page
	    struct Page *curr_page;
	    while (1) {
	        /*LAB3 EXERCISE 4: YOUR CODE*/ 
	        // 编写代码
	        // 遍历页面链表pra_list_head，查找最早未被访问的页面
	        if (curr_ptr == head){  // 由于是将页面page插入到页面链表pra_list_head的末尾，所以pra_list_head制起标识头部的作用，跳过
	            curr_ptr = list_next(curr_ptr);
	        }
	        // 获取当前页面对应的Page结构指针
	        curr_page = le2page(curr_ptr, pra_page_link);
	        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
	        if (curr_page->visited != 1){
	            *ptr_page = curr_page;
	            cprintf("curr_ptr %p\n",curr_ptr);
	            list_del(curr_ptr);
	            break;
	        }
	        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
	        if (curr_page->visited == 1){
	            curr_page->visited = 0;
	        }
	        curr_ptr = list_next(curr_ptr);
	    }
	    return 0;
	}

```

## 4-4问题解答

* **比较Clock页替换算法和FIFO算法的不同**：
* Clock 页替换算法和 FIFO（先进先出）页替换算法都是常用的页面置换算法，但它们的工作方式和性能特点有所不同，下面对两者的异同做一比较。
* **FIFO（先进先出）算法：**
   * 基本思想：FIFO 算法按页面进入内存的顺序进行管理，每次需要置换页面时，选择最早进入内存的页面进行替换。
   * 工作方式：
      * FIFO 维护一个队列，队列中的每一项表示一个物理页面。
      * 新页面加载时，会将页面添加到队列的尾部。
      * 当页面需要替换时，FIFO 选择队列头部的页面（即最早加载的页面）进行替换。
   * 优缺点：
      * 优点：算法实现简单，易于理解和实现。
      * 缺点：FIFO 没有考虑页面的实际使用情况，可能会将近期使用的页面替换掉，因此可能会产生较大的页面交换开销，无法有效反映页面的局部性原理。
* **Clock 页替换算法：**
   * 基本思想：Clock 算法通过使用页面的访问位（A 位）来决定哪些页面应该被替换，近似实现了 LRU（最近最少使用） 算法。Clock 算法的核心是通过一个循环链表和访问位来模拟一个“时钟”，按顺序检查页面的访问位，避免了 FIFO 算法的缺点。
   * 工作方式：
      * Clock 算法使用一个循环链表来维护所有可交换的页面，每个页面都有一个 访问位（A 位）。
      * 当需要选择一个页面进行替换时，算法检查当前指针指向的页面的访问位：
         * 如果访问位为 0，则表示该页面未被访问，可以将其替换掉。
         * 如果访问位为 1，则表示该页面被访问过，算法将访问位清零，然后跳过该页面，继续检查下一个页面。
      * 这个过程就像时钟指针旋转，逐个检查页面，直到找到合适的页面进行替换。
   * 优缺点：
      * 优点：Clock 算法比 FIFO 更智能，因为它能根据页面的访问情况来决定哪些页面应该被替换。通过访问位的检查，Clock 算法能够模拟 LRU 的思想，避免了 FIFO 算法的一些缺陷。
      * 缺点：需要硬件或操作系统的支持来设置访问位，增加了实现的复杂性。
* **Clock 算法与 FIFO 算法的比较：**
   * 页面替换策略：
      * FIFO：按页面加载顺序，最早加载的页面最先被替换。
      * Clock：根据页面的访问情况来决定是否替换，访问过的页面不立即被替换，而是将访问位重置。
   * 性能：
      * FIFO：由于不考虑页面的访问频率，可能会导致较差的性能，尤其是在局部性较强的程序中，最近使用的页面可能被替换掉，导致更多的页面缺失。
      * Clock：相较于 FIFO，Clock 算法能更好地反映页面的使用情况。通过访问位的机制，Clock 能够避免频繁替换那些最近使用的页面，性能更优。
   * 实现复杂度：
      * FIFO：简单，使用队列来维护页面顺序即可。
      * Clock：稍微复杂，需要使用循环链表和访问位来管理页面。
   * 效率：
      * FIFO：虽然实现简单，但由于其缺乏对页面访问频率的考虑，可能导致频繁的页面交换。
      * Clock：相对较为高效，通过访问位的机制优化了页面选择过程。

# 实验结果展示

* 到此我们实现了本次实验的两个编码部分。我们运行make qemu 和 make grade结果如下所示：

![图片2](img/图片2.png)

![图片3](img/图片3.png)

# 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

* 如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

## **1. 优势**

### 1.1 减少页表开销

- 页表项减少：
  - 大页的页表项覆盖更大的地址空间。例如，一个 4KB 页表项只能映射 4KB 的地址空间，而一个 2MB 大页表项则映射 2MB 的地址空间。
  - 这样需要的页表项数量大幅减少，从而降低页表的存储空间需求。
- 减少页表层级：
  - 使用大页可以避免多级页表的开销，例如不需要分配中间页表，直接通过一级页表即可完成映射。

### 1.2 提高 TLB 效率

- TLB 命中率提升：
  - TLB（Translation Lookaside Buffer）用于缓存虚拟地址到物理地址的映射。
  - 每个 TLB 条目缓存一个页表项，当使用大页时，一个条目覆盖更大的地址范围，从而提升命中率，减少 TLB 缺失的频率。
- 降低 TLB 刷新频率：
  - 因为大页减少了需要的 TLB 条目数量，因此切换进程或虚拟地址空间时，TLB 刷新的开销也相对较低。

### 1.3 性能提升

- 地址转换效率更高：
  - 分级页表需要逐级解析页表，而大页可以直接通过一个页表项完成地址转换，从而减少内存访问次数，提高速度。
- 减少内存碎片：
  - 对于需要大块连续内存的应用（如数据库、虚拟化等），使用大页减少了小页分配导致的内存碎片问题。

### 1.4 简化管理

- 页表简单：
  - 一个大页的页表结构更简单，因为不需要处理多级页表结构和中间页表的分配。
- 适合特定场景：
  - 大页适用于内存密集型应用，例如大数据处理、机器学习模型训练、虚拟机内存管理等场景。

------

## **2. 劣势和风险**

### 2.1 内存浪费

- 内部碎片：
  - 如果程序实际使用的内存比大页的大小小很多（例如只需要 1KB，但大页是 2MB），会造成大量的内存浪费。
  - 对于需要分配大量小内存的场景，这种浪费会非常严重。

### 2.2 缺乏灵活性

- 映射粒度大：
  - 大页的粒度较大，不适合处理小范围的内存映射需求。对于需要频繁修改小内存映射的场景，大页会显得笨重。
- 精细控制困难：
  - 大页不能灵活调整每一小块的权限（如读、写、执行）。如果需要更细粒度的权限控制，则分级页表更适合。

### 2.3 页表更新复杂

- 分割和合并：
  - 如果需要对大页中的一部分地址空间进行修改，可能需要将整个大页拆分为多个小页，从而增加管理的复杂性。
- 动态映射困难：
  - 动态调整内存映射或部分释放内存时，大页的管理机制可能需要额外的逻辑支持。

### 2.4 大页内存分配困难

- 需要连续物理内存：
  - 大页映射需要一块连续的物理内存。对于高度碎片化的系统，找到这样的大块物理内存可能非常困难，导致分配失败。
- 系统启动时规划：
  - 如果没有在系统启动时预留足够的空间用于大页，后续可能难以启用大页机制。

### 2.5 不适合小内存工作负载

- 应用不匹配：
  - 对于小型应用或嵌入式系统，通常不需要大页面支持，小页面更能满足需求，同时避免了资源浪费。

# 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）

## LRU页替换算法

* 利用局部性，通过过去的访问情况预测未来的访问情况，我们可以认为最近还被访问过的页面将来被访问的可能性大，而很久没访问过的页面将来不太可能被访问。于是我们比较当前内存里的页面最近一次被访问的时间，把上一次访问时间离现在最久的页面置换出去。

## 双向链表实现

* 这里主要采用双向链表实现，当我们每一次要进行页访问时，我们通过双向链表将即将访问的页放在链表的表头，如此往复，这样就会使表尾始终是上一次访问时间离现在最久的页面

* 源代码：

```c++

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_entry_t *curr = list_next(head);  // 从第一个元素开始遍历
    while (curr != head) {
        struct Page *curr_page = le2page(curr, pra_page_link);
        if (curr_page == page) {
            // 如果页面已经在链表中，先将其删除
            list_del(curr);
            break;
        }
        curr = list_next(curr);
    }
    // 将页面插入到链表的开头，表示它是最新访问的
    list_add_before(head, entry);
    
    // 设置页面的虚拟地址并标记为已访问
    page->pra_vaddr = addr;
    page->visited = 1;
    
    return 0;
}

```

* 这里是实现将访问的页取出放到链表头操作。

```c++

static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
        assert(head != NULL);
    assert(in_tick==0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);// 得到链表中的最后一个元素
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

```

* 这里是取链表尾作为置换出去的受害者。

```c++

static void
print_mm_list() {
    cprintf("--------begin----------\n");
    list_entry_t *head = &pra_list_head, *le = head;
    while ((le = list_next(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
    }
    cprintf("---------end-----------\n");
}
static int
_lru_check_swap(void) {
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    return 0;
}

```

* 这里是设置了需要打印的代码和需要check的代码，然后我们需要修改一下LRU的接口，使函数能够成功接入：

```c++

swap_init(void)
{
    sm = &swap_manager_lru;
    //....other code
    
    
    return r;
}

```

* 最终`make qemu`得到结果：

```txt

ubuntu@Legion:~/os/lab3$ make qemu
OpenSBI v0.4 (Jul  2 2019 11:53:53)
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name          : QEMU Virt Machine
Platform HART Features : RV64ACDFIMSU
Platform Max HARTs     : 8
Current Hart           : 0
Firmware Base          : 0x80000000
Firmware Size          : 112 KB
Runtime SBI Version    : 0.1

PMP0: 0x0000000080000000-0x000000008001ffff (A)
PMP1: 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc0200032 (virtual)
  etext  0xc02044e8 (virtual)
  edata  0xc020a040 (virtual)
  end    0xc0211570 (virtual)
Kernel executable memory footprint: 70KB
memory management: default_pmm_manager
membegin 80200000 memend 88000000 mem_size 7e00000
physcial memory map:
  memory: 0x07e00000, [0x80200000, 0x87ffffff].
check_alloc_page() succeeded!
check_pgdir() succeeded!
check_boot_pgdir() succeeded!
check_vma_struct() succeeded!
Store/AMO page fault
page fault at 0x00000100: K/W
check_pgfault() succeeded!
check_vmm() succeeded.
SWAP: manager = lru swap manager
BEGIN check_swap: count 2, total 31661
setup Page Table for vaddr 0X1000, so alloc a page
setup Page Table vaddr 0~4MB OVER!
set up init env for check_swap begin!
Store/AMO page fault
page fault at 0x00001000: K/W
Store/AMO page fault
page fault at 0x00002000: K/W
Store/AMO page fault
page fault at 0x00003000: K/W
Store/AMO page fault
page fault at 0x00004000: K/W
set up init env for check_swap over!
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page c in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page a in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page b in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page b in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page a in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page b in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page c in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page d in lru_check_swap
Store/AMO page fault
page fault at 0x00004000: K/W
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
write Virt Page a in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x3000
vaddr: 0x5000
---------end-----------
count is 1, total is 8
check_swap() succeeded!
++ setup timer interrupts
100 ticks
100 ticks

```

* 结果成功体现LRU页替换算法！



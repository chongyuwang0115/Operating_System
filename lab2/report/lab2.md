# <center>操作系统第二次实验报告</center>

## 练习1：理解first-fit 连续物理内存分配算法（思考题）

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：你的first fit算法是否有进一步的改进空间？

### default_init

```c++
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

- 该函数初始化 free_list（空闲页面链表）并将空闲页面计数 nr_free 设置为0。
- list_init 初始化链表头，将 free_list 设为一个空链表。

### default_init_memmap

```c++
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0); //确保n大于0，即要初始化的页面数必须是正数。如果 n == 0，则直接报错。
    struct Page *p = base; 
    for (; p != base + n; p ++) {
        //该循环从base开始遍历n个页面，将它们逐个初始化。p 表示当前正在初始化的页面，base + n 表示最后一个要初始化页面之后的地址。
        assert(PageReserved(p)); //确保当前页面p处于保留状态，即该页面是为内核或操作系统保留的，不能被随意分配。这是为了保证初始化的页面是安全的且符合系统约定。
        p->flags = p->property = 0; //清空页面的标志位，这意味着当前页面没有任何特定状态（例如，页面未被保留、未分配）。同时清除页面的 property 字段。这个字段通常表示页面块的大小，但对于除块首页外的其他页面，它为0。
        set_page_ref(p, 0);//设置页面的引用计数为0，表示当前页面未被引用。
    }
    base->property = n; // 设置base页面（即块首页面）的property为n，表示从base开始的连续n个页面组成一个连续的空闲页面块
    SetPageProperty(base);// 设置块首页面base的PG_property标志位，表示这是一个空闲的物理内存块的首页面
    nr_free += n; // 将系统中空闲页面的总数nr_free增加n，以反映这块内存现在可以被分配了。
    if (list_empty(&free_list)) { // 检查空闲页面链表free_list是否为空。
        list_add(&free_list, &(base->page_link)); // 如果链表为空，说明目前没有任何空闲页面块，将当前页面块base添加到链表中。
    } else { // 如果空闲链表free_list不为空，接下来需要找到一个合适的位置将当前的页面块插入链表中。
        list_entry_t* le = &free_list; // 指向空闲链表的第一个节点（链表头），接下来会遍历链表。
        while ((le = list_next(le)) != &free_list) { // 遍历free_list，直到遍历回到链表的起始位置（即链表头）。
            struct Page* page = le2page(le, page_link); // le2page宏将链表节点转换为Page结构体指针page，方便比较当前页面块base的地址与链表中其他页面的地址。
            if (base < page) {
                list_add_before(le, &(base->page_link)); // 如果base所表示的页面块的地址小于当前链表中的页面page，说明base页面块应该插入到page之前，保持链表的地址顺序
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link)); // 如果链表已经遍历到末尾，并且base页面块的地址大于链表中所有的页面块地址，说明base应该插入到链表的最后。
            }
        }
    }
}
```

- **参数 base**表示指向要初始化的第一个页面的Page结构体的指针。它表示一块物理内存的起始地址；**参数 n**表示要初始化的页面数，也就是从base开始的n个连续物理页面。
- **初始化页面属性**：遍历base开始的n个页面，清除它们的标志和引用计数，将它们标记为可用。
- **设置块首页面**：将页面块的首页面base设置为具有n个页面，并设置该页面的property和PG_property标志位。
- **插入空闲链表**：根据页面的地址顺序，将页面块插入到空闲链表中。如果链表为空，则直接添加；否则按地址顺序找到正确的位置插入，保持链表有序。

### default_alloc_pages

```c++
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0); // 确保n大于0，即要初始化的页面数必须是正数。如果 n == 0，则直接报错。
    if (n > nr_free) { 
        // 检查系统中是否有足够的空闲页面。nr_free表示当前空闲页面的数量，如果n大于nr_free，说明没有足够的页面来满足分配请求，此时返回NULL，表示分配失败
        return NULL;
    }
    struct Page *page = NULL; 
    list_entry_t *le = &free_list;// 初始化链表指针，指向空闲页面链表的头free_list
    while ((le = list_next(le)) != &free_list) {// 遍历free_list，直到遍历回到链表的起始位置（即链表头）。
        struct Page *p = le2page(le, page_link); // le2page宏将链表节点转换为Page结构体指针page，方便比较当前页面块base的地址与链表中其他页面的地址。
        if (p->property >= n) { // 检查页面块的大小p->property是否大于或等于n。property字段表示这个页面块包含的连续空闲页面的数量。如果这个页面块足够大，就可以进行分配
            page = p;
            break;
        }
    }
    if (page != NULL) { // 如果找到了合适的页面块，继续执行后续的分配步骤。如果没有找到，函数将返回NULL
        list_entry_t* prev = list_prev(&(page->page_link)); // 获取page页面块前面的链表节点prev，用于在后面处理链表的插入操作
        list_del(&(page->page_link)); // 从空闲链表中删除page这个页面块。因为它即将被分配给请求者，所以不能继续保留在空闲链表中
        if (page->property > n) { // 如果找到的页面块page的大小property大于n，这意味着分配的页面数少于块的大小，因此我们需要拆分这个块
            struct Page *p = page + n; // 计算新页面块的起始地址p，它位于page之后的第n个页面。新页面块由剩下的空闲页面组成
            p->property = page->property - n; // 将剩余页面块的大小设为原块大小减去分配的页面数n。剩下的页面块将被重新插入到空闲链表中
            SetPageProperty(p); // 设置新页面块的PG_property标志，表示这是一个有效的空闲页面块
            list_add(prev, &(p->page_link)); // 将剩余的页面块插入到prev节点之后的链表中。这样就将新的空闲页面块重新插入到了空闲页面链表中
        }
        nr_free -= n; // 减少系统中空闲页面的计数nr_free
        ClearPageProperty(page); // 清除分配的页面块page的PG_property标志，表示这个页面块已经被分配，不再是空闲页面
    }
    return page;
}
```

工作流程如下：

- **检查空闲页面数量**：首先确保系统中有足够的空闲页面可以分配。
- **遍历空闲链表**：找到第一个符合要求（大小>= n）的页面块。
- **分配页面块**：如果找到了符合条件的页面块，则从链表中删除。
- **处理剩余页面**：如果页面块大小大于请求的页面数n，则将剩下的页面重新插入到空闲链表中。
- **更新状态**：减少空闲页面计数，并返回分配的页面块

###  default_free_pages

```c++
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0); // 确保n大于0，即要初始化的页面数必须是正数。如果 n == 0，则直接报错。
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保每个页面p当前既不是保留页，也不是空闲块的首页面。这样可以防止释放非法页面。 
        p->flags = 0; // 清空页面的标志位，表示这个页面不再被分配，已经变为空闲页
        set_page_ref(p, 0); // 将页面的引用计数设为0，表示没有其他对象在引用该页面。
    }
    base->property = n; // 设置块首页面的property，表示从base开始的连续n个页面为一个页面块
    SetPageProperty(base); // 设置base的PG_property标志位，表示这个页面块的首页面是一个空闲块
    nr_free += n; // 更新系统中的空闲页面总数，增加n

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link)); // 检查空闲页面链表free_list是否为空。如果链表为空，直接将base插入为第一个节点
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) { // 如果链表不为空,找到第一个地址大于base的页面块，将base插入到它之前，保持链表按地址顺序排列
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link)); // 如果遍历到链表的末尾，base应该插入到链表的最后。
            }
        }
    }
    
    list_entry_t* le = list_prev(&(base->page_link)); // 获取base前面的链表节点，看看能否合并。
    if (le != &free_list) {
        p = le2page(le, page_link); 
        if (p + p->property == base) {
            //如果前一个页面块p的地址加上它的大小正好等于base的地址，说明p和base是相邻的,合并块，更新p的property，将base包含的页面数量加到p中
            p->property += base->property;
            ClearPageProperty(base); // 清除base的PG_property标志，表示base不再是一个独立的块
            list_del(&(base->page_link)); // 从空闲链表中删除base
            base = p; // 更新base指针，使其指向合并后的块的开始
        }
    }
    
    le = list_next(&(base->page_link)); // 获取base后面的链表节点
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            //检查base和后面的页面块p是否相邻，如果是相邻的，可以合并,合并页面块，将p的大小加到base的property中
            base->property += p->property;
            ClearPageProperty(p); // 清除base的PG_property标志，表示base不再是一个独立的块
            list_del(&(p->page_link)); 从空闲链表中删除p
        }
    }

}
```

将 n个从base开始的物理页面释放，并将它们重新加入到空闲页面链表free_list中。同时，函数会尝试合并相邻的空闲页面块，以减少内存碎片。

- **参数检查与页面初始化**：确保要释放的页面有效并清空它们的属性。
- **将页面块插入空闲链表**：根据页面的地址顺序，将新的空闲块插入链表。
- **尝试合并相邻的页面块**：在插入后，检查是否可以与前后的空闲块合并。

### 实现过程

#### 1. **物理内存管理初始化**

物理内存管理的第一步是初始化内存管理器的数据结构，通常是在系统启动时进行。这里主要是建立空闲链表，用于管理系统中的空闲物理页面。

##### **函数：default_init()**

- **作用**：初始化空闲页面链表free_list和系统的空闲页面计数器nr_free。
- **过程**：将空闲页面链表设置为空，并将空闲页面计数器置为0。

#### 2. **初始化物理页面块**

在分配物理内存之前，需要将物理内存按页面大小进行划分，并初始化每个页面。将空闲页面加入到空闲链表中，以便后续的内存分配能够使用这些页面。

##### **函数：default_init_memmap(struct Page \*base, size_t n)**

- **作用**：初始化从base开始的 `n` 个连续物理页面，清空页面的标志和引用计数，并将其标记为空闲页面，然后将其插入到空闲页面链表中。
- 过程：
  1. 遍历从base开始的n个物理页面，初始化页面的标志和引用计数。
  1. 将该页面块插入到空闲链表中，保持链表按地址顺序排列。
  1. 更新系统的空闲页面计数nr_free。

#### 3. **分配物理页面**

内存分配的核心是找到一个合适的空闲块，并将其分配给请求方。First-Fit 算法遍历空闲页面链表，找到第一个能够满足请求的块，并返回该块的起始地址。

##### **函数：default_alloc_pages(size_t n)**

- **作用**：分配至少 `n` 个连续的物理页面，使用 First-Fit 算法找到满足要求的第一个块。
- 过程：
  1. 遍历空闲页面链表，找到第一个大小>= n的页面块。
  1. 如果块的大小大于n，则将多余的部分拆分，并重新插入到链表中。
  1. 更新系统的空闲页面计数nr_free并返回分配好的页面块。
  1. 如果没有找到足够大的页面块，则返回NULL。

#### 4. **释放物理页面**

当页面不再被使用时，需要将其释放，并将其重新插入到空闲页面链表中。同时，需要检查能否将相邻的空闲页面块合并，减少内存碎片。

##### **函数：default_free_pages(struct Page \*base, size_t n)**

- **作用**：将从base开始的n个物理页面释放，并重新插入到空闲链表中。同时尝试合并相邻的空闲块，减少碎片。
- 过程：
  1. 遍历从base开始的n个页面，将它们标记为可用并重置引用计数。
  1. 将释放的页面块插入到空闲页面链表中，按地址顺序排列。
  1. 检查前后是否有相邻的空闲块，如果有则进行合并。
  1. 更新系统的空闲页面计数nr_free。

### 优化（仅讨论针对firstfit算法的优化，不考虑更换算法）

- **内存碎片问题**：可以增加定期对空闲块进行整理的策略，每隔一段时间将分散的空闲块合并成连续的大块，避免页面较大时内存不够用的问题。
- **分配效率问题**：可以使用树形结构来存储空闲块，按块大小进行排序，在分配时能快速找到合适的块，不必进行线性遍历
- **内存分配中的同步问题**：采用分区锁机制将空闲链表划分为多个区域，每个区域对应一个锁，可以减少锁的争用，提高并发性能。还可以使用无锁内存分配算法或等待自由算法实现内存管理，避免线程间的同步开销。

## 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

- 你的 Best-Fit 算法是否有进一步的改进空间？

### 编写代码

对于前面的First-Fit我们可以知道，相对于First-Fit，Best-Fit最大的不同就是其是从全部空闲区中找出能满足作业要求的，且**大小最小**的空闲分区，这种方法能使碎片尽量小。也就是说，在遍历的过程中，不但要满足小于要求的size n，还要满足是所有符合要求的空闲页中最小的。基于原有的First Fit算法，需要修改下列函数：

+ `default_alloc_pages`函数：

```c++
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *best_page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;//设置最小size

    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) {
            best_page = p; // 记录当前找到的最适合的页框块
            min_size = p->property; // 更新最小适配大小
        }
    }

    if (best_page != NULL) {
        list_del(&(best_page->page_link));
        if (best_page->property > n) {
            struct Page *remaining_page = best_page + n;
            remaining_page->property = best_page->property - n; // 更新剩余页框块的大小
            SetPageProperty(remaining_page); // 设置剩余页框为属性页
            list_add(&free_list, &(remaining_page->page_link)); // 将剩余页框插入到空闲链表中
        }
        nr_free -= n;
        ClearPageProperty(best_page); // 清除分配出去的页框的属性标志
    }
    return best_page;
}
```

#### 运行结果

### 你的 Best-Fit 算法是否有进一步的改进空间？

1. **双向链表优化查找效率：**

在当前实现中，空闲块的查找是通过线性遍历整个链表实现的，这对于大规模内存块的管理来说效率较低。可以考虑维护一个双向链表，同时按块大小排序，这样可以更快地找到合适的块。如果能直接跳过不合适的块，将极大地提高效率。

2. **空闲块的索引机制**：

通过增加一层索引机制，比如使用平衡二叉树（如AVL树）或堆结构来管理空闲块，这可以大幅减少寻找最佳适应块的时间复杂度，从 `O(n)` 降低到 `O(log n)`。这种优化能够提高内存分配的效率。

### 优化尝试

这里将索引机制优化为一个avl树（一个例子，具体实现需要写一个avl树的定义文件）：

```c++
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <best_fit_pmm.h>
#include <stdio.h>
#include <avltree.h> // 引入AVL树库，用于管理空闲块

free_area_t free_area;
AVLTree free_tree; // 使用AVL树来管理空闲块

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    avltree_init(&free_tree); // 初始化AVL树
    nr_free = 0;
}

static void
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0; // 清除页框的标志位
        set_page_ref(p, 0); // 将页框的引用计数设置为0
        ClearPageProperty(p); // 清除页框的属性标志
    }
    base->property = n; // 设置页框块的大小属性
    SetPageProperty(base); // 设置页框为属性页
    nr_free += n;
    
    // 将空闲块插入到AVL树中
    avltree_insert(&free_tree, base->property, base);
}

static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }

    // 使用AVL树查找最小的大于等于n的块
    struct Page *best_page = avltree_find_min_ge(&free_tree, n);
    if (best_page == NULL) {
        return NULL;
    }

    // 从AVL树中删除找到的块
    avltree_delete(&free_tree, best_page->property, best_page);

    if (best_page->property > n) {
        struct Page *remaining_page = best_page + n;
        remaining_page->property = best_page->property - n; // 更新剩余页框块的大小
        SetPageProperty(remaining_page); // 设置剩余页框为属性页
        avltree_insert(&free_tree, remaining_page->property, remaining_page); // 将剩余页框插入到AVL树中
    }
    nr_free -= n;
    ClearPageProperty(best_page); // 清除分配出去的页框的属性标志
    return best_page;
}
```

### 结论

目前我们优化best-fit的方式都是通过优化遍历链表的过程，若是我们单单优化索引和内存块的数据结构，那么在后来释放内存块或者合并内存块的过程中会不会出现复杂度增加的程度大于前期对内存块索引的优化？总的来讲，我们对于该算法的优化要考虑整体算法的优化，而不是单单对于一个地方达到速度最快。

## 扩展练习Challenge1：Buddy_System（伙伴系统）分配算法（需要编程）

### 任务描述

* Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...
   * 参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)，在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

### 设计思路

* 在实现Buddy_System（伙伴系统）分配算法之前，我们首先需要用通俗的语言来介绍一下什么是伙伴系统分配算法。
   * Buddy System是一种内存管理算法，主要用于动态分配内存。它通过将内存分成大小为2的幂的块（即页），相当于分离出若干个块大小一致的空闲链表，进而来简化内存的分配和释放。
      * 具体而言，内存被分割成多个“伙伴”，如果需要的块不够大，系统可以将较大的块拆分成两个较小的块，直到找到合适的块为止。
      * 当释放内存时，系统会检查相邻的块，如果相邻块都是空闲的，则将它们合并为一个更大的块。
      * 搜索该链表并给出与我们需要的快的大小最佳匹配的块即可。
      * 其优点是：快速搜索合并（O(logN)时间复杂度）以及低外部碎片（最佳适配best-fit）。
      * 其缺点是：因为链表的内部碎片按2的幂划分块，所以如果碰上66单位大小，那么必须划分128单位大小的块，而非与其大小最接近的64单位大小的块，可能会导致空间的浪费。
* 在简单的用自然语言描述了什么是伙伴系统分配算法之后，我们给出相对抽象一些的概念：
   * **分配原理**：整个可分配的分区大小为 M；需要的分区大小为 N，当 N 小于或等于 M 时，将整个块分配给该进程。也就是说，如果需要的分区大小小于当前空闲分区的大小时，我们将当前大小的空闲分区分为两个相等的空闲分区，重复这一划分过程，直到找到一个合适的大小 M，将大小为 M 的空闲分区分配给该进程。
   * **合并条件**：在释放内存时，伙伴系统会根据以下条件合并相邻的空闲块：
      * 大小相同且为2的整数次幂
      * 地址相邻
      * 低地址空闲块的起始地址为块大小的整数次幂的位数

### 代码解读

* 为了减轻工作压力，省去自己编写测试脚本的工作，本次实现我们将Lab2的工程文件进行了复制，并直接在其中的best_fit_pmm.c文件中实现buddy system分配算法。我们继续使用双向链表实现buddy system分配算法，并最后直接使用make grade命令进行测试，其测试结果可以直接对我们的算法正确性进行检测。

#### 头文件及预备工作

* 首先我们需要引入一些头文件、外部变量以及宏定义，进而实现基本的功能要求并提升代码的运行效率。

```C

	#include <pmm.h>
	#include <list.h>
	#include <string.h>
	#include <best_fit_pmm.h>
	#include <stdio.h>
	
	extern free_area_t free_area; // 存储空闲内存区域的信息
	
	#define free_list (free_area.free_list)
	#define nr_free (free_area.nr_free

```

#### 获取指数函数

* 在伙伴系统实现过程中，找到与请求内存大小最近的2的整数次幂是一个关键步骤。为此，我们编写一个辅助函数来获取该向下取整的幂指数。该函数将输入的大小转换为最接近的、较小的2的整数次幂，从而确保内存的有效利用和分配的高效性。这样，在内存分配和释放时，可以最大限度地减少内存碎片，提高系统的整体性能。

```C

	// 获取指数函数,最接近的2的幂
	size_t
	get_exp(size_t num)
	{
	    size_t exp = 0;
	    while (num > 1)
	    {
	        num >>= 1; // 右移一位，相当于除以2
	        exp++;
	    }
	    return (size_t)(1 << exp); // 通过左移操作计算出结果
	}

```

#### 初始化空闲链表和空闲页数

* 我们初始化空闲链表和空闲页数，首先对空闲链表进行初始化并将当前可用的页数置0，进而保证在分配开始前我们的数据结构整体为空。

```C

	best_fit_init(void)
	{
	    list_init(&free_list);
	    nr_free = 0;
	}

```

#### 初始化内存映射

* 本函数用于在伙伴系统中初始化内存页框，其主要目标是将指定的 n 个内存页框从保留状态转为可用状态，并按块大小排序将其插入到空闲页链表中。它使用**最佳适配**策略来插入内存块，以确保空闲页块链表按照块大小进行排序，便于内存的高效分配。
   * 首先，函数对传入的页框范围进行遍历操作，依次将这些页框的属性和标志位清空，将它们标记为未使用状态。每个页框的引用计数被重置为 0，表明该页框还没有被任何进程使用。
   * 初始化后，将这些空闲的页框数量加入到系统的空闲页计数器 nr_free 中，表示系统中可供分配的内存页框数量增加了。
   * 代码随后通过一个循环将 n 个页框划分为若干块大小为2的幂次的内存块。每次获取当前可以处理的最大块大小（通过 get_exp() 函数），并逐步从尾到头进行划分。这种分割方式符合伙伴系统的思想，确保内存块的大小总是2的幂次，从而方便在后续内存释放时与邻近块合并。
   * 划分后的内存块根据**最佳适配算法**的策略被插入到系统维护的空闲页链表 free_list 中。
      * 在链表中，空闲块根据大小排序（块大小越大越靠后）。当块大小相同时，按照内存地址排序（地址越小的块靠前）。
      * 通过有序插入，确保空闲页块链表在后续内存分配时能够快速找到最适合的块，减少内存碎片。
   * 每次插入完一块后，减去已经处理的页框数量，继续处理剩余的内存，直到所有页框被划分并插入空闲链表中。
* 总而言之，这段代码的主要目标是将一段连续的内存页块初始化为可用状态，并按大小和地址顺序插入空闲页链表中，确保内存管理系统能够高效地进行后续的内存分配和释放。

```C

	static void
	best_fit_init_memmap(struct Page *base, size_t n)
	{
	    assert(n > 0);
	    struct Page *p = base;
	    for (; p != base + n; p++)
	    {
	        assert(PageReserved(p));
	        // 清空当前页框的标志和属性信息
	        p->flags = p->property = 0;
	        // 将页框的引用计数设置为0
	        set_page_ref(p, 0);
	    }
	    nr_free += n;
	    // 设置base指向尚未处理内存的尾地址，从后向前初始化
	    base += n;
	    while (n != 0)
	    {
	        // 获取本轮处理内存页数
	        size_t curr_n = get_exp(n);
	        // 将base向前移动
	        base -= curr_n;
	        // 设置此时的property参数
	        base->property = curr_n;
	        // 标记可用
	        SetPageProperty(base);
	        // 我们采用按照块大小排序方式插入空闲块链表，当大小相同时的排序策略是地址
	        list_entry_t *le;
	        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
	        {
	            struct Page *page = le2page(le, page_link);
	            if ((page->property > base->property) || (page->property == base->property && page > base))
	                break;
	        }
	        list_add_before(le, &(base->page_link));
	        n -= curr_n;
	    }
	}

```

#### 内存分配

* 本函数的主要功能是从空闲内存页链表中分配 n 个页框。如果可用的页框不足，将返回 NULL。该函数根据伙伴系统的规则，对请求的内存页进行合适的分配和切割。
   * 首先函数接收一个 size_t 类型的参数 n，表示请求的页框数量。首先确保 n 大于 0。
   * 随后使用 get_exp 函数计算 n 向上取整到最接近的2的幂次。如果 size 小于 n，则将 n 设为 2 * size，确保分配的内存块满足伙伴系统的要求。检查当前可用的空闲页框 nr_free 是否足够满足请求。如果不够，返回 NULL。
   * 然后初始化指针 le 指向空闲链表的头部，然后遍历链表，查找满足请求的空闲页框。对于每个遍历到的空闲页框，检查其 property（表示当前块的大小）是否大于等于请求的 n。
   * 一旦找到符合要求的空闲页框，将其赋值给 page。如果找到了符合要求的页框，则退出循环。
   * 如果找到的 page 的 property 大于请求的 n，则需要进行切割。
      * 在切割过程中，将 page 的 property 除以 2，表示将其大小减半。
      * 同时创建一个新的页框 p，表示切割出的右半部分，并将其属性设置为新块的大小。
      * 将新块插入到空闲链表中，保持链表的有序性。
   * 一旦切割完成，更新系统的空闲页框计数 nr_free，并清除 page 的属性以表示它已被分配。在分配完成后，确保 page 的 property 正好等于请求的大小 n，并从空闲链表中删除该块。
   * 最后，返回指向分配内存的 page 指针。
* 总而言之，这段代码实现了在伙伴系统中根据最佳适配策略分配内存的功能，确保有效管理内存，提高内存使用效率。通过切割和链表操作，支持动态内存请求和释放，降低内存碎片的可能性。

```C

	static struct Page *
	best_fit_alloc_pages(size_t n)
	{
	    assert(n > 0);
	    // 现在我们要向上取整来分配合适的内存
	    size_t size = get_exp(n);
	    if (size < n)
	        n = 2 * size;
	    if (n > nr_free)
	    {
	        return NULL;
	    }
	    struct Page *page = NULL;
	    list_entry_t *le = &free_list;
	    // 遍历空闲链表，查找满足需求的空闲页框
	    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
	    while ((le = list_next(le)) != &free_list)
	    {
	        struct Page *p = le2page(le, page_link);
	        if (p->property >= n){
	            page = p;
	            break;
	        }
	    }
	    // 如果需要切割，分配切割后的前一块
	    if (page != NULL)
	    {
	        while (page->property > n)
	        {
	            page->property /= 2;
	            // 切割出的右边那一半内存块不用于内存分配
	            struct Page *p = page + page->property;
	            p->property = page->property;
	            SetPageProperty(p);
	            list_add_after(&(page->page_link), &(p->page_link));
	        }
	        nr_free -= n;
	        ClearPageProperty(page);
	        assert(page->property == n);
	        list_del(&(page->page_link));
	    }
	    return page;
	}

```

#### 内存释放

* 本函数的主要功能是释放 n 个页框，并将其合并到空闲链表中，以便后续的内存请求可以重新利用这些页框。
   * 首先函数接收两个参数：base（指向要释放的页框的起始地址）和 n（要释放的页框数量）。首先确保 n 大于 0。
   * 随后我们使用 get_exp 函数计算 n 向上取整到最接近的2的幂次。如果 size 小于 n，则将 n 设为 2 * size，确保释放的内存块满足伙伴系统的要求。
   * 遍历从 base 开始的 n 个页框，确保它们不是保留状态，并且没有被标记为已分配。清空页框的 flags 和引用计数，设置为 0。
   * 然后我们对属性进行更新。设置释放的页块的 property 为 n，标记该页块为已释放状态，并增加系统的空闲页框计数 nr_free。
   * 初始化指针 le，指向空闲链表的下一个元素，遍历链表，找到适当的位置插入释放的页块。在插入时，保持空闲链表的有序性（先按块大小，再按地址）。
   * **合并条件**：在释放内存时，伙伴系统会根据以下条件合并相邻的空闲块：
      * 大小相同且为2的整数次幂
      * 地址相邻
      * 低地址空闲块的起始地址为块大小的整数次幂的位数
   * 向左合并：检查前一个页块是否可以与当前页块合并。
      * 如果前一个空闲页块的 property 与当前页块相同，并且地址相邻，则将当前页块合并到前一个页块中。
      * 更新前一个页块的大小，清除当前页块的属性，并从链表中删除当前页块。
   * 向右合并：循环遍历链表，检查后续的空闲页块是否可以与合并后的页块合并。
      * 如果当前页块的 property 与后续页块相同且地址相邻，则合并。
      * 更新当前页块的大小，清除后续页块的属性，并从链表中删除后续页块。
   * 最后是退出条件，如果当前页块的 property 小于后续页块的 property，则无法合并，退出循环。在退出前，检查当前页块在链表中的位置，确保相同大小的空闲块聚集在一起，以优化后续的查找。
* 总而言之，这段代码实现了在伙伴系统中释放内存的功能，通过状态清理、链表操作和合并机制，维护内存的高效使用。它确保释放的页框能被后续的请求有效地重用，并减少内存碎片。通过动态调整空闲链表，支持灵活的内存管理。

```C

	static void
	best_fit_free_pages(struct Page *base, size_t n)
	{
	    assert(n > 0);
	    // 回收也是同样的，现在我们要向上取整来分配合适的内存
	    size_t size = get_exp(n);
	    if (size < n)
	        n = 2 * size;
	    struct Page *p = base;
	    for (; p != base + n; p++)
	    {
	        assert(!PageReserved(p) && !PageProperty(p));
	        p->flags = 0;
	        set_page_ref(p, 0);
	    }
	    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
	    base->property = n;
	    SetPageProperty(base);
	    nr_free += n;
	
	    list_entry_t *le;
	    // 先插入至链表中
	    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
	    {
	        p = le2page(le, page_link);
	        // 这里的条件修改：与初始化策略相似
	        if ((base->property < p->property) || (base->property == p->property && base < p))
	            break;
	    }
	    list_add_before(le, &(base->page_link));
	    // 合并：合并条件如下
	    /*
	        - 大小相同且为2的整数次幂
	        - 地址相邻
	        - 低地址空闲块的起始地址为块大小的整数次幂的位数
	    */

	    // 1、判断前面的空闲页块是否与当前页块是连续的，相同大小的，如果是连续的且是相同大小的，则将当前页块合并到前面的空闲页块中
	    if ((p->property == base->property) && (p + p->property == base))
	    {
	        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
	        p->property += base->property;
	        // 3、清除当前页块的属性标记，表示不再是空闲页块
	        ClearPageProperty(base);
	        // 4、从链表中删除当前页块
	        list_del(&(base->page_link));
	        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
	        base = p;
	        le = &(base->page_link);
	    }
	
	    // 循环向右合并

	    while (le != &free_list)
	    {
	        p = le2page(le, page_link);
	        if ((p->property == base->property) && (base + base->property == p))
	        {
	            base->property += p->property;
	            ClearPageProperty(p);
	            list_del(&(p->page_link));
	            le = &(base->page_link);
	        }
	        // 无法合并时，退出
	        else if (base->property < p->property)
	        {
	            // 修改base在链表中的位置使大小相同的聚在一起
	            list_entry_t *targetLe = list_next(&base->page_link);
	            while (le2page(targetLe, page_link)->property < base->property)
	                targetLe = list_next(targetLe);
	            if (targetLe != list_next(&base->page_link))
	            {
	                list_del(&(base->page_link));
	                list_add_before(targetLe, &(base->page_link));
	            }
	            // 最后退出
	            break;
	        }
	        le = list_next(le);
	    }
	}

```

#### 检测函数

* 我们最后编写了如下样例，并使用assert抛出错误，执行结果在后面展示。

```C

	static void
	best_fit_check(void)
	{
	    int count = 0, total = 0;
	    list_entry_t *le = &free_list;
	    while ((le = list_next(le)) != &free_list)
	    {
	        struct Page *p = le2page(le, page_link);
	        assert(PageProperty(p));
	        count++, total += p->property;
	    }
	    assert(total == nr_free_pages());
	
	    basic_check();
	
	    struct Page *p0 = alloc_pages(26), *p1;
	    assert(p0 != NULL);
	    assert(!PageProperty(p0));
	
	    list_entry_t free_list_store = free_list;
	    list_init(&free_list);
	    assert(list_empty(&free_list));
	    assert(alloc_page() == NULL);
	
	    unsigned int nr_free_store = nr_free;
	    nr_free = 0;
	    //.........................................................
	    // 先释放
	    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
	    // 首先检查是否对齐2
	    p0 = alloc_pages(6);  // 8- 8+ 16+
	    p1 = alloc_pages(10); // 8- 8+ 16-
	    assert((p0 + 8)->property == 8);
	    free_pages(p1, 10); // 8- 8+ 16+
	    assert((p0 + 8)->property == 8);
	    assert(p1->property == 16);
	    p1 = alloc_pages(16); // 8- 8+ 16-
	    // 之后检查合并
	    free_pages(p0, 6); // 16+ 16-
	    assert(p0->property == 16);
	    free_pages(p1, 16); // 32+
	    assert(p0->property == 32);

	    p0 = alloc_pages(8); // 8- 8+ 16+
	    p1 = alloc_pages(9); // 8- 8+ 16-
	    free_pages(p1, 9);   // 8- 8+ 16+
	    assert(p1->property == 16);
	    assert((p0 + 8)->property == 8);
	    free_pages(p0, 8); // 32+
	    assert(p0->property == 32);
	    // 检测链表顺序是否按照块的大小排序的
	    p0 = alloc_pages(5);
	    p1 = alloc_pages(16);
	    free_pages(p1, 16);
	    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
	    free_pages(p0, 5);
	    assert(list_next(&(free_list)) == &(p0->page_link));
	
	    p0 = alloc_pages(5);
	    p1 = alloc_pages(16);
	    free_pages(p0, 5);
	    assert(list_next(&(free_list)) == &(p0->page_link));
	    free_pages(p1, 16);
	    assert(list_next(&(free_list)) == &(p0->page_link));

	    // 还原
	    p0 = alloc_pages(26);
	    //.........................................................
	    assert(nr_free == 0);
	    nr_free = nr_free_store;
	
	    free_list = free_list_store;
	    free_pages(p0, 26);
	
	    le = &free_list;
	    while ((le = list_next(le)) != &free_list)
	    {
	        assert(le->next->prev == le && le->prev->next == le);
	        struct Page *p = le2page(le, page_link);
	        count--, total -= p->property;
	    }
	    assert(count == 0);
	    assert(total == 0);
	}

```

* 我们可以很方便地利用make grade对我们实验的代码正确性进行检测，如果我们make grade无报错显示，则说明我们通过测试。运行结果如下：

![d84358df8347d4c689288cb8e826523](D:\微信文件\WeChat Files\wxid_yzjezuvbs1jn22\FileStorage\Temp\d84358df8347d4c689288cb8e826523.png)

## 扩展练习Challenge3：硬件的可用物理内存范围的获取方法（思考题）

如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

### **通过 BIOS/UEFI 获取内存信息**

这是最常见且被广泛使用的方法，可靠且几乎所有现代硬件都支持这种机制。现代操作系统可以通过访问 BIOS或 UEFI来获取系统物理内存的布局。BIOS/UEFI 会在启动时生成一张内存映射表，表明物理内存的不同区域的属性。

实现方法为：在启动时，OS 可以通过中断调用（例如INT 0x15的E820h服务）从 BIOS 获取内存映射表，对于 UEFI，OS 可以通过调用 UEFI 提供的GetMemoryMap函数来获取内存区域的详细信息，包括哪些区域是可用的，哪些是保留的。

BIOS 返回的内存映射表中，每个条目通常包含起始地址、大小以及该区域的类型（例如，可用、保留、设备映射等）。OS 根据这些条目决定哪些区域可以用于操作系统分配。

基本代码如下：

```assembly
mov eax, 0xE820         ; 调用 E820 功能
mov edx, 0x534D4150     ; 'SMAP' 魔术数
mov ecx, 24             ; 缓冲区大小
mov ebx, 0              ; 首次调用 EBX 应该为 0
mov es, seg             ; 设置 ES 段寄存器
mov di, offset buffer   ; 指向内存映射表的缓冲区

int 0x15                ; 调用 BIOS 中断

jc  error               ; 如果 CF 设置，跳转到 error 处理

cmp eax, 0x534D4150     ; 检查返回的魔术数是否正确
jne  error              ; 如果不正确，跳转到 error

mov ebx, next_block     ; 更新 EBX，为下次调用做准备
```

###  **通过 ACPI 获取内存信息**

ACPI是一种规范，用于发现和配置硬件，提供了更详细的硬件信息，适合处理复杂的系统配置。ACPI提供了一系列描述系统硬件状态的表格，其中包含了内存映射的信息,内存映射通常在SRAT（系统资源关联表）和SPCR（串行端口控制器寄存器）中描述。

操作系统可以读取 ACPI 表格来获取有关物理内存的信息。通过ACPI的RSDP（根系统描述表指针）找到RSDT或XSDT表，从中找到内存信息相关的表格。ACPI 还可以描述设备保留的内存区域，从而帮助 OS 避免使用这些区域。RSDT和XSDT的区别如下：

| 特性           | RSDT                           | XSDT                        |
| -------------- | ------------------------------ | --------------------------- |
| 指针大小       | 32 位                          | 64 位                       |
| 最大地址范围   | 4GB 以内                       | 64 位地址空间（超过 4GB）   |
| 使用场景       | 32 位系统，低于 4GB 的内存映射 | 64 位系统，适用于大内存系统 |
| ACPI 表签名    | "RSDT"                         | "XSDT"                      |
| 支持的地址空间 | 受限于 32 位地址空间           | 可跨越更大的地址空间        |

### **使用内存控制器或北桥设备**

如果 BIOS/UEFI 信息不可用，或系统没有正确配置 ACPI 表时，可以使用内存控制器或北桥替代。一些平台允许操作系统直接从内存控制器或芯片组查询物理内存的大小和分布情况。内存控制器会记录系统中已安装内存的总量和内存布局，操作系统可以通过访问特定的控制器寄存器来获取这些信息。不过该方法依赖于硬件特定的寄存器，可能无法在所有平台上通用。

例如在x86中，操作系统可以通过访问特定的硬件寄存器或通过 PCI 总线查询芯片组的配置，来读取系统中的物理内存信息，获取可用物理内存范围。

### **使用引导加载程序（Bootloader）传递信息**

操作系统可以通过引导加载程序（如 GRUB 或 LILO）来获取内存信息，系统启动时Bootloader可以通过BIOS/UEFI获取内存信息，并将这些信息传递给内核。

- **如何实现**：
  - 使用类似 GRUB 的引导加载程序，操作系统在启动时从 Bootloader 接收内存映射信息（例如 GRUB Multiboot 规范）。Bootloader 已经为内核准备好了系统的内存布局，内核只需要读取这些信息即可。
- **优点**：减少了操作系统启动时获取内存映射的复杂性，因为这些工作已经由 Bootloader 处理




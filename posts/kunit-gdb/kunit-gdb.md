---
title: Catching kernel crash on KUnit tests with GDB
date: 2023-08-25
description:
mainfont: DejaVuSerif
monofont: DejaVuSerif
...

Getting into KUnit tests development, we usually fell in crafting a
hand-made (and error prone) environment consisted of a lot of mocked
structs and functions aiming to cover every possible codepath. This would
be simple if you're testing simple functions which doesn't interact a
lot with external environment, but even those might hide some traps on
implicitly called functions at an deeper level of nesting. If you're
in such situation, having a kernel to crash by running your test could be
undesirably common, going even worse when you realize that the error
message didn't say much about the crash cause.

Fortunatelly, KUnit support running tests using the UML arch, which is much
easier to debug than any other, due the fact that the kernel runs entirely
in userspace, as a regular program, and so you don't even need to play with
specific debug modules and virtualization stuffs. Despite some specific
set of tests, almost every KUnit test can run in UML (which is the default
when using the kunit.py tool).

As an addendum, I think it's worth mentioning that despite the examples
on this post are about KUnit tests, all the gdb things applies equally well to any
UML kernel. So, even if you're not really interested on KUnit tests,
you may also enjoy this post. :smile:

# The GNU Debugger
A debugger is a kind of software that basically allows you to inspect
a running program. In there, you can, at any point of execution, print
variables values, examine function call stack, trace code execution line
by line and a lot of other nice things that help you understand what
exactly your program is doing.

gdb is probably the most powerful debugger you might see in that
context. With a few commands, you are able to debug the most kind of
things, but you can also extend gdb with hand-made scripts to fully
extract its great potential. In my case, I just understand the bare
minimal of gdb, which is what I'll try to cover here, but despite this
being too little, it covers a big amount of gdb use cases.

Now it's time to forgot about printing variables on the code,
you can just print them from gdb!

# An example
Suppose that you wanna test that `misc_example_increment_bar` function:

**example.h:**
```c {.numberLines}
struct s1 {
	int foo;
};

struct s2 {
	int bar;
	struct s1 *baz;
};

void misc_example_increment_bar(struct s2 *s);
```

**example.c:**
```c {.numberLines}
#include "example.h"

void misc_example_increment_bar(struct s2 *s)
{
	s->baz->foo--;
	s->bar++;
}
```

As the function name say, it's just supposed to increment `s->bar`. You
may noticed that we also decrement `s->baz->foo`, but let it as
a side effect that wasn't really clear at the first look on this
function. This is intentionally left simple to doesn't noise the example,
the tradeoff is that it becomes much less realistic.  Just imagine that
`s->baz->foo` was present on a function that is implicitly called by
`misc_example_increment_bar` and that you didn't realized it yet.

So, let's test it:

**example_test.c:**
```c {.numberLines}
#include <kunit/test.h>
#include "example.h"

static void misc_example_increment_bar_test(struct kunit *test)
{
	struct s2 *s;
	s = kunit_kzalloc(test, sizeof(struct s2), GFP_KERNEL);
	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, s);

	s->bar = 1;
	misc_example_increment_bar(s);
	KUNIT_EXPECT_EQ(test, 2, s->bar);
}

static struct kunit_case misc_example_test_cases[] = {
	KUNIT_CASE(misc_example_increment_bar_test),
	{ }
};

static struct kunit_suite misc_example_test_suite = {
	.name = "misc-example",
	.test_cases = misc_example_test_cases,
};
kunit_test_suite(misc_example_test_suite);
```

What this test is doing is: allocate a `struct s2`, set its `s->bar`,
call `misc_example_increment_bar` and assert that the `s->bar` value
was properly incremented, that's all.

By running this test you'll get something like this:

```
[10:02:13] Starting KUnit Kernel (1/1)...
[10:02:13] ============================================================
[10:02:13] ================= misc-example (1 subtest) =================
[10:02:13] [ERROR] Test: misc-example: missing expected subtest!
[10:02:13]
[10:02:13] Pid: 16, comm: kunit_try_catch Tainted: G        W        N 6.5.0-rc2-00046-gccff6d117d8d-dirty
[10:02:13] RIP: 0033:misc_example_increment_bar+0x4/0x10
[10:02:13] RSP: 00000000a187bf48  EFLAGS: 00010203
[10:02:13] RAX: 0000000000000000 RBX: 0000000061c4a870 RCX: 00000000a1803d78
[10:02:13] RDX: 000000006002ac00 RSI: 0000000000000000 RDI: 0000000061c4a870
[10:02:13] RBP: 00000000a1803d20 R08: 0000000000000000 R09: 0000000000000000
[10:02:13] R10: 0000000061eb4120 R11: 0000000061c20030 R12: 00000000a1803d38
[10:02:13] R13: 00000000a1803a40 R14: 0000000061eb40c0 R15: 0000000000000000
[10:02:13] Kernel panic - not syncing: Segfault with no mm
[10:02:13] CPU: 0 PID: 16 Comm: kunit_try_catch Tainted: G        W        N 6.5.0-rc2-00046-gccff6d117d8d-dirty #142
[10:02:13] Stack:
[10:02:13]  602355e9 a187bf80 602a309c 61eb40c0
[10:02:13]  61c073c0 a1803d38 a1803d38 601cca80
[10:02:13]  601cca8b 61c073c0 6005598c 00000000
[10:02:13] Call Trace:
[10:02:13]  [<602355e9>] ? misc_example_increment_bar_test+0x49/0x110
[10:02:13]  [<602a309c>] ? schedule+0x6c/0xf0
[10:02:13]  [<601cca80>] ? kunit_generic_run_threadfn_adapter+0x0/0x20
[10:02:13]  [<601cca8b>] ? kunit_generic_run_threadfn_adapter+0xb/0x20
[10:02:13]  [<6005598c>] ? kthread+0xfc/0x150
[10:02:13]  [<6001aad2>] ? new_thread_handler+0x82/0xc0
[10:02:13] [CRASHED]
[10:02:13] [ERROR] Test: misc-example: missing subtest result line!
[10:02:13] ================== [CRASHED] misc-example ==================
[10:02:13] ============================================================
[10:02:13] Testing complete. Ran 1 tests: crashed: 1, errors: 2
```

Well, this is not a very pleasant message, but what you could
actually gather from it is that the kernel crashed when running the
`misc_example_increment_bar` function. That alone tell a lot about the
crash and in our case it's easy to see what caused the crash, but now
we will examine a way to get more details about it.

# Running the kernel through GDB
You can actually run any binary program through gdb, but it might not
be so meaningful if you don't enable debug symbols at compile time.
That is, the gdb will be fine running your program, but it won't be
capable to tell you the name of the variables, functions and neither
where's the line of code it's executing, for example. So unless you're
reverse engineering something, you will really wanna enable debug symbols
in your program. You normally do that by passing the `-g` argument to
`gcc`, but as everything in the kernel, you usually don't mess with
gcc arguments, you use Kconfig. So, to enable debug symbols in your
kernel built, you must enable at least the `CONFIG_DEBUG_KERNEL` and
`CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT` configs. The kernel has more
debug options that can help your debug session, like `CONFIG_GDB_SCRIPTS`,
but we won't cover that in this tutorial as it's a introductory one.

```
$ ./tools/testing/kunit/kunit.py build \
      --kconfig_add CONFIG_DEBUG_KERNEL=y \
      --kconfig_add CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
```

Now you have your kernel built with debug symbols, and now the fun
part: running the kernel through gdb. You may wonder if now we should
boot the kernel on a virtual machine with gdb server and
whatnot, but remember that you're dealing with a UML kernel, it's a
regular program. So, you can just run it as follow:

```
$ ./.kunit/vmlinux
```

This is the power of UML! So guess what, how can you run your kernel
through gdb?

```
$ gdb ./.kunit/vmlinux
```

Cool, now you can start running the kernel by entering the `run`
command. This let the program to execute as if it was called by the shell
(you might pass arguments as well).

```
(gdb) run
...
Program received signal SIGSEGV, Segmentation fault.
                                                    0x0000000060244ed4 in misc_example_increment_bar (s=s@entry=0x60820870)
    at ../drivers/misc/example.c:7
7               s->baz->foo--;

```

At this moment, a lot of things was showed in your terminal (that
I omitted with `...`), but what really matters is that last showed
message. The gdb is basically telling exactly where the kernel
crashed! And we literally did nothing but typed `run`. If it wasn't
clear enough, let's examine a bit more:

```
(gdb) print *s
$1 = {bar = 1, baz = 0x0}

```

There, I just print what `s` points (that is a `struct s2`), and so we can
see the value of each its members. Now it's very clear the crash culprit:
`s->baz` is `NULL`, while we are dereferencing it on `s->baz->foo--;`
on the example.c! Now you can fix that, for example, by allocating
`s->baz` on the test. :smile:

# A bit more of GDB
I couldn't write a gdb tutorial leaving out the `break` `next` and `step`
trio. They all, plus the `print`, form a great arsenal that you'll be
using over your debug session. Let's see an example.

Suppose that instead of just see where the kernel broke, you want
to inspect its execution line by line. To do so, you need to set
a breakpoint, which basically is a point in the code where you're
telling the gdb to stop on and provide you access to its command line. A
breakpoint can be anything, a specific line of a file, a function and
even a memory address. The `help` command is your friend here, use
it to discover  all possibilities, just `help break`. By having gdb
stopped at some breakpoint, you can use any inspect command to do so,
like the `print` previously covered.  There's also `list`, that shows
the source code around the current breakpoint, which is very useful to
locate yourself over the debug session.

So, for example, you might set the breakpoint on the
`misc_example_increment_bar_test` function, and you do that by using the
`break` command before you type `run`:

```
(gdb) break misc_example_increment_bar_test
Breakpoint 1 at 0x60244ee0: file ../drivers/misc/example_test.c, line 8.
(gdb) run
...
Breakpoint 1, misc_example_increment_bar_test (test=0x64803d00)
    at ../drivers/misc/example_test.c:8
8               s = kunit_kzalloc(test, sizeof(struct s2), GFP_KERNEL);
```

The gdb paused the program just at the start of the function! Now you can
inspect the program and, when tired of being stuck at that breakpoint,
(optionally) set another one and `continue`. The `continue` command
just resume the program until it reach the next breakpoint, that may
not exists, letting the program to run until its end.

Now there's the `next` and `step` commands that almost do the same:
step to the next line, that is, set a breakpoint to the next line and
`continue`. They both differs just in the fact that `next` doesn't
digs into subroutine calls, while `step` digs. Let's explore that in the
following examples (for now, I just removed the `s->baz->foo--;`
line from example.c to stop crashing the kernel):

**Using `next`:**
```
(gdb) break drivers/misc/example_test.c:12
Breakpoint 1 at 0x60244f1f: file ../drivers/misc/example_test.c, line 12.
...
Breakpoint 1, misc_example_increment_bar_test (test=0x64803d00)
    at ../drivers/misc/example_test.c:12
12              misc_example_increment_bar(s);
(gdb) next
14              KUNIT_EXPECT_EQ(test, 2, s->bar);
```

**Using `step`:**
```
(gdb) break drivers/misc/example_test.c:12
Breakpoint 1 at 0x60244f1f: file ../drivers/misc/example_test.c, line 12.
...
Breakpoint 1, misc_example_increment_bar_test (test=0x64803d00)
    at ../drivers/misc/example_test.c:12
12              misc_example_increment_bar(s);
(gdb) step
misc_example_increment_bar (s=s@entry=0x60804140) at ../drivers/misc/example.c:7
7               s->bar++;
```

By setting a breakpoint just before calling `misc_example_increment_bar`,
we could see that when followed by `next`, the next breakpoint became
the next line just after the previous one, while with step it went to
the next line considering the called function, that is the first line
of the function.

---
In any circumstance, debugging may be very hard and time consuming,
and so go even worse if you have no good tool to assist you into that
journey. With gdb, you're in great place, and so the main point of this
post was to show how quick and simple is starting to use it. There's no
need to be scared about the learning curve of introducing another piece
of software in your workflow, it can be simple!

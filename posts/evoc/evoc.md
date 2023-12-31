---
title: Living the Dream of Developing Free Software
date: 2023-06-14
description: My journey getting into Xorg EVoC.
...

Since 2020, when I discovered about Free Software, I was in active
commitment with the cause, that became part of my daily live. Then,
naturally, I dreamed about someday work with free software development,
but at the time I didn't had much programming skill so I just kept me
in studying and hacking my OS. Due my skills dealing with GNU/Linux
systems, I got my first job as sysadmin in 2021 and since now it was
what I'm doing. In the middle-time, I transferred (in 2022) to the Computer
Science undergraduate course (I was in my 4th year of Medical Physics
before). But despite all this facts, I always had interest in system
programming, but I never had any opportunity to get in depth about it,
neither in the job market nor the university, so, again, I just kept me
studying things that I like, promising me that someday I'll find a way
to dedicate myself in studying what I like most. And so, that day became real.

I was just reading some Telegram groups when I crossed a message from
[tony](https://andrealmeid.com/) announcing he will be mentoring
this [GSoC project](https://www.x.org/wiki/DRMcoverage2023/) by Xorg
Foundation. The project idea was about increasing the code coverage of the
Linux DRM subsystem, so I don't hesitated to get in touch to know about
the details. *Spoiler*: Google rejected my proposal, but Xorg didn't,
and now I'm in the Xorg [EVoC](https://www.x.org/wiki/XorgEVoC/) :smile:.

# Starting at the warm-up
One of the first steps to prepare a proposal to GSoC was to complete the
initial proposed warm-up activities, that was:

1. Setup a virtual machine
2. Learn how to compile the Linux kernel
3. Learn how to install and remove a Linux kernel
4. Learn how to deal with modules
5. Learn how to use kw to speed-up your workflow and try to deploy a
new kernel by using this tool
6. Learn the basics about the Linux kernel contribution process
7. Read the Freedesktop Contributor Covenant
8. Subscribe to the dri-devel mailing-list and join the oftc#dri-devel
channel on IRC

At that point, my only experience with the kernel was building it to
my Gentoo install, nothing more than it, but it was enough to get it done
and learning a lot of things.

I firstly setup my VM using qemu (that was new to me and I liked a lot)
by installing Gentoo on it and configuring the directory sharing. Since
I choose Gentoo, I was able to do the first steps in a single one,
due the fact I would deal with the kernel in a regular Gentoo installation
anyway.

I tried to use the `kw` tool, but it don't support Gentoo yet and I
decided me to focus on understanding each manual step I could do in the
workflow to get the things done (I really prefer it that way when I'm new
to something, I tend to do everything manually until I'm sufficiently
comfortable to automate it).

Finally, I learned about the whole kernel contributing process, that
was completely new to me and differ a lot of everything I used to see,
so I carefully study it, since it's an very important part of the
process. Studying the contributing process involved being part of the
dri-devel mailing list and creating the habit to read it often, beside
the fact its email flux is too high so that is very hard to be always
tuned on (but that's okay, it's how everything works and you shouldn't
be 100% aware of everything that happens on all mailing lists).

## My first patch
The last activity, but definitely not least, was about making my first
patch (and sent it to the relevant mailing list) on the kernel. This
was the most challenging activity to me, since I wasn't really
understanding, at that point, what any code seem was doing, it was just a
lot of mystical code that I cannot understand yet. But it's okay, there is some
simple things you can do to contribute without a really good understand
about the code, and that was what I done: compiling some module with
`W=1` and choose some apparently simple warning to try to fix.

This led me to choose an unused-but-set-variable warning
that was (apparently) easy to fix, that was an unused returning value of a
function call on `drivers/gpu/drm/amd/amdgpu/amdgpu_mes.c` file. I
just removed that variable and sent [my
patch](https://lore.kernel.org/all/20230325203136.14401-1-gcarlos@disroot.org/),
but after a while I noticed that the warning disappeared, and with a
`git blame` I realized that this warning already had a [patch fixing
it](https://lore.kernel.org/all/20230317081718.2650744-18-lee@kernel.org/)
(in a better way) even before I sent my patch to the mailing list. This
was negligence of my part, but I actually learned what was wrong with
my patch (despite the fact it was sent too lately) and even it wouldn't
be accepted even if I had it sent before.

I ended the warm-up by learning a lot of things that by itself worth the
effort to get it done. Getting some guide (either by my mentors and the
suggested articles) was vital to get into the intimidating place
that is the Linux code without being stuck.

# The proposal
Then when I was warmed up, I started to write the proposal, describing a
bit of myself, how I did the warm-up and about what I would be proposing.

The proposal was obvious due the initial project
idea: increase coverage of the DRM code. That is, write
[KUnit](https://www.kernel.org/doc/html/latest/dev-tools/kunit/index.html)
tests for the DRM subsystem functions. I would just choose
what exactly I would like to test, and I choose some
functions from the `drm_framebuffer.c` file. The process
for choosing it was generating a [KUnit test coverage
report](https://flusp.ime.usp.br/kernel/generate-kunit-test-coverage/)
and searching for some file that had a low coverage rate (but not zero,
since it would be hard to write the tests without any preexisting
exemplar to base on). And so, I did a little search about what were
contained in each selected file and after that I did my choose.

## The proposal was ~~rejected~~ approved
The deadline reaches and I submitted my proposal, but after waiting
anxiously the long one month of analysis I was receipted with a decline
by Google. At this point, I was extremely sad, cause that was my only
opportunity to dedicate myself to something I strongly like and all my
hopes goes out after the notice.

My mentors, however, suggested that they could submit my proposal to
the EVoC program. I wasn't really hopeful that it would be
accepted, but it didn't hurt to try and so I decided to. I really
wasn't expecting anything but another decline, but I was (fortunately)
much wrong about this and so I'm here to tell the history where my proposal
was accepted :smile:!

# Who is my mentors
I'll be mentored by these awesome people:

- [André Almeida (tony)](https://andrealmeid.com/)
- [Maíra Canal](https://mairacanal.github.io/)
- [Tales L. Aparecida](https://tales-aparecida.github.io/tales-tips-and-tricks/)

# What to expect now?
I'm very very grateful and excited about this unique and perfect
opportunity I'm having that is changing my life, so I will do my best
to fulfill what was proposed and enjoy every second dedicated to this
project.

Today I'm writing this blogpost and I'm a bit delayed beside the proposed
timeline but I'm already working to change it by starting writing some
tests once finishing it.

I promise to return back with some interesting thing I have been doing
during the project, see ya!

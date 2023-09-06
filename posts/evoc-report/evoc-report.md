---
title: EVoC Final Report
date: 2023-09-04
description: The end of a outstanding journey.
...

It hasn't been so far away since I was extremely excited for starting to
work on that awesome free software project, but now I'm just at the end
of that outstanding journey. I ever dreamed in become a free software
contributor, and now I can just confirm that it's what I want to my life.

During EVoC, I could incredibly grow myself into someone who can
understand how free software are developed and be confident to start
contributing with. Now, I expect that it may be just the start of a long
standing journey on the world of free software development, where I aim
to keep me always actively working on.

# The goals of my EVoC project
Just to recapitulate a bit, the main goal of my EVoC project was to
increase the DRM code coverage on the kernel by writing KUnit tests.
To do it, I chose select some functions from `drm_framebuffer.c`
to start testing. However, over the project I changed it a bit, since
I became to understand a little more about these functions and noticed
some better candidates to be tested instead.

# Everything was a challenge
Since the start (and even now) I was absolutely concerned about my
programming skills and now I'm glad I could come from never programmed
any real world software to sending patches to the Linux kernel. This
is basically the resume of all that work, I would never imagine that I
could start to contributing to such a big and complex piece of software,
but the EVoC showed me the opposite.

Over the EVoC, the first thing I learned was that it's simply impossible
to learn everything you think you should know. When starting to work,
I faced every video, blogpost and documentation about DRM and the only
feeling left was: I know nothing, but now I can complement: I know nothing
but an infinitesimal part more then I knew at the start. That little is,
in true a huge amount of knowledge, which is what really allowed me to
contribute to the kernel. Therefore, what remain is: focus in the small
part you wanna work and just start. You'll learn a lot by doing things,
as simple as it may be.

# What I have done
At the moment, I was able to contribute with the following patches to
the Linux kernel:

1.  [drm/tests: Fix swapped drm_framebuffer tests parameter names](https://lore.kernel.org/all/20230624212905.21338-1-gcarlos@disroot.org/)
2.  [drm/tests: Stop using deprecated dev_private member on drm_framebuffer tests]
3.  [drm/tests: Add parameters to the drm_test_framebuffer_create test]
4.  [drm/tests: Add test case for drm_internal_framebuffer_create()]
5.  [drm/tests: Add test for drm_framebuffer_check_src_coords()]
6.  [drm/tests: Add test for drm_framebuffer_lookup()]
7.  [drm/tests: Add test for drm_framebuffer_init()]
8.  [drm/tests: Add test for drm_framebuffer_free()]
9.  [drm/tests: Add test for drm_mode_addfb2()]
10. [drm/tests: Add test for drm_fb_release()]
11. [drm/tests: Add test for drm_framebuffer_cleanup()]
12. [drm: Remove plane hsub/vsub alignment requirement for core helpers](https://lore.kernel.org/all/20230720021937.27124-2-gcarlos@disroot.org/)
13. [drm: Replace drm_framebuffer plane size functions with its equivalents](https://lore.kernel.org/all/20230720021937.27124-3-gcarlos@disroot.org/)
14. [drm: Add kernel-doc for drm_framebuffer_check_src_coords()]

However, just that first one was accepted and I'm currently working on
appling proposed review changes on the patches until they are accepted.

With all the patches I made, the `drm_framebuffer.c` line coverage came
from 18.1% to 44.9%, while the function coverage came from 8% to 52.2%.
Despite this file not being entirely covered by unit tests, the outcome
coverage is very significant, since the parts left untested are, in
majority, legacy code and ioctls, these which in turn is much better
tested in integration tests instead, like the ones present
[IGT](https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/tree/master/tests?ref_type=heads).

# What was left over
Despite changes from the proposed functions to test to what I really
tested, I tried to maintain at least a one-by-one correspondence over
them, but there was one function that was left out without any other
tested in its place, which is the `drm_framebuffer_remove`. It's, of
course, partially tested by another test, since it's split into two
different static functions, one for legacy devices and other to atomic
capable ones. I spent a good time trying to figure out how to test
that atomic part but I was unsuccessful. Of course, I could do like all
the other functions I decided to not test and put another in its place,
but that in specific would be a good function to test, so I spend a good
time trying it instead, but when I figured out that I wasn't capable of
do it, it was too late to try testing another one.

# Acknowledgments
I would like to thanks a lot the support I had from my mentors
[Tony](https://andrealmeid.com/), [Maíra](https://mairacanal.github.io/)
and [Tales](https://tales-aparecida.github.io/). They played a very
important role guiding me through that project and I'm very grateful
for all the help I get. I would also like to thanks my colleague
[Grillo](https://grillo-0.github.io/blog/) for all his companionship
and help.

Moreover, I would like to thank the X.org foundation for accepting
and funding the project, without this it would be impossible to me to
dedicate myself exclusively to a free software project.

---
title: Fighting the event loop for speed
description: Analyzing the different methods for running lots of functions fast, while not completely taking up the event loop to allow for rendering.
date: 2020-03-16
layout: layouts/post.njk
---

Recently I started work on a Chip8 emulator and needed to get a screen setup for it.
For this I used a jJavaScriptcanvas, but this caused a problem once I started implementing redraws to the screen.
Previously I just had CPU executions inside of a while loop which only stopped once the CPU switched the halted boolean on.
This meant the event loop was full until the machine halted, and it would only get around to rendering the screen once the program had halted.
This meant that simple games or counters that went on forever would never render.

My first idea was to use setTimeouts with a wait time of 0, with each non-halting CPU cycle spawning another setTimeout.
This seemed promising at first but once I started testing more than a couple lines of machine code I realized this method was actually fairly slow.
To test the speed I wrote a quick [codepen](https://codepen.io/herohamp/pen/jOPxpYL), which showed that only about 220 setTimeouts were being called a second while I was in Brave (Chromium based) and a ppitiful37 a second while in Suckless' Surf browser.
These numbers made more sense after I found a [post by Yehonathan Sharvit](https://blog.klipse.tech/javascript/2016/10/31/setTimeout-0msec.html) which claimed that setTimeouts had a minimum time of 4ms.
His post also introduced me to the use of postMessage to ccontinuouslyrun a function while leaving time for rendering.
This method seemed to work in the short term, but as I started to make programs that ran for longer than a couple seconds I noticed that there seemed to be a stutter every few seconds that lasted up to a full second.
Sadly it seemed that postMessage also was not up to the task.

I looked around more and could not find anything up to the task, MessageChannel looked promising but also had the same issue that postMessage had.
It was at this point I started to get desperate and creative when looking for a solution.
It was then I realized that I could batch executions recursively then call a setTimeout of 0 every X calls.
Once this was implemented I saw animmediatet improvement, running a [quick test](https://codepen.io/herohamp/pen/eYNrjXP) showed I was getting 20k executions a second on my test function, and with my actual program the visuals were still updating in realtime while allowing for fast execution.

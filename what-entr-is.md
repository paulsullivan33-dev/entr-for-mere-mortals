# What Entr Is

Every programmer knows this dance. You
change a line in a file. You save. You
switch to a terminal, press the up arrow,
press Enter, and watch your test — or your
build, or your program — run again. You
read the result, switch back, change
another line, and do the whole dance
again. A hundred times a day, the machine
sits idle waiting for you to tell it the
one thing it could have noticed itself:
*the file changed.*

**entr is the program that notices.** Its
full name is the **Event Notify Test
Runner**, and the name is the whole idea.
You give entr two things: a list of files,
and a command. entr watches the files.
Every time one of them changes, entr runs
the command. Save in your editor, and the
test runs — not because you asked again,
but because the save *was* the asking.

```bash
ls *.py | entr python3 -m pytest
```

That one line is most of entr. The list of
files arrives on entr's **standard input**
(the pipe from `ls`), and everything after
the options is the command to run. Chapter
4 takes a first watch apart slowly; this
chapter is about the shape of the idea and
the one rule that comes with it.

## A lookout, not a clock

It helps to place entr next to a tool it
is *not*. **cron** runs commands when the
clock says so: every hour, at midnight, on
Mondays. entr runs a command when the
*world* says so: a file under watch was
just saved. Neither is better; they answer
different questions. cron's question is
*how long since it last ran?* entr's
question is *did anything change?*

Underneath, entr does not check the files
over and over like a nervous guard walking
a fence line. It asks the **operating
system** to keep watch — the Linux
**inotify** service, or **kqueue** on the
BSDs and macOS — and the system wakes entr
the moment a watched file is touched.
That is why entr can sit open all day on a
laptop and use, between saves, no
measurable processor at all. Chapter 2
opens this up; the kernel's event messages
can even be watched directly (transcript
`entr-lab/transcripts/t09-event-trace.txt`).

## The rule, stated before everything else

entr is a tame tool compared to most in
this series: it watches your own files and
runs your own commands. It still deserves
one rule, stated plainly, because the
specific way entr can hurt you is easy to
miss:

> **entr runs the command you gave it,
> unattended, on every save — including
> the saves you make halfway through a
> thought.**

A test command is harmless. A command that
deletes, overwrites or publishes is not,
and entr will run it faithfully at the
worst moment: while the file it operates
on is half-edited and wrong. So rehearse
every entr command once by hand, on
practice files, before you let it run on
its own. Be doubly careful with the
restart mode of chapter 6, which kills and
restarts a real program on each save: the
program being restarted should be one that
can afford to die at any moment, and never
the only copy of anything that matters.
The lab in this guide obeyed the rule
throughout: every command entr ran touched
only files the lab had invented for the
purpose.

## A first taste

The lab watched one small text file and
counted its lines on every save
(transcript `entr-lab/transcripts/t01-first-watch.txt`):

```text
$ echo notes.txt | entr -n sh -c 'echo "run at $(date +%T) -- notes.txt has $(wc -l < notes.txt) lines"'
run at 11:17:05 -- notes.txt has 4 lines
run at 11:17:07 -- notes.txt has 5 lines
run at 11:17:09 -- notes.txt has 6 lines
```

Three runs: one the moment entr started
(the command always runs once at startup,
unless you postpone it with `-p`), then
one for each line appended in another
window. Check: the line counts rise by
exactly one per save, and the timestamps
sit two seconds apart because the lab's
saves were two seconds apart — cause and
effect, with nothing in between.

## Who it is for

The developer in the edit-run-read loop,
whatever the language: tests, builds,
document renders, style checks, a server
that needs restarting. The writer whose
manuscript is plain text and whose
"build" is joining chapters together (the
lab's second fixture, from chapter 5). The
system administrator who wants a service
reloaded when its configuration file
changes, on a machine they are sitting at.
The common thread is one person, a folder
of files, and a command they are tired of
typing.

## What it is not

entr is not a **build system**: it does
not know which outputs depend on which
inputs, it just runs the whole command
every time (pair it with `make`, which
does know — chapter 11). It is not a
service manager: its restart mode is a
developer's convenience, not supervision
with logging and policy (that is systemd's
country, and there is a guide in this
series for it). It is not a backup or
synchronisation tool: it notices changes
but keeps no copies. And it is not a
daemon that watches a whole machine:
entr watches the list you handed it, in
the terminal you started it in, until you
stop it. Within those borders it is very
good at its one job.

# The Moving Parts

entr is a small program — one file of C,
a few thousand lines — but it has four
distinct parts, and most confusion about
entr is really confusion about which part
you are talking to. This chapter names
them, so that later chapters can say "the
list" or "the runner" and mean something
exact.

## The list

entr reads its **list of files to watch**
from standard input, once, at startup:

```bash
find drafts -name '*.md' | entr ./build.sh
```

Whatever prints filenames, one per line,
can feed it: `ls`, `find`, `git ls-files`,
a list typed into a file and redirected
in. Three facts about the list explain a
great deal of entr's behaviour:

- **It is a snapshot.** The list is read
  once and never refreshed. A file created
  after entr starts is not on it and will
  never be watched by that run of entr.
  Chapter 7 is entirely about this fact
  and the `-d` option that works around
  it.
- **Every name must exist.** entr checks
  each file at startup; a name it cannot
  examine is refused with an error
  (transcript
  `entr-lab/transcripts/t00-version-and-errors.txt`):

  ```text
  entr: unable to stat 'missing.txt'
  entr: No regular files to watch
  ```

- **Order matters, a little.** The first
  file on the list is the default answer
  when entr needs "the file that changed"
  and none has yet (see the `/_` marker in
  chapter 5).

Directories on the list are refused —
entr watches *files* — unless the `-d`
option of chapter 7 turns directory
membership into a signal of its own.

## The watcher

The **watcher** is entr's connection to
the operating system's file-event service:
**inotify** on Linux, **kqueue** on macOS
and the BSDs. entr registers every file on
its list with that service, then sleeps.
When a watched file is written, closed,
moved or touched, the system hands entr an
**event** naming the file. No polling, no
repeated checking: between events entr is
doing literally nothing, which you can
confirm with any process viewer — it will
show entr asleep at 0% processor, however
many files it watches.

You can watch the watcher. Setting the
environment variable **EV_TRACE** makes
entr print each event as it arrives
(transcript
`entr-lab/transcripts/t09-event-trace.txt`):

```text
$ echo notes.txt | EV_TRACE=1 entr -np echo 'notes changed'
open_max: 63753
0/1: fflags: 0x8 r 100660 notes.txt
0/1: fflags: 0x2 r 100660 notes.txt
```

The numbers are the kernel's event codes
(the exact values differ between Linux and
the BSDs — the shape of the thing does
not), and the first line reports how many
files this machine would let one process
hold open. Chapter 13 returns to EV_TRACE
as a diagnostic: if events arrive but the
command misbehaves, the watcher is fine
and the fault is downstream.

## The runner

The **runner** is what happens after an
event. entr starts the command, and then —
this is the part people trip over — **it
waits for the command to finish before it
responds to further events**. A test suite
that takes twenty seconds will not be
started five times because you saved five
times in those twenty seconds. Events
that arrive *while* a command is running
are **consolidated**: folded together, so
that at most they cause one further run
afterwards — and, by design, a change the
command itself makes to a watched file
while it runs is folded away entirely,
which is entr's protection against a
command retriggering itself forever.

The `-a` option turns that protection
off: *respond to all events*, including
those that arrive mid-run. Chapter 12
shows the two settings side by side on a
command that edits its own watched file —
one run in four seconds without `-a`,
seventy-three with it — and explains when
anyone would accept that bargain.

In restart mode (`-r`, chapter 6) the
runner changes character: the command is
a long-running program, and on each event
entr terminates it — with **SIGTERM**, the
polite "please stop" signal — waits for
it to actually die, and only then starts
it again.

## The terminal

entr is an interactive tool and it talks
to your **terminal** directly. It reads
single keys while it watches: **space**
means "run the command now" and **q**
means quit (chapter 9 demonstrates both).
It also tidies up after interactive
commands, and sets the environment
variable `PAGER` to `/bin/cat` by default
so that a command which pages its output
does not stop dead waiting for keys nobody
can type.

Because it insists on a real terminal,
entr refuses to start in places that do
not have one — scripts, pipelines, this
guide's test harness — with a message that
names the remedy:

```text
entr: unable to get terminal attributes, use '-n' to run non-interactively
```

The `-n` option waives the terminal: no
keys are read, and entr becomes safe to
run from scripts. Several of the lab's
transcripts were captured that way, and
each says so; everything else in the guide
behaves identically in both modes.

## The contract

Two small things complete the picture, and
both are promises you can build on:

- **The `/_` marker.** If one of the
  command's arguments is exactly `/_`,
  entr replaces it with the absolute path
  of the file that triggered the run.
  Chapter 5 builds on this.
- **Exit statuses.** entr itself exits
  with **0** when you stop it (Ctrl-C or
  `q`), **1** when something was wrong
  with the watch (no usable files, a
  watched file deleted outright), and
  **2** when a directory watch (`-d`)
  noticed a new file. The `-z` option of
  chapter 6 adds one more: run once and
  hand back the *command's* exit status as
  entr's own.

With the four parts named — list, watcher,
runner, terminal — the rest of the guide
is just putting each of them to work.

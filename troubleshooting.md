# Troubleshooting

Work through these in the order given for
your symptom. Every entry starts from
something entr actually prints — or
conspicuously does not — and every cause
named here is one the lab produced on
purpose or met on the way. The diagnostic
instruments are three: the error line
itself, **EV_TRACE** (chapter 2), which
shows whether events are arriving at all,
and the exit status (chapter 2's contract:
0 planned, 1 broken, 2 directory altered).

## "unable to get terminal attributes"

```text
entr: unable to get terminal attributes, use '-n' to run non-interactively
```

entr started somewhere with no terminal —
a script, a pipeline, an editor's shell
window — and stopped rather than guess.
The message names the cure: add `-n`.
You give up the space bar and `q`
(chapter 9); everything else is the same.
In an actual terminal this message does
not appear.

## "No regular files to watch", "unable to stat"

The list let entr down: it was empty, or
every name on it failed to resolve. Causes
in order of likelihood: you are in the
wrong directory (the names are relative,
and they are relative to *here*); the
left-hand side of the pipe printed
nothing — run it alone and look; or a
name contains a space and your list-builder
did not survive it. entr prints
`unable to stat 'name'` for each failure
before the summary line, so the guilty
name is always named.

## It runs once and never again

First, forgive it: that is `-p` and `-z`
doing their documented jobs, if either
flag is present. Without them, check in
this order:

1. **Is the file you are saving the file
   on the list?** Print the list (run its
   left-hand side alone). Editors that
   open a *copy* — or a symlink's target
   while entr holds the link's path, or
   the other way round — are the standing
   cause. Save the exact path entr was
   given and watch it work.
2. **Are events arriving?** Restart with
   `EV_TRACE=1` and save. Event lines
   mean the watcher is healthy and the
   command is the problem (see the next
   section). Silence means the kernel is
   not being told — on a network
   filesystem, chapter 12's limit may be
   the whole explanation.
3. **Did the file get deleted outright?**
   If the save method removes the file
   before rewriting it, the watch ended
   at the first such save, with
   `cannot open` and exit status 1
   (transcript t90). Rename-replacement
   saves are fine; delete-and-recreate is
   not. The chapter 7 loop is the standing
   remedy.

## It runs constantly, or far too often

The command is touching something on its
own list — its output file, its log, a
generated source — or a neighbour process
is. Read the list, read the command, and
find the overlap; chapter 12's
self-trigger trap (one run in four
seconds by default, seventy-three with
`-a`) is this symptom photographed. If
`-a` is set, taking it off is very likely
the entire fix. If the triggers are real
but trivial — a timestamp file some other
tool keeps touching — removing that one
name from the list is the fix, and it can
only be done by choosing the list more
carefully; entr has no ignore list of its
own beyond what builds the list (a `find`
with exclusions is the usual tool).

## "exec ... No such file or directory"

entr tried to run a program and the
program does not exist *under that exact
name*. If the named thing is a whole
sentence — `exec wc -w drafts/*.md |
head -n 1` in transcript t06 — you meant
shell syntax, and the fix is `-s` or an
`sh -c` wrapper (chapter 8). If the name
is short and real, the program is not on
the PATH entr inherited from where it was
started; entr reads no shell startup
files, so aliases and functions from your
interactive shell do not exist for it.
Give the path, or a script that has it.

## The restarted program will not die, or dies wrong

In `-r` mode entr sends SIGTERM and waits
(chapter 6). A program that ignores
SIGTERM, or a wrapper script that fails
to pass it down, will hold the restart
up until it exits by other means; entr
runs the command in its own process
group to make the signal hard to lose,
so the surviving cause is usually a
program that catches the signal and
carries on deliberately — a behaviour to
fix in the program, or to test with the
chapter's ticker before believing it of
entr. And remember the asymmetry: if the
program exits *on its own*, entr does not
restart it until the next event or a
press of the space bar. A quiet screen
after a crash is information, not a
malfunction.

## Exit status 2, and the watch "ended by itself"

That is `-d` succeeding, not failing: a
new file appeared, entr reported
`directory altered` and stepped aside
(chapter 7). If nobody respawns it — a
loop, a script — the watch is over. Run
without `-d` if arrivals are none of your
concern, or adopt the loop if they are.

## When the trail runs out

`man entr` is short, complete and
unusually honest about defaults; the
project's site keeps the release history
that dates every option. And EV_TRACE
remains the deepest instrument entr
offers: a watch that shows its events has
very few places left to hide.

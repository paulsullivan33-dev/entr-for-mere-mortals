# Limits

entr is one small tool with clean edges,
and this chapter collects the edges in one
place. Everything here is either visible
in the lab's transcripts or a documented
property of the machinery entr stands on;
the two kinds are marked as they come.

## The list is the limit

entr watches the files it was **given at
startup**, and nothing else, ever, for
the life of that run. It does not watch
directories for their contents (chapter 7's
`-d` watches them for *arrivals*, which is
different), it does not follow the output
of a command that would have printed a
longer list later, and it does not
discover. Every gap in coverage is a gap
in the list, and the cure is always the
same: a better list, or a respawn with a
fresh one.

## A deleted file ends the watch

Editors that save by **renaming** a new
file over the old one are handled
gracefully — entr follows the name, and
the watch survives save after save
(transcript
`entr-lab/transcripts/t90-traps.txt`):

```text
run at 11:22:52 -- notes.txt now has 2 lines
run at 11:22:54 -- notes.txt now has 3 lines
```

But a watched file deleted **outright**
— removed, with nothing put back in the
same motion — ends the story:

```text
entr: cannot open 'notes.txt': No such file or directory
```

entr exits with status 1, and recreating
the file does not revive it. The
distinction is real and worth internalising:
replacement is a change of *contents* at a
path; deletion is the path itself going
away, and entr was holding the path. If
your workflow deletes and recreates its
inputs — some generators do — wrap entr
in the chapter 7 loop, which respawns it
with a fresh list as a matter of routine.

## Events are not differences

entr knows *that* a file changed. It does
not know *what* changed, and cannot be
taught: there is no way to say "run only
if the third line changed," "ignore
whitespace-only saves," or "skip the save
where I only fixed a comment." The kernel
reports events; entr passes them on. Any
selectivity beyond *which file* must live
inside the command — and chapter 10's
recipes lean on that, letting `make`'s
timestamps or the test suite's own focus
flags do the discriminating.

## While a command runs, the world is folded

By design (chapter 2), events that arrive
**while the command is running** are
consolidated, and a change the command
makes to a watched file during its own
run is not allowed to retrigger it. The
lab measured the bargain on a command
that appends to its own watched file
(transcript t90): in a four-second window
the default settings ran it **once**; the
same watch with `-a` ran it **seventy-three
times**, each append queuing the next run.

The limit cuts both ways, and honesty
requires both edges. Without `-a`, a
genuine save made in the middle of a long
test run does not get a run of its own —
it is folded into, at most, one run
afterwards, and a change the *command*
made and a change *you* made during the
same run are folded together. With `-a`,
every event is sacred, including the ones
that make a command chase its own tail
at seventy-three runs per four seconds.
Choose per watch, and know that the
default's prejudice — fewer runs, never
a loop — is the one most afternoons want.

## The command is a guest, with a guest's rights

entr runs one command at a time, waits
for it, and starts nothing in parallel.
There is no queue of pending work beyond
that one folded run, no record kept of
past runs, no log unless the command
keeps its own. Watching is also confined
to what **this machine's kernel can see**:
files on network filesystems whose
changes are made by *other* machines may
never produce a local event at all —
that is a property of inotify and kqueue
themselves (described here from their
documentation, not from a lab run), and
no setting in entr reaches around it.

## Scale, and the edge of the list

A list can hold a great many files — the
lab's trace reported a per-process open
limit of 63,753 — but the kernel's own
watch limits and your sanity both argue
for lists that name a *project*, not a
*drive*. entr watching an entire home
folder is entr starting your test suite
because a browser wrote a cache file.

And the meta-limit that contains the
others: entr is a developer's tool, run
by a person, in a terminal. It has no
users, no permissions of its own, no
notion of a service that must never be
down. Where those begin, chapter 11's
systemd path units and real supervision
begin — entr's honest work is finished
well before that border.

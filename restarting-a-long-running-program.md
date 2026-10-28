# Restarting a Long-Running Program

Half the commands entr is asked to run are
not one-shot jobs like tests and builds.
They are programs that are supposed to
*stay running* — a development web server,
a worker, a preview of a site — and the
developer's loop with those is not
*run it again* but *restart it so it picks
up my change*. Doing that by hand, dozens
of times a day, is the oldest chore in
programming. The `-r` option is entr's
answer: **reload mode**.

The outcome of this chapter: a program
that restarts itself, provably, on every
change to its configuration — and a clear
idea of what entr does to the old copy on
its way out.

## The practice program

The lab's `ticker.sh` is a stand-in for a
server, twenty seconds of shell standing
in for twenty thousand lines of anything:
when it starts it announces its **process
id** — its unique number among running
programs — and every two seconds it prints
a heartbeat line, so that in a transcript
you can *see* whether the program ticking
in front of you is the same individual you
started with, or a replacement:

```text
ticker started: pid 67632 at 11:17:39
  heartbeat from pid 67632 at 11:17:41
```

The watch is over the ticker's
configuration file, `settings.conf`:

```bash
echo settings.conf | entr -r ./ticker.sh
```

(The lab's harness adds `-n`; in a
terminal it is not needed.) entr starts
the ticker immediately, and then the
transcript
(`entr-lab/transcripts/t03-restart.txt`)
unfolds:

```text
ticker started: pid 67632 at 11:17:39
  heartbeat from pid 67632 at 11:17:41
  heartbeat from pid 67632 at 11:17:43
ticker started: pid 67979 at 11:17:44
  heartbeat from pid 67979 at 11:17:46
  heartbeat from pid 67979 at 11:17:48
ticker started: pid 68092 at 11:17:49
  heartbeat from pid 68092 at 11:17:51
```

Check: three different process ids —
67632, 67979, 68092 — means three
different programs lived here, one after
another, and each change to
`settings.conf` (there were two, a second
or so before the :44 and :49 restarts)
retired one and started the next. The
heartbeats never overlap: at every moment
exactly one ticker is alive.

## What entr does to the old copy

The handover is deliberate, and its order
matters to real programs:

1. entr sends the running program
   **SIGTERM**, the conventional "shut
   down now, tidily" signal. A program
   that handles it can close its files and
   its network sockets properly.
2. entr **waits for the program to
   actually exit**. It does not start the
   replacement alongside the original —
   which is why the transcript's
   heartbeats dovetail instead of
   overlapping, and why a restarted server
   can re-open the same network port
   without finding it still occupied.
3. Only then is the new copy started.

To make sure signals reach the whole
program and not just its front door, entr
runs the command in its own **process
group** — so a shell script that launches
helpers cannot mask the termination by
being merely a wrapper. And if the program
ends on its own — crashing, or finishing —
entr does not restart it unbidden: it
waits, and the next change (or a press of
the space bar, chapter 9) is what brings
it back. A repeatedly crashing program
therefore sits visibly dead rather than
spinning, which is the correct editorial
comment on its condition.

## The `-z` companion: run once, then stop

A small relative of reload mode deserves
introducing here. The **`-z`** flag tells
entr to exit right after the command's
next completion, and to hand the
*command's* exit status back as entr's
own. Combined with a watch, it turns entr
into a patient one-shot trigger: *wait
until this file changes, run this once,
tell me how it went.* Transcript
`entr-lab/transcripts/t08-one-shot.txt`:

```text
one-shot run at 11:17:34
entr exit status: 3
```

The command was written to exit with
status 3, and 3 is what entr's caller
received — a script wrapping entr can
therefore act on the result of a run it
waited for. With `-r` and `-z` together,
a long-running program is restarted on
each change but entr steps aside for good
if the program is stopped by a command or
signal rather than by the watcher.

## The rehearsal rule, again

Everything chapter 1 said applies with
interest here. A restarted program is a
*killed* program, possibly mid-write,
mid-transaction, mid-thought. Development
servers are built to survive it; not
everything is. Restart your own
experiments freely, rehearse on the
practice program first, and let real
supervision — systemd and its restart
policies — carry the programs whose
deaths would matter.

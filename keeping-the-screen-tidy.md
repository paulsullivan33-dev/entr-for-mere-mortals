# Keeping the Screen Tidy

A watcher that runs your tests fifty
times an afternoon produces fifty runs of
output, stacked in the terminal like
pages of a long printout. Finding "the
latest run" in that pile — and being sure
which lines belong to it — becomes the
actual work. This chapter collects entr's
three answers to the mess: clearing the
screen so the latest run is the only run,
driving the watcher from the keyboard,
and dressing its exit lines in words.
None of them changes what entr *does*;
all of them change what a long afternoon
with it feels like.

## `-c`: a clean screen for every run

The `-c` option **clears the terminal
before each run**. Trigger a run, by
saving or by the space bar, and the
previous output is wiped away before the
new output lands: the screen always shows
exactly one run, the current one, from
its first line. A failure can no longer
hide three runs up, and "did it pass
*this* time" stops being a scrolling
question.

Specify `-c` twice (`-cc`) and entr also
erases the terminal's **scrollback
buffer** — the history you could otherwise
scroll up into — so the old runs are not
merely off-screen but gone. The lab
recorded the actual bytes this sends
(transcript
`entr-lab/transcripts/t05-clear-screen.txt`),
shown with control characters visible:

```text
^[[2J^[[3J^[[HRUN at 11:20:35
^[[2J^[[3J^[[HRUN at 11:20:37
^[[2J^[[3J^[[HRUN at 11:20:39
```

Before every single run: erase the
visible screen (`^[[2J`), erase the
scrollback (`^[[3J`, the twice-specified
addition), park the cursor at the top
(`^[[H`), and only then let the command
speak. Three runs in the capture, three
identical prefaces — check: the clearing
belongs to the run, startup included.

One honest cost: a cleared screen keeps
no evidence. When a run's output is
something you will want later — a stack
trace from the run before the fix — let
the command write it to a file as well,
or skip `-c` for that watch.

## The keyboard: space and q

While entr watches in a terminal, two
keys are live, and a long watch is much
pleasanter for knowing them:

- **Space** runs the command *now*, with
  no file change at all — the manual way
  to say "again." In restart mode (chapter
  6) space performs the full termination
  and restart, exactly as a save would.
- **q** quits, at once and silently —
  tidier than reaching for Ctrl-C, and
  the same exit status 0.

Transcript `entr-lab/transcripts/t07-keyboard.txt`
shows all three causes of a run in one
sitting: startup, a save, and a space:

```text
RUN at 11:20:42 -- 1 lines
RUN at 11:20:44 -- 2 lines
RUN at 11:20:46 -- 2 lines
```

The second and third runs both report 2
lines, and that unchanging number *is*
the evidence: between them nothing was
saved, so the third run can only have
been the space bar's doing. Then `q`
ended the session without another line.

## `-x`: exit lines in words

When a watched command fails, entr knows
how it failed but normally leaves the
evidence scattered in the command's own
output. The `-x` option adds one tidy
line per run, formatted by a small
**awk script** — the status filter — so
*"the command ran"* is always followed by
*"…and here is how it ended."* The script
lives at a path named by the environment
variable **ENTR_STATUS_SCRIPT** (default
`~/.entr/status.awk`); if it does not
exist, entr creates an example for you on
first use.

Transcript `entr-lab/transcripts/t10-status-messages.txt`,
whose command deliberately exits with
status 7:

```text
run at 11:24:29
sh returned exit code 7
```

The second line is the example filter's
work: entr fed it the raw facts (*exit*,
*7*, *sh*) and it answered in words. The
filter is yours to edit — the file is a
handful of awk patterns — so a team can
make failures shout in its own format.
Two cautions, both from the manual and
both sensible: by default the filter may
not use shell commands or redirection
(give `-x` twice to permit them, which
turns the filter into a small program
that runs on every exit — treat it with
the respect that implies); and `-x` is
the newest option in the guide, added in
release 5.6, so older packages will not
know it (chapter 3's version check).

## And `-n`, one more time

Everything in this chapter except the
keyboard needs no terminal decisions, but
the keyboard needs a terminal to exist.
In `-n` mode — scripts, CI jobs, this
guide's own captures — the keys simply do
not apply, and `-c` writes its clearing
bytes to whatever the output is connected
to, which in a log file looks like
rubbish. The tidy screen is a
sitting-at-the-machine pleasure; let
scripts have the plain firehose.

# Your First Watch

This chapter takes one file, one command,
and one save, and pulls the moment apart
until there is nothing left in it you have
not seen. The outcome: by the end you can
start a watch, predict exactly when the
command will run, and stop it cleanly.

The lab's practice file is `entr-lab/
notes.txt`, a four-line notebook:

```text
Field notes
-----------
charged the spare battery
checked the tyre pressure
```

Any text file of your own will do as well;
nothing in this chapter depends on the
contents.

## The smallest useful command

```bash
echo notes.txt | entr sh -c 'echo "run at $(date +%T) -- notes.txt has $(wc -l < notes.txt) lines"'
```

Read it left to right, in the order entr
itself experiences it:

1. `echo notes.txt` prints one filename.
   That is the whole **list** — chapter 2's
   snapshot, containing a single name.
2. The pipe hands the list to entr on its
   standard input.
3. Everything after `entr` is the
   **command**: here, `sh -c '...'` — a
   shell asked to run one small script
   that prints the time and counts the
   file's lines. (A shell wrapper is
   needed because the command contains
   shell machinery — quotes, `$(...)` —
   and entr runs programs directly, without
   a shell of its own. Chapter 8 is about
   exactly this, and about the `-s` option
   that folds the wrapper into entr.)
4. entr checks that `notes.txt` exists,
   registers it with the operating
   system's watcher, runs the command once,
   and waits.

In a real terminal, that is all there is
to type. (The lab's transcript was
captured by a script, which has no
terminal, so it carries the extra `-n`
flag from chapter 2 — the command, the
runs and the timing are identical.)

## What happens, in order

Transcript `entr-lab/transcripts/t01-first-watch.txt`,
with the lab's saves made from a script two
seconds apart so the timing is easy to
read:

```text
run at 11:17:05 -- notes.txt has 4 lines
run at 11:17:07 -- notes.txt has 5 lines
run at 11:17:09 -- notes.txt has 6 lines
```

Three runs, and each has a distinct cause
worth being able to name:

- **11:17:05 — the startup run.** entr
  always runs the command once, the moment
  the watch begins, before any change.
  This surprises everyone exactly once.
  It is there so you can see the command
  works — a broken command fails in front
  of you, not silently at the first save —
  and it can be postponed with the `-p`
  flag (chapter 5 uses it) when an
  immediate run would be wasteful or
  meaningless.
- **11:17:07 — the first save.** A line
  was appended to `notes.txt`; the watcher
  woke, and the command ran and reported
  the new count, 5.
- **11:17:09 — the second save.** Another
  line; another run; 6.

Check: your own first watch should behave
identically — one run before you touch
anything, then one run per save, and no
runs at all while the file sits still.
If the counts in your version do not rise
by exactly the lines you added, chapter 13
has a diagnostic order for finding out
why.

## Stopping, and what stopping means

**Ctrl-C** stops the watcher (so does
pressing `q` in a terminal — chapter 9).
entr exits with status **0**, its way of
saying *this ending was the plan*. Nothing
is left running: entr starts no background
helpers, and the command it runs belongs
to the moment of the run and is gone.

One thing the first watch quietly teaches:
entr does not care *what* changed in the
file, only *that* it changed. The run at
11:17:07 would have happened for a typo
fix or a deleted paragraph just as surely
as for an appended line. entr trades in
events, not differences — a limit chapter
12 states plainly, and a freedom as well:
the command can be anything, because entr
asks nothing of it except that it runs.

The natural next step is a longer list:
every file in a small project, and a
command that knows *which* file changed.
That is chapter 5.

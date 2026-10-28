# Shell Commands and Pipelines

Sooner or later every entr user types the
command they *mean* — and watches entr
refuse it:

```bash
ls *.py | entr pytest -q | tee results.txt
```

Some of that line works (the pipe into
entr is real). The pipe *after* the
command is not — or rather, it belongs to
the shell's reading of the whole line, so
`tee` receives entr's own output, not a
fresh run's… and a pipeline *inside* the
command, quoted as one string, fails
outright. This chapter is about where
entr's edges are: entr runs **one program,
directly, with no shell involved**, and
everything in this chapter follows from
that sentence. The outcome: you can give
entr any command, however much shell it
needs, and know which of the three ways
of doing so you are using.

## Way one: a program and its arguments

The default. Everything after the options
is a program name followed by argument
words, exactly as the shell split them:

```bash
echo report.sql | entr -cp psql -f /_
```

That example is the manual's own, and it
is complete: program `psql`, arguments
`-f` and the `/_` marker. No quotes to
fight, no shell to misread anything. Most
entr commands in the world look like
this, and should.

What the default cannot express is a
command that is itself shell *syntax* —
a pipeline, a redirection, an `&&`. Hand
entr such a thing as one quoted string
and it takes you literally, looking for a
program whose name is the whole string.
Transcript `entr-lab/transcripts/t06-shell-mode.txt`
catches it doing so:

```text
$ ls drafts/*.md | entr -n 'wc -w drafts/*.md | head -n 1'
entr: exec wc -w drafts/*.md | head -n 1: No such file or directory
```

Note entr's character in defeat: it
reports the failed start and **keeps
watching**, ready to fail again identically
at the next save, forever. The error is
clear once you know entr tried to *exec*
the string as a name — which is the tell
to look for in chapter 13.

## Way two: ask a shell explicitly

The wrapper you have already met:

```bash
... | entr sh -c 'make test | head -n 20'
```

`sh -c` *is* a program — one whose job is
interpreting shell syntax — so the
default mechanism carries it without
complaint, and pipelines, redirections
and `$(...)` inside the quotes are the
shell's business again. The costs are the
usual quoting costs: the whole command is
a single string your *outer* shell must
not chew on, hence the single quotes, and
inside it, strings within strings get
fiddly. For a one-line incantation it is
perfect; for a paragraph, write a script
file and have entr run that.

## Way three: `-s`, entr's own shell mode

The `-s` flag folds way two into entr:
the first argument is handed to a shell
to evaluate, as a complete command line:

```bash
find drafts -name '*.md' | entr -s 'cat drafts/*.md | wc -w'
```

The shell used is the one named by your
**SHELL** environment variable
(`/bin/sh` if unset), so the syntax that
works is your own shell's. Two things
`-s` adds beyond the wrapper:

- **The changed file arrives as `$0`.**
  In shell mode the `/_` argument has a
  sibling: the name of the first file to
  trigger the run is placed in the shell's
  `$0`, readable inside the command
  string. The lab used it to label its
  pipeline's output:

  ```text
  $ find drafts -name '*.md' | entr -snp 'echo "changed file: ${0##*/}"; cat drafts/*.md | wc -w'
  changed file: chapter-three.md
  76
  ```

  (`${0##*/}` is the shell's own trimming
  of the path down to its last component;
  `$0` itself held the full path, as `/_`
  would have. The word count, 76, is the
  three chapters plus the line that had
  just been added to chapter three.)

- **A terminated child is reported.** In
  shell mode entr prints the signal if
  the command is killed by one — a small
  honesty that matters when the command
  is a pipeline whose far end died.

## Choosing

Prefer way one whenever the command fits
it — no quoting, no shell, nothing to
misread. Reach for `-s` when you catch
yourself wanting a pipe or a redirection
*inside* the watched command, which in
practice is often. Keep `sh -c` for
commands you are pasting into places
where flags are awkward, and for the
occasional incantation that must name
its shell explicitly. All three run the
command the same way once it starts; the
difference is entirely in who parses the
words.

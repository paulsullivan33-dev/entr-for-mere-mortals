# Feeding Entr a File List

One file is a fine first watch, but real
work lives in folders: every source file
of a program, every chapter of a draft,
every configuration file of a service.
This chapter is about building the list —
with `find`, `ls` or `git` — and about the
`/_` marker, which tells the command
*which* file changed. The outcome: a
watch over a whole small project, whose
builds are provoked by, and labelled with,
the file that caused them.

The lab's project is a short story in
three markdown chapters, `entr-lab/
drafts/chapter-one.md` and its siblings,
and a build script, `entr-lab/build.sh`,
which joins the chapters into one file
and counts the words — a build in
everything but seriousness.

## Building the list

Since the list is just filenames on
standard input, every tool that finds
files is an entr tool:

```bash
ls *.py | entr ...              # the shell's wildcards
find drafts -name '*.md' | entr ...   # find's tests
git ls-files | entr ...         # every file git tracks
find . -name '*.c' -o -name '*.h' | entr ...
cat my-files.txt | entr ...     # a list you keep
```

`git ls-files` deserves its reputation
here: the list it prints — tracked files,
nothing else — is very often exactly the
list a developer means by "my project."
Each recipe has its own trap: wildcards
are expanded by the shell *before* entr
starts, so a file created later with the
right suffix is still not on the list;
`find` prints directories too if you let
it, and entr will refuse the directories
and complain. Test any list by running
the left-hand side of the pipe alone
first, and reading what it prints. That
printed list, no more and no less, is
what entr will watch.

## `/_`: the file that changed

A command run for "something in the
project changed" usually wants to know
*what*. entr offers the **placeholder**
`/_` (slash-underscore): if one of the
command's arguments is exactly `/_`, entr
replaces it, at each run, with the
**absolute path of the first file that
triggered that run**. Before any change
has happened — for the startup run — the
first file on the list stands in.

The lab's build uses it directly:

```bash
find drafts -name '*.md' | entr -np ./build.sh /_
```

`build.sh` receives the changed file as
its first argument (`$1`) and prints it,
so every build in the transcript is
labelled with its cause. The `-p` flag
postpones the startup run — pointless for
a build nobody has provoked yet — so the
transcript shows only earned builds.

Transcript `entr-lab/transcripts/t02-file-list.txt`:

```text
build at 11:17:31 -- triggered by: drafts/chapter-two.md
combined.md now holds 77 words
build at 11:17:32 -- triggered by: drafts/chapter-one.md
combined.md now holds 82 words
```

(The script trims the working folder's
prefix off the path for display; what
entr handed it was the full absolute
path.) Check: two edits, to two different
files, produced two builds, each naming
the file that was edited. The word counts
audit the whole story — the three
chapters held 71 words between them; the
first edit added a six-word sentence and
the count became 77; the second added
five words and it became 82. Nothing
rebuilt while nothing was changing, and
nothing rebuilt twice.

## Two disciplines the list teaches

**Keep the output off the list.** The
build writes `combined.md` into the
project folder — but the list contains
only `drafts/*.md`, so the build's own
output cannot trigger the next build.
This is the simplest form of the rule
from chapter 1, and chapter 12 shows the
alternative: a command that rewrites a
file it watches, and what entr's
consolidation does and does not save you
from.

**The list forgives nothing at startup.**
A misspelt filename is not skipped
quietly; entr refuses it
(`unable to stat`, chapter 3) and, if no
usable files remain, declines to run at
all. Annoying once, valuable forever:
a watch that is silently watching the
wrong file is worse than no watch.

What the list still cannot do is grow.
A fourth chapter, created tomorrow, is
invisible to today's watch — chapter 7
takes that on. First, chapter 6 gives the
command something harder to do than a
build: staying alive.

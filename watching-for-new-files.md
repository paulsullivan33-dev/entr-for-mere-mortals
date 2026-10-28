# Watching for New Files

Chapter 2 stated the awkward fact plainly:
the list is a **snapshot**, read once at
startup. A file that does not exist when
entr starts can never join the watch —
and real projects grow new files all the
time. A new chapter, a new source file, a
new test: if entr cannot see them, the
developer must remember to restart the
watcher at exactly the moment they are
least likely to remember anything.

The **`-d` option** — *directory watch* —
is entr's negotiated settlement with this
fact. It cannot add the new file to the
list. Instead, it treats the *arrival* of
a new file as an event important enough
to stop for.

The outcome of this chapter: a watcher
that notices a new file in a watched
folder, tells you so, and exits with a
status your scripts can act on — plus
the small loop that turns that exit into
a fresh watch that includes the newcomer.

## How `-d` behaves

With `-d`, entr also tracks the
**directories that contain the listed
files**. If a new file appears in one of
them, entr runs the command one last
time, prints a notice, and exits with
status **2**:

Transcript `entr-lab/transcripts/t04-directory-watch.txt`:

```text
$ ls drafts/*.md | entr -dn echo 'watcher running -- no new files yet'
watcher running -- no new files yet

# (a new ordinary file is created: drafts/chapter-four.md)
watcher running -- no new files yet
entr: directory altered

$ echo $?
2
```

Three details in that short transcript
each deserve a sentence:

- The command ran **once more** when the
  new file arrived, before entr exited.
  Whatever the command builds therefore
  includes the state of the folder at that
  moment as far as its inputs reach — the
  new chapter is not yet an *input*, since
  the list was already fixed, but the run
  serves as a last word before the
  restart the loop below provides.
- The notice is **`entr: directory
  altered`** on entr's own output, distinct
  from anything the command prints.
- The exit status is **2** — not an
  error. Chapter 2's contract: 0 is a
  planned stop, 1 is a problem, 2 is
  "the directory changed under me."

## Dotfiles: once is shy, twice is not

Files whose names begin with a dot are
treated as private by long Unix custom,
and `-d` honours the custom: the same
transcript shows a `drafts/.hidden-draft.md`
being created mid-watch and **ignored**.
Give `-d` twice (`-dd`) and the shyness
is waived — the transcript's second half
shows the identical dotfile ending the
watch at once. Editor temporary files and
version-control internals are the usual
reason to leave the default as it is.

## The loop that makes it whole

An exit is only useful if something acts
on it. The manual's own idiom closes the
circle — run entr in a loop, rebuilding
the list each time around:

```bash
while sleep 0.1; do
    ls drafts/*.md | entr -d ./build.sh
done
```

Now the story completes itself. entr
starts, builds once (the startup run),
and watches. You edit a chapter: the
build runs. You create `chapter-four.md`:
entr runs the build, reports the altered
directory, exits with status 2 — and the
loop immediately starts a **new** entr
whose list, freshly printed by `ls`, now
includes chapter four. From then on its
edits are watched like the others. The
tiny `sleep` keeps the loop polite if
entr ever exits instantly and repeatedly,
for instance on a misspelt command.

The price of the arrangement is honesty
about what it is: not a watcher that
learns, but a watcher that *respawns*.
During the fraction of a second between
exit and restart, the folder is unwatched.
For builds and tests that price is
nothing. It is also why exit code 2
exists as a separate number: a script can
let 0 mean *finished* and 2 mean
*respawn me*, and chapter 13's
troubleshooting leans on that distinction.

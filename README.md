# Entr for Mere Mortals

Saving a file and then re-running the
same command by hand — up arrow, Enter,
read, edit, save, up arrow, Enter — is
the metronome of programming, and most
of it is wasted motion: the machine
knew the file had changed before you
did. **entr**, the **Event Notify Test
Runner**, closes that loop. You hand it
a list of files and a command; it
watches the files, and every time one
of them changes, the command runs.
Tests on every save. A build on every
edit. A development server that restarts
itself when its configuration changes.
One line, and the dance is over.

This guide explains how entr works —
the list, the watcher inside the
operating system, the runner that waits
for each command to finish — how to
watch one file, then a whole project,
how to tell the command *which* file
changed, how to restart a long-running
program instead of re-running a job, how
to notice when a *new* file arrives, how
to give entr commands that need a shell,
and how to keep the screen readable
while it works. The traps are
demonstrated, not just warned about.

The one rule is stated in chapter 1 and
it is about faithfulness, not malice:
**entr runs the command you gave it,
unattended, on every save** — including
the save you make halfway through a
thought. Rehearse commands on practice
files first, and be careful with any
command that deletes, overwrites or
publishes, because entr will run it at
exactly the wrong moment if you let it.
The lab obeyed the rule throughout:
every command entr ran touched only
files the lab had invented for the
purpose.

The lab behind this guide ran the real
thing: **entr 5.7**, the current
release, downloaded as the project's
official tarball and built from source
with `./configure` and `make` on a
small Linux machine, then exercised
against fixtures the lab wrote for the
purpose — a four-line notebook, a
three-chapter story, a settings file,
and two small scripts that announce
what they are doing. Against those
fixtures the lab ran a first watch with
a run per save, built a book from its
chapters on every edit with each build
labelled by the file that provoked it,
restarted a practice program twice and
proved the restarts by its process ids,
watched a folder and caught a new
chapter arriving, cleared the screen
before every run and photographed the
control bytes that did it, ran shell
pipelines both wrongly and rightly,
made entr describe a command's failure
in words, and sprang the three traps of
chapter 12 on purpose: the editor save
that replaces the file, the deletion
that ends a watch, and the command that
edits its own watched file — once in
four seconds under entr's protection,
seventy-three times without it.

What the lab could not do, it did not
fake. It had one Linux machine, so the
behaviour of the same entr on macOS and
the BSDs — where the kernel's watcher
has a different name and the same job —
is taught from the documentation and
labelled as such, as is the delivery of
file events over network filesystems.
Nothing was installed system-wide on
the lab machine: the distribution
package was verified by extraction, the
source build in a scratch folder.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What entr is**](what-entr-is.md) —
  the mental model: a lookout that runs
  your command when a file changes, and
  the one rule about unattended commands
- [**The moving parts**](the-moving-parts.md) —
  the list, the kernel watcher, the
  runner that consolidates events, the
  terminal, and entr's small contract of
  placeholders and exit statuses
- [**Installing entr**](installing-entr.md) —
  the package in one command, the source
  build in four, and why the version you
  get can matter at the edges
- [**Your first watch**](your-first-watch.md) —
  one file, one command, three runs, each
  with its cause named
- [**Feeding entr a file list**](feeding-entr-a-file-list.md) —
  lists from `ls`, `find` and `git
  ls-files`, and the `/_` marker that
  tells the command which file changed
- [**Restarting a long-running program**](restarting-a-long-running-program.md) —
  the `-r` reload mode: SIGTERM, a
  patient wait, a fresh process — and
  the `-z` one-shot that hands back the
  command's own exit status
- [**Watching for new files**](watching-for-new-files.md) —
  the `-d` directory watch, its exit
  status 2, dotfiles shy and unshy, and
  the respawning loop that completes it
- [**Shell commands and pipelines**](shell-commands-and-pipelines.md) —
  one program run directly, an `sh -c`
  wrapper, or entr's own `-s` shell mode
  with the changed file in `$0`
- [**Keeping the screen tidy**](keeping-the-screen-tidy.md) —
  clearing the screen per run, the space
  bar and `q`, and `-x` exit lines
  formatted in words
- [**Recipes**](recipes.md) — tests on
  every save, a server restarted by its
  own config, builds that notice new
  files, a checker fed the changed file,
  and a folder mirrored while you work
- [**The neighbours**](the-neighbours.md) —
  watchexec, inotifywait, the watcher
  inside your framework, make, systemd
  path units, and fswatch: what each
  does that entr doesn't, and vice versa
- [**Limits**](limits.md) — the list
  never grows, a deletion ends the
  watch, events are not differences, and
  a command that edits its own watched
  file, measured
- [**Troubleshooting**](troubleshooting.md) —
  the terminal refusal, the run that
  never comes, the run that never stops,
  and the three instruments that settle
  every argument
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

entr as system infrastructure — services
supervised from boot, with users and
policies — belongs to systemd and its
path units, pointed at in chapter 11 and
taught in this series' systemd guide.
File synchronisation and backup are
other tools' jobs; entr notices changes
and keeps no copies. And no chapter can
make an unsafe command safe to run
unattended: if the command would be a
mistake typed by hand at the wrong
moment, entr simply makes it a punctual
one.

## How to use this guide

Read chapter 1 for the model and the
rule, and chapter 2 before running
anything — knowing which part holds what
turns later confusion into a named
problem. Chapter 4 takes your first
watch in the same sitting as the
install, against a file that cannot
matter. Chapter 5 is the one that turns
a watcher into a workflow; chapter 6 if
your command is a program that stays
alive. Chapters 12 and 13 are the pair
to read before entr earns a place in
real work: the limits are few, but they
are exact, and every troubleshooting
entry is a limit wearing a symptom. The
lab's transcripts live in
`entr-lab/transcripts/`; its fixtures
are `entr-lab/notes.txt`,
`entr-lab/drafts/`, `entr-lab/settings.conf`
and the scripts `entr-lab/ticker.sh` and
`entr-lab/build.sh`; its notes are
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Bash for Mere Mortals](https://paulsullivan33-dev.github.io/bash-for-mere-mortals/)
- [cron for Mere Mortals](https://paulsullivan33-dev.github.io/cron-for-mere-mortals/)
- [systemd for Mere Mortals](https://paulsullivan33-dev.github.io/systemd-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/entr-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/entr-for-mere-mortals/blob/main/LICENSE-CODE).

# Glossary

The terms this guide uses, collected in
one place. Where a word is entr's own,
the definition is entr's meaning, which
occasionally differs from its everyday
one.

**Command (or utility).** The program
entr runs when a watched file changes —
everything after the options on entr's
command line. Entr's manual calls it the
*utility*; this guide says *command*.

**Consolidation.** entr's folding together
of events that arrive while a command is
running, so they cause at most one
further run — and a change the command
makes to a watched file during its own
run causes none. The `-a` option waives
it.

**Directory watch.** The `-d` option:
entr also tracks the folders containing
the listed files, and exits with status 2
if a new file appears in one. Given
twice (`-dd`), it notices dotfiles too.

**Event.** One report from the operating
system that a watched file changed —
written, closed, moved, touched. entr's
raw material; visible with EV_TRACE.

**Event Notify Test Runner.** entr's full
name, and its biography in four words:
it is notified of events, and it runs
things — tests first among equals.

**inotify.** The Linux kernel service
that reports file events to programs
that ask. entr's watcher on Linux;
**kqueue** is the equivalent on macOS and
the BSDs.

**List.** The filenames entr reads from
its standard input at startup, and the
full extent of what it will ever watch
in that run. Also: *watch list*.

**Non-interactive mode.** The `-n`
option: entr does not open the terminal
or read keys, making it safe in scripts
and pipelines, at the cost of the space
bar and `q`.

**Placeholder (`/_`).** An argument on the
command line that entr replaces with the
absolute path of the first file to
trigger the run. In shell mode (`-s`),
the same name is available as `$0`.

**Postpone.** The `-p` option: suppress
the startup run, so the command runs
only when a change provokes it.

**Reload mode.** The `-r` option: the
command is a long-running program, and
on each event entr terminates it
(SIGTERM, then a patient wait) and starts
it again.

**Restart.** See *reload mode* — this
guide uses the words interchangeably, as
the world does.

**Shell mode.** The `-s` option: the
first argument is evaluated by a shell
(the one named by `$SHELL`), making
pipelines and redirections available
inside the watched command.

**Snapshot.** What the list is: the
project's files as they were at the
moment entr started, unchanging
thereafter.

**Startup run.** The run entr performs
the moment a watch begins, before any
change. On purpose, postponable, and the
first surprise every new user meets.

**Status filter.** The awk script used
by `-x` to format a command's ending
into words ("sh returned exit code 7").
Lives at `$ENTR_STATUS_SCRIPT`, by
default `~/.entr/status.awk`, and is
created as an example if missing.

**Trigger.** The file whose event caused
a given run; the name the `/_`
placeholder and `$0` report.

# The Neighbours

entr is the smallest tool in a crowded
neighbourhood: everything that watches
files and reacts lives within a street of
it. This chapter characterises the
neighbours honestly — what each does that
entr does not, and vice versa. None of
them was run for this guide; the
descriptions come from their own
documentation, and the point is choosing,
not ranking.

## watchexec

The closest neighbour, and the one most
often named in the same breath.
**watchexec** watches *directories*,
recursively, by itself — no `find` pipe,
no snapshot problem, new files simply
join. It adds filtering by extension and
by ignore files (it understands
`.gitignore`), its own debounce timing,
and options for signalling the command
rather than killing it. In exchange it is
a larger tool with a larger surface to
learn. If you find chapter 7's
exit-and-respawn loop inelegant, or you
routinely watch a whole tree, watchexec
is probably the tool you actually want.
If your watch fits on one line, entr's
line is shorter.

## inotifywait and the hand-rolled watcher

On Linux, **inotifywait** (from the
inotify-tools package) prints file events
as text, one per line, and stops there:
no runner, no consolidation, no opinions.
A shell loop around it — read an event,
run a command — rebuilds entr by hand,
event format by event format. People do
this when they need an event entr does
not expose (only attribute changes, say,
or events on a single directory's
entries), or on a machine where only
inotify-tools is available. It teaches
you exactly what entr has been sparing
you; chapter 2's EV_TRACE transcript
shows the raw material it works with.

## The watcher inside your framework

Many development stacks ship their own:
**nodemon** for Node programs, the reload
modes of web frameworks and static-site
generators, `cargo watch` in the Rust
world, test runners with a `--watch`
flag. These know things entr cannot —
which of *their* files matter, how to
restart *their* runtime gracefully,
sometimes how to reload without
restarting at all (a browser refreshed,
a module swapped in place). Inside one
stack, prefer the built-in. entr's ground
is everything else: mixed folders,
plain-text pipelines, languages and tools
with no watcher of their own, and one
uniform habit across all of them.

## make, doing its half

`make` is not a watcher at all, and the
pairing of the two is the classic shape:
**entr notices, make decides.** entr runs
`make` on every relevant save; make's own
timestamp logic works out which outputs
are stale and rebuilds only those. Each
tool covers the other's famous gap —
entr without make reruns the whole
command every time, and make without entr
waits for a human to invoke it. Chapter
5's build script is a makefile that had
not yet admitted it.

## systemd path units

At the system's edge, **systemd** offers
`.path` units: the service manager itself
watches a path and starts a service when
it changes. That is the right altitude
for machine-level reactions — a spool
folder that should be processed whenever
a file lands, watched from boot, with
logging and permissions and supervision.
It is the wrong altitude for a
developer's edit-save loop, which wants a
terminal, a space bar and no privileges.
entr lives in the session; path units
live in the system; they meet mainly in
chapter 6's warning not to make entr do a
supervisor's job.

## fswatch

**fswatch** watches paths across
platforms and *prints* events, like
inotifywait but portable and with several
monitor backends. It is the raw material
again rather than the finished tool:
pair it with `xargs` or a loop when entr's
model — a list, a command, a runner — is
not the shape you need, most often on
macOS where its platform monitor is
strong.

The thread through all of this: watching
is easy to start and surprisingly full of
edges — consolidation, signals, new
files, editors' save tricks. entr's whole
personality is having chosen one small,
defensible set of answers. The neighbours
chose others.

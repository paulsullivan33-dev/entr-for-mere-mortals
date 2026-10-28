# Recipes

Short, complete answers to the situations
entr is actually bought for. Every recipe
is assembled from mechanisms the earlier
chapters verified — the transcripts are
named where a recipe's shape matches one
— and each is meant to be adapted, not
worshipped. Watch your own files, with
your own commands, rehearsed once by hand
(chapter 1's rule), and these will behave.

## Run the tests on every save

```bash
ls *.py | entr -p python3 -m pytest -q
```

`-p` skips the startup run, so the suite
runs only when provoked. Watching the
test files as well as the sources —
`ls *.py tests/*.py` — turns editing a
test into a provocation too, which it is.

## Rebuild a document when any source changes

Chapter 5's build, in working clothes:

```bash
find drafts -name '*.md' | entr -np ./build.sh /_
```

The build script receives the changed
file as `$1` and can rebuild everything
(the simple, always-right choice) or use
the name to do less. The combined output
stays **off** the list, so the build
never provokes itself. Swap the story
chapters for a manual's sections, a
thesis, a set of web pages: the shape is
identical.

## Restart a development server on config or code changes

```bash
ls app.py settings.conf | entr -r python3 app.py
```

Chapter 6's mechanism verbatim: SIGTERM,
a real wait for the old process to die
(so the port is free), then the new copy.
List the code as well as the config if
you want edits to either to restart it —
for many frameworks the framework's own
reloader does this job from the inside,
and chapter 11 says when to prefer it.

## Rebuild when files are added, not just edited

```bash
while sleep 0.1; do
    ls drafts/*.md | entr -d ./build.sh
done
```

Chapter 7's loop. A new file ends the
watch with status 2; the loop restarts
entr with a fresh list that includes the
newcomer, and its startup run builds with
it present.

## Check a file with a tool that wants a filename

```bash
echo report.sql | entr -cp psql -f /_
```

The manual's own example, and the
purest use of `/_`: the changed file
*is* the argument. `-c` keeps each run's
output alone on the screen (chapter 9).
Any checker with a filename argument —
a linter, a formatter in check mode, a
spelling checker — drops into the same
frame.

## Wait for a change, run once, report the result

```bash
echo data.csv | entr -z ./validate.sh; echo "validator said: $?"
```

Chapter 6's `-z`: entr waits for the
first change, runs the validator once,
and exits with the validator's own exit
status, which the surrounding script
reads. Useful in small automation: "when
the export lands in this folder, check
it and tell me properly whether it is
sound" — with `-d` added, the trigger can
be the file's arrival rather than its
modification.

## Keep a folder mirrored while you work

```bash
find site -type f | entr -p rsync -a site/ backup-server:site/
```

Every save re-mirrors the folder — with
chapter 1's warning fully engaged: this
command *publishes* on every save,
half-edited files included, so point it
at a staging destination, never the live
one, and rehearse it by hand until its
behaviour is boring. entr will run it
exactly as faithfully as you wrote it.

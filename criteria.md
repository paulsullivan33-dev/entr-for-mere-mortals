# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 12 names what the tool
   cannot do: a list that never grows, a deleted file that ends
   the watch, events that are not differences, the folding of
   events while a command runs, and change on other machines
   that the local kernel never sees.
8. **The safety rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *entr runs the command you
   gave it, unattended, on every save* — before any procedure
   depends on it, and later chapters point back to it where a
   command would delete, overwrite or publish on every save.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu 24.04 sandbox.
entr **5.7** — the current release — was downloaded as the
project's official release tarball (eradman/entr on GitHub)
and built in a scratch folder with `./configure` and `make`,
exactly the source route chapter 3 teaches; the resulting
binary was exercised without being installed system-wide.
The Ubuntu 24.04 distribution package (entr 5.5) was
downloaded and *extracted*, not installed, and its binary run
once to confirm the release and usage output chapter 3
describes. All transcripts live in `entr-lab/transcripts/`;
the lab's fixtures are `entr-lab/notes.txt`, `entr-lab/drafts/`,
`entr-lab/settings.conf`, and the two scripts `ticker.sh` and
`build.sh`. Runs were made against scratch copies of the
fixtures so the copies in this repository stay as a reader
would start them.

Run for real, with transcripts as evidence:

- Bare invocation and the startup refusals: release and usage
  lines, empty list, a listed file that does not exist, and
  the no-terminal refusal that names `-n` (t00).
- A one-file watch of `notes.txt`: the startup run and one
  run per appended line, line counts and timestamps proving
  cause and effect (t01).
- A `find`-built list over three draft chapters with `-p`
  postponing the first run and the `/_` placeholder labelling
  each build with the file that triggered it (t02).
- Restart mode (`-r`) against the ticker program: two edits
  to `settings.conf`, three distinct process ids with
  dovetailing heartbeats (t03).
- Directory watch (`-d`): a dotfile ignored, an ordinary new
  file ending the watch after one final run, the
  `directory altered` notice and exit status 2; with `-dd`
  the dotfile ending it instead (t04).
- Clear screen (`-cc`) captured through a terminal recorder:
  the erase-screen, erase-scrollback and cursor-home bytes
  before every run (t05).
- Shell mode: a pipeline string refused without `-s`
  (`exec ... No such file or directory`, with entr keeping
  watch), then the same job done with `-s`, `$0` naming the
  changed file and the pipeline producing its count (t06).
- The keyboard, under a real terminal: the space bar
  producing a run with no file change, `q` quitting (t07).
- One-shot mode (`-z`): a run provoked by a change, entr
  exiting afterwards and returning the command's own exit
  status, 3 in the lab's rigged example (t08).
- EV_TRACE event output from the kernel watcher, including
  the per-process open-file limit line (t09).
- Status messages (`-x`): entr creating its example awk
  filter when none existed, and the filter formatting a
  rigged exit-7 ending as `sh returned exit code 7` (t10).
- The traps, all sprung deliberately: editor-style
  rename-replacement saves survived twice; a watched file
  deleted outright ending the watch with status 1 and not
  reviving when recreated; a command appending to its own
  watched file running **once** in four seconds under default
  consolidation and **73 times** in four seconds with `-a`
  (t90).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- The `sudo apt install entr` route itself: the package was
  verified by extraction (above), but nothing was installed
  system-wide on the build machine; package installs on
  other systems (Homebrew, pkg, pacman, dnf) are named from
  their own documentation.
- Behaviour on macOS and the BSDs, where the watcher is
  kqueue instead of inotify; every run here was on Linux,
  and the guide says so where the two could differ.
- File events on network filesystems, where changes made by
  other machines may never reach the local kernel — a
  documented property of inotify/kqueue, stated as such in
  chapters 12 and 13.
- The comparison tools in chapter 11 (watchexec, inotifywait,
  nodemon and its kin, `make`, systemd path units, fswatch)
  are characterised, not benchmarked.

Fixtures are this guide's own and deliberately generic: a
four-line notebook, a three-chapter story about a lighthouse
keeper, a settings file with a speed and a colour, and two
small scripts that announce what they are doing. No example
is modelled on any real person, network, service or
organisation, and nothing was watched that the lab did not
itself create.

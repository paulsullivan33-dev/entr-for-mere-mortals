# Installing Entr

entr is a small C program with no runtime
dependencies beyond the C library, and
nearly every operating system packages it.
The **package** route is the one to take:
one command, and updates arrive with the
rest of your system. The **source** route
exists, is short, and is what this guide's
lab used to get the newest release — the
install chapter describes both, and the
difference between them matters for
exactly one reason, explained below.

## The package install

On Debian or Ubuntu:

```bash
sudo apt install entr
```

On macOS with Homebrew, `brew install
entr`. On FreeBSD, `pkg install entr`. On
Arch, `sudo pacman -S entr`. On Fedora,
`sudo dnf install entr`. Everywhere, the
result is the same single command, `entr`,
usually with its manual page (`man entr`),
which is well written and worth reading
whole — it is four pages, not forty.

Check: after any install, run entr with
nothing attached —

```text
$ entr </dev/null
release: 5.7
usage: entr [-acdnprsxz] utility [argument [/_] ...] < filenames
```

That bare run is entr introducing itself:
the release line says which version you
have, and the usage line lists its option
letters. The run is transcript
`entr-lab/transcripts/t00-version-and-errors.txt`,
together with the other things entr says
when it cannot start: no files on its
list, and a file that does not exist.

## The version you get, and why it can matter

entr develops slowly and carefully: the
current release, **5.7**, is dated
February 2025, and releases arrive a year
or two apart. Distribution packages lag
behind by a release or so — the Ubuntu
24.04 package this lab compared against
is 5.5. For the core of entr — everything
in chapters 4 to 8 — the difference will
never be felt. It is felt at the edges:
the `-x` status-message option of
chapter 9 was added in 5.6, so a 5.5
package will reject it as an unknown
option. If a command in this guide fails
on your machine with an option error,
compare the release line from the check
above against the version named in the
chapter before suspecting anything else.

## The source install

The project's home is at **eradman.com/
entrproject**, and its releases are
tarballs on GitHub under **eradman/entr**.
Building needs only a C compiler and
`make`:

```bash
tar xzf entr-5.7.tar.gz
cd entr-5.7
./configure
make
sudo make install
```

That is the whole of it: `configure`
picks the right makefile for your system
(Linux, macOS, and each BSD have their
own), `make` compiles one C file, and the
install puts `entr` and its manual page
under `/usr/local` by default.

This guide's lab used exactly that route:
it downloaded the 5.7 release tarball,
ran `./configure` and `make` in a scratch
folder, and exercised the resulting binary
for every transcript in the guide —
without installing anything system-wide,
so the machine could be left as it was
found. The transcripts are labelled as
version 5.7 for that reason, and the
criteria file (`criteria.md`) keeps the
details, including the comparison against
the distribution package.

## What "installed" looks like

There is no configuration file, no
service, no first-run setup: `entr` on
your path is entr installed. Uninstalling
is the package manager's business, or
deleting the built binary — entr keeps no
state anywhere, except one optional file
of your own making: the status script of
chapter 9, which entr looks for at
`~/.entr/status.awk` only when asked.

You are ready for a first watch.

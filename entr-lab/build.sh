#!/bin/sh
# A stand-in "build": join the draft chapters into one
# file and report the word count. The file that
# triggered the build is handed over as $1 (entr puts
# it there when the command line ends in /_).
# combined.md is deliberately NOT one of the watched
# files, so the build cannot trigger itself.
# entr hands over an absolute path; the script trims
# the working folder's prefix off it for display.
echo "build at $(date +%T) -- triggered by: ${1#"$PWD"/}"
cat drafts/*.md > combined.md
echo "combined.md now holds $(wc -w < combined.md) words"

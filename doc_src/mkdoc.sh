#!/bin/sh
# Generate README.md from doc_src/readme.md
#
# The line below to generates the bib.json file. Note that this URL is
# specific to my laptop installation of Zotero with the BetterBibtex extension
# The Zotero library being used is EZID-dev
curl "http://127.0.0.1:23119/better-bibtex/export/library?/11/library.json" > bib.json
pandoc --filter=pandoc-citeproc  readme.md -o ../README.md --bibliography=bib.json --csl=ieee.csl --to=gfm

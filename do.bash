sdir=slides
#subj=hg2052

### Build flags, used for every document below.
###   -gg  force a clean rebuild.  Without it, a .aux left over from an
###        older polyglossia makes a deck die with
###          "Critical Package polyglossia Error: The language * is not loaded"
###   -interaction=nonstopmode  never stop at the "?" prompt.  Without it
###        a single broken deck hangs this whole script waiting for a
###        keypress that never comes.
latexopts="-gg -interaction=nonstopmode"

pushd .
cd $sdir
### Only the decks that are tracked in git.  Drafts and backups match
### lec-*.tex too (lec-06-lexicon-bak, lec-06a-lexicon, ...), are not
### published, and some of them do not build.  If you add a new deck,
### git add it and it will be picked up here.
for slide in `git ls-files 'lec-*.tex' 'presentation.tex'`
do
    base=`basename $slide .tex`
    echo Processing ${base}
    latexmk ${latexopts} -xelatex ${base}
    ## clean up
    #rm *.aux *.bbl *.blg *.log *~ *.dvi *.ps *.pdf
done
popd

### copy changed slides
### Named explicitly rather than slides/*.pdf, which would also push
### local builds back into docs/pdf -- assignment.pdf (the retired NTU
### version), ch08a-recreated.pdf, hpsg-latex.pdf, draft decks, ...
pushd .
cd $sdir
pdfs=`git ls-files 'lec-*.tex' 'presentation.tex' | sed 's/\.tex$/.pdf/'`
popd
rsync -avc `for p in $pdfs; do echo $sdir/$p; done` docs/pdf

### the assignment template and the HPSG/LaTeX guide
### These live in docs/template and are served from there, so there is
### nothing to copy afterwards.  pdflatex, not xelatex: the template
### loads inputenc/fontenc.
tdir=docs/template
pushd .
cd $tdir
for doc in assignment hpsg-latex-guide
do
    echo Processing ${doc}
    latexmk ${latexopts} -pdf ${doc}
done
popd

#htmldoc  --duplex --color --fontsize 12 --webpage -f /home/bond/papers/Outlines/${subj}-outline.pdf www/index.html


echo
echo Updated all slides: check the index.html is up to date
echo
echo Please commit any changes
echo
echo
git status
echo

#!/bin/bash
# Makes pdf version then html version then copies html to docs


SCPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
# SCPT_DIR=/Volumes/Data/Courses/Choice/LectureNotes/AssetPricing/Handouts/LucasAPM-07Crisis
jobName="LucasAssetPrice"

cp .latexmkrc_gh-pages .latexmkrc
latexmk -C

# get default formatting stuff
cmd="/bin/bash `kpsewhich tex4htMakeCFG.sh` $jobName"
echo "$cmd"
eval "$cmd"

# Tables need to be tabular not pictures
rpl ',pic-tabular}' '}' *.cfg

econ_ark_theme=/tmp/econ-ark-html-theme
curl https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Web/Styling/REMARKs-HTML/econ-ark-html-theme.css -o $econ_ark_theme.css
cp $econ_ark_theme.css page-style.css

cmd="[[ ! -e _config.yml ]] && echo 'theme: jekyll-theme-minimal' > _config.yml" 
echo "$cmd" ; eval "$cmd"

latexmk -c
# make4ht is unreliable in getting bib entries right, unless the file has already been compiled
# as a dvi
pdflatex -output-format=dvi "$jobName"
bibtex "$jobName"
# pdflatex -output-format=dvi "$jobName"
# pdflatex -output-format=dvi "$jobName"

cmd="source ~/.bash_profile ; make4ht --loglevel error --utf8 --config $jobName.cfg --format html5 $(basename $jobName) "'"svg"'"   "'"-cunihtf -utf8"'""

# compiling it with make4ht generates the $jobName.css file
echo "$cmd"
eval "$cmd"
cp "$jobName.css" "$jobName-generated-by-make4ht.css"

# Update style files
css="cat page-style.css | cat - $jobName-generated-by-make4ht.css > $jobName-page-style.css && mv $jobName-page-style.css $jobName.css"

# Replace make4ht-generated css with augmented
eval "$css"
rm -f page-style.css && rm -f $jobName-generated-by-make4ht.css

cp $jobName.html index.html

mkdir -p docs

mv *.html *.yml *.css *.cfg *.svg *.mk4 *.idv *.dvi *.lg .latexmkrc docs 
cp *.pdf *.bib *.xref *.bib "$jobName.tex" docs

cp .latexmkrc_main .latexmkrc

latexmk -c

latexmk "$jobName"
bibtex "$jobName"
latexmk "$jobName"

latexmk -c

rm -f .latexmkrc 

cd docs

open index.html

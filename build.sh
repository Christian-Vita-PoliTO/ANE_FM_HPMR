#!/usr/bin/env bash
# Ricompila manoscritto, lettera di risposta e versione con le differenze marcate.
#
#   ./build.sh          tutto
#   ./build.sh paper    solo il manoscritto
#   ./build.sh letter   solo la lettera
#   ./build.sh diff     solo il latexdiff
#
# Non modifica nessun file .tex: alla fine stampa i numeri di pagina e di riga
# correnti delle etichette \linelabel, da confrontare con quelli citati nella lettera.

set -u
cd "$(dirname "$0")"

MAIN=elsarticle-template-num-names
BASE=versions/v1_submitted/main.tex
TARGET="${1:-all}"
FAILED=0

quiet() { "$@" >/dev/null 2>&1; }

report() {   # report <nome> <file .log>
    local errs pages
    errs=$(grep -c '^!' "$2" 2>/dev/null); errs=${errs:-?}
    pages=$(grep -a -o '([0-9]* pages' "$2" 2>/dev/null | tail -1 | tr -d '(')
    if [ "$errs" != "0" ]; then
        printf '  %-12s ERRORI: %s\n' "$1" "$errs"
        grep -a -A2 '^!' "$2" | head -20
        FAILED=1
    else
        printf '  %-12s ok, %s\n' "$1" "${pages:-? pages}"
    fi
}

if [ "$TARGET" = all ] || [ "$TARGET" = paper ]; then
    echo "manoscritto..."
    quiet pdflatex -interaction=nonstopmode "$MAIN.tex"
    quiet bibtex "$MAIN"
    quiet pdflatex -interaction=nonstopmode "$MAIN.tex"
    quiet pdflatex -interaction=nonstopmode "$MAIN.tex"
    report "$MAIN" "$MAIN.log"
    grep -a -i 'citation.*undefined\|reference.*undefined' "$MAIN.log" | sort -u | head
fi

if [ "$TARGET" = all ] || [ "$TARGET" = letter ]; then
    echo "lettera..."
    ( cd response_letter && quiet pdflatex -interaction=nonstopmode response_letter.tex )
    report response_letter response_letter/response_letter.log
    if grep -q '^[^%]*\\todo{' response_letter/response_letter.tex; then
        echo "  attenzione: nella lettera ci sono ancora dei \\todo"
    fi
fi

if [ "$TARGET" = all ] || [ "$TARGET" = diff ]; then
    echo "versione con le differenze marcate..."
    if [ ! -f "$BASE" ]; then
        echo "  versione sottomessa non trovata in $BASE"
        FAILED=1
    else
        mkdir -p build_diff
        if [ -f diff_v1_v2.tex ]; then
            echo "  ATTENZIONE: c'e' un diff_v1_v2.tex nella cartella di lavoro."
            echo "  Non viene piu' usato ne' aggiornato. Se ci hai scritto dentro,"
            echo "  quelle modifiche vanno riportate in $MAIN.tex, altrimenti spariscono."
        fi
        # il file delle differenze e' generato: vive dentro build_diff/, non nella
        # cartella di lavoro, cosi' non si confonde con i sorgenti da modificare a mano
        latexdiff -t CFONT --math-markup=whole "$BASE" "$MAIN.tex" > build_diff/diff_v1_v2.tex 2>/dev/null
        python3 fix_diff_labels.py build_diff/diff_v1_v2.tex
        quiet pdflatex -interaction=nonstopmode -output-directory=build_diff build_diff/diff_v1_v2.tex
        cp -f bibliography.bib build_diff/ 2>/dev/null
        ( cd build_diff && quiet bibtex diff_v1_v2 )
        quiet pdflatex -interaction=nonstopmode -output-directory=build_diff build_diff/diff_v1_v2.tex
        quiet pdflatex -interaction=nonstopmode -output-directory=build_diff build_diff/diff_v1_v2.tex
        report diff_v1_v2 build_diff/diff_v1_v2.log
    fi
fi

if [ -f "$MAIN.aux" ] && { [ "$TARGET" = all ] || [ "$TARGET" = paper ]; }; then
    echo
    echo "posizioni correnti delle etichette citate nella lettera:"
    grep -o 'newlabel{rl:[a-z_0-9]*}{{[0-9]*}{[0-9]*}' "$MAIN.aux" |
        sed 's/newlabel{rl:\([a-z_0-9]*\)}{{\([0-9]*\)}{\([0-9]*\)}/  \1|riga \2|pagina \3/' |
        awk -F'|' '{printf "  %-16s %-10s %s\n", $1, $2, $3}'
    echo
    echo "  se hai spostato del testo, controlla che i riferimenti nella lettera coincidano."
fi

exit $FAILED

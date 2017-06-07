#!/bin/bash
rm -r output
mkdir -p output/testdata
for f in testdata/0*.lsp
do
    # TA's version
    echo -n "Judging $f "
    ./csmli_TA $f > $f.ta.out
    echo -n " [TA]"
    ./csmli < $f > $f.me.out
    echo -n "[ME] "
    msg=$(diff $f.ta.out $f.me.out)
    if [[ $? -eq 0   ]]; then
        echo "[AC]"
    else
        echo "[WA]"
        cat $f
        echo "Correct Output:"
        printf "$msg\n"
        echo "^ Your Output."
    fi
done

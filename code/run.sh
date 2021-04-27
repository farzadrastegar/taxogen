#!/bin/bash
## Name of the input corpus
corpusName=dblp
## Name of the taxonomy
taxonName=our-l3-0.15
## If need preprocessing from raw input, set it to the first argument
CONFIGURE=""
if [ $# -ne 0 ]; then
   CONFIGURE=$1
fi

if [[ $CONFIGURE == "with-config" ]]; then
	echo '-> Compile word2vec'
	## compile word2vec for embedding learning
	gcc word2vec.c -o word2vec -lm -pthread -O2 -Wall -funroll-loops -Wno-unused-result

	if [ ! -f ../data/$corpusName/raw/papers.txt ]; then
		echo "../data/$corpusName/raw/papers.txt must exist!"
		exit
	fi
	if [ ! -f ../data/$corpusName/raw/keywords.txt ]; then
		echo "../data/$corpusName/raw/keywords.txt must exist!"
		exit
	fi
	if [ ! -f ../data/$corpusName/input/embeddings.txt ]; then
		echo "../data/$corpusName/input/embeddings.txt must exist!"
		exit
	fi

	## create initial folder if not exist
	if [ ! -d ../data/$corpusName/init ]; then
		mkdir -p ../data/${corpusName}/init
	fi

	echo '-> Start cluster-preprocess.py'
	time python cluster-preprocess.py $corpusName

	echo '-> Start preprocess.py'
	time python preprocess.py $corpusName

	cp ../data/$corpusName/input/embeddings.txt ../data/$corpusName/init/embeddings.txt
	cp ../data/$corpusName/input/keywords.txt ../data/$corpusName/init/seed_keywords.txt
fi

echo '-> Start TaxonGen'
if [ $# -eq 2 ]; then
	python main.py --datapath "$2"
else
	python main.py
fi

echo '-> Generate compressed taxonomy'
if [ ! -d ../data/$corpusName/taxonomies ]; then
	mkdir -p ../data/$corpusName/taxonomies
fi
python compress.py -root ../data/$corpusName/$taxonName -output ../data/$corpusName/taxonomies/$taxonName.txt

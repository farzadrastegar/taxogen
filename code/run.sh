#!/bin/bash
shopt -s expand_aliases
alias run_python='python2'

## name of the input corpus
corpusName="dblp"
## name of the taxonomy
taxonName="our-l3-0.15"
## path to data
datapath="../data"

__dl="--download"

__usage="
USAGE: $(basename $0) <with-config|no-config> [OPTIONS]

OPTIONS: 
	-d, --download			data used in the paper will be downloaded at '$datapath'
	-p, --path </path/to/data>	path to data for taxonomy construction (default=$datapath)	
 
	'/path/to/data' must contain the following tree
	data
	└── dblp
		├── input
		│   └── embeddings.txt
		└── raw
			├── keywords.txt
			└── papers.txt
"

## parse <with-config|no-config> from arguments
CONFIGURE=${1:?"<with-config|no-config> is required!""${__usage}"}
if [[ $CONFIGURE != "with-config" && $CONFIGURE != "no-config" ]]; then
	echo "<with-config|no-config> is required!"
	echo
	echo "$__usage"
	exit
fi

## parse [OPTIONS] from arguments
DOWNLOAD=""
OPTIONS=${2:?"-d OR -p is required!""${__usage}"}
if [[ $OPTIONS != "-d" && $OPTIONS != "--download" ]] 
then
	if [[ $OPTIONS == "-p" || $OPTIONS == "--path" ]]
	then
		datapath=${3:?"--path </path/to/data> is required!""${__usage}"}
	else
		echo "-d OR -p is required!"
		echo
		echo "$__usage"
		exit
	fi
else
	DOWNLOAD="$__dl"
fi


## download the data used in the paper
if [[ $DOWNLOAD == "$__dl" ]]; then
	echo "-> Download paper's dblp"
	mkdir -p $datapath/dblp
	wget -O $datapath/dblp/dblp.tar.gz https://worksheets.codalab.org/rest/bundles/0x3b33ffbc3a4346fd8e288dfeda291d6c/contents/blob/
	tar xvzf $datapath/dblp/dblp.tar.gz -C $datapath/dblp
	rm $datapath/dblp/dblp.tar.gz
fi

if [[ $CONFIGURE == "with-config" ]]; then
	echo "-> Compile word2vec"
	## compile word2vec for embedding learning
	gcc word2vec.c -o word2vec -lm -pthread -O2 -Wall -funroll-loops -Wno-unused-result

	if [ ! -f $datapath/$corpusName/raw/papers.txt ]; then
		echo "$datapath/$corpusName/raw/papers.txt must exist!"
		exit
	fi
	if [ ! -f $datapath/$corpusName/raw/keywords.txt ]; then
		echo "$datapath/$corpusName/raw/keywords.txt must exist!"
		exit
	fi
	if [ ! -f $datapath/$corpusName/input/embeddings.txt ]; then
		echo "$datapath/$corpusName/input/embeddings.txt must exist!"
		exit
	fi

	## create initial folder if not exist
	if [ ! -d $datapath/$corpusName/init ]; then
		mkdir -p $datapath/${corpusName}/init
	fi

	echo "-> Start cluster-preprocess.py"
	time run_python cluster-preprocess.py "$datapath/$corpusName"

	echo "-> Start preprocess.py"
	time run_python preprocess.py "$datapath/$corpusName"

	cp $datapath/$corpusName/input/embeddings.txt $datapath/$corpusName/init/embeddings.txt
	cp $datapath/$corpusName/input/keywords.txt $datapath/$corpusName/init/seed_keywords.txt
fi

echo "-> Start TaxonGen"
if [[ $datapath != "" ]]; then
	run_python main.py --datapath "$datapath"
else
	run_python main.py
fi

echo "-> Generate compressed taxonomy"
if [ ! -d $datapath/$corpusName/taxonomies ]; then
	mkdir -p $datapath/$corpusName/taxonomies
fi
run_python compress.py -root $datapath/$corpusName/$taxonName -output $datapath/$corpusName/taxonomies/$taxonName.txt

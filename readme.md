```diff
+ April 28, 2021: The instructions for how to run code got updated. See below for more information.
```

# About

This repo is an implementation of the following paper for constructing topic taxonomy from text corpora.

"TaxoGen: Unsupervised Topic Taxonomy Construction by Adaptive Term Embedding and Clustering",
Chao Zhang, Fangbo Tao, Xiusi Chen, Jiaming Shen, Meng Jiang, Brian Sadler, Michelle Vanni, Jiawei Han,
ACM SIGKDD Conference on Knowledge Discovery and Pattern Mining (KDD), 2018.


# Input

The input consists of three files:

1. `papers.txt`
  - This data file contains all the documents (e.g., paper titles). 
  - Every line is a sequence of processed keywords (either uni-grams or phrases). 
  - The keywords are separated by blank spaces (words in a phrase are concatenated by '_').
2. `keywords.txt`
  - This data file contains all keywords extracted from the document collection (e.g., entities, noun phrases). 
  - Every line is a keyword.
3. `embeddings.txt`
  - This data file contains the embeddings of all the keywords. 
  - Every line is the embedding of a keyword.



The DBLP dataset used in the paper is available here:

https://drive.google.com/file/d/1GbxKrxrmFrKt5vgDHP1xe1Qr_rfvR1jh/view?usp=sharing


# How to Run

This code works with Python 2.7. Make sure `python2 -V` gives you 2.7.x.

Install python packages using the command below.

`pip2 install -r requirements.txt`

Also, make sure that `gcc` is installed (on Ubuntu 18.04, run the `apt install` command below to install gcc).

`apt install build-essential -y`

This code is tested with the following `gcc` version.

```
gcc --version
gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0
```

In order to run code, follow the guidelines below.

```
USAGE: ./run.sh <with-config|no-config> [OPTIONS]

OPTIONS: 
        -d, --download                  data used in the paper will be downloaded at '../data'
        -p, --path </path/to/data>      path to data for taxonomy construction (default=../data)      
 
        '/path/to/data' must contain the following tree
        data
        └── dblp
                ├── input
                │   └── embeddings.txt
                └── raw
                        ├── keywords.txt
                        └── papers.txt

```

Common ways of running code is as follows.

**Option 1**: 

If you would like to run code and let it prepare the data files **used in the paper** in proper directories, use this command:

```
cd code
./run.sh with-config --download
```

**Option 2**:

If you would like to run code and let it prepare **your** data files in proper directories, use this command by speicfying the path to your data.

```
cd code
./run.sh with-config --path "/path/to/data"
```

Note: your "/path/to/data" must contain the following directory tree:

```
data
└── dblp
    ├── input
    │   └── embeddings.txt
    └── raw
        ├── keywords.txt
        └── papers.txt
```

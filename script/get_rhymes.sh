#!/bin/bash

SCRIPT=$(perl -MCwd -le 'print Cwd::abs_path(shift)' $0)
DIR=$(dirname $SCRIPT)

mkdir $DIR/../data
cd $DIR/../data
lwp-download "https://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/cmudict.0.7a"
lwp-download "http://downloads.sourceforge.net/project/wordlist/POS/Rev%201/pos-1.tar.gz"
tar -xzvf pos-1.tar.gz


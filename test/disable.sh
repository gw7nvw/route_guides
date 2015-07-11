#!/bin/bash
find $1 -name "*.rb" > disable.lst
for file in `cat disable.lst`; do echo ${file}; mv ${file} ${file}.disable; done

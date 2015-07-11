#!/bin/bash
for file in `cat disable.lst`; do echo ${file}; mv ${file}.disable ${file}; done

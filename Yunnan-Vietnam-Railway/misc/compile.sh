#!/bin/bash

pandoc --standalone --latex-engine=xelatex -V CJKmainfont="Microsoft YaHei" -o sample.pdf \
../README.md \
../DAY1.md \
../DAY2.md \
../DAY3.md \
../DAY4.md \
../DAY5.md \
../DAY6.md \
../DAY7.md \
../DAY8.md \
../DAY9.md \
;

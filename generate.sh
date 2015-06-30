#!/bin/bash
gitbook build
# note : for this to work, one must have installed gitbook-cli and ebook-convert (through npm) and calibre (through apt-get)
gitbook pdf . ./introduction_elasticsearch.pdf

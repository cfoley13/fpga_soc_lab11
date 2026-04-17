#!/bin/bash
echo "Content-type: text/html" # Tells the browser what kind of content to expect
echo "" # An empty line. Mandatory, if it is missed the page content will not load
echo "<p><em>"
echo "loading PL...<br>"
fpgautil -b lab11.bit.bin
echo "done...<br>"
echo "</p></em><p>"
echo "configuring Codec...<br>"
./configure_codec.sh
echo "</p>"
echo "<p><em>All Done!</em></p>" 

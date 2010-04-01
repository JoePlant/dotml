@echo off

xsltproc %DOTML%\stylesheet\dot.xsl %1.xml > %1.dot
dot -Tsvg %1.dot -o %1.svg


%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getCoords1.m script

read Results Table from MIJI and store the coordinates as the fijichannel3
variable
%}

fijichannel3=MIJ.getResultsTable;
fijichannel3=fijichannel3(:,5:6);
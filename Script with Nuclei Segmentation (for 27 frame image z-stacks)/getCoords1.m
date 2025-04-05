%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getCoords1.m script

read Results Table from MIJI and store the coordinates as the fijichannel1
variable
%}

fijichannel1=MIJ.getResultsTable;
fijichannel1=fijichannel1(:,5:6);
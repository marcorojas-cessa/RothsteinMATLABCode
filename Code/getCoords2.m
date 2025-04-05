%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getCoords1.m script

read Results Table from MIJI and store the coordinates as the fijichannel2
variable
%}

fijichannel2=MIJ.getResultsTable;
fijichannel2=fijichannel2(:,5:6);
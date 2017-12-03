clear all;
numOfNeurons = 92;
addpath('../Tools/append_pdfs');
pdfs = dir(['./Results/PDF/Neuron_*.pdf']);
length(pdfs)
for i = 31:60
    fileName = strcat('./Results/PDF/','neuron_', num2str(i) ,'_results.pdf');
    append_pdfs(['./Results/PDF/results2.pdf'],fileName);
end
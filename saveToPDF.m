clear all;
numOfNeurons = 92;
addpath('../Tools/append_pdfs');
for i = 1:numOfNeurons
   figs = dir(['./Results/Neuron_' num2str(i) '_*.fig']);
   numOfFigs = length(figs);
   for j = 1:numOfFigs
       figs(j).name
    openfig(['./Results/' figs(j).name], 'invisible');
    fileName = ['./Results/PDF/' 'fig_' num2str(i) '_' num2str(j) '.pdf'];

    print(fileName, '-dpdf', '-fillpage');
    append_pdfs(['./Results/PDF/neuron_' num2str(i) '_results.pdf'], fileName);
   end
end
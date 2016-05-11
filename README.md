# EJLFigureReproduction

Reproduces Fig. 2 of Heitman, Brackbill, Greschner, Litke, Sher &
Chichilnisky, 2016 with isetbio.

http://biorxiv.org/content/early/2016/03/24/045336

Load a movie stimulus, generate an os object for the movie, generate an
inner retina object, load parameters from a physiology experiment in the
Chichilnisky Lab into the IR object and compute the response of the RGC
mosaic.

Selected rasters and PSTHs for particular cells are shown which match the
cells in the figure. The fractional variance explained is computed for
each cell for a white noise test movie and a natural scenes test movie.
These values are plotted against each other to show the failure of the
GLM model to predict the cells' responses to natural scene stimuli.

Currently, only the dataset from the first experiment is available on the
Remote Data Toolbox. This dataset includes parameters for GLM fits to
cells in the On Parasol and Off Parasol mosaics as well as the recorded
spikes from the experiment. 

4/2016
(c) isetbio team

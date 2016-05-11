% t_rgcNaturalScenesFigure2
% 
% Reproduce Fig. 2 of Heitman, Brackbill, Greschner, Litke, Sher &
% Chichilnisky, 2016 with isetbio.
% 
% http://biorxiv.org/content/early/2016/03/24/045336
% 
% Load a movie stimulus, generate an os object for the movie, generate an
% inner retina object, load parameters from a physiology experiment in the
% Chichilnisky Lab into the IR object and compute the response of the RGC
% mosaic.
% 
% Selected rasters and PSTHs for particular cells are shown which match the
% cells in the figure. The fractional variance explained is computed for
% each cell for a white noise test movie and a natural scenes test movie.
% These values are plotted against each other to show the failure of the
% GLM model to predict the cells' responses to natural scene stimuli.
% 
% Currently, only the dataset from the first experiment is available on the
% Remote Data Toolbox. This dataset includes parameters for GLM fits to
% cells in the On Parasol and Off Parasol mosaics as well as the recorded
% spikes from the experiment. 
% 
% 4/2016
% (c) isetbio team

%% Initialize 
clear
% ieInit;

%% Switch on input type
% White noise (WN) or natural scenes with eye movements (NSEM)

% In order to generate the plot of the fractional variance for all of the
% selected cells, the script must be run with the three for loops (lines
% 46-48), and the two stimulusTestI values must be iterated through. To run the
% tutorial step by step, uncomment lines 40-42 and execute each cell,
% instead of running the script through.

% experimentI   = 1;
% cellTypeI     = 1;
% stimulusTestI = 2;

plotFracFlag = 0;

for experimentI   = 1       % Choose dataset to load parameters and spikes
for cellTypeI     = 2%:2    % Choose On Parasol (1) or Off Parasol (2)
for stimulusTestI = 1:2     % Choose WN test stimulus (1) or NSEM test stimulus (2)
% Switch on the conditions indices
% Experimental dataset
switch experimentI
    case 1; experimentID = '2013-08-19-6';
    otherwise; error('Data not yet available');
%     case 2; experimentID = '2012-08-09-3'; % Data not yet available
%     case 3; experimentID = '2013-10-10-0';
%     case 4; experimentID = '2012-09-27-3';
end
% The other experimental data will be added to the RDT in the future.

% Stimulus: white noise or natural scene movie with eye movements
switch stimulusTestI
    case 1; stimulusTest = 'WN';
    case 2; stimulusTest = 'NSEM';
end

% Cell type: ON or OFF Parasol
switch cellTypeI
    case 1; cellType = 'On Parasol';
    case 2; cellType = 'Off Parasol';
end
%% Load stimulus movie and fit/spiking data using RemoteDataToolbox

% Loads the appropriate movie and spiking data for the experimental
% conditions.
[testmovie, xval_mosaic] =  loadDataRGCFigure2(experimentI,stimulusTestI,cellTypeI);

% Length of WN movie is 1200, take nFrames to limit natural movie to same length
nFrames = 1200; 
testmovieshort = testmovie.matrix(:,:,1:nFrames); 

%% Show test movie
showFrames = 50;
ieMovie(testmovieshort(:,:,1:showFrames));

%% Generate outer segment object

% In this case, the RGC GLM calculation converts from the frame buffer
% values in the movie to the spiking responses.  For this calculation, we
% store the movie stimulus in the the outer segment object 'displayRGB'.

os1 = osCreate('displayRGB'); 
os1 = osSet(os1, 'timeStep', 1/120);

% Attach the movie to the object
os1 = osSet(os1, 'rgbData', double(testmovieshort));

%% Generate RGC object for simulated GLM prediction of response
% Set the parameters for the inner retina RGC mosaic. For the inner retina
% type irPhys, the values for eyeSide, eyeRadius and eyeAngle have no
% effect, because those are dependent on the properties of the retinal
% piece used in the Chichilnisky Lab experiment.

% Set parameters
params.name = 'macaque phys';
params.eyeSide = 'left'; 
params.eyeRadius = 12; 
params.eyeAngle = 0; ntrials = 0;

% Determined at beginning to allow looping
params.experimentID = experimentID; % Experimental dataset
params.stimulusTest = stimulusTest; % WN or NSEM
params.cellType = cellType;         % ON or OFF Parasol

% Create object
innerRetina = irPhys(os1, params);
nTrials = 57; innerRetina = irSet(innerRetina,'numberTrials',nTrials);

%% Plot a few simple properties

% Select the cells used in the actual paper
switch cellTypeI
    case 1; cellInd = 2;
    case 2; cellInd = 31;
end

% Plot the spatial RF, temporal IR and post-spike filter
if plotFracFlag == 0
    irPlotFig2Linear(innerRetina,cellInd);
end
%% Compute the inner retina response

% Linear convolution
innerRetina = irCompute(innerRetina, os1);

% Spike computation
for tr = 1:ntrials
    innerRetina = irComputeSpikes(innerRetina, os1);
end

% Get the PSTH from the object
innerRetinaPSTH = mosaicGet(innerRetina.mosaic{1},'responsePsth');

%% Create a new inner retina object and attach the recorded spikes
% We also want to compare the spikes recorded in the experiment to those
% from the simulation. We create a separate inner retina object with
% isetbio to store these spikes. This makes it easy to use isetbio to plot
% aspects of the response.

% Create the object.
innerRetinaRecorded = irPhys(os1, params);  
innerRetinaRecorded = irSet(innerRetinaRecorded,'numberTrials',nTrials);

% Set the recorded spikes that we got from the RDT into the object.
innerRetinaRecorded = irSet(innerRetinaRecorded,'recordedSpikes',xval_mosaic);
% Get the PSTH using an isetbio routine.
innerRetinaRecordedPSTH = mosaicGet(innerRetinaRecorded.mosaic{1},'responsePsth');

%% Compare Rasters and PSTHs for a particular cell
switch cellTypeI
    case 1; cellInd = 2;
    case 2; cellInd = 31;
end
% Plot the simulated and recorded rasters for a cell
irPlotFig2Raster(innerRetina, innerRetinaRecorded,cellInd,stimulusTestI);
% Plot the simulated and recorded PSTHs for a cell
irPlotFig2PSTH(innerRetina, innerRetinaPSTH, innerRetinaRecordedPSTH,cellInd,stimulusTestI);

%% Calculate fractional variance predicted
% The fraction of explained variance is used as a mesaure of the accuracy
% of the simulated PSTH.
fractionalVariance{experimentI,stimulusTestI,cellTypeI} = ...
    calculateFractionalVariance(innerRetinaPSTH, innerRetinaRecordedPSTH, stimulusTestI);

% Plot the explained variance for WN and NSEM against each other
if (stimulusTestI == 2) && (plotFracFlag == 1); 
    irPlotFig2FracVar(experimentI,cellTypeI,fractionalVariance); 
    
end;

plotFracFlag = 1;
%%%
end%stimulusTestI
end%cellTypeI
end%experimentI

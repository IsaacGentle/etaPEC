%% Intialise Graphical User Interface
% Does what it says on the tin...

% If your matlab paths get all mucked up:
% 1) run in command line: restoredefaultpath
% 2) Rerun this script

%% Add all folder below this one to path
currentFolder = pwd;
addpath([currentFolder,'\gui'])
addpath([currentFolder,'\data'])
addpath([currentFolder,'\library'])
addpath([currentFolder,'\library\input'])
addpath([currentFolder,'\library\modelPEC'])
addpath([currentFolder,'\library\modelPV'])

%% Load GUI
PEC_device_efficiency_GUI()
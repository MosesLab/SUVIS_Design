function [ r ] = draw_zemax( args )

% if ~exist('args', 'var')
%     args = [];
% end

% Initialize the OpticStudio connection
TheApplication = InitConnection();
if isempty(TheApplication)
    % failed to initialize a connection
    r = [];
else
    try
        r = BeginApplication(TheApplication, args);
        CleanupConnection(TheApplication);
    catch err
        CleanupConnection(TheApplication);
        rethrow(err);
    end
end
end


function [r] = BeginApplication(TheApplication, args)
% INPUT PARAMETERS:
%  phi_s = angular position of   slit   on Rowland circle (rad)
%  phi_g = angular position of grating  on Rowland circle (rad)
%  phi_d = angular position of detector on Rowland circle (rad)
%  R_g = grating radius
%  w_g = grating width (diameter if circular)
%  d_s = width of slit
%  d_g = grating groove period
%  d_d = detector pixel spacing
%  N_d = Number of detector pixels in the dispersion direction
%  m = spectral order
%  lambda = wavelength
phi_s = args(1);
phi_g = args(2);
phi_d = args(3);
R_g = args(4);
w_g = args(5);
d_s = args(6);
d_g = args(7);
d_d = args(8);
N_d = args(9);
m = args(10);

RR = R_g/2 % radius of Rowland circle

% Cartesian coordinates of grating, slit, and detector (centers).
x_g = RR .* cos(phi_g);
y_g = RR .* sin(phi_g);
x_s = RR .* cos(phi_s);
y_s = RR .* sin(phi_s);
x_d = RR .* cos(phi_d);
y_d = RR .* sin(phi_d);

% Displacement vector from grating to slit
x_gs = (x_s - x_g);
y_gs = (y_s - y_g);

% Grating normal unit vector
x_gn = (-x_g)/RR;
y_gn = (-y_g)/RR;

% Alpha angle at grating center (inverting the cross product)
alpha = angle2d( x_gn, y_gn, x_gs, y_gs );

% beta angle at center of detector
beta = angle2d( x_gn, y_gn, x_d, y_d );

% wavelength at center of detector
lambda = (d_g ./ m) .* ( sin(alpha) + sin(beta) );


import ZOSAPI.*;
import ZOSAPI_Interfaces.*;



% Set up primary optical system
TheSystem = TheApplication.PrimarySystem;
% Make new file
testFile = 'E:\Users\byrdie\School\Research\SUVIS_Design\matlab\zemax\design.zmx';
TheSystem.New(false);
TheSystem.SaveAs(testFile);

% Aperture
TheSystemData = TheSystem.SystemData;
TheSystemData.Aperture.ApertureValue = 4;
% Fields
Field_1 = TheSystemData.Fields.GetField(1);
Field_2 = TheSystemData.Fields.AddField(0,0.5,1.0);
% Wavelength preset
TheSystemData.Wavelengths.GetWavelength(1).Wavelength = lambda;

% Lens data
TheLDE = TheSystem.LDE;
cBreak = TheLDE.InsertNewSurfaceAt(2);
cBreak.ChangeType(ZOSAPI_Interfaces.SurfaceType_CoordinateBreak)


% Save and close
TheSystem.Save();

r = [];
end

function movePolar(TheLDE, ind)
    
    cBreak = TheLDE.InsertNewSurfaceAt(ind);
    cBreak.SurfaceType = CoordinateBreak;

end

function app = InitConnection()

import System.Reflection.*;

% Find the installed version of OpticStudio.

% This method assumes the helper dll is in the .m file directory.
% p = mfilename('fullpath');
% [path] = fileparts(p);
% p = strcat(path, '\', 'ZOSAPI_NetHelper.dll' );
% NET.addAssembly(p);

% This uses a hard-coded path to OpticStudio
NET.addAssembly('C:\Program Files\Zemax OpticStudio\ZOS-API\Libraries\ZOSAPI_NetHelper.dll');

success = ZOSAPI_NetHelper.ZOSAPI_Initializer.Initialize();
% Note -- uncomment the following line to use a custom initialization path
% success = ZOSAPI_NetHelper.ZOSAPI_Initializer.Initialize('C:\Program Files\OpticStudio\');
if success == 1
    LogMessage(strcat('Found OpticStudio at: ', char(ZOSAPI_NetHelper.ZOSAPI_Initializer.GetZemaxDirectory())));
else
    app = [];
    return;
end

% Now load the ZOS-API assemblies
NET.addAssembly(AssemblyName('ZOSAPI_Interfaces'));
NET.addAssembly(AssemblyName('ZOSAPI'));

% Create the initial connection class
TheConnection = ZOSAPI.ZOSAPI_Connection();

% Attempt to create a Standalone connection

% NOTE - if this fails with a message like 'Unable to load one or more of
% the requested types', it is usually caused by try to connect to a 32-bit
% version of OpticStudio from a 64-bit version of MATLAB (or vice-versa).
% This is an issue with how MATLAB interfaces with .NET, and the only
% current workaround is to use 32- or 64-bit versions of both applications.
app = TheConnection.CreateNewApplication();
if isempty(app)
    HandleError('An unknown connection error occurred!');
end
if ~app.IsValidLicenseForAPI
    HandleError('License check failed!');
    app = [];
end

end

function LogMessage(msg)
disp(msg);
end

function HandleError(error)
ME = MXException(error);
throw(ME);
end

function  CleanupConnection(TheApplication)
% Note - this will close down the connection.

% If you want to keep the application open, you should skip this step
% and store the instance somewhere instead.
TheApplication.CloseApplication();
end



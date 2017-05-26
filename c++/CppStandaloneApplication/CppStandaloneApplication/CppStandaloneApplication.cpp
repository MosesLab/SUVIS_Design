// CppStandaloneApplication.cpp : Defines the entry point for the console application.
//



#include "stdafx.h"
#include <stdlib.h>
#include <stdio.h>

#define _USE_MATH_DEFINES // for C++  

#include <cmath>

#include <iostream>
#include <string>
#include <ctime>
#include <functional>
#include <assert.h>




#import "C:\\Program Files\\Zemax OpticStudio\\ZOS-API\\Libraries\\ZOSAPII.tlb"
#import "C:\\Program Files\\Zemax OpticStudio\\ZOS-API\\Libraries\\ZOSAPI.tlb"
// Note - .tlh files will be generated from the .tlb files (above) once the project is compiled.
// Visual Studio will incorrectly continue to report IntelliSense error messages however until it is restarted.

using namespace std;
using namespace ZOSAPI;
using namespace ZOSAPI_Interfaces;

double angle2d(double ax, double ay, double bx, double by);
void move_polar(ILensDataEditorPtr lde, ILDERowPtr row, double r, double phi);
void handleError(std::string msg);
void logInfo(std::string msg);
void finishStandaloneApplication(IZOSAPI_ApplicationPtr TheApplication);

int _tmain(int argc, _TCHAR* argv[])
{
	CoInitialize(NULL);

	// Create the initial connection class
	IZOSAPI_ConnectionPtr TheConnection(__uuidof(ZOSAPI_Connection));


	// Attempt to create a Standalone connection
	IZOSAPI_ApplicationPtr TheApplication = TheConnection->CreateNewApplication();
	if (TheApplication == nullptr)
	{
		handleError("An unknown error occurred!");
		return -1;
	}

	// Check the connection status
	if (!TheApplication->IsValidLicenseForAPI)
	{
		handleError("License check failed!");
		return -1;
	}
	if (TheApplication->Mode != ZOSAPI_Mode::ZOSAPI_Mode_Server)
	{
		handleError("Standlone application was started in the incorrect mode!");
		return -1;
	}

	// Start the Zemax application
	IOpticalSystemPtr TheSystem = TheApplication->PrimarySystem;

	// Open a new Zemax file
	TheSystem->New(false);

	// Design using a custom grating
	double offset = 4 * M_PI / 180; // Offset detector from normal
	double phi_s = 10 * M_PI / 180; // (rad)angular position of slit     on Rowland Circle
	double phi_g = M_PI - offset; // (rad)angular position of grating  on Rowland Circle
	double phi_d = offset; // (rad)angular position of detector on Rowland Circle
	double R_g = 1500; // (mm)grating radius
	double w_g = 75; // grating diameter
	double d_s = 15e-3; // (mm)width of slit
	double d_g = 1 / 2400; // (mm)grating groove period
	double d_d = 15e-3; // (mm)detector pixel spacing
	double N_d = 2048; // Number of detector pixels in the dispersion direction
	double m = 1; // spectral order
	double r_s = 3;		// (mm) Radius of feed optic
	double h_d = N_d / 2 * d_d;	// Full height of the detector

	double RR = R_g / 2;	// Radius of rowland circle

	// Cartesian coordinates of grating slit and detector (centers).
	double z_g = RR * cos(phi_g);
	double x_g = RR * sin(phi_g);
	double z_s = RR * cos(phi_s);
	double x_s = RR * sin(phi_s);
	double z_d = RR * cos(phi_d);
	double x_d = RR * sin(phi_d);

	// Displacement vector from grating to slit
	double z_gs = z_s - z_g;
	double x_gs = x_s - x_g;

	// Grating normal unit vector
	double z_gn = - z_g / RR;
	double x_gn = -x_g / RR;

	// Alpha angle at grating center
	double alpha = angle2d(z_gn, x_gn, z_gs, x_gs);

	// Beta angle at center of detector
	double beta = angle2d(z_gn, x_gn, z_d, x_d);

	// Wavelength at center of detector
	double lambda = (d_g / m) * (sin(alpha) + sin(beta));

	TheSystem->SystemData->Aperture->ApertureValue = w_g;

	// Open the lens data editor
	ILensDataEditorPtr lde = TheSystem->LDE;

	// Perform a coordinate transfor to the center of the Rowland circle, with the entrance slit on
	// the same x-coordinate as the slit
	ILDERowPtr ov_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// grab the stop surface
	ov_row->ChangeType(ov_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr ov_surf = ov_row->SurfaceData;	// acquire surface data to access coordinate break methods
	ov_surf->Decenter_X = -x_s;	// change the decenter to be on the same x-coordinate as the slit
	ov_row->Thickness = RR;		// Move to the center of the rowland circle

	// Create the feed optic
	ILDERowPtr s_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Insert the surface before the image surface
	s_row->ChangeType(s_row->GetSurfaceTypeSettings(SurfaceType_Toroidal));		// Change the surface type to toroidal
	ISurfaceToroidalPtr s_surf = s_row->SurfaceData;
	s_surf->RadiusOfRotation = r_s;		// Radius of rotation of the toroid is equal to the radius of the feed optic
	ISurfaceApertureTypePtr s_apType = s_row->ApertureData->CreateApertureTypeSettings(SurfaceApertureTypes_RectangularAperture);
	ISurfaceApertureRectangularPtr rect = s_apType->Get_S_RectangularAperture();
	rect->XHalfWidth = r_s;		// x half width equal to radius of feed optic
	rect->YHalfWidth = w_g / 2; // y half width equal to radius of grating
	s_row->ApertureData->ChangeApertureTypeSettings(s_apType);
	s_row->Material = _bstr_t::_bstr_t("MIRROR");
	move_polar(lde, s_row, RR - r_s, phi_s);

	// Create the diffraction grating
	ILDERowPtr g_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Insert the surface before the image surface
	s_row->ChangeType(s_row->GetSurfaceTypeSettings(SurfaceType_DiffractionGrating));		// Change the surface type to diffraction grating
	ISurfaceDiffractionGratingPtr g_surf = g_row->SurfaceData;
	//g_surf->DiffractionOrder = m;	// Image in the diffraction order specified by m
	//g_surf->LinesPerMicroMeter = 1 / d_g;	// Number of lines per millimeter is also specified as an argument
	//g_row->SemiDiameter = w_g / 2;



	TheSystem->SaveAs(_bstr_t::_bstr_t("E:\\Users\\byrdie\\School\\Research\\SUVIS_Design\\zemax\\suvis_design.zmx"));

	

	TheSystem->Close(false);
			
	// Clean up
	finishStandaloneApplication(TheApplication);
	

	return 0;
}

// Find the angle between a pari of 2-vectors. Given components of vectors a and b,
// the angle theta is from a to b. That is, if a cross b is positive, then alpha is positive
double angle2d(double ax, double ay, double bx, double by) {

	// Magnitudes of the two vectors
	double a = sqrt(ax * ax + ay * ay);
	double b = sqrt(bx * bx + by * by);

	// Simply invert the cross product
	return asin((ax * by - ay * bx) / (a * b));

}

// Move a surface to the specified polar position and then return to the original point
void move_polar(ILensDataEditorPtr lde, ILDERowPtr row, double r, double phi) {

	ILDERowPtr cb1_row = lde->InsertNewSurfaceAt(row->SurfaceNumber);	// create first coordinate break at same index as input surface
	cb1_row->ChangeType(cb1_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb1_surf = cb1_row->SurfaceData;	// acquire surface data to access coordinate break methods
	cb1_surf->TiltAbout_Y = phi * 180 / M_PI;
	cb1_row->Thickness = r;		// Move to the center of the rowland circle

	ILDERowPtr cb2_row = lde->InsertNewSurfaceAt(row->SurfaceNumber + 2);	// create second coordinate break after input surface
	cb2_row->ChangeType(cb2_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb2_surf = cb2_row->SurfaceData;	// acquire surface data to access coordinate break methods
	cb2_surf->TiltAbout_Y = -phi * 180 / M_PI;
	cb2_row->Thickness = -r;		// Move to the center of the rowland circle

}

void handleError(std::string msg)
{
	throw new exception(msg.c_str());
}

void logInfo(std::string msg)
{
	printf("%s", msg.c_str());
}

void finishStandaloneApplication(IZOSAPI_ApplicationPtr TheApplication)
{
    // Note - TheApplication will close automatically when this application exits, so this isn't strictly necessary in most cases
	if (TheApplication != nullptr)
	{
		TheApplication->CloseApplication();
	}
}



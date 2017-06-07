// CppStandaloneApplication.cpp : Defines the entry point for the console application.
//



#include "stdafx.h"
#include <stdlib.h>
#include <stdio.h>

#define _USE_MATH_DEFINES // for C++  

#include <cmath>

#include <sstream>
#include <fstream>
#include <iostream>
#include <string>
#include <ctime>
#include <functional>
#include <assert.h>
#include <direct.h>
#include <algorithm>
#include <vector>
#include <locale>
#include <clocale>
#include <codecvt>






#import "C:\\Program Files\\Zemax OpticStudio\\ZOS-API\\Libraries\\ZOSAPII.tlb"
#import "C:\\Program Files\\Zemax OpticStudio\\ZOS-API\\Libraries\\ZOSAPI.tlb"
// Note - .tlh files will be generated from the .tlb files (above) once the project is compiled.
// Visual Studio will incorrectly continue to report IntelliSense error messages however until it is restarted.

using namespace std;
using namespace ZOSAPI;
using namespace ZOSAPI_Interfaces;

double angle2d(double ax, double ay, double bx, double by);
void move_polar(ILensDataEditorPtr lde, ILDERowPtr row, double r, double phi);
void rot_z(ILensDataEditorPtr lde, ILDERowPtr row, double phi);
void handleError(std::string msg);
void logInfo(std::string msg);
void finishStandaloneApplication(IZOSAPI_ApplicationPtr TheApplication);
vector<double> getRayXY(string file);
vector<vector<string>> parse_ray_file(string file);
void print_ray_file(vector<vector<string>> mat);
string ws2s(wstring wstr);

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

	int ray_density = 200;

	// Design using a custom grating
	double offset = 4.1 * M_PI / 180.0; // Offset detector from normal
	double phi_s = offset + 30 * M_PI / 180.0; // (rad)angular position of slit     on Rowland Circle
	double phi_g = M_PI - offset; // (rad)angular position of grating  on Rowland Circle
	double phi_d = offset; // (rad)angular position of detector on Rowland Circle
	double R_g = 1000; // (mm)grating radius
	double w_g = 100; // grating diameter
	double d_s = 15e-3; // (mm)width of slit
	double d_g = 1.0 / 2160.0; // (mm)grating groove period
	double d_d = 15e-3; // (mm)detector pixel spacing
	int N_d = 2048; // Number of detector pixels in the dispersion direction
	int m = 1; // spectral order
	double r_s = 3;		// (mm) Radius of feed optic

	
	//double phi_s = _tcstod(argv[1], NULL);	 // (rad)angular position of slit     on Rowland Circle
	//double phi_g = _tcstod(argv[2], NULL);	// (rad)angular position of grating  on Rowland Circle
	//double phi_d = _tcstod(argv[3], NULL);	 // (rad)angular position of detector on Rowland Circle
	//double R_g = _tcstod(argv[4], NULL); // (mm)grating radius
	//double w_g = _tcstod(argv[5], NULL);	 // grating diameter
	//double d_s = _tcstod(argv[6], NULL);	 // (mm)width of slit
	//double d_g = _tcstod(argv[7], NULL);	 // (mm)grating groove period
	//double d_d = _tcstod(argv[8], NULL); ; // (mm)detector pixel spacing
	//int N_d = stoi(argv[9]); ; // Number of detector pixels in the dispersion direction
	//int m =  stoi(argv[10]); ; // spectral order
	//double r_s = _tcstod(argv[11], NULL);			// (mm) Radius of feed optic


	double h_d = N_d / 2.0 * d_d;	// Full height of the detector
	double h_s = h_d * 2.0; // Height of aperture

	double w_d = (N_d - 1) * d_d;

	double RR = R_g / 2.0;	// Radius of rowland circle

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

	// Displacement vector from grating to detector
	double z_gd = z_d - z_g;
	double x_gd = x_d - x_g;

	// Alpha angle at grating center
	double alpha = angle2d(z_gn, x_gn, z_gs, x_gs);

	// Beta angles
	double beta_0 = angle2d(z_gn, x_gn, z_gd - w_d/2 * sin(phi_d), x_gd + w_d / 2 * cos(phi_d));	// Wavelength on left edge of detector
	double beta_1 = angle2d(z_gn, x_gn, z_gd, x_gd);	// wavelength in center of detector
	double beta_2 = angle2d(z_gn, x_gn, z_gd + w_d / 2 * sin(phi_d), x_gd - w_d / 2 * cos(phi_d));	// wavelength on right edge of detector

	// Wavelength at center of detector
	double lambda_0 = (d_g / ((double) m)) * (sin(alpha) + sin(beta_0));
	double lambda_1 = (d_g / ((double)m)) * (sin(alpha) + sin(beta_1));
	double lambda_2 = (d_g / ((double)m)) * (sin(alpha) + sin(beta_2));

	// Calculate vectors from center of grating to edge of grating
	// in the plane of the Rowland circle
	double z_g_plus = -w_g * x_gn / 2;
	double x_g_plus = -w_g * z_gn / 2;
	double z_g_minus = -z_g_plus;
	double x_g_minus = -x_g_plus;


	// Calculate the vectors from the edge of the grating to the virtual image
	// inside the feed optic
	double z_gs_plus = z_gs - z_g_plus;
	double x_gs_plus = x_gs - x_g_plus;
	double z_gs_minus = z_gs - z_g_minus;
	double x_gs_minus = x_gs - x_g_minus;

	// Find the vector from the virtual image to the surface of the feed optic
	double z_v_zero = -(r_s / 2.0) * z_gs / sqrt(z_gs * z_gs + x_gs * x_gs);
	double x_v_zero = -(r_s / 2.0) * x_gs / sqrt(z_gs * z_gs + x_gs * x_gs);
	double z_v_plus = -(r_s / 2.0) * z_gs_plus / sqrt(z_gs_plus * z_gs_plus + x_gs_plus * x_gs_plus);
	double x_v_plus = -(r_s / 2.0) * x_gs_plus / sqrt(z_gs_plus * z_gs_plus + x_gs_plus * x_gs_plus);
	double z_v_minus = -(r_s / 2.0) * z_gs_minus / sqrt(z_gs_minus * z_gs_minus + x_gs_minus * x_gs_minus);
	double x_v_minus = -(r_s / 2.0) * x_gs_minus / sqrt(z_gs_minus * z_gs_minus + x_gs_minus * x_gs_minus);
	

	

	// Add wavelengths into zemax
	TheSystem->SystemData->Aperture->ApertureValue = h_s;
	TheSystem->SystemData->Wavelengths->GetWavelength(1)->Wavelength = lambda_1 * 1000.0;
	TheSystem->SystemData->Wavelengths->AddWavelength(lambda_0 * 1000.0, 1.0);
	TheSystem->SystemData->Wavelengths->AddWavelength(lambda_2 * 1000.0, 1.0);

	// Add Fields
	double vdx = (x_v_plus + x_v_minus) / 2.0 / (TheSystem->SystemData->Aperture->ApertureValue / 2.0);
	double vcx = 1 - (abs(x_v_plus - x_v_minus) / 2.0) / (TheSystem->SystemData->Aperture->ApertureValue / 2.0);
	IFieldPtr f0 = TheSystem->SystemData->Fields->GetField(1);
	IFieldPtr f1 = TheSystem->SystemData->Fields->AddField(0.25, 0.0, 1.0);
	IFieldPtr f2 = TheSystem->SystemData->Fields->AddField(-0.25, 0.0, 1.0);
	IFieldPtr f3 = TheSystem->SystemData->Fields->AddField(0.0, 0.25, 1.0);
	IFieldPtr f4 = TheSystem->SystemData->Fields->AddField(0.0, -0.25, 1.0);
	f0->VDX = vdx;
	f1->VDX = vdx;
	f2->VDX = vdx;
	f3->VDX = vdx;
	f4->VDX = vdx;
	f0->VCX = vcx;
	f1->VCX = vcx;
	f2->VCX = vcx;
	f3->VCX = vcx;
	f4->VCX = vcx;

	// Enable ray aiming to determine the correct stop location
	//TheSystem->SystemData->RayAiming->RayAiming = RayAimingMethod_Real;
	//TheSystem->SystemData->RayAiming->UseRayAimingCache = true;
	//TheSystem->SystemData->RayAiming->AutomaticallyCalculatePupilShiftsIsChecked = false;
	//TheSystem->SystemData->RayAiming->PupilShiftX = (x_v_plus + x_v_minus) / 2.0;
	//TheSystem->SystemData->RayAiming->PupilCompressX = vcx;

	// Open the lens data editor
	ILensDataEditorPtr lde = TheSystem->LDE;
	

	// Add a dummy surface to place the stop in the correct location
	ILDERowPtr dum_row = lde->GetSurfaceAt(1);
	dum_row->Thickness = RR + z_s - r_s / 2.0;
	dum_row->Comment = _bstr_t::_bstr_t("DUMMY");



	// Create the feed optic
	//ILDERowPtr so_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Create rotation offset surface
	//so_row->ChangeType(so_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	//so_row->Thickness = r_s / 2;
	//so_row->Comment = _bstr_t::_bstr_t("FEED OPTIC rotation offset");
	ILDERowPtr s_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Insert the surface before the image surface
	s_row->ChangeType(s_row->GetSurfaceTypeSettings(SurfaceType_Toroidal));		// Change the surface type to toroidal
	ISurfaceToroidalPtr s_surf = s_row->SurfaceData;
	s_surf->RadiusOfRotation = r_s;		// Radius of rotation of the toroid is equal to the radius of the feed optic
	ISurfaceApertureTypePtr s_apType = s_row->ApertureData->CreateApertureTypeSettings(SurfaceApertureTypes_RectangularAperture);
	ISurfaceApertureRectangularPtr rect = s_apType->Get_S_RectangularAperture();
	rect->XHalfWidth =  r_s;		// x half width equal to radius of feed optic
	rect->YHalfWidth = h_s; // y half width equal to double the height of the detector
	s_row->ApertureData->ChangeApertureTypeSettings(s_apType);
	s_row->TypeData->IsStop = true;
	s_row->Material = _bstr_t::_bstr_t("MIRROR");
	s_row->Comment = _bstr_t::_bstr_t("FEED OPTIC");
	// move_polar(lde, s_row, RR - r_s, phi_s);
	//ILDERowPtr si_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Create rotation offset surface
	//si_row->ChangeType(si_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	//ISolveDataPtr si_solve = si_row->ThicknessCell->CreateSolveType(SolveType_SurfacePickup);
	//si_solve->Get_S_SurfacePickup()->Surface = so_row->SurfaceNumber;
	//si_solve->Get_S_SurfacePickup()->ScaleFactor = -1;
	//si_row->ThicknessCell->SetSolveData(si_solve);
	//si_row->Comment = _bstr_t::_bstr_t("FEED OPTIC inverse rotation offset");

	// Perform a coordinate transfor to the center of the Rowland circle, with the entrance slit on
	// the same x-coordinate as the slit
	ILDERowPtr ov_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// grab the stop surface
	ov_row->ChangeType(ov_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr ov_surf = ov_row->SurfaceData;	// acquire surface data to access coordinate break methods
	ov_surf->Decenter_X = -x_s;	// change the decenter to be on the same x-coordinate as the slit
	ov_row->Thickness = -z_s + r_s / 2.0;	// Move to the center of the rowland circle
	ov_row->Comment = _bstr_t::_bstr_t("Center on Rowland circle");

	// Create the diffraction grating
	ILDERowPtr g_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// Insert the surface before the image surface
	g_row->ChangeType(s_row->GetSurfaceTypeSettings(SurfaceType_DiffractionGrating));		// Change the surface type to diffraction grating
	ISurfaceDiffractionGratingPtr g_surf = g_row->SurfaceData;
	g_surf->DiffractionOrder = -m;	// Image in the diffraction order specified by m
	g_surf->LinesPerMicroMeter = 1.0 / d_g / 1000.0;	// Number of lines per millimeter is also specified as an argument
	g_row->SemiDiameter = w_g / 2.0;		// Size of diffraction grating is specified as an argument
	g_row->Material = _bstr_t::_bstr_t("MIRROR");
	g_row->Radius = R_g;
	g_row->Comment = _bstr_t::_bstr_t("GRATING");
	g_row->TypeData->SurfaceCannotBeHyperhemispheric = true;
	move_polar(lde,g_row,  -RR, phi_g - M_PI);
	rot_z(lde, lde->GetSurfaceAt(lde->NumberOfSurfaces - 4), M_PI / 2);


	// Create detector
	ILDERowPtr d_row = lde->GetSurfaceAt(lde->NumberOfSurfaces-1);
	d_row->Comment = _bstr_t::_bstr_t("DETECTOR");
	d_row->SemiDiameter = w_d / 2;
	ILDERowPtr cb1_row = lde->InsertNewSurfaceAt(lde->NumberOfSurfaces - 1);	// create first coordinate break at same index as input surface
	cb1_row->ChangeType(cb1_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb1_surf = cb1_row->SurfaceData;	// acquire surface data to access coordinate break methods
	cb1_surf->TiltAbout_Y = phi_d * 180 / M_PI;
	cb1_row->Thickness = RR;		// Move to the center of the rowland circle
	_bstr_t c1 = _bstr_t::_bstr_t("DETECTOR polar transform");
	cb1_row->Comment = _bstr_t::_bstr_t(c1);

	// Open 3D layout
	IA_Ptr draw = TheSystem->Analyses->New_Analysis_SettingsFirst(AnalysisIDM_Draw3D);
	IAS_Ptr dSet = draw->GetSettings();

	//TheSystem->Analyses->New_StandardSpot();

	//IA_Ptr ray = TheSystem->Analyses->New_RayTrace();
	//ray->WaitForCompletion();
	//IAS_RayTracePtr ray_s = ray->GetSettings();
	//ray_s->Hx = 0.0;
	//ray_s->Hy = 0.0;
	//ray_s->Px = 0.0;
	//ray_s->Py = 1.0;
	//ray_s->Type = RayTraceType_DirectionCosines;
	//ray_s->UseGlobal = false;
	//ray->ApplyAndWaitForCompletion();
	//IAR_Ptr ray_r = ray->GetResults();
	//ray_r->GetTextFile(_bstr_t::_bstr_t("D:/Users/krg/Roy Smart/School/Research/SUVIS_Design/test.txt"));
	//
	//
	//vector<vector<string>> ray_dat = parse_ray_file("D:/Users/krg/Roy Smart/School/Research/SUVIS_Design/test.txt");
	//print_ray_file(ray_dat);

	IBatchRayTracePtr rt = TheSystem->Tools->OpenBatchRayTrace();

	char buf[1000];
	_getcwd(buf, 1000);
	string cp(buf);
	string zp = cp + "/../zemax/suvis_design.zmx";
	replace(zp.begin(), zp.end(), '\\', '/');
	TheSystem->SaveAs(_bstr_t::_bstr_t(zp.c_str()));
	cout << zp << endl;
	

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

	_bstr_t row_com = row->Comment;

	ILDERowPtr cb1_row = lde->InsertNewSurfaceAt(row->SurfaceNumber);	// create first coordinate break at same index as input surface
	cb1_row->ChangeType(cb1_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb1_surf = cb1_row->SurfaceData;	// acquire surface data to access coordinate break methods
	cb1_surf->TiltAbout_Y = phi * 180 / M_PI;
	cb1_row->Thickness = r;		// Move to the center of the rowland circle
	_bstr_t c1 = _bstr_t::_bstr_t( " polar transform");
	cb1_row->Comment = _bstr_t::_bstr_t(row_com + c1);

	ILDERowPtr cb2_row = lde->InsertNewSurfaceAt(row->SurfaceNumber + 2);	// create second coordinate break after input surface
	cb2_row->ChangeType(cb2_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb2_surf = cb2_row->SurfaceData;	// acquire surface data to access coordinate break methods
	ISolveDataPtr cb2_solve = cb2_row->ThicknessCell->CreateSolveType(SolveType_SurfacePickup);
	cb2_solve->Get_S_SurfacePickup()->Surface = row->SurfaceNumber;
	cb2_solve->Get_S_SurfacePickup()->ScaleFactor = -1;
	cb2_row->ThicknessCell->SetSolveData(cb2_solve);
	_bstr_t c2 = _bstr_t::_bstr_t(" inverse transform r");
	cb2_row->Comment = _bstr_t::_bstr_t(row_com + c2);

	ILDERowPtr cb3_row = lde->InsertNewSurfaceAt(row->SurfaceNumber + 3);	// create second coordinate break after input surface
	cb3_row->ChangeType(cb3_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb3_surf = cb3_row->SurfaceData;	// acquire surface data to access coordinate break methods
	ISolveDataPtr cb3_solve = cb3_surf->TiltAbout_Y_Cell->CreateSolveType(SolveType_SurfacePickup);
	cb3_solve->Get_S_SurfacePickup()->Surface = row->SurfaceNumber;
	cb3_solve->Get_S_SurfacePickup()->ScaleFactor = -1;
	cb3_surf->TiltAbout_Y_Cell->SetSolveData(cb3_solve);
	_bstr_t c3 = _bstr_t::_bstr_t(" inverse transform phi");
	cb3_row->Comment = _bstr_t::_bstr_t(row_com + c3);

}

void rot_z(ILensDataEditorPtr lde, ILDERowPtr row, double phi) {

	_bstr_t row_com = row->Comment;

	ILDERowPtr cb1_row = lde->InsertNewSurfaceAt(row->SurfaceNumber);	// create first coordinate break at same index as input surface
	cb1_row->ChangeType(cb1_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb1_surf = cb1_row->SurfaceData;	// acquire surface data to access coordinate break methods
	cb1_surf->TiltAbout_Z = phi * 180 / M_PI;
	_bstr_t c1 = _bstr_t::_bstr_t(" rotate z");
	cb1_row->Comment = _bstr_t::_bstr_t(row_com + c1);

	ILDERowPtr cb3_row = lde->InsertNewSurfaceAt(row->SurfaceNumber + 2);	// create second coordinate break after input surface
	cb3_row->ChangeType(cb3_row->GetSurfaceTypeSettings(SurfaceType_CoordinateBreak));	// change type to coordinate break
	ISurfaceCoordinateBreakPtr cb3_surf = cb3_row->SurfaceData;	// acquire surface data to access coordinate break methods
	ISolveDataPtr cb3_solve = cb3_surf->TiltAbout_Z_Cell->CreateSolveType(SolveType_SurfacePickup);
	cb3_solve->Get_S_SurfacePickup()->Surface = row->SurfaceNumber;
	cb3_solve->Get_S_SurfacePickup()->ScaleFactor = -1;
	cb3_surf->TiltAbout_Z_Cell->SetSolveData(cb3_solve);
	_bstr_t c3 = _bstr_t::_bstr_t(" unrotate z");
	cb3_row->Comment = _bstr_t::_bstr_t(row_com + c3);

}

vector<vector<string>> parse_ray_file(string file) {
	
	vector<vector<string>> tok_mat;
	
	// Copy UTF16 file into standard string
	std::stringstream ss;
	std::ifstream fin(file);
	ss << fin.rdbuf(); // dump file contents into a stringstream
	std::string const &s = ss.str();
	std::wstring ws;
	ws.resize(s.size() / sizeof(wchar_t));
	std::memcpy(&ws[0], s.c_str(), s.size()); // copy data into wstring

	string ray_str = ws2s(ws);
	istringstream f_stream(ray_str);

	string ray_line;
	while (getline(f_stream, ray_line)) {
		istringstream l_stream(ray_line);
		vector<string> tok_line;
		string token;
		while (getline(l_stream, token, '\t')) {
			tok_line.push_back(token);
		}
		tok_mat.push_back(tok_line);
	}

	return tok_mat;
}

void print_ray_file(vector<vector<string>> mat) {
	for (unsigned int i = 0; i < mat.size(); i++) {
		vector<string> row = mat[i];
		for (unsigned int j = 0; j < row.size(); j++) {
			cout << row[j] << "_";
		}
		cout << endl;
	}
}

string ws2s(wstring wstr)
{
	string str(wstr.begin(), wstr.end());
	return str;
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



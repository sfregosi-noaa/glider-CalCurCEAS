%% load and examine

ncFile = "C:\Users\selene.fregosi\Downloads\NRS11_20212023_sensitivity.nc";

ncI = ncinfo(ncFile);

ncFreq = ncread(ncFile, 'frequency');
ncSens = ncread(ncFile, 'sensitivity');

%% modify data only
ncwrite(ncFile, 'frequency', newFreq);
% this may require the dimensions to be the same??

%% modify structure

% Open the NetCDF file for writing
ncid = netcdf.open(ncFile, 'NC_WRITE');

% Switch to define mode
netcdf.reDef(ncid);

% Add a new global attribute
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'new_attribute', 'This is my new attribute');

% If you wanted to add a new variable, you would use netcdf.defVar here.

% Exit define mode
netcdf.endDef(ncid);

% Optionally, update data in a variable
varid = netcdf.inqVarID(ncid, 'temperature');
netcdf.putVar(ncid, varid, newData);

% Close the NetCDF file
netcdf.close(ncid);

clear
close all

%% origin
lat0 =  -20.544686;
lon0 = -175.393311 + 360.0;

%% lonlat
latrange = [-60,60];
lonrange = [120,300];
dl = 0.25;
nlon = round(abs(diff(lonrange))/dl)+1;
nlat = round(abs(diff(latrange))/dl)+1;
lon = linspace(lonrange(1),lonrange(2),nlon);
lat = linspace(latrange(1),latrange(2),nlat);
[LON,LAT] = meshgrid(lon,lat);

degmesh = sqrt((LON-lon0).^2 + (LAT-lat0).^2);
kmmesh = deg2km(degmesh);

%% params
dt = 600;
t = dt:dt:3600*10;
nt = length(t);
speed = 0.3;
wavelength = 1500*0.3;


%% draw border lines
lat1 = zeros(100,nt);
lon1 = zeros(100,nt);
deg1 = zeros(nt,1);
latf = zeros(100,nt);
lonf = zeros(100,nt);
latb = zeros(100,nt);
lonb = zeros(100,nt);
for j = 1:nt
    deg1(j) = km2deg(speed*t(j));
    [lat1(:,j),lon1(:,j)] = scircle1(lat0,lon0,deg1(j),'degrees');
    [latf(:,j),lonf(:,j)] = scircle1(lat0,lon0,km2deg(speed*t(j)+0.5*wavelength),'degrees');
    [latb(:,j),lonb(:,j)] = scircle1(lat0,lon0,max(km2deg(speed*t(j)-0.5*wavelength),1),'degrees');    
end
clon = -60.0;
lon1(lon1<=clon) = lon1(lon1<=clon)+360.0;
lonf(lonf<=clon) = lonf(lonf<=clon)+360.0;
lonb(lonb<=clon) = lonb(lonb<=clon)+360.0;

npts = 500;
lon1 = interp1(1:100,lon1,linspace(1,100,npts));
lat1 = interp1(1:100,lat1,linspace(1,100,npts));
lonf = interp1(1:100,lonf,linspace(1,100,npts));
latf = interp1(1:100,latf,linspace(1,100,npts));
lonb = interp1(1:100,lonb,linspace(1,100,npts));
latb = interp1(1:100,latb,linspace(1,100,npts));

%% meshgrid interpolation
edge_lon = vertcat(lon(:), lon(:), repmat(lonrange(1),[nlat,1]), repmat(lonrange(2),[nlat,1]));
edge_lat = vertcat(repmat(latrange(1),[nlon,1]), repmat(latrange(2),[nlon,1]), lat(:), lat(:));
edge_0 = zeros(2*(nlon+nlat),1);

lontmp = LON(:);
lattmp = LAT(:);

p = 2.0;
pres = zeros(nlat,nlon,nt);
for j = 1:nt
    disp(num2str(j,'%d'));
    F = scatteredInterpolant( ...
        vertcat(lon1(:,j),lonf(:,j),lonb(:,j), edge_lon), ...
        vertcat(lat1(:,j),latf(:,j),latb(:,j), edge_lat), ...
        vertcat(p*ones(npts,1),zeros(npts,1),zeros(npts,1), edge_0), ...
        'natural','none');
%     pres(:,:,j) = reshape(F(LON(:),LAT(:)),[nlat,nlon]);
    tmp = reshape(F(LON(:),LAT(:)),[nlat,nlon]);

    %% remove
    distmat = NaN*zeros(npts,numel(lontmp));
    for l = 1:numel(lontmp)
        distmat(:,l) = deg2km(sqrt((lontmp(l)-lon1(:,j)).^2 + (lattmp(l)-lat1(:,j)).^2));
    end
    distmat = min(distmat);
    ind_0 = distmat > wavelength;
    tmp(ind_0) = 0.0;
    pres(:,:,j) = tmp;
    
end


%% save
save('pres.mat','-v7.3',...
     'lon0','lat0','lonrange','latrange','lon','lat',...
     'nlon','nlat','dl','pres','npts',...
     'speed','wavelength','dt','t','nt')


% j = 16;
% F = scatteredInterpolant(vertcat(lon1(:,j),lonf(:,j),lonb(:,j), edge_lon), ...
%                          vertcat(lat1(:,j),latf(:,j),latb(:,j), edge_lat), ...
%                          vertcat(2*ones(npts,1),zeros(npts,1),zeros(npts,1), edge_0), ...
%                          'natural','none');
% Z = reshape(F(LON(:),LAT(:)),[nlat,nlon]);
% figure
% ax = gca;
% imagesc(lon,lat,Z); ax.YDir = 'normal';
% axis equal
% colorbar;
% caxis([0,2])
% hold on
% plot(lonf(:,j),latf(:,j),'m-','LineWidth',2);
% plot(lonb(:,j),latb(:,j),'m-','LineWidth',2);
% plot(lon1(:,j),lat1(:,j),'r.','LineWidth',2);
% hold off






# R scripts in this directory are as follows:
________________________________________________

## Main scripts (used for results in the report) are:
1) Beregne naturens egnethet - Validering stier.r		: calculates nature suitability for validation trails
2) Beregne naturens egnethet - Alle stier.r				: calculates nature suitability for all trails
3) Beregne egnethet for stisyklister.r					: calculates used suitability for all trails
________________________________________________

## Additional main scripts are:
1) Beregne naturens egnethet - Validering stier.refined.r
2) Beregne naturens egnethet - Alle stier.refined.r
These refined scripts use an improved method for calculation of slope. Slope for any point is now calculated as:
 (1) change in elevation between points 5 m downstream and 5 m upstream along trail 
over
 (2) change in along-trail distance between points 5 m downstream and 5 m upstream along trail
Previously, slopes were calculated as: 
 (1) change in elevation between points 5 m downstream and 5 m upstream along trail 
over 
 (2) change in Euclidian distance between points 5 m downstream and point 5 m upstream along trail
The latter approach biases estimates with increasing wiggliness of the trail. Differences between the two approaches are generally negligble due to the short distances involved but the refined approach is recommended.

The refined scripts also allow estimation of slope at more locations (previously the minimum distance allowed was 14 m, refined versions allow this to be 10 m)

The refined script "Beregne naturens egnethet - Alle stier.refined.r" also reads a slighly cleaned version of the Langsua trail data (Langsua_NP_network_trails_cleaned.shp). In this shp file, several short trails unconnected to the network were removed; and several dicontinuous trails were split into separate trails. 
_________________________________________________
 
## Main scripts and additional main scripts read the following scripts for processing look-up-tables:

1) add.TWI.LUT.r
2) add.slope.LUT.r
3) add.single.LUT.r
4) add.joint.LUT.r
_________________________________________________

## Additional scripts for preprocessing or postprocessing data are:

1) Lage TWI LUT.r				: reads TWI rasters to make TWI look-up-tables
2) Fyll hull i 1 kvm DTM.r			: fills holes in 1 m DTM data using 10 m DTM data
3) Endre løsmasser fra vektor til raster.r	: rasterizes løsmasser vectors data
4) Slå sammen feltundersøkelse og GIS-lag.r	: merge GIS data with field data




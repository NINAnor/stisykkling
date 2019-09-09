-- CREATE SCHEMA IF NOT EXISTS stisykkling AUTHORIZATION "richard.hedger";

-- GRANT ALL ON SCHEMA stisykkling TO "richard.hedger";

-- GRANT USAGE ON SCHEMA stisykkling TO gisuser;

-- ALTER DEFAULT PRIVILEGES IN SCHEMA stisykkling GRANT SELECT ON TABLES TO gisuser;

CREATE TABLE IF NOT EXISTS stisykkling.omrade_buffer AS SELECT ST_Buffer(geom, 130000) AS geom, omrade FROM (
SELECT geom, "OMRADENAVN" AS omrade FROM "ProtectedSites"."Norway_ProtectedAreas_polygons" WHERE "OMRADENAVN" IN ('Langsua','Sjunkhatten') UNION ALL
SELECT ST_Envelope(ST_Collect(geom)) AS geom, CAST('Bergen' AS varchar(50)) AS omrade FROM stisykkling."Stislitasje_Bergen waypoints" UNION ALL
SELECT ST_Envelope(ST_Collect(geom)) AS geom, CAST('Nordseter' AS varchar(50)) AS omrade FROM stisykkling."Slitasje_Nordseter waypoints"
) AS x;
-- CREATE INDEX "stisykkling_omrade_buffer_spidx" ON stisykkling."omrade_buffer" USING gist(geom);

psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "ALTER TABLE \"Topography\".\"Norway_FKB_Veg_polygons\" ADD COLUMN geom_valid geometry;"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "UPDATE \"Topography\".\"Norway_FKB_Veg_polygons\" SET geom_valid = ST_CollectionExtract(geom, 3)
-- CASE
-- WHEN ST_IsValid(geom) THEN geom
-- ELSE ST_MakeValid(geom)
-- END
;"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "ALTER TABLE \"Topography\".\"Norway_FKB_Veg_polygons\" DROP COLUMN geom;"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "ALTER TABLE \"Topography\".\"Norway_FKB_Veg_polygons\" RENAME COLUMN geom_valid TO geom;"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"Topography_Norway_FKB_Veg_polygons_spidx\" ON \"Topography\".\"Norway_FKB_Veg_polygons\" USING gist(geom);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "VACUUM ANALYZE \"Topography\".\"Norway_FKB_Veg_polygons\";"


for table in Norway_N50_AnleggsPunkt Norway_N50_Navn Norway_N50_VegBom Norway_N50_VegSti Norway_N50_TuristHytte Norway_N50_HoydePunkt Norway_N50_ArealdekkeFlate Norway_N50_Arealdekke_polygons Norway_FKB_AR5_polygons Norway_FKB_Arealbruk_polygons Norway_FKB_Bygning_points Norway_FKB_Høydekurve_points Norway_FKB_TraktorvegSti_points Norway_FKB_TraktorvegSti_lines Norway_FKB_Veg_polygons Norway_FKB_Veg_points Norway_FKB_Veg_lines
do
res_table=$(echo $table | sed 's/Norway/Stisykkling/g')
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE TABLE IF NOT EXISTS stisykkling.\"${res_table}\" AS SELECT a.*, b.omrade FROM \"Topography\".\"${table}\" AS a, stisykkling.omrade_buffer AS b WHERE ST_Intersects(a.geom, b.geom);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"stisykkling_${res_table}_spidx\" ON stisykkling.\"${res_table}\" USING gist(geom);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"stisykkling_${res_table}_oidx\" ON stisykkling.\"${res_table}\" USING btree(omrade);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"stisykkling_${res_table}_idx\" ON stisykkling.\"${res_table}\" USING btree(gid);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "VACUUM ANALYZE stisykkling.\"${res_table}\";"
done

"TransportNetworks"."Norway_TurOgFriluftsruter_ruteinfopunkt"

table=Norway_TurOgFriluftsruter_ruteinfopunkt
res_table=$(echo $table | sed 's/Norway/Stisykkling/g')
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE TABLE IF NOT EXISTS stisykkling.\"${res_table}\" AS SELECT a.*, b.omrade FROM \"TransportNetworks\".\"${table}\" AS a, stisykkling.omrade_buffer AS b WHERE ST_Intersects(a.posisjon, b.geom);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"stisykkling_${res_table}_spidx\" ON stisykkling.\"${res_table}\" USING gist(posisjon);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE INDEX \"stisykkling_${res_table}_oidx\" ON stisykkling.\"${res_table}\" USING btree(omrade);"
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "VACUUM ANALYZE stisykkling.\"${res_table}\";"


v.in.ogr input="PG:host=gisdata-db.nina.no dbname=gisdata user=stefan.blumentrath" layer=stisykkling.omrade_buffer output=omrade_buffer
psql -h gisdata-db.nina.no -d gisdata -U stefan.blumentrath -c "CREATE TABLE IF NOT EXISTS stisykkling.nasjonalparker AS SELECT * FROM \"ProtectedSites\".\"Norway_ProtectedAreas_polygons\" WHERE \"OMRADENAVN\" IN ('Langsua','Sjunkhatten');"

v.in.ogr input="PG:host=gisdata-db.nina.no dbname=gisdata user=stefan.blumentrath" layer=stisykkling.nasjonalparker output=nasjonalparker


mkdir /data/R/Prosjekter/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/GIS/NVDB
for row in $(v.db.select -c omrade_buffer)
do
cat=$(echo $row | cut -f1 -d'|')
name=$(echo $row | cut -f2 -d'|')
v.extract input=omrade_buffer output=$name cat=$cat
g.region -p vector=$name
mkdir /data/R/Prosjekter/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/GIS/NVDB/$name
python $HOME/v.in.nvdb.py objects=43 outdir=/data/R/Prosjekter/15333500_slitasje_og_egnethet_for_stier_brukt_til_sykling/GIS/NVDB/$name nvdb_api_path=$HOME/nvdbapiV2 output_prefix=NVDB_${name}
done

###########################################################################
Fritidsbygg Fritidsbygg (hytter, sommerhus og lignende) 161
Helårsb.benyttes som fritidsb. Helårsb.benyttes som fritidsb.; helårsbolig utenom
våningshus som benyttes som fritidsbolig.
162
Våningh. benyttes som fritidsb Våningh. benyttes som fritidsb; våningshus som benyttes
som fritidsbolig
163
Seterhus; sel; rorbu og
lignende
Seterhus; sel; rorbu og lignende; 171
Skogs- og utmarkskoie; gamme Skogs- og utmarkskoie; gamme; 172
Naust/redskapshus for fiske Naust/redskapshus for fiske; naust / redskapshus for fiske 245
Annen fiskeri- og fangstbygn. Annen fiskeri- og fangstbygn.; 248
Annen landbruksbygning Annen landbruksbygning; 249
Jernbane- og T-banestasjon Jernbane- og T-banestasjon; 412
Hotellbygning Hotellbygning; større bygning for overnatting, godkjent
etter hotelloven.
511
Motellbygning Motellbygning; egentlig motorhotell, oftest beliggende
langs en hovedferdselsåre.
512
Annen hotellbygning Annen hotellbygning; annen bygning for overnatting -
godkjent etter hotelloven. , eller bygning som har nær
tilknytning til/tjener slik(e) bygning(er).
519
Vandre-feriehjem;turisthytte Vandre-feriehjem;turisthytte; rimelig nattelosji, ofte
knyttet til medlemskap i en forening.
522
Appartement Appartement; bygning med fritidsboliger/ boliger til utleie,
boligene har bad og kokemuligheter, og leies oftest for
døgn- eller ukebasis.
523
Camping- /utleiehytte Camping- /utleiehytte; enklere overnattingshytte
fortrinnsvis beregnet for bilturister. Som regel er de knyttet
til en campingplass. Gjestene holder vanligvis sengetøy
selv
524
Restaurantbygning;
kafébygning
Restaurantbygning; kafébygning; Restaurantbygning
eller kafébygning.
531
Annen restaurantbygning Annen restaurantbygning; andre spisesteder som ikke
passer inn i kodene over, eller bygning som har nær
tilknytning til/tjener slik(e) bygning(er).
539
Annen hotell og rest.bygn Annen hotell og rest.bygn; 590


import {
	type OfflineSource,
	IndexedDBSource,
	Protocol,
	FetchSource,
	PMTiles,
} from "../../src/index";

const protocol = new Protocol();

maplibregl.addProtocol("pmtiles", protocol.tile);

const PMTILES_URL =
	"http://localhost:8000/protomaps(vector)ODbL_firenze.pmtiles";

const load = async () => {
	// load the file on init and save to indexedDB to user later
	const serverResponse = await fetch(PMTILES_URL);
	const buffer = await serverResponse.arrayBuffer();
	const blob = new Blob([buffer], { type: "application/octet-stream" });
	const dbname = "offline-pmtiles";
	const tablename = "offline-pmtiles";
	const db = await IndexedDBSource.openDb(dbname, tablename);

	const offlineSource = new IndexedDBSource(
		db,
		{ filename: "protomaps(vector)ODbL_firenze.pmtiles", blob },
		tablename,
	);

	const p = new PMTiles(offlineSource);

	const tile1 = await p.getZxy(0, 0, 0);
	console.log({ tile1 });
	// console.log({tile1, tile2})

	// const map = new maplibregl.Map({
	//     container: "map",
	//     hash: true,
	//     // style: "https://demotiles.maplibre.org/style.json"
	//     style: {
	//                 version: 8,
	//                 sources: {
	//                     example_source: {
	//                     type: "vector",
	//                     // For standard Z/X/Y tile APIs or Z/X/Y URLs served from go-pmtiles, replace "url" with "tiles" and remove all the pmtiles-related client code.
	//                     // tiles: ["https://example.com/{z}/[x}/{y}.mvt"],
	//                     // see https://maplibre.org/maplibre-style-spec/sources/#vector
	//                     url: "pmtiles://" + PMTILES_URL,
	//                     attribution:
	//                         '© <a href="https://openstreetmap.org">OpenStreetMap</a>',
	//                     },
	//                 },
	//                 layers: [
	//                     {
	//                     id: "water",
	//                     source: "example_source",
	//                     "source-layer": "water",
	//                     filter: ["==",["geometry-type"],"Polygon"],
	//                     type: "fill",
	//                     paint: {
	//                         "fill-color": "#80b1d3",
	//                     },
	//                     },
	//                     {
	//                     id: "buildings",
	//                     source: "example_source",
	//                     "source-layer": "buildings",
	//                     type: "fill",
	//                     paint: {
	//                         "fill-color": "#d9d9d9",
	//                     },
	//                     },
	//                     {
	//                     id: "roads",
	//                     source: "example_source",
	//                     "source-layer": "roads",
	//                     type: "line",
	//                     paint: {
	//                         "line-color": "#fc8d62",
	//                     },
	//                     },
	//                     {
	//                     id: "pois",
	//                     source: "example_source",
	//                     "source-layer": "pois",
	//                     type: "circle",
	//                     paint: {
	//                         "circle-color": "#ffffb3",
	//                     },
	//                     },
	//                 ],
	//                 }
	// })

	// map.showTileBoundaries = true
};

load();

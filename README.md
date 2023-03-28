## seismic-exploratory-data-analysis

# This project aims to describe the data collection and data cleaning process for seismic databases

## Data Collection
The process is described in more detail at https://github.com/gabipana7/seismic-networks-julia-dev/tree/main/data_collection

It involves:
- identifiying the data sources
- parsing and downloading
- data cleaning:
    - data pre-processing
    - droping irrelevant data
    - resolving missing/inconsistent data
- exporting the catalog to .csv

Current use cases:
- Vrancea, Romania (INFP catalog)
- California, USA (SCEDC catalog)
- Italy (INGV catalog)
- Japan (JMA catalog)

We are left with the following catalogs:

|                    | events  | timespan                                           | latitude           | longitude          | depth        | magnitude  |
|--------------------|---------|----------------------------------------------------|--------------------|--------------------|--------------|------------|
| Romania (INFP)     | 32289   | 0984-01-01T00:00:00 - 2022-12-31T15:24:39.550	      | 43.5941 - 48.23    | 20.1 - 29.84       | 0.0 - 218.4  | 0.1 - 7.9  |
| California (SCEDC) | 808085  | 1932-01-02T16:42:53.680 - 2023-03-07T07:30:05.530  | 32.0 - 37.0        | -122.0 - -114.0    | 0.0 - 51.1   | 0.01 - 7.5 |
| Italy (INGV)       | 418580  | 1985-01-02T18:39:30.740 - 2023-03-08T11:05:17.900	  | -69.757 - 84.3258  | -179.99 - 179.939  | 0.0 - 675.4  | 0.1 - 9.0  |
| Japan (JMA)        | 3563558 | 1983-01-01T00:36:05.840 - 2020-08-31T23:55:49.130	  | 17.4093 - 50.4268  | 118.905 - 156.681  | 0.0 - 698.4  | 0.1 - 9.0  |

## Exploratory Data Analysis
By exploring the data we identify the portions of the data that interests us.

In some cases, data needs to be trimmed:
- geographically, because some catalogs cover a wider region
- in time, because data collection is inconsistent in the past


### Romania (INFP)

![events_per_year](https://user-images.githubusercontent.com/72228598/228258207-c9fab899-4951-4883-922e-5d9f424d3c41.png)

![events_per_year_mags](https://user-images.githubusercontent.com/72228598/228258334-90f019ae-49d2-4a50-b78a-956a38506e32.png)

It is visible that the earthquake collection picked up in 1977. We can deduce that this is due to the 7.4 magnitude earthquake of 4 March 1977 which had devastated the country. There was another spike in the data in 2005, indicating another rise in interest and funding regarding seismology in the region.

As a trim year 1977 is selected. All further analyses regarding this dataset are implemented to the data starting with this year.


2D Visualization of earthquakes

![Earthquakes by Depth](https://user-images.githubusercontent.com/72228598/228258692-041a2507-2476-4f6b-926c-a264d2a14648.png)

![Earthquakes by Magnitude](https://user-images.githubusercontent.com/72228598/228258818-9e85eede-d7fb-4f92-a6d4-3a0a127bd3ba.png)


3D Visualization of earthquakes
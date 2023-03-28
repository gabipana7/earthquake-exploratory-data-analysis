## seismic-exploratory-data-analysis

## This project aims to describe the data collection and data cleaning process for seismic databases

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

![romania_semi3D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228259723-6e9b0eed-640b-4377-a4af-f61ff0ecaed9.png)

![romania_semi3D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228259796-427c9bc3-3e95-4fa8-af52-c4c407b413ea.png)



#### Vrancea region

Special attention is given to Vrancea region, as it is the main area of seismicity in Romania


2D Visualization of earthquakes

![vrancea_2D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228260289-84d47b05-127d-4a71-acd5-30b07d46a67e.png)

![vrancea_2D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228260377-581ba5c8-385b-4e00-a7dd-bfcf1e0e538d.png)


3D Visualization of earthquakes

![vrancea_semi3D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228260359-2114c784-811e-4950-83af-6d518bf12e1e.png)

![vrancea_semi3D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228260372-cfda3cac-6672-4b3f-bd99-6e3fa39cf968.png)

---
### California (SCEDC)

![events_per_year](https://user-images.githubusercontent.com/72228598/228260805-e5ad98fd-2ced-44ea-ab07-83023867743d.png)

![events_per_year_mags](https://user-images.githubusercontent.com/72228598/228260910-f7446867-98e7-4a15-a8d0-9a759ef15ca0.png)

Collection of seismic data picked up in 1977. 

There are a few spikes in the data suggesting increased activity and/or monitoring:
- 1992: the two subsequent earthquakes on the 28th of June: Landers first (7.3 Mw), then Big Bear (6.5 Mw), causing deaths and extensive damage to infrastructure
- 2010: Baja California earthquake on the 4th of April with a magnitude of 7.2 Mw which caused billions of dollars in destruction.
- 2019: the Ridgecrest doublet on the 4th of July, measuring 6.4 Mw and 7.1 Mw.

As a trim year we selected 1977. All further analyses regarding this dataset are implemented to the data starting with this year.


2D Visualization of earthquakes

![california_2D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228261485-fdd28947-03cb-48e5-8214-27bc496b3f04.png)
![california_2D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228261496-5637acbc-756e-48d9-a5cc-d1d39fea3cb6.png)


3D Visualization of earthquakes

![california_semi3D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228261503-14a8d274-37d4-4e91-882a-6ead83aa551e.png)
![california_semi3D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228261507-f8fac8a6-cc45-47e9-a46c-0405b85007c1.png)

There are several bulks in the region suggesting multiple earthquake centers. Here we would like to focus on the whole California region, so the geographical ranges are not trimmed.

---
### Italy (INGV)

![events_per_year](https://user-images.githubusercontent.com/72228598/228262226-e89035b4-545b-4215-b6d8-43bec7de6728.png)

![events_per_year_mags](https://user-images.githubusercontent.com/72228598/228262211-8393bbc4-c5a4-4cbf-aecd-d2f9dcc0bb24.png)

The data seems to be quite inconsistent. Through a 2D visualization we can understand why this is

![2D_mag_0 0](https://user-images.githubusercontent.com/72228598/228262221-3baf38da-6adf-44b2-ab0a-29fb96784e55.png)

The INGV catalog indexes the events in the Mediterranean region, as well as the large events from all over the world. 

The region that interests us is Italy, so we trim the data accordingly.

![italy_events_per_year_mags](https://user-images.githubusercontent.com/72228598/228262217-39176cfb-eb46-4fc6-8d92-60f0fbc13782.png)

![italy_events_per_year_mags_no_microearthquakes](https://user-images.githubusercontent.com/72228598/228262220-dcb71197-b349-4000-b554-69d5ff3bea19.png)

Data collection seems pretty even throughout the years if we do not take into account microearthquakes detection, which started to come into place around the year 2005. This might be in part due to the earthquake of 24 November 2004 in Lombardy, Salò, with a magnitude of 5.1 Mw, in which many buildings were damaged.

Another spike in the data can be seen in 2016, which may be in part because of the earthquakes of 24 August and 30 October. They had magnitudes of 6.2 Mw and 6.6 Mw respectively, and caused deaths and damage to infrastructure.

We decide to keep the timespan that is represented in the catalog, keeping the year 1985 as the starting point.


2D Visualization of earthquakes

![italy_2D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228262783-d5579550-e6c7-4d43-adaf-d046ad5b7b03.png)

![italy_2D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228262792-dda6752a-0a39-443d-b7a3-ded01b887e87.png)


3D Visualization of earthquakes

![italy_semi3D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228262800-418db04f-5789-44e6-a4d3-cb390a518ad0.png)

![italy_semi3D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228262809-5c7a6b98-3171-43e6-8269-a9e396c1ab4f.png)


---
### Japan (JMA)

![events_per_year](https://user-images.githubusercontent.com/72228598/228263467-9d05e4d3-cba5-4fa0-b893-9703fa5e79e6.png)

Collection of seismic data picked up in 1995. Part of the reason might be due to the Great Hanshin earthquake of 17 January 1995 which caused extensive damage and a very high death toll in the region. 

As a result, funding of seismology increased so that data is more abundant starting with that year.

As a trim year we selected 1995. All further analyses regarding this dataset are implemented to the data starting with this year.

The data was already trimmed geographically to keep just the Japan region during the preprocessing phase. Also, historical data was droped.


2D Visualization of earthquakes

![japan_2D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228263974-47c65f14-2cfc-4010-9e12-a3702f5e83d9.png)

![japan_2D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228263976-7903374a-52c2-40e9-a243-d9f847fcd617.png)


3D Visualization of earthquakes

![japan_semi3D_mag_0 0_Depth](https://user-images.githubusercontent.com/72228598/228263984-98eb8e61-505f-4fbc-851e-2f7bfaaffd17.png)

![japan_semi3D_mag_0 0_Magnitude](https://user-images.githubusercontent.com/72228598/228263990-baecfd4a-2708-495e-a6a3-31f09f23d9d6.png)

---

Finally, the data considered for further analysis is the following:

|                    | events  | timespan                                           | latitude           | longitude          | depth        | magnitude  |
|--------------------|---------|----------------------------------------------------|--------------------|--------------------|--------------|------------|
| Romania (INFP)     | 32289   | 0984-01-01T00:00:00 - 2022-12-31T15:24:39.550	      | 43.5941 - 48.23    | 20.1 - 29.84       | 0.0 - 218.4  | 0.1 - 7.9  |
| California (SCEDC) | 808085  | 1932-01-02T16:42:53.680 - 2023-03-07T07:30:05.530  | 32.0 - 37.0        | -122.0 - -114.0    | 0.0 - 51.1   | 0.01 - 7.5 |
| Italy (INGV)       | 418580  | 1985-01-02T18:39:30.740 - 2023-03-08T11:05:17.900	  | -69.757 - 84.3258  | -179.99 - 179.939  | 0.0 - 675.4  | 0.1 - 9.0  |
| Japan (JMA)        | 3563558 | 1983-01-01T00:36:05.840 - 2020-08-31T23:55:49.130	  | 17.4093 - 50.4268  | 118.905 - 156.681  | 0.0 - 698.4  | 0.1 - 9.0  |

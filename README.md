# glider-CalCurCEAS

Repository for passive acoustic glider efforts overlapping with the 2024 
CalCurCEAS (California Current Cetacean and Ecosystem Assessment Survey). This 
project is part of NOAA's
[PAM Strategic Initiative](https://nmfs-ost.github.io/PAM_National_NMFS_Network/content/SI_Coordination.html) 
and UxS Strategic Initiative. 

This repository contains documentation and code for survey planning, survey 
execution, post-mission processing, and analysis of glider operations and 
initial basic cetacean analysis. 

Downstream analyses for a particular species or research question are housed in 
other repositories which will be linked here:

- [SPACIOUS-Glider-PAM-Sperm-Whale](https://github.com/PIFSC-Protected-Species-Division/SPACIOUS-Glider-PAM-Sperm-Whale)
Encounter and click-level sperm whale analysis for the [SPACIOUS project](https://nmfs-ost.github.io/PAM-Stocks/content/gliderStocks.html). 

Glider piloting files, raw acoustic files, and large analysis outputs 
*are not* be stored here. 

#### Working with this repository
To avoid upstream/downstream conflicts, please **fork** this repository to your 
GitHub account. Then, make any changes directly in your fork of the repository. 
If you have made changes that should be incorporated into the main repository, 
then create a **pull request** to pull your changes to the primary repository. 

If you have questions, suggestions, or problems, please open an 
[ISSUE](https://github.com/sfregosi-noaa/glider-CalCurCEAS/issues)

#### Google Drive Links
[CalCurCEAS Glider 2024 folder](https://drive.google.com/drive/u/0/folders/1h6PC8eH8BzDcbnq1kNLVLJI7YYhtB4r8)

[Glider Summit folder](https://drive.google.com/drive/u/0/folders/1_1w17zMtWYugvaZtuxSfmWLgKcBNYzDD)

[Meeting notes](https://docs.google.com/document/d/1nYkHaxqJKG1i3mgdO6H7gXtYwynZ-1RUO_NX5IPk3mE/edit#heading=h.398ih9qo4jqm)

[Trackline options](https://docs.google.com/document/d/1NwKQ2VxagRuMKWgMJnZO26QlkgC2rQFMd823x6BZVJk/edit)

#### Data availability

Recordings will be made available at NCEI once they have been fully processed 
and screened. The link will be provided here. 

Raw and processed data products are stored in NOAA Fisheries Google Cloud 
Platform (GCP) buckets:



**Glider piloting/environmental data and raw acoustic data**

NOAA NMFS PAM-SI PIFSC GCP Bucket

The folder structure is as as follows:

```
gs://pifsc-1/glider

├───sg639_CalCurCEAS_Sep2024
│   ├───piloting
│   │   ├───basestationFiles
│   │   ├───flightStatus
│   │   └───profiles
│   └───recordings
│       └───raw_acoustic_data
├───sg679_CalCurCEAS_Aug2024
│   ├───piloting
│   │   ├───basestationFiles
│   │   ├───flightStatus
│   │   └───profiles
│   └───recordings
│       └───raw
└───sg680_CalCurCEAS_Sep2024
    ├───piloting
    │   ├───basestationFiles
    │   ├───flightStatus
    │   └───profiles
    └───recordings
        └───raw

```

*Note: the piloting folder will eventuall be moved to the PIFSC Uncrewed Marine
Systems Program bucket (`gs://nmfs-pic-ums`) once the final folder structure of
that bucket is established.*

**Processed acoustic data**

NOAA NMFS PAM-SI SWFSC GCP Bucket

The folder structure is as as follows:

```
gs://swfsc-1/2024_CalCurCEAS/glider/audio_flac
├───sg639_CalCurCEAS_Sep2024
├───sg679_CalCurCEAS_Aug2024
└───sg680_CalCurCEAS_Sep2024

```





## Disclaimer

<sub>The scientific results and conclusions, as well as any views or opinions 
expressed herein, are those of the author(s) and do not necessarily reflect the 
views of NOAA or the Department of Commerce.</sub>

<sub>This repository is a scientific product and is not official communication 
of the National Oceanic and Atmospheric Administration, or the United States 
Department of Commerce. All NOAA GitHub project code is provided on an 'as is' 
basis and the user assumes responsibility for its use. Any claims against the 
Department of Commerce or Department of Commerce bureaus stemming from the use 
of this GitHub project will be governed by all applicable Federal law. Any 
reference to specific commercial products, processes, or services by service 
mark, trademark, manufacturer, or otherwise, does not constitute or imply their 
endorsement, recommendation or favoring by the Department of Commerce. The 
Department of Commerce seal and logo, or the seal and logo of a DOC bureau, 
shall not be used in any manner to imply endorsement of any commercial product 
or activity by DOC or the United States Government.</sub>

<sub>Software code created by U.S. Government employees is not subject to 
copyright in the United States (17 U.S.C. §105). The United States/Department 
of Commerce reserves all rights to seek and obtain copyright protection in 
countries other than the United States for Software authored in its entirety by 
the Department of Commerce. To this end, the Department of Commerce hereby 
grants to Recipient a royalty-free, nonexclusive license to use, copy, and 
create derivative works of the Software outside of the United States.</sub>

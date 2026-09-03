# CalCurCEAS Fall 2024 cetacean analysis readme


## Analysis overview (updated fall 2026)
- possible odontocete encounters were identified and marked using Triton Logger
- Triton logs were collapsed and reformatted for PAMpal using the Triton log functions in agate
- AcousticStudies were created with PAMpal, using the events marked in Triton
- AcousticStudies were filtered for noise using crputils::er_filterClicks
- Event summary reports were generated from the AcousticStudies
- The event summary reports were reviewed (SF) for high level classification
	- `eventTable_sgXXX_CalCurCEAS_Sep2024-2026-08-25_sfReveiw.csv`
	- 'sf' column key:
| code | description |
| na_min | event does not have enough signals (20) for classification, should be removed | 
| mix | possible mixed species, needs to be reviewed |
| UO | general unidentified odontocete event | 
| band | banding is present in concatenated spectrogram |
| noise | possible noise, needs further review |
| pbw | possible beaked whale |
| Tt | Tursiops | 

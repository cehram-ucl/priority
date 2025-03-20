# Health inequalities in People with seveRe mental Illnesses: Impact of antipsychOtic tReatments and social Inequalities on long Term phYsical health (PRIORITY)

## Population
- Diagnosis of severe mental illness (SMI)
- Aged 18 to 99
- Between 2000 and 2019 (possibly up to 2023)
- 2 consecutive prescriptions for an antipsychotic within 3 months (check this)
- Exclude:
	- Practice doesn't meet quality standards
	- Outcome before initiation of antipsychotic medication
 	- Dementia diagnosis?

## Exposure
First prescription of *olanzapine*, *risperidone* or *quetiapine* in people with no previous treatment records (no previous prescriptions or any code that could indicate treatment for SMI)

## Outcomes
1. Change in:
	- Low-density lipoprotein cholesterol (LDL-C)
	- Systolic blood pressure (BP)
	- Glycated haemoglobin (HbA1c)
	- Weight
2. Events following treatment initiation:
	- Cardiovascular disease (myocardial infarction, stroke, unstable angina, and major cardiovascular surgery, based on definition used in [Bazo-Alvarez et al., 2021](https://doi.org/10.1038/s41598-021-02670-9))
	- Type-2 diabetes mellitus (T2DM) (first time the patient reports an HbA1c>=6.5% (or >= 48 mmol/mol) or a formal T2DM diagnosis)
	- All-cause mortality

## Covariates
- Age at first antipsychotic prescription
- Gender
- Social deprivation (Townsend score)
- Smoking status
- Alcohol consumption
- Statin treatment
- Antihypertensive treatment
- Ethnicity
- Region

## Codelists

### Product codes
| Codelist          |            Validated codelist?            |                Repository codelists?                 |                    Creation script                     |                    Finished codelist                     | Clinician Reviewed? |                                Complete?                                 |
| ----------------- | :---------------------------------------: | :--------------------------------------------------: | :----------------------------------------------------: | :------------------------------------------------------: | :-----------------: | :----------------------------------------------------------------------: |
| Antihypertensives | [❌](codelists_validated.md#product-codes) | [✔️(6)](codelists_repositories.md#antihypertensives) | [antihypertensives.do](codelists/antihypertensives.do) | [antihypertensives.csv](codelists/antihypertensives.csv) |          ❌          | ❌ Required:<ul><li>Codelist comparison</li><li>Clinical review</li></ul> |
| Antipsychotics    | [❌](codelists_validated.md#product-codes) |  [✔️(4)](codelists_repositories.md#antipsychotics)   |    [antipsychotics.do](codelists/antipsychotics.do)    |    [antipsychotics.csv](codelists/antipsychotics.csv)    |          ❌          |                        ❌ Clinical review required                        |
| Statins           | [❌](codelists_validated.md#product-codes) |      [✔️(8)](codelists_repositories.md#statins)      |           [statins.do](codelists/statins.do)           |           [statins.do](codelists/statins.csv)            |          ❌          | ❌ Required:<ul><li>Codelist comparison</li><li>Clinical review</li></ul> |

### Medical codes (description)
| Codelist                     |                             Validated codelist?                              |                    Repository codelists?                    |                               Creation script                                |                                Finished codelist                                 |                   Clinician Reviewed?                    |         Complete?          |
| ---------------------------- | :--------------------------------------------------------------------------: | :---------------------------------------------------------: | :--------------------------------------------------------------------------: | :------------------------------------------------------------------------------: | :------------------------------------------------------: | :------------------------: |
| Alcohol use disorder         |   [❌(but 1 recommended)](codelists_validated.md#medical-codes-description)   |  [✔️(13)](codelists_repositories.md#alcohol-use-disorder)   |         [alcohol_use_disorder.do](codelists/alcohol_use_disorder.do)         |          [alcohol_use_disorder.csv](codelists/alcohol_use_disorder.csv)          |                            ❌                             |                            |
| Diabetes mellitus (type-2)   |            [❌](codelists_validated.md#medical-codes-description)             | [✔️(2)](codelists_repositories.md#diabetes-mellitus-type-2) |              [type_2_diabetes.do](codelists/type_2_diabetes.do)              |               [type_2_diabetes.csv](codelists/type_2_diabetes.csv)               |       [✔️](codelists/type_2_diabetes_raw_CCG.xlsx)       |             ✔️             |
| Ethnicity                    |            [❌](codelists_validated.md#medical-codes-description)             |        [✔️(4)](codelists_repositories.md#ethnicity)         |                    [ethnicity.do](codelists/ethnicity.do)                    |                     [ethnicity.csv](codelists/ethnicity.csv)                     |                            ❌                             |             ✔️             |
| Ischaemic heart disease      |            [❌](codelists_validated.md#medical-codes-description)             | [✔️(9)](codelists_repositories.md#ischaemic-heart-disease)  |      [ischaemic_heart_disease.do](codelists/ischaemic_heart_disease.do)      |       [ischaemic_heart_disease.csv](codelists/ischaemic_heart_disease.csv)       |   [✔️](codelists/ischaemic_heart_disease_raw_CA.xlsx)    |             ✔️             |
| Major cardiovascular surgery |            [❌](codelists_validated.md#medical-codes-description)             | [❌](codelists_repositories.md#major-cardiovascular-surgery) | [major_cardiovascular_surgery.do](codelists/major_cardiovascular_surgery.do) |  [major_cardiovascular_surgery.csv](codelists/major_cardiovascular_surgery.csv)  | [✔️](codelists/major_cardiovascular_surgery_raw_CA.xlsx) |             ✔️             |
| Myocardial infarction        | [✔️(Persson et al., 2021)](codelists_validated.md#medical-codes-description) |  [✔️(9)](codelists_repositories.md#myocardial-infarction)   |        [myocardial_infarction.do](codelists/myocardial_infarction.do)        |         [myocardial_infarction.csv](codelists/myocardial_infarction.csv)         |    [✔️](codelists/myocardial_infarction_raw_CA.xlsx)     |             ✔️             |
| Severe mental illness        |            [❌](codelists_validated.md#medical-codes-description)             |  [✔️(4)](codelists_repositories.md#severe-mental-illness)   |                                [pre-existing]                                | [smi(pop def)_snomed_6_PWS_v2.csv](codelists/smi(pop%20def)_snomed_6_PWS_v2.csv) |                            ❌                             | ❌ Clinical review required |
| Smoking status               |            [❌](codelists_validated.md#medical-codes-description)             |      [✔️(3)](codelists_repositories.md#smoking-status)      |               [smoking_status.do](codelists/smoking_status.do)               |                [smoking_status.csv](codelists/smoking_status.csv)                |                            ❌                             |                            |
| Stroke                       |            [❌](codelists_validated.md#medical-codes-description)             |         [✔️(11)](codelists_repositories.md#stroke)          |                       [stroke.do](codelists/stroke.do)                       |                        [stroke.csv](codelists/stroke.csv)                        |            [✔️](codelists/stroke_raw_CA.xlsx)            |             ✔️             |

### Medical codes (value)

#### Cholesterol (broadened from low-density lipoprotein cholesterol (LDL-C)) [yes]
1. PubMed validated codelist search:
    - Search: "cholesterol validated (CPRD OR SNOMED CT)"
    - 6 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "cholesterol"
      - 41 results
      - no suitable codelists
    - LSHTM Data Compass:
      - Search: "cholesterol codelist"
      - 6 results
      - no suitable codelists
    - OpenCodelists:
      - Search: "cholesterol"
      - 22 results
      - 13 suitable codelists:
        - https://www.opencodelists.org/codelist/ardens/cholesterol-total-level/2020-11-06/
        - https://www.opencodelists.org/codelist/opensafely/cholesterol-tests/09896c09/
        - https://www.opencodelists.org/codelist/opensafely/cholesterol-tests-numerical-value/7e3a22f3/
        - https://www.opencodelists.org/codelist/ardens/hdl-cholesterol/2020-11-06/
        - https://www.opencodelists.org/codelist/bristol/hdl-cholesterol/64775990/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/hdlcchol_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ldlcchol_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ndacholest_cod/20200812/
        - https://www.opencodelists.org/codelist/ardens/non-hdl-cholesterol/2020-11-06/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/nonhdlcchol_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/chol_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/chol2_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/tcholhdl_cod/20200812/
3. Codelist creation script:
    - [cholesterol.do](codelists/cholesterol.do)
4. Finished codelist:
    - [cholesterol.csv](codelists/cholesterol.csv)

#### Blood pressure (broadened from systolic blood pressure) [yes]
1. PubMed validated codelist search:
    - Search: "blood pressure validated (CPRD OR SNOMED CT)"
    - 8 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "blood pressure"
      - 24 results
      - no suitable codelists
    - LSHTM Data Compass:
      - Search: "blood pressure codelist"
      - 20 results
      - 2 suitable codelists:
      	- https://datacompass.lshtm.ac.uk/id/eprint/4214/
      	- https://datacompass.lshtm.ac.uk/id/eprint/3590/
    - OpenCodelists:
      - Search: "blood pressure"
      - 10 results
      - 4 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/abpm_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/homebp_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bp_cod/20200812/
        - https://www.opencodelists.org/codelist/opensafely/systolic-blood-pressure-qof/3572b5fb/
3. Codelist creation script:
    - [blood_pressure.do](codelists/blood_pressure.do)
4. Finished codelist:
    - [blood_pressure.csv](codelists/blood_pressure.csv)

#### Glycated haemoglobin (HbA1c) [yes]
1. PubMed validated codelist search:
    - Search: "hba1c validated (CPRD OR SNOMED CT)"
    - 5 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "hba1c"
      - 74 results
      - 1 suitable codelists:
      	- https://phenotypes.healthdatagateway.org/phenotypes/PH833/version/1745/detail/
    - LSHTM Data Compass:
      - Search: "hba1c codelist"
      - 1 results
      - no suitable codelists
    - OpenCodelists:
      - Search: "hba1c"
      - 7 results
      - 6 suitable codelists:
        - https://www.opencodelists.org/codelist/opensafely/glycated-haemoglobin-hba1c-tests/2ab11f20/
        - https://www.opencodelists.org/codelist/opensafely/glycated-haemoglobin-hba1c-tests-numerical-value/5134e926/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dccthba1c_cod/20200812/
        - https://www.opencodelists.org/codelist/ardens/hba1c-level/2020-11-06/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ifcchbamd_cod/20211221/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/ifcchbam_cod/20200812/
3. Codelist creation script:
    - [HbA1c.do](codelists/HbA1c.do)
4. Finished codelist:
    - [HbA1c.csv](codelists/HbA1c.csv)

#### Weight/Body mass index (BMI) (broadened from just weight) [look for IP publication on excluding above 99th centile] [yes]
1. PubMed validated codelist search:
    - Search: "(weight OR body mass index OR BMI) validated (CPRD OR SNOMED CT)"
    - 31 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "body mass index" and "bmi" and "weight"
      - 18 and 50 and 22 results
      - no suitable codelists
    - LSHTM Data Compass:
      - Search: "bmi codelist OR weight codelist"
      - 10 results
      - 3 suitable codelists:
      	- https://datacompass.lshtm.ac.uk/id/eprint/2413/
       	- https://datacompass.lshtm.ac.uk/id/eprint/3323/
        - https://datacompass.lshtm.ac.uk/id/eprint/4214/
    - OpenCodelists:
      - Search: "bmi" and "weight" and "height"
      - 20 and 12 and 4 results
      - 4 suitable codelists:
        - https://www.opencodelists.org/codelist/primis-covid19-vacc-uptake/bmi/v2.5/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bmival_cod/20201016/
        - https://www.opencodelists.org/codelist/opensafely/weight-snomed/5459abc6/
        - https://www.opencodelists.org/codelist/opensafely/height-snomed/3b4a3891/
3. Codelist creation script:
    - [body_mass_index.do](codelists/body_mass_index.do)
4. Finished codelist:
    - [body_mass_index.csv](codelists/body_mass_index.csv)

#### Alcohol consumption (possible? alcohol use disorder codelist may be sufficient) [todo]
1. PubMed validated codelist search:
    - Search: "alcohol validated (CPRD OR SNOMED CT)"
    - 8 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "alcohol"
      - 62 results
      - no suitable codelists (descriptive rather than value codes)
    - LSHTM Data Compass:
      - Search: "alcohol codelist"
      - 58 results
      - no suitable codelists (descriptive rather than value codes)
    - OpenCodelists:
      - Search: "alcohol"
      - 19 results
      - 3 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/auditc_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/audit_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/fast_cod/20200812/
3. Codelist creation script:
    - [alcohol_consumption.do](codelists/alcohol_consumption.do)
4. Finished codelist:
    - [alcohol_consumption.csv](codelists/alcohol_consumption.csv)

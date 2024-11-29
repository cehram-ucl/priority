# Health inequalities in People with seveRe mental Illnesses: Impact of antipsychOtic tReatments and social Inequalities on long Term phYsical health (PRIORITY)

## Population
- Diagnosis of severe mental illness (SMI)
- Aged 18 to 99
- Between 2000 and 2019 (possibly up to 2023)
- 2 consecutive prescriptions for an antipsychotic within 3 months (check this)
- Exclude:
	- Practice doesn't meet quality standards
	- Outcome before initiation of antipsychotic medication

## Exposure
First prescription of *olanzapine*, *risperidone* or *quetiapine* in people with no previous treatment records (no previous prescriptions or any code that could indicate treatment for SMI)

## Outcomes
1. Change in:
	- Low-density lipoprotein cholesterol (LDL-C)
	- Systolic blood pressure (BP)
	- Glycated haemoglobin (HbA1c)
	- weight
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

### Medication codes (should all already be inside DSH):
- Olanzapine
- Risperidone
- Quetiapine
- Other antipsychotic medication
- Statin medication
- Antihypertensive medication

### Descriptive codes:

#### Severe mental illness
- Definition inside DSH

#### Type-2 diabetes mellitus (T2DM)
1. PubMed validated codelist search:
    - Search: "type 2 diabetes validated (CPRD OR SNOMED CT)"
    - 16 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "diabetes"
      - 159 results
      - No suitable codelists (only combined type 1 and 2 lists)
    - LSHTM Data Compass:
      - Search: "diabetes codelist"
      - 3 results
      - 1 suitable codelists:
      	- https://datacompass.lshtm.ac.uk/id/eprint/3743/
    - OpenCodelists:
      - Search "diabetes"
      - 61 results
      - 2 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dmtype2_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/dmtype2audit_cod/20210127/
3. Codelist creation script:
    - [type_2_diabetes.do](codelists/type_2_diabetes.do)
4. Finished codelist:
    - [type_2_diabetes.csv](codelists/type_2_diabetes.csv)

#### Cardiovascular disease (definition from [Bazo-Alvarez et al., 2021](https://doi.org/10.1038/s41598-021-02670-9))
##### Myocardial infarction
1. PubMed validated codelist search:
    - Search: "myocardial infarction validated (CPRD OR SNOMED CT)"
    - 11 results
    - 1 validated codelists found (2 for CPRD GOLD):
      - [Persson et al., 2021](https://doi.org/10.2147/CLEP.S319245) (78% concordance with Hospital Episode Statistics Admitted Patient Care)
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "myocardial infarction"
      - 62 results
      - 3 suitable codelists:
        - https://phenotypes.healthdatagateway.org/phenotypes/PH942/version/2120/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH949/version/2127/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH988/version/2166/detail/
    - LSHTM Data Compass:
      - Search: "myocardial infarction codelist"
      - 36 results
      - 4 suitable codelists (need limiting to just "myocardial infarction" variables):
        - https://datacompass.lshtm.ac.uk/id/eprint/2102/
        - https://datacompass.lshtm.ac.uk/id/eprint/2196/
        - https://datacompass.lshtm.ac.uk/id/eprint/2815/
        - https://datacompass.lshtm.ac.uk/id/eprint/3265/
        - https://datacompass.lshtm.ac.uk/id/eprint/3590/
    - OpenCodelists:
      - Search: "myocardial infarction"
      - 5 results
      - 1 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/mi_cod/20210127/
3. Codelist creation script:
    - [myocardial_infarction.do](codelists/myocardial_infarction.do)
4. Finished codelist:
    - [myocardial_infarction.csv](codelists/myocardial_infarction.csv)

##### Stroke
1. PubMed validated codelist search:
    - Search: "stroke validated (CPRD OR SNOMED CT)"
    - 18 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "stroke"
      - 62 results
      - 3 suitable codelists:
        - https://phenotypes.healthdatagateway.org/phenotypes/PH983/version/2161/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH948/version/2126/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH1018/version/2196/detail/
    - LSHTM Data Compass:
      - Search: "stroke codelist"
      - 36 results
      - 3 suitable codelists (need limiting to just "stroke" variables):
        - https://datacompass.lshtm.ac.uk/id/eprint/2196/
        - https://datacompass.lshtm.ac.uk/id/eprint/2815/
        - https://datacompass.lshtm.ac.uk/id/eprint/3265/
    - OpenCodelists:
      - Search: "stroke"
      - 17 results
      - 2 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/strk_cod/20210127/
        - https://www.opencodelists.org/codelist/qcovid/has_stroke_or_tia/69e5b712/
3. Codelist creation script:
    - [stroke.do](codelists/stroke.do)
4. Finished codelist:
    - [stroke.csv](codelists/stroke.csv)

##### Ischaemic heart disease (broadened from unstable angina)
1. PubMed validated codelist search:
    - Search: "ischaemic heart disease validated (CPRD OR SNOMED CT)"
    - 9 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "ischaemic heart disease" and "angina"
      - 40 and 20 results
      - 3 suitable codelists:
        - https://phenotypes.healthdatagateway.org/phenotypes/PH27/version/54/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH956/version/2134/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH986/version/2164/detail/
    - LSHTM Data Compass:
      - Search: "ischaemic heart disease codelist OR angina codelist"
      - 27 results
      - 3 suitable codelists (need limiting to just "ischaemic heart disease" variables):
        - https://datacompass.lshtm.ac.uk/id/eprint/2196/
        - https://datacompass.lshtm.ac.uk/id/eprint/2815/
        - https://datacompass.lshtm.ac.uk/id/eprint/3265/
    - OpenCodelists:
      - Search: "ischaemic heart disease" and "angina"
      - 0 and 2 results
      - 1 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/angina_cod/20210127/
3. Codelist creation script:
    - [ischaemic_heart_disease.do](codelists/ischaemic_heart_disease.do)
4. Finished codelist:
    - [ischaemic_heart_disease.csv](codelists/ischaemic_heart_disease.csv)

##### Major cardiovascular surgery
1. PubMed validated codelist search:
    - Search: "surgery validated (CPRD OR SNOMED CT)"
    - 16 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "surgery"
      - 0 results
    - LSHTM Data Compass:
      - Search: "surgery codelist"
      - 19 results
      - no suitable codelists
    - OpenCodelists:
      - Search: "surgery"
      - 12 results
      - no suitable codelists
3. Codelist creation script:
    - [major_cardiovascular_surgery.do](codelists/major_cardiovascular_surgery.do)
4. Finished codelist:
    - [major_cardiovascular_surgery.csv](codelists/major_cardiovascular_surgery.csv)

#### Smoking status
*Suggest using codelist from [Phil's COPD prevalence paper](https://doi.org/10.2147/COPD.S411739): [smoking_status.dta.csv](https://github.com/NHLI-Respiratory-Epi/COPD_prevalence/blob/main/codelists/CSV/smoking_status.dta.csv).*
1. PubMed validated codelist search:
    - Search: "smoking validated (CPRD OR SNOMED CT)"
    - 15 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "smoking"
      - 78 results
      - 2 suitable codelists:
        - https://phenotypes.healthdatagateway.org/phenotypes/PH982/version/2160/detail/
        - https://phenotypes.healthdatagateway.org/phenotypes/PH1017/version/2195/detail/
    - LSHTM Data Compass:
      - Search: "smoking codelist"
      - 15 results
      - 1 suitable codelists:
        - https://datacompass.lshtm.ac.uk/id/eprint/4214/
    - OpenCodelists:
      - Search: "smoking"
      - 3 results
      - no suitable codelists (no categorisation of status)
3. Codelist creation script:
    - [smoking_status.do](codelists/smoking_status.do)
4. Finished codelist:
    - [smoking_status.csv](codelists/smoking_status.csv)

#### Alcohol use disorder
*Suggest using the recommended codelist by [Cook et al.](https://doi.org/10.2147/CLEP.S477778): [Alcohol use disorder.csv](https://github.com/NHLI-Respiratory-Epi/Alcohol_use_disorder_codelist/blob/main/Alcohol%20use%20disorder.csv)*
1. PubMed validated codelist search:
    - Search: "alcohol validated (CPRD OR SNOMED CT)"
    - 8 results
    - no validated codelists found (but a recommended codelist by [Cook et al., 2024](https://doi.org/10.2147/CLEP.S477778) is available for alcohol use disorder)
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "alcohol"
      - 62 results
      - 1 suitable codelists:
        - https://phenotypes.healthdatagateway.org/phenotypes/PH1107/version/3517/detail/
    - LSHTM Data Compass:
      - Search: "alcohol codelist"
      - 58 results
      - 1 suitable codelists:
        - https://datacompass.lshtm.ac.uk/id/eprint/3421/
    - OpenCodelists:
      - Search: "alcohol"
      - 19 results
      - 11 suitable codelists:
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcadv_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcoholint_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcintdec_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcbrint_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcbrintdec_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/excessalc_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcexint_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcexintdec_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcref_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcspadv_cod/20200812/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/alcspadvdec_cod/20200812/
3. Codelist creation script:
    - [alcohol_use_disorder.do](codelists/alcohol_use_disorder.do)
4. Finished codelist:
    - [alcohol_use_disorder.csv](codelists/alcohol_use_disorder.csv)

#### Ethnicity
*Use one of Rohini's codelists: https://doi.org/10.1093/pubmed/fdt116 https://doi.org/10.12688%2Fwellcomeopenres.16620.3*
1. PubMed validated codelist search:
    - Search: "ethnicity validated (CPRD OR SNOMED CT)"
    - 19 results
    - no validated codelists found
2. Repository codelist search:
    - HDR UK Phenotype library:
      - Search: "ethnicity"
      - 23 results
      - no suitable codelists
    - LSHTM Data Compass:
      - Search: "ethnicity codelist"
      - 8 results
      - 3 suitable codelists:
        - https://datacompass.lshtm.ac.uk/id/eprint/2102/
        - https://datacompass.lshtm.ac.uk/id/eprint/2414/
        - https://datacompass.lshtm.ac.uk/id/eprint/4214/
    - OpenCodelists:
      - Search: "ethnicity"
      - 68 results
      - 1 suitable codelists:
        - https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/
3. Codelist creation script:
    - [ethnicity.do](codelists/ethnicity.do)
4. Finished codelist:
    - [ethnicity.csv](codelists/ethnicity.csv)

### Value codes:

#### Cholesterol (broadened from low-density lipoprotein cholesterol (LDL-C))
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

#### Blood pressure (broadened from systolic blood pressure)
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

#### Glycated haemoglobin (HbA1c)
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

#### Weight/Body mass index (BMI) (broadened from just weight)
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
      - 2 suitable codelists:
      	- https://datacompass.lshtm.ac.uk/id/eprint/2413/
	- https://datacompass.lshtm.ac.uk/id/eprint/3323/
    - OpenCodelists:
      - Search: "bmi" and "weight" and "height"
      - 20 and 12 and 4 results
      - 4 suitable codelists:
        - https://www.opencodelists.org/codelist/primis-covid19-vacc-uptake/bmi/v2.5/
        - https://www.opencodelists.org/codelist/nhsd-primary-care-domain-refsets/bmival_cod/20201016/
        - https://www.opencodelists.org/codelist/opensafely/weight-snomed/5459abc6/
        - https://www.opencodelists.org/codelist/opensafely/height-snomed/3b4a3891/
3. Codelist creation script:
    - [bmi.do](codelists/bmi.do)
4. Finished codelist:
    - [bmi.csv](codelists/bmi.csv)

#### Alcohol consumption (possible? alcohol use disorder codelist may be sufficient)
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

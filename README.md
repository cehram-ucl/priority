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
| Statins           | [❌](codelists_validated.md#product-codes) |      [✔️(8)](codelists_repositories.md#statins)      |           [statins.do](codelists/statins.do)           |           [statins.csv](codelists/statins.csv)           |          ❌          | ❌ Required:<ul><li>Codelist comparison</li><li>Clinical review</li></ul> |

### Medical codes (description)
| Codelist                     |                             Validated codelist?                              |                    Repository codelists?                    |                               Creation script                                |                                Finished codelist                                 |                   Clinician Reviewed?                    |               Complete?                |
| ---------------------------- | :--------------------------------------------------------------------------: | :---------------------------------------------------------: | :--------------------------------------------------------------------------: | :------------------------------------------------------------------------------: | :------------------------------------------------------: | :------------------------------------: |
| Alcohol use disorder         |   [❌(but 1 recommended)](codelists_validated.md#medical-codes-description)   |  [✔️(13)](codelists_repositories.md#alcohol-use-disorder)   |         [alcohol_use_disorder.do](codelists/alcohol_use_disorder.do)         |          [alcohol_use_disorder.csv](codelists/alcohol_use_disorder.csv)          |                            ❌                             | Ordered categorical variable required? |
| Dementia                     |            [❌](codelists_validated.md#medical-codes-description)             |        [✔️(20)](codelists_repositories.md#dementia)         |                     [dementia.do](codelists/dementia.do)                     |                      [dementia.csv](codelists/dementia.csv)                      |                            ❌                             |       ❌ Clinical review required       |
| Diabetes mellitus (type-2)   |            [❌](codelists_validated.md#medical-codes-description)             | [✔️(2)](codelists_repositories.md#diabetes-mellitus-type-2) |              [type_2_diabetes.do](codelists/type_2_diabetes.do)              |               [type_2_diabetes.csv](codelists/type_2_diabetes.csv)               |       [✔️](codelists/type_2_diabetes_raw_CCG.xlsx)       |                   ✔️                   |
| Ethnicity                    |            [❌](codelists_validated.md#medical-codes-description)             |        [✔️(4)](codelists_repositories.md#ethnicity)         |                    [ethnicity.do](codelists/ethnicity.do)                    |                     [ethnicity.csv](codelists/ethnicity.csv)                     |                            ❌                             |                   ✔️                   |
| Ischaemic heart disease      |            [❌](codelists_validated.md#medical-codes-description)             | [✔️(9)](codelists_repositories.md#ischaemic-heart-disease)  |      [ischaemic_heart_disease.do](codelists/ischaemic_heart_disease.do)      |       [ischaemic_heart_disease.csv](codelists/ischaemic_heart_disease.csv)       |   [✔️](codelists/ischaemic_heart_disease_raw_CA.xlsx)    |                   ✔️                   |
| Major cardiovascular surgery |            [❌](codelists_validated.md#medical-codes-description)             | [❌](codelists_repositories.md#major-cardiovascular-surgery) | [major_cardiovascular_surgery.do](codelists/major_cardiovascular_surgery.do) |  [major_cardiovascular_surgery.csv](codelists/major_cardiovascular_surgery.csv)  | [✔️](codelists/major_cardiovascular_surgery_raw_CA.xlsx) |                   ✔️                   |
| Myocardial infarction        | [✔️(Persson et al., 2021)](codelists_validated.md#medical-codes-description) |  [✔️(9)](codelists_repositories.md#myocardial-infarction)   |        [myocardial_infarction.do](codelists/myocardial_infarction.do)        |         [myocardial_infarction.csv](codelists/myocardial_infarction.csv)         |    [✔️](codelists/myocardial_infarction_raw_CA.xlsx)     |                   ✔️                   |
| Severe mental illness        |            [❌](codelists_validated.md#medical-codes-description)             |  [✔️(4)](codelists_repositories.md#severe-mental-illness)   |                                [pre-existing]                                | [smi(pop def)_snomed_6_PWS_v2.csv](codelists/smi(pop%20def)_snomed_6_PWS_v2.csv) |                            ❌                             |       ❌ Clinical review required       |
| Smoking status               |            [❌](codelists_validated.md#medical-codes-description)             |      [✔️(3)](codelists_repositories.md#smoking-status)      |               [smoking_status.do](codelists/smoking_status.do)               |                [smoking_status.csv](codelists/smoking_status.csv)                |                            ❌                             |                                        |
| Stroke                       |            [❌](codelists_validated.md#medical-codes-description)             |         [✔️(11)](codelists_repositories.md#stroke)          |                       [stroke.do](codelists/stroke.do)                       |                        [stroke.csv](codelists/stroke.csv)                        |            [✔️](codelists/stroke_raw_CA.xlsx)            |                   ✔️                   |

### Medical codes (value)
| Codelist                     |               Validated codelist?               |                     Repository codelists?                     |                  Creation script                   |                  Finished codelist                   |            Clinician Reviewed?             | Complete? |
| ---------------------------- | :---------------------------------------------: | :-----------------------------------------------------------: | :------------------------------------------------: | :--------------------------------------------------: | :----------------------------------------: | :-------: |
| Cholesterol                  | [❌](codelists_validated.md#medical-codes-value) |        [✔️(13)](codelists_repositories.md#cholesterol)        |     [cholesterol.do](codelists/cholesterol.do)     |     [cholesterol.csv](codelists/cholesterol.csv)     |  [✔️](codelists/cholesterol_raw_CA.xlsx)   |    ✔️     |
| Blood pressure               | [❌](codelists_validated.md#medical-codes-value) |       [✔️(6)](codelists_repositories.md#blood-pressure)       |  [blood_pressure.do](codelists/blood_pressure.do)  |  [blood_pressure.csv](codelists/blood_pressure.csv)  | [✔️](codelists/blood_pressure_raw_CA.xlsx) |    ✔️     |
| Glycated haemoglobin (HbA1c) | [❌](codelists_validated.md#medical-codes-value) | [✔️(7)](codelists_repositories.md#glycated-haemoglobin-hba1c) |           [HbA1c.do](codelists/HbA1c.do)           |           [HbA1c.csv](codelists/HbA1c.csv)           |     [✔️](codelists/HbA1c_raw_CCG.xlsx)     |    ✔️     |
| Weight/Body mass index (BMI) | [❌](codelists_validated.md#medical-codes-value) | [✔️(7)](codelists_repositories.md#weightbody-mass-index-bmi)  | [body_mass_index.do](codelists/body_mass_index.do) | [body_mass_index.csv](codelists/body_mass_index.csv) |                     ❌                      |    ✔️     |

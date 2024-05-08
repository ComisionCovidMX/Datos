

/*******************************************************************************
*Comisión Independiente Covid													
*Abril 2024	
*Dofile de Stata para replicar modelos multinivel de riesgo de morir para
pacientes COVID registrados en SISVER, cap 3 informe final (Desigualdades)															
*******************************************************************************/

/*Notas: 
1. Las variables que inician con "log" representan transformaciones utilizando el seno hiperbólico inverso (similar a logaritmo, admite valores = 0).
Fórmula: ln(x + ((x^2 + 1)^0.5))

2. Las variables que inician con "std" fueron estandarizadas con media=0, desv. est=1
*/


import delimited SISVER_COVID_VARSMUN_2020_2021.csv, varnames(1) clear

*M1
melogit mortal mujer hablaindigena c.edad##c.edad diabetes epoc asma inmusupr hipertension otra_com cardiovascular obesidad renal_cronica tabaquismo stddiassintomasaingreso usmer ib12.sector stdtotaldecamasx10milhab stdpctpobsinderechohab2020 stdpctanalf2020 stdpctsineducbasica2020 stdpctsindrenaje2020 stdpctsinelectricidad2020 stdpctsinaguaentub2020 stdpctpisotierra2020 stdpctviviendashacinamiento2020 stdpctpoblocmenos5milhab2020 stdpctpobmenos2sm2020 logpop2020 logpopdensity2020 i.semanaepidemiologica || mun_id: , or baselevels vce(robust) difficult startgrid(0 0.1 0.2)


*M2
melogit mortal mujer c.edad##c.edad diabetes epoc asma inmusupr hipertension otra_com cardiovascular obesidad renal_cronica tabaquismo stddiassintomasaingreso usmer ib12.sector stdtotaldecamasx10milhab stdpctpobsinderechohab2020 stdpctanalf2020 stdpctsineducbasica2020 stdpctsindrenaje2020 stdpctsinelectricidad2020 stdpctsinaguaentub2020 stdpctpisotierra2020 stdpctviviendashacinamiento2020 stdpctpoblocmenos5milhab2020 stdpctpobmenos2sm2020 logpop2020 logpopdensity2020 logtasamortmunxsemana logpruebasenmunxsemanaxmilhab i.semanaepidemiologica || mun_id: , or baselevels vce(robust) difficult startgrid(0 0.1 0.2)

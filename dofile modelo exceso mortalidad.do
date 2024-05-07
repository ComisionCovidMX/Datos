
/*******************************************************************************
*Comisión Independiente Covid													
*Abril 2024	
*Dofile de Stata para replicar el análisis de exceso de mortalidad entre países
que se incluye en el capítulo 2 del informe final																
*******************************************************************************/

*Cargar la matriz
import delimited excesomortalidad_paises.csv, varnames(1) clear


*Estandarizar variables
foreach var of varlist cumexcesswho_per100k logmedianage logpop20 malesper100females pctpobciudades50khab loggdppercapita2019 pctinformaloutput2019 pctgovthealthexpgdp2019_who pctprivatehealthexpgdp2019 haqindex2019 avg_ihrcorecapacitiesscores2019 prematuredeathsncds_2019 pctobesemen2019 pctobesewomen2019 pctmen30_79hypertension2019 pctwomen30_79hypertension2019 diabetesprevalence2021 {
	
    egen z`var' = std(`var')
	
}


*Modelo con datos de exceso de mortalidad de OMS (2020-2021) por país, versión mayo 2023:
reg cumexcesswho_per100k zlogmedianage zlogpop20 zmalesper100females zpctpobciudades50khab zloggdppercapita2019 zpctinformaloutput2019 zpctgovthealthexpgdp2019_who zpctprivatehealthexpgdp2019 zhaqindex2019 zavg_ihrcorecapacitiesscores2019 zprematuredeathsncds_2019 zpctobesemen2019 zpctobesewomen2019 zpctmen30_79hypertension2019 zpctwomen30_79hypertension2019 zdiabetesprevalence2021  , r

*Obtener predicciones lineales, error estándar de la predicción e intervalos
predict pr_m1, xb
predict se_m1, stdp
gen pr_m1_lower = pr_m1 - 1.96 * se_m1
gen pr_m1_upper = pr_m1 + 1.96 * se_m1

*Cálculo de cifras absolutas a partir de la mortalidad observada y la tasa por 100 mil hab., más intervalos.
gen muertesesperadasm1 = (cum_excess_who_2023release*pr_m1)/cumexcesswho_per100k
gen muertesevitablesm1 = cum_excess_who_2023release-muertesesperadasm1

local suffixes lower upper

foreach suf in `suffixes'{
	gen muertesesperadasm1_`suf' = (cum_excess_who_2023release*pr_m1_`suf')/cumexcesswho_per100k
	gen muertesevitablesm1_`suf' = cum_excess_who_2023release-muertesesperadasm1_`suf'

}

*Estimaciones para México en 2020 y 2021 (cuadro 1, cap. 2)
list countryname cum_excess_who_2023release muertesesperadasm1 muertesevitablesm1 muertesesperadasm1_lower muertesevitablesm1_lower muertesesperadasm1_upper muertesevitablesm1_upper if code == "MEX"

*Gráfica de muertes en exceso por 100 mil hab. esperadas según modelo vs. observadas (gráfica 6, cap.2)
twoway (scatter cumexcesswho_per100k pr_m1 if code != "MEX", mlabel(code)) (scatter cumexcesswho_per100k pr_m1 if code == "MEX", mlabel(code) msize(large))  (lfit cumexcesswho_per100k pr_m1, mlabel(code))

*Gráfice anexo metodológico, resultados modelo 118 países
coefplot, drop(_cons) xsize(6.5) ysize(7.5) ylab(, nogrid) xlab(, nogrid) grid(none)



*-----------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------*
*Modelo con datos de exceso de mortalidad de IHME/Lancet (2020-2021)
reg excess_death_rate_ihme zlogmedianage zlogpop20 zmalesper100females zpctpobciudades50khab zloggdppercapita2019 zpctinformaloutput2019 zpctgovthealthexpgdp2019_who zpctprivatehealthexpgdp2019 zhaqindex2019 zavg_ihrcorecapacitiesscores2019 zprematuredeathsncds_2019 zpctobesemen2019 zpctobesewomen2019 zpctmen30_79hypertension2019 zpctwomen30_79hypertension2019 zdiabetesprevalence2021  , r

*Obtener predicciones lineales, error estándar de la predicción e intervalos
predict pr_m2, xb
predict se_m2, stdp
gen pr_m2_lower = pr_m2 - 1.96 * se_m2
gen pr_m2_upper = pr_m2 + 1.96 * se_m2

*Cálculo de cifras absolutas a partir de la mortalidad observada y la tasa por 100 mil hab., más intervalos.
gen muertesesperadasm2 = (excess_deaths_ihme*pr_m2)/excess_death_rate_ihme
gen muertesevitablesm2 = excess_deaths_ihme-muertesesperadasm2

local suffixes lower upper

foreach suf in `suffixes'{
	gen muertesesperadasm2_`suf' = (excess_deaths_ihme*pr_m2_`suf')/excess_death_rate_ihme
	gen muertesevitablesm2_`suf' = excess_deaths_ihme-muertesesperadasm2_`suf'

}

*Estimaciones para México en 2020 y 2021 (cuadro 1, cap. 2)
list countryname excess_deaths_ihme excess_death_rate_ihme pr_m2 muertesesperadasm2 muertesevitablesm2 muertesesperadasm2_lower muertesevitablesm2_lower muertesesperadasm2_upper muertesevitablesm2_upper if code == "MEX"

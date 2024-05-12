

/*******************************************************************************
*Comisión Independiente Covid													
*Abril 2024	
*Dofile de Stata para replicar el análisis de exceso de mortalidad entre países
que se incluye en el anexo al capítulo 2 del informe final																
*******************************************************************************/

*Cargar la matriz
import delimited excesomortalidad_paises_clustersample.csv, varnames(1) clear


*Estandarizar variables
foreach var of varlist cumexcesswho_per100k logmedianage logpop20 malesper100females pctpobciudades50khab loggdppercapita2019 pctinformaloutput2019 pctgovthealthexpgdp2019_who pctprivatehealthexpgdp2019 haqindex2019 avg_ihrcorecapacitiesscores2019 prematuredeathsncds_2019 pctobesemen2019 pctobesewomen2019 pctmen30_79hypertension2019 pctwomen30_79hypertension2019 diabetesprevalence2021 {
	
    egen z`var' = std(`var')
	
}


*------------------------------------------------------------------------------------*
*Modelo con datos de exceso de mortalidad de OMS (2020-2021) por país, versión mayo 2023:

reg cumexcesswho_per100k zlogmedianage zlogpop20 zmalesper100females zpctpobciudades50khab zloggdppercapita2019 zpctinformaloutput2019 zpctgovthealthexpgdp2019_who zpctprivatehealthexpgdp2019 zhaqindex2019 zavg_ihrcorecapacitiesscores2019 zprematuredeathsncds_2019 zpctobesemen2019 zpctobesewomen2019 zpctmen30_79hypertension2019 zpctwomen30_79hypertension2019 zdiabetesprevalence2021  , r

predict pr_mcluster, xb
predict se_mcluster, stdp
gen pr_mcluster_lower = pr_mcluster - 1.96 * se_mcluster
gen pr_mcluster_upper = pr_mcluster + 1.96 * se_mcluster

*Cálculo de cifras absolutas a partir de la mortalidad observada y la tasa por 100 mil hab., más intervalos.
gen muertesesperadasmcluster_who = (cum_excess_who_2023release*pr_mcluster)/cumexcesswho_per100k
gen muertesevitablesmcluster_who = cum_excess_who_2023release-muertesesperadasmcluster_who

local suffixes lower upper

foreach suf in `suffixes'{
	gen muertesesperadasmcluster_`suf' = (cum_excess_who_2023release*pr_mcluster_`suf')/cumexcesswho_per100k
	gen muertesevitablesmcluster_`suf' = cum_excess_who_2023release-muertesesperadasmcluster_`suf'

}

*Estimaciones para México en 2020 y 2021 (cuadro 1, anexo cap. 2)
list countryname cum_excess_who_2023release muertesesperadasmcluster_who muertesevitablesmcluster_who muertesesperadasmcluster_lower muertesevitablesmcluster_lower muertesesperadasmcluster_upper muertesevitablesmcluster_upper if code == "MEX"


*-----------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------*
*Modelo con datos de exceso de mortalidad de IHME/Lancet (2020-2021)
reg excess_death_rate_ihme zlogmedianage zlogpop20 zmalesper100females zpctpobciudades50khab zloggdppercapita2019 zpctinformaloutput2019 zpctgovthealthexpgdp2019_who zpctprivatehealthexpgdp2019 zhaqindex2019 zavg_ihrcorecapacitiesscores2019 zprematuredeathsncds_2019 zpctobesemen2019 zpctobesewomen2019 zpctmen30_79hypertension2019 zpctwomen30_79hypertension2019 zdiabetesprevalence2021  , r

predict pr_mcluster2, xb
predict se_mcluster2, stdp
gen pr_mcluster2_lower = pr_mcluster2 - 1.96 * se_mcluster2
gen pr_mcluster2_upper = pr_mcluster2 + 1.96 * se_mcluster2

*Cálculo de cifras absolutas a partir de la mortalidad observada y la tasa por 100 mil hab., más intervalos.
gen muertesesperadasmcluster2 = (excess_deaths_ihme*pr_mcluster2)/excess_death_rate_ihme
gen muertesevitablesmcluster2 = excess_deaths_ihme-muertesesperadasmcluster2

local suffixes lower upper

foreach suf in `suffixes'{
	gen muertesesperadasmcluster2`suf' = (excess_deaths_ihme*pr_mcluster2_`suf')/excess_death_rate_ihme
	gen muertesevitablesmcluster2`suf' = excess_deaths_ihme-muertesesperadasmcluster2`suf'

}

*Estimaciones para México en 2020 y 2021 (cuadro 1, anexo cap. 2)
list countryname excess_deaths_ihme excess_death_rate_ihme muertesesperadasmcluster2 muertesevitablesmcluster2 muertesesperadasmcluster2lower muertesevitablesmcluster2lower muertesesperadasmcluster2upper muertesevitablesmcluster2upper if code == "MEX"

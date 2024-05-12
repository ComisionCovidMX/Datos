

/*********************************************************************************					
**Comisión Independiente Covid
**Código para reproducir cifras basadas en análisis de ENIGH 2018, 2020, 2022.
**Cpítulos economía y educación informe final 														
**Marzo 2024																	
*********************************************************************************/

/*Pasos principales:
1. Calcular ingreso por decil a partir de muestra de hogares y codificar decil al que pertenecen.
2. Calcular % del ingreso del hogar que se destina a salud y a educación, por decil.
3. Tasas de asistencia escolar por decil.
*/

*Se requiere descarga de bases de concentrado de hogares, viviendas y población de ENIGH 2018, 2020 y 2022



***************************************
**# ENIGH 2018.

**Cálculo de deciles de ingreso con la base de hogares. 

**Cargar base a nivel hogar
use concentradohogar_enigh2018.dta, clear

egen totalhouseholds = total(factor)

*Definir número de hogares por decil, dado el número nacional de hogares
gen decile_size = ceil( totalhouseholds / 10)

***Ordenar hogares de menor a mayor por ingreso corriente trimestral
sort ing_cor

**Calcular suma acumulada de hogares hasta observación _n, según factor de expansión de cada observación
gen cumulative_households = sum(factor)

**Asignar el decil correspondiente a cada obs
gen decil = .

local lower_limit = 0
forval i = 1/9 {
    local upper_limit = `lower_limit' + decile_size
    replace decil = `i' if cumulative_households > `lower_limit' & cumulative_households <= `upper_limit'
    local lower_limit = `upper_limit' + 1
}

replace decil = 10 if decil == .

**Ingreso total nacional de todos los hogares, por decil
egen totalincome = total(factor*ing_cor), by(decil)
format %15.0g totalincome

*Total de hogares por decil, según factor el factor de expansión de cada observación
egen total_weight = total(factor), by(decil)

*Ingreso promedio de  hogares por decil
gen meanincomebydecile = totalincome/total_weight

tab decil, summarize(meanincomebydecile)


************************
************************
*-----------------------------------------------------------------*
***Gasto en educación y salud como % del ingreso, por decil

**** % del gasto del hogar que se destina a salud, por decil
egen total_health_expenses = total(salud * factor), by(decil)
egen total_education_expenses = total(educacion * factor), by(decil)

*Gastos promedio por decil
gen avg_educacion = total_education_expenses/total_weight
gen avg_salud = total_health_expenses/total_weight

// % de gasto salud y educación vs. ingreso hogar total
gen health_expenses_share = (total_health_expenses / totalincome) * 100
gen education_expenses_share = (total_education_expenses / totalincome) * 100

tab decil, summarize( avg_educacion )
tab decil, summarize( avg_salud )
tab decil, summarize( health_expenses_share )
tab decil, summarize( education_expenses_share )

save "hogares2018_condeciles.dta", replace



************************
************************
*-----------------------------------------------------------------*
**Tasas asistencia escolar por decil. 

*Unir bases de viviendas (nivel 3) y hogares (nivel) 2) base personas (nivel 1) 

use "poblacion_enigh2018.dta", clear
merge m:1 folioviv using "viviendas_enigh2018.dta"
drop _merge

merge m:1 folioviv foliohog using "hogares2018_condeciles.dta"

**Ordenar
sort cumulative_households numren

**Convertir vars de asistencia escolar y otras, a numéricas
replace asis_esc = "." if asis_es == " "
destring asis_es, replace

foreach var of varlist nivel grado tipoesc{
	replace `var' = "." if `var' == " "
	destring `var', replace
}

*Recodificar, 1=asiste a escuela, 0=no
recode asis_esc 2=0, gen(asiste_escuela)


*Número total de personas de 3 a 17 (y por rangos de nivel educativo) que asiste a escuela a nivel nacional, por decil
egen total_school_attendance = total(asiste_escuela * factor) if edad >= 3 & edad <= 17, by(decil)

**Lo mismo, por rangos de edades de pob. en edad preescolar, primaria, secundaria y prepa
egen totasisteaescuela_3a5 = total(asiste_escuela * factor) if edad >= 3 & edad <= 5, by(decil)
egen totasisteaescuela_6a11 = total(asiste_escuela * factor) if edad >= 6 & edad <= 11, by(decil)
egen totasisteaescuela_12a14 = total(asiste_escuela * factor) if edad >= 12 & edad <= 14, by(decil)
egen totasisteaescuela_15a17 = total(asiste_escuela * factor) if edad >= 15 & edad <= 17, by(decil)


*Número total de menores en el país por decil 
gen enedadescolar = 1 if edad >= 3 & edad <= 17
egen total_enedadescolar = total(enedadescolar * factor), by(decil)


**Número total de menores en edad escolar, por nivel escolar:
gen enedadpreescolar = 1 if edad >= 3 & edad <= 5
gen enedadprimaria = 1 if edad >= 6 & edad <= 11
gen enedadsecundaria = 1 if edad >= 12 & edad <= 14
gen enedadpreparatoria = 1 if edad >= 15 & edad <= 17

foreach var of varlist enedadpreescolar enedadprimaria enedadsecundaria enedadpreparatoria{
	egen total_`var' = total(`var' * factor), by(decil)
}


*Tasa de asistencia escolar a nivel nacional, total y por grupos de edad
gen school_attendance_rate = (total_school_attendance / total_enedadescolar)*100

gen attendancerate_edadpreescolar = (totasisteaescuela_3a5/ total_enedadpreescolar)*100
gen attendancerate_edadprimaria = (totasisteaescuela_6a11/ total_enedadprimaria)*100
gen attendancerate_edadsecundaria = (totasisteaescuela_12a14/ total_enedadsecundaria)*100
gen attendancerate_edadpreparatoria = (totasisteaescuela_15a17/ total_enedadpreparatoria)*100


tab decil, summarize(total_enedadescolar)
tab decil, summarize(total_school_attendance)
tab decil, summarize(school_attendance_rate)


****Asistencia por edad, año a año, pob de 1 a 18 años
forvalues i = 1/18{
	gen edad`i'asiste = 1 if edad == `i' & asis_esc == 1
	gen edad`i'noasiste = 1 if edad == `i' & asis_esc == 2
 }

foreach var of varlist edad1asiste-edad18noasiste{
	gen `var'_xfactor = `var'*factor
}


**Tabla de número de menores que asisten y no asisten a escuela por edad, año a año:
collapse (sum) edad1asiste_xfactor edad1noasiste_xfactor edad2asiste_xfactor edad2noasiste_xfactor edad3asiste_xfactor edad3noasiste_xfactor edad4asiste_xfactor edad4noasiste_xfactor edad5asiste_xfactor edad5noasiste_xfactor edad6asiste_xfactor edad6noasiste_xfactor edad7asiste_xfactor edad7noasiste_xfactor edad8asiste_xfactor edad8noasiste_xfactor edad9asiste_xfactor edad9noasiste_xfactor edad10asiste_xfactor edad10noasiste_xfactor edad11asiste_xfactor edad11noasiste_xfactor edad12asiste_xfactor edad12noasiste_xfactor edad13asiste_xfactor edad13noasiste_xfactor edad14asiste_xfactor edad14noasiste_xfactor edad15asiste_xfactor edad15noasiste_xfactor edad16asiste_xfactor edad16noasiste_xfactor edad17asiste_xfactor edad17noasiste_xfactor edad18asiste_xfactor edad18noasiste_xfactor, by(decil)


*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*




********************************************************************************
**# 2. ENIGH 2020

**Cálculo de deciles de ingreso con la base de hogares. 

**Cargar base a nivel hogar
use concentradohogar_enigh2020.dta, clear

egen totalhouseholds = total(factor)

*Definir número de hogares por decil, dado el número nacional de hogares
gen decile_size = ceil( totalhouseholds / 10)

***Ordenar hogares de menor a mayor por ingreso corriente trimestral
sort ing_cor

**Calcular suma acumulada de hogares hasta observación _n, según factor de expansión de cada observación
gen cumulative_households = sum(factor)

**Asignar el decil correspondiente a cada obs
gen decil = .

local lower_limit = 0
forval i = 1/9 {
    local upper_limit = `lower_limit' + decile_size
    replace decil = `i' if cumulative_households > `lower_limit' & cumulative_households <= `upper_limit'
    local lower_limit = `upper_limit' + 1
}

replace decil = 10 if decil == .

**Ingreso total nacional de todos los hogares, por decil
egen totalincome = total(factor*ing_cor), by(decil)
format %15.0g totalincome

*Total de hogares por decil, según factor el factor de expansión de cada observación
egen total_weight = total(factor), by(decil)

*Ingreso promedio de  hogares por decil
gen meanincomebydecile = totalincome/total_weight

tab decil, summarize(meanincomebydecile)


************************
************************
*-----------------------------------------------------------------*
***Gasto en educación y salud como % del ingreso, por decil

**** % del gasto del hogar que se destina a salud, por decil
egen total_health_expenses = total(salud * factor), by(decil)
egen total_education_expenses = total(educacion * factor), by(decil)

*Gastos promedio por decil
gen avg_educacion = total_education_expenses/total_weight
gen avg_salud = total_health_expenses/total_weight

// % de gasto salud y educación vs. ingreso hogar total
gen health_expenses_share = (total_health_expenses / totalincome) * 100
gen education_expenses_share = (total_education_expenses / totalincome) * 100

tab decil, summarize( avg_educacion )
tab decil, summarize( avg_salud )
tab decil, summarize( health_expenses_share )
tab decil, summarize( education_expenses_share )

save "hogares2020_condeciles.dta", replace



************************
************************
*-----------------------------------------------------------------*
**Tasas asistencia escolar por decil. 

*Unir bases de viviendas (nivel 3) y hogares (nivel) 2) base personas (nivel 1) 

use "poblacion_enigh2020.dta", clear
merge m:1 folioviv using "viviendas_enigh2020.dta"
drop _merge

merge m:1 folioviv foliohog using "hogares2020_condeciles.dta"

**Ordenar
sort cumulative_households numren

**Convertir vars de asistencia escolar y otras, a numéricas
replace asis_esc = "." if asis_es == " "
destring asis_es, replace

foreach var of varlist nivel grado tipoesc{
	replace `var' = "." if `var' == " "
	destring `var', replace
}

*Recodificar, 1=asiste a escuela, 0=no
recode asis_esc 2=0, gen(asiste_escuela)


*Número total de personas de 3 a 17 (y por rangos de nivel educativo) que asiste a escuela a nivel nacional, por decil
egen total_school_attendance = total(asiste_escuela * factor) if edad >= 3 & edad <= 17, by(decil)

**Lo mismo, por rangos de edades de pob. en edad preescolar, primaria, secundaria y prepa
egen totasisteaescuela_3a5 = total(asiste_escuela * factor) if edad >= 3 & edad <= 5, by(decil)
egen totasisteaescuela_6a11 = total(asiste_escuela * factor) if edad >= 6 & edad <= 11, by(decil)
egen totasisteaescuela_12a14 = total(asiste_escuela * factor) if edad >= 12 & edad <= 14, by(decil)
egen totasisteaescuela_15a17 = total(asiste_escuela * factor) if edad >= 15 & edad <= 17, by(decil)


*Número total de menores en el país por decil 
gen enedadescolar = 1 if edad >= 3 & edad <= 17
egen total_enedadescolar = total(enedadescolar * factor), by(decil)


**Número total de menores en edad escolar, por nivel escolar:
gen enedadpreescolar = 1 if edad >= 3 & edad <= 5
gen enedadprimaria = 1 if edad >= 6 & edad <= 11
gen enedadsecundaria = 1 if edad >= 12 & edad <= 14
gen enedadpreparatoria = 1 if edad >= 15 & edad <= 17

foreach var of varlist enedadpreescolar enedadprimaria enedadsecundaria enedadpreparatoria{
	egen total_`var' = total(`var' * factor), by(decil)
}


*Tasa de asistencia escolar a nivel nacional, total y por grupos de edad
gen school_attendance_rate = (total_school_attendance / total_enedadescolar)*100

gen attendancerate_edadpreescolar = (totasisteaescuela_3a5/ total_enedadpreescolar)*100
gen attendancerate_edadprimaria = (totasisteaescuela_6a11/ total_enedadprimaria)*100
gen attendancerate_edadsecundaria = (totasisteaescuela_12a14/ total_enedadsecundaria)*100
gen attendancerate_edadpreparatoria = (totasisteaescuela_15a17/ total_enedadpreparatoria)*100


tab decil, summarize(total_enedadescolar)
tab decil, summarize(total_school_attendance)
tab decil, summarize(school_attendance_rate)


****Asistencia por edad, año a año, pob de 1 a 18 años
forvalues i = 1/18{
	gen edad`i'asiste = 1 if edad == `i' & asis_esc == 1
	gen edad`i'noasiste = 1 if edad == `i' & asis_esc == 2
 }

foreach var of varlist edad1asiste-edad18noasiste{
	gen `var'_xfactor = `var'*factor
}


**Tabla de número de menores que asisten y no asisten a escuela por edad, año a año:
collapse (sum) edad1asiste_xfactor edad1noasiste_xfactor edad2asiste_xfactor edad2noasiste_xfactor edad3asiste_xfactor edad3noasiste_xfactor edad4asiste_xfactor edad4noasiste_xfactor edad5asiste_xfactor edad5noasiste_xfactor edad6asiste_xfactor edad6noasiste_xfactor edad7asiste_xfactor edad7noasiste_xfactor edad8asiste_xfactor edad8noasiste_xfactor edad9asiste_xfactor edad9noasiste_xfactor edad10asiste_xfactor edad10noasiste_xfactor edad11asiste_xfactor edad11noasiste_xfactor edad12asiste_xfactor edad12noasiste_xfactor edad13asiste_xfactor edad13noasiste_xfactor edad14asiste_xfactor edad14noasiste_xfactor edad15asiste_xfactor edad15noasiste_xfactor edad16asiste_xfactor edad16noasiste_xfactor edad17asiste_xfactor edad17noasiste_xfactor edad18asiste_xfactor edad18noasiste_xfactor, by(decil)



*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*




********************************************************************************
**# 3. Análisis 2022

**Cargar base a nivel hogar
use concentradohogar_enigh2022.dta, clear

egen totalhouseholds = total(factor)

*Definir número de hogares por decil, dado el número nacional de hogares
gen decile_size = ceil( totalhouseholds / 10)

***Ordenar hogares de menor a mayor por ingreso corriente trimestral
sort ing_cor

**Calcular suma acumulada de hogares hasta observación _n, según factor de expansión de cada observación
gen cumulative_households = sum(factor)

**Asignar el decil correspondiente a cada obs
gen decil = .

local lower_limit = 0
forval i = 1/9 {
    local upper_limit = `lower_limit' + decile_size
    replace decil = `i' if cumulative_households > `lower_limit' & cumulative_households <= `upper_limit'
    local lower_limit = `upper_limit' + 1
}

replace decil = 10 if decil == .

**Ingreso total nacional de todos los hogares, por decil
egen totalincome = total(factor*ing_cor), by(decil)
format %15.0g totalincome

*Total de hogares por decil, según factor el factor de expansión de cada observación
egen total_weight = total(factor), by(decil)

*Ingreso promedio de  hogares por decil
gen meanincomebydecile = totalincome/total_weight

tab decil, summarize(meanincomebydecile)


************************
************************
*-----------------------------------------------------------------*
***Gasto en educación y salud como % del ingreso, por decil

**** % del gasto del hogar que se destina a salud, por decil
egen total_health_expenses = total(salud * factor), by(decil)
egen total_education_expenses = total(educacion * factor), by(decil)

*Gastos promedio por decil
gen avg_educacion = total_education_expenses/total_weight
gen avg_salud = total_health_expenses/total_weight

// % de gasto salud y educación vs. ingreso hogar total
gen health_expenses_share = (total_health_expenses / totalincome) * 100
gen education_expenses_share = (total_education_expenses / totalincome) * 100

tab decil, summarize( avg_educacion )
tab decil, summarize( avg_salud )
tab decil, summarize( health_expenses_share )
tab decil, summarize( education_expenses_share )

save "hogares2022_condeciles.dta", replace



************************
************************
*-----------------------------------------------------------------*
**Tasas asistencia escolar por decil. 

*Unir bases de viviendas (nivel 3) y hogares (nivel) 2) base personas (nivel 1) 

use "poblacion_enigh2022.dta", clear
merge m:1 folioviv using "viviendas_enigh2022.dta"
drop _merge

merge m:1 folioviv foliohog using "hogares2022_condeciles.dta"

**Ordenar
sort cumulative_households numren

**Convertir vars de asistencia escolar y otras, a numéricas
replace asis_esc = "." if asis_es == " "
destring asis_es, replace

foreach var of varlist nivel grado tipoesc{
	replace `var' = "." if `var' == " "
	destring `var', replace
}

*Recodificar, 1=asiste a escuela, 0=no
recode asis_esc 2=0, gen(asiste_escuela)


*Número total de personas de 3 a 17 (y por rangos de nivel educativo) que asiste a escuela a nivel nacional, por decil
egen total_school_attendance = total(asiste_escuela * factor) if edad >= 3 & edad <= 17, by(decil)

**Lo mismo, por rangos de edades de pob. en edad preescolar, primaria, secundaria y prepa
egen totasisteaescuela_3a5 = total(asiste_escuela * factor) if edad >= 3 & edad <= 5, by(decil)
egen totasisteaescuela_6a11 = total(asiste_escuela * factor) if edad >= 6 & edad <= 11, by(decil)
egen totasisteaescuela_12a14 = total(asiste_escuela * factor) if edad >= 12 & edad <= 14, by(decil)
egen totasisteaescuela_15a17 = total(asiste_escuela * factor) if edad >= 15 & edad <= 17, by(decil)


*Número total de menores en el país por decil 
gen enedadescolar = 1 if edad >= 3 & edad <= 17
egen total_enedadescolar = total(enedadescolar * factor), by(decil)


**Número total de menores en edad escolar, por nivel escolar:
gen enedadpreescolar = 1 if edad >= 3 & edad <= 5
gen enedadprimaria = 1 if edad >= 6 & edad <= 11
gen enedadsecundaria = 1 if edad >= 12 & edad <= 14
gen enedadpreparatoria = 1 if edad >= 15 & edad <= 17

foreach var of varlist enedadpreescolar enedadprimaria enedadsecundaria enedadpreparatoria{
	egen total_`var' = total(`var' * factor), by(decil)
}


*Tasa de asistencia escolar a nivel nacional, total y por grupos de edad
gen school_attendance_rate = (total_school_attendance / total_enedadescolar)*100

gen attendancerate_edadpreescolar = (totasisteaescuela_3a5/ total_enedadpreescolar)*100
gen attendancerate_edadprimaria = (totasisteaescuela_6a11/ total_enedadprimaria)*100
gen attendancerate_edadsecundaria = (totasisteaescuela_12a14/ total_enedadsecundaria)*100
gen attendancerate_edadpreparatoria = (totasisteaescuela_15a17/ total_enedadpreparatoria)*100


tab decil, summarize(total_enedadescolar)
tab decil, summarize(total_school_attendance)
tab decil, summarize(school_attendance_rate)


****Asistencia por edad, año a año, pob de 1 a 18 años
forvalues i = 1/18{
	gen edad`i'asiste = 1 if edad == `i' & asis_esc == 1
	gen edad`i'noasiste = 1 if edad == `i' & asis_esc == 2
 }

foreach var of varlist edad1asiste-edad18noasiste{
	gen `var'_xfactor = `var'*factor
}


**Tabla de número de menores que asisten y no asisten a escuela por edad, año a año:
collapse (sum) edad1asiste_xfactor edad1noasiste_xfactor edad2asiste_xfactor edad2noasiste_xfactor edad3asiste_xfactor edad3noasiste_xfactor edad4asiste_xfactor edad4noasiste_xfactor edad5asiste_xfactor edad5noasiste_xfactor edad6asiste_xfactor edad6noasiste_xfactor edad7asiste_xfactor edad7noasiste_xfactor edad8asiste_xfactor edad8noasiste_xfactor edad9asiste_xfactor edad9noasiste_xfactor edad10asiste_xfactor edad10noasiste_xfactor edad11asiste_xfactor edad11noasiste_xfactor edad12asiste_xfactor edad12noasiste_xfactor edad13asiste_xfactor edad13noasiste_xfactor edad14asiste_xfactor edad14noasiste_xfactor edad15asiste_xfactor edad15noasiste_xfactor edad16asiste_xfactor edad16noasiste_xfactor edad17asiste_xfactor edad17noasiste_xfactor edad18asiste_xfactor edad18noasiste_xfactor, by(decil)



*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------*



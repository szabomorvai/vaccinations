* Mass media coverage and vaccination uptake: evidence from the demand for meningococcal vaccinations in Hungary
* Anikó Bíró - Ágnes Szabó-Morvai 
* 2021.01.26.

**********************panel data analysis by vacc type**************************************
*use "$dir\Data\vaccin_regdata", clear
global dir "C:\Users\szabomorvai.agnes\Dropbox\Research\Vaccinations_HU\Temp"



	cap drop total_imd_per_Kcap
	gen total_imd_per_Kcap=total_imd/tot_pop_0_17*1000
	
	gen imd_per_Mcap=imd_per_Kcap*1000
	gen total_imd_per_Mcap=total_imd_per_Kcap*1000
	
foreach i in 0 1 2  4 { 
		gen quant_per_Mcap`i' = quant_per_Kcap`i'*1000
}


replace quant_per_Kcap1=. if mdate<654 //MenB not available before July 2014
replace quant_per_Kcap2=. if mdate<618 //MenACWY not available before July 2011

replace quant_per_Mcap1=. if mdate<654 //MenB not available before July 2014
replace quant_per_Mcap2=. if mdate<618 //MenACWY not available before July 2011

xtset num_megye mdate

	cap drop total_imd
	by mdate, sort: egen total_imd=sum(imd)
	xtset num_megye mdate
	

* Effect of unemployment

gen popK_per_gp=pop_per_gp/1000 //1,000 population per GP
gen gp_per_Kpop=1/pop_per_gp*1000


//fill up 2017-2018

gen eu02_help=eu02 if year==2016 & month==12
by num_megye, sort: egen eu02_help2016=min(eu02_help)
replace eu02=eu02_help2016 if year>2016
drop eu02_help*

cap drop  childs_gp_per_100Kpop
gen childs_gp_per_100Kpop=eu02/pop_0_17*100000

gen secondary_edu_perc=secondary_edu*100

forval i=0/2 {

	reg quant_per_Mcap`i' unemp secondary_edu_perc childs_gp_per_100Kpop i.mdate   if year>=2014, robust
	outreg2 using "$dir\outreg_megye.xls", coefastr bracket append

}


*influence of total media coverage - by county		
foreach i in 0 1 2 4 { 
	xtreg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)
	
}


//Specification checks: same regression, but without fixed effects

foreach i in 0 1 2  { 
	reg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap      if year>=2014, robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease_noFE.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)
	
}

foreach i in 0 1 2  { 
	xtreg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap      if year>=2014, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease_noFE.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)
	
}



* influence of death news - by county		
foreach i in 0 1 2  { 

	xtreg quant_per_Mcap`i' death_news l1.death_news l2.death_news l3.death_news l4.death_news /*l5.death_news l6.death_news*/ ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate    if year>=2014, fe robust
	lincom death_news + l1.death_news + l2.death_news + l3.death_news + l4.death_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year*)
}




//effect on searching behaviour

*influence of total media coverage - by county		
	xtreg searchinterest_county total_news l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news 
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year*)
	
* influence of death news - by county		
	xtreg searchinterest_county death_news l1.death_news l2.death_news l3.death_news l4.death_news /*l5.death_news l6.death_news*/ ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate    if year>=2014, fe robust
	lincom death_news + l1.death_news + l2.death_news + l3.death_news + l4.death_news 
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_disease.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year*)


//Heterogeneity by time


foreach i in 0 1 2  { 
	xtreg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap i.mdate, fe robust
	outreg2 using "$dir\outreg_time_heterog.xls", noaster noparen append sideway

	
	xtreg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap i.mdate if year>=2014, fe robust
	outreg2 using "$dir\outreg_time_heterog.xls", noaster noparen append sideway

	
	xtreg quant_per_Mcap`i' total_news l1.total_news l2.total_news l3.total_news l4.total_news ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap i.mdate if year>=2016 & year<=2017, fe robust
	outreg2 using "$dir\outreg_time_heterog.xls", noaster noparen append sideway

}

//Heterogeneity by county groups

by mdate, sort: egen median_unemp=xtile(unemp), n(2)

xtset num_megye mdate
foreach i in 0 1 2  { 
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_unemp==1, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)
	
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_unemp==2, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)	
}

by mdate, sort: egen median_gp=xtile(childs_gp_per_100Kpop), n(2)

xtset num_megye mdate
foreach i in 0 1 2  { 
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_gp==1, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)	
	
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_gp==2, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)	
	
}

by mdate, sort: egen median_edu=xtile(secondary_edu), n(2)

xtset num_megye mdate
foreach i in 0 1 2  { 
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_edu==1, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)	
	
	xtreg quant_per_Mcap`i' total_news  l1.total_news l2.total_news l3.total_news l4.total_news   ///
	imd_per_Mcap l.imd_per_Mcap l2.imd_per_Mcap l3.imd_per_Mcap l4.imd_per_Mcap   i.mdate   if year>=2014 & median_edu==2, fe robust
	lincom total_news + l1.total_news + l2.total_news + l3.total_news + l4.total_news
	local coef=r(estimate)
	local se=r(se)
	local t `=`coef'/`se'' 
	outreg2 using "$dir\outreg_heterog.xls", coefastr bracket append ///
	addstat("estimate", `coef', "standard error", `se', "t statistic", `t') drop(*year* *mdate*)	
	
}





cd C:\Users\Lyn_Sofiya\Desktop\Assignment\
import delimited "C:\Users\Lyn_Sofiya\Desktop\Assignment\Assign.csv", varnames(1) stringcols(3 4) numericcols(1 5 6 7 8)
save C:\Users\Lyn_Sofiya\Desktop\Assignment\Assign.dta, replace

*Renaming variables
rename unemploymenttotaloftotallaborfor unemploy_tot
rename unemploymentyouthtotaloftotallab unemploy_youth
rename spglobalequityindicesannualchang S_and_P
rename gdppercapitapppconstant2017inter GDPperCap
rename countryname country
rename time year

*Transforming countries into string data and droping them
replace country = subinstr(country, " ", "_", .)

*Dropping countries without enough data for balanced panel
drop if country == "Albania"
drop if country == "Andorra"
drop if country == "Azerbaijan"
drop if country == "Armenia"
drop if country == "Belarus"
drop if country == "Bermuda"
drop if country == "Bosnia_and_Herzegovina"
drop if country == "Channel_Islands"
drop if country == "Faroe_Islands"
drop if country == "Gibraltar"
drop if country == "Georgia"
drop if country == "Greenland"
drop if country == "India"
drop if country == "Isle_of_Man"
drop if country == "Kosovo"
drop if country == "Kyrgyz_Republic"
drop if country == "Liechtenstein"
drop if country == "Moldova"
drop if country == "Monaco"
drop if country == "Montenegro"
drop if country == "North_Macedonia"
drop if country == "San_Marino"
drop if country == "Saudi_Arabia"
drop if country == "Serbia"
drop if country == "Tajikistan"
drop if country == "Turkmenistan"
drop if country == "Uzbekistan"

*Generating Log Variable
gen ln_unemploy_tot = log(unemploy_tot)
gen ln_unemploy_youth = log(unemploy_youth)

*Linear Regression
reg ln_unemploy_tot S_and_P, robust
/*Linear regression                               Number of obs     =        741
     
Linear regression                               Number of obs     =        741
                                                F(1, 739)         =       2.10
                                                Prob > F          =     0.1482
                                                R-squared         =     0.0025
                                                Root MSE          =     .45325

------------------------------------------------------------------------------
             |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |   .0006949   .0004801     1.45   0.148    -.0002476    .0016373
       _cons |   1.994121   .0174202   114.47   0.000     1.959922     2.02832
----------------------
----------------------------------------------------------



*/


reg ln_unemploy_youth S_and_P, robust

/*

Linear regression                               Number of obs     =        724
                                                F(1, 722)         =       0.45
                                                Prob > F          =     0.5005
                                                R-squared         =     0.0005
                                                Root MSE          =     .49295

------------------------------------------------------------------------------
             |               Robust
ln_unemplo~h | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |   .0003539    .000525     0.67   0.500    -.0006768    .0013847
       _cons |   2.807209   .0193353   145.19   0.000     2.769248    2.845169
------------------------------------------------------------------------------

. 

*/



*Generating dummies for upper-middle income countries
sum GDPperCap

/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
   GDPperCap |        792     39664.5    19039.19   7496.813   120647.8

. 
*/

		
gen less_middle=0
	replace less_middle = 1 if GDPperCap>39664.5
	replace less_middle = . if missing(GDPperCap)

reg S_and_P less_middle, robust
/*
Linear regression                               Number of obs     =        744
                                                F(1, 742)         =       0.94
                                                Prob > F          =     0.3317
                                                R-squared         =     0.0012
                                                Root MSE          =     32.562

------------------------------------------------------------------------------
             |               Robust
     S_and_P | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 less_middle |  -2.277134    2.34418    -0.97   0.332    -6.879149    2.324881
       _cons |   9.291514   1.918983     4.84   0.000     5.524231     13.0588
-----------------------------------

*/


*Generating codes for countries
egen id = group(country)
tab id
xtset id year, yearly

*Generating First Difference
gen d_S_and_P = d.S_and_P
gen d_ln_unemploy_tot = d.ln_unemploy_tot
gen d_ln_unemploy_youth = d.ln_unemploy_youth

*No Lags
reg d.ln_unemploy_tot d.S_and_P, cluster(year)

/* 

Linear regression                               Number of obs     =        706
                                                F(1, 20)          =       1.90
                                                Prob > F          =     0.1828
                                                R-squared         =     0.0490
                                                Root MSE          =     .15483

                                  (Std. err. adjusted for 21 clusters in year)
------------------------------------------------------------------------------
D.           |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |
         D1. |   .0007601   .0005508     1.38   0.183    -.0003888     .001909
             |
       _cons |  -.0114973   .0204787    -0.56   0.581    -.0542152    .0312207
------------------------------------------------------------------------------
*/


*/
reg d.ln_unemploy_tot d.S_and_P, cluster(country)
/*
Linear regression                               Number of obs     =        706
                                                F(1, 34)          =      48.06
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0490
                                                Root MSE          =     .15483

                               (Std. err. adjusted for 35 clusters in country)
------------------------------------------------------------------------------
D.           |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |
         D1. |   .0007601   .0001096     6.93   0.000     .0005373    .0009829
             |
       _cons |  -.0114973   .0047138    -2.44   0.020    -.0210768   -.0019178
-------------------------------
--------------------------------------------------
*/

*With 5 year lag

reg d.ln_unemploy_tot L(0/5)d.S_and_P, cluster(country)
/*
Linear regression                               Number of obs     =        531
                                                F(6, 34)          =      23.80
                                                Prob > F          =     0.0000
                                                R-squared         =     0.2565
                                                Root MSE          =     .14508

                               (Std. err. adjusted for 35 clusters in country)
------------------------------------------------------------------------------
D.           |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |
         D1. |   .0002303   .0001806     1.28   0.211    -.0001367    .0005973
         LD. |  -.0017144   .0003029    -5.66   0.000      -.00233   -.0010988
        L2D. |  -.0029229   .0004448    -6.57   0.000    -.0038269   -.0020189
        L3D. |  -.0027315   .0004055    -6.74   0.000    -.0035555   -.0019075
        L4D. |  -.0017703   .0003474    -5.10   0.000    -.0024763   -.0010643
        L5D. |  -.0008341   .0002034    -4.10   0.000    -.0012474   -.0004208
             |
       _cons |  -.0218168   .0058795    -3.71   0.001    -.0337655   -.0098681
------------------------------------------------------------------------------

*/

reg d.ln_unemploy_tot L(0/5)d.S_and_P, cluster(year)

/*
Linear regression                               Number of obs     =        531
                                                F(6, 15)          =       9.41
                                                Prob > F          =     0.0002
                                                R-squared         =     0.2565
                                                Root MSE          =     .14508

                                  (Std. err. adjusted for 16 clusters in year)
------------------------------------------------------------------------------
D.           |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |
         D1. |   .0002303   .0003297     0.70   0.496    -.0004725    .0009331
         LD. |  -.0017144   .0006408    -2.68   0.017    -.0030803   -.0003486
        L2D. |  -.0029229    .000688    -4.25   0.001    -.0043894   -.0014564
        L3D. |  -.0027315   .0006303    -4.33   0.001    -.0040749   -.0013882
        L4D. |  -.0017703   .0004806    -3.68   0.002    -.0027948   -.0007458
        L5D. |  -.0008341   .0003731    -2.24   0.041    -.0016294   -.0000389
             |
       _cons |  -.0218168   .0193875    -1.13   0.278    -.0631403    .0195067
------------------------------------------------------------------------------

*/

reg d.unemploy_tot L(0/5)d.S_and_P upper_middle, cluster(year)


/*
Linear regression                               Number of obs     =        531
                                                F(7, 15)          =      15.82
                                                Prob > F          =     0.0000
                                                R-squared         =     0.2738
                                                Root MSE          =     1.2769

                                  (Std. err. adjusted for 16 clusters in year)
------------------------------------------------------------------------------
D.           |               Robust
unemploy_tot | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |
         D1. |   .0019655   .0024794     0.79   0.440    -.0033192    .0072501
         LD. |  -.0151624   .0045683    -3.32   0.005    -.0248995   -.0054252
        L2D. |  -.0266046   .0049949    -5.33   0.000    -.0372509   -.0159583
        L3D. |  -.0258027   .0049244    -5.24   0.000    -.0362988   -.0153065
        L4D. |   -.017518   .0039156    -4.47   0.000     -.025864    -.009172
        L5D. |  -.0086127   .0030064    -2.86   0.012    -.0150206   -.0022048
             |
upper_middle |   .2315466   .1339865     1.73   0.104    -.0540388     .517132
       _cons |  -.2812308   .1775137    -1.58   0.134    -.6595923    .0971307
------------------------------------------------------------------------------

*/


xtreg ln_unemploy_tot S_and_P i.year, fe cluster(country)

/*
------------------------------------------------------------------------------
             |               Robust
ln_unemplo~t | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
     S_and_P |   .0019765   .0005547     3.56   0.001     .0008492    .0031038
             |
        year |
       2001  |  -.0279718   .0244487    -1.14   0.261    -.0776575    .0217139
       2002  |  -.0362816   .0381985    -0.95   0.349    -.1139102     .041347
       2003  |  -.0967092   .0609369    -1.59   0.122    -.2205478    .0271295
       2004  |  -.0769508    .062452    -1.23   0.226    -.2038686    .0499671
       2005  |  -.0619484   .0672246    -0.92   0.363    -.1985652    .0746683
       2006  |  -.2076396   .0771024    -2.69   0.011    -.3643305   -.0509487
       2007  |  -.3137144   .0857468    -3.66   0.001    -.4879729   -.1394559
       2008  |  -.1335844   .0772036    -1.73   0.093     -.290481    .0233122
       2009  |  -.0208218   .0828657    -0.25   0.803    -.1892252    .1475815
       2010  |   .1192155   .0778909     1.53   0.135     -.039078    .2775089
       2011  |   .1389249   .0827762     1.68   0.102    -.0292966    .3071465
       2012  |   .1001926   .0855438     1.17   0.250    -.0736533    .2740386
       2013  |   .1205857   .0866894     1.39   0.173    -.0555883    .2967597
       2014  |   .1254715   .0882794     1.42   0.164    -.0539338    .3048768
       2015  |   .0539251   .0901765     0.60   0.554    -.1293355    .2371857
       2016  |  -.0501455   .0961755    -0.52   0.605    -.2455976    .1453066
       2017  |  -.2119913   .1015688    -2.09   0.044    -.4184039   -.0055788
       2018  |  -.2548412    .100725    -2.53   0.016     -.459539   -.0501433
       2019  |  -.4000683   .1086725    -3.68   0.001    -.6209173   -.1792193
       2020  |  -.2167799   .1058963    -2.05   0.048    -.4319871   -.0015727
       2021  |  -.2632389   .1092954    -2.41   0.022    -.4853538    -.041124
             |
       _cons |   2.060607   .0655742    31.42   0.000     1.927344     2.19387
-------------+----------------------------------------------------------------
     sigma_u |  .34521557
     sigma_e |  .27125787
         rho |  .61826684   (fraction of variance due to u_i)
------------------------------------------------------------------------------

. 
/*
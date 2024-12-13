/*****************************************/
/* Author: Bri Noel                      */
/*****************************************/

/* Create new library */
libname report "C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report";


/* Import CSV files for each year */
proc import out = report.climate_1963
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_1963.csv"  
            dbms=csv replace; 
            getnames=yes;
run;
proc import out = report.climate_1975
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_1975.csv"  
            dbms=csv replace; 
            getnames=yes;
run;
proc import out = report.climate_1987
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_1987.csv"  
            dbms=csv replace; 
            getnames=yes;
run;
proc import out = report.climate_1999
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_1999.csv"  
            dbms=csv replace; 
            getnames=yes;
run;

proc import out = report.climate_2011
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_2011.csv"  
            dbms=csv replace; 
            getnames=yes;
run;
proc import out = report.climate_2023
			datafile ="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\LA_climate_2023.csv"  
            dbms=csv replace; 
            getnames=yes;
run;

/***** Data Cleaning and New Variable Creation *****/
/* Combine all six datasets into one dataset */
data report.climate_data;
    set report.climate_1963 (in=a)
        report.climate_1975 (in=b)
        report.climate_1987 (in=c)
        report.climate_1999 (in=d)
        report.climate_2011 (in=e)
        report.climate_2023 (in=f);
    
    /* Create a YEAR variable to identify the data */
    if a then YEAR = "1963";
    else if b then YEAR = "1975";
    else if c then YEAR = "1987";
    else if d then YEAR = "1999";
    else if e then YEAR = "2011";
    else if f then YEAR = "2023";
run;

/* Remove unneccessary variables with repeated information not needed for analysis */
data report.climate_data (drop = STATION LATITUDE LONGITUDE ELEVATION NAME);
	set report.climate_data;
run;

/* Remove indicator or _attribute variables */
data report.climate_data (drop = TEMP_ATTRIBUTES DEWP_ATTRIBUTES SLP_ATTRIBUTES STP_ATTRIBUTES VISIB_ATTRIBUTES WDSP_ATTRIBUTES MAX_ATTRIBUTES MIN_ATTRIBUTES PRCP_ATTRIBUTES);
	set report.climate_data;
run;


/* Create frequency tables for remaining variables */
proc freq data = report.climate_data;
table TEMP;
run;

proc freq data = report.climate_data;
table DEWP;
run;

proc freq data = report.climate_data;
table SLP;
run;

proc freq data = report.climate_data;
table STP; 
run;

proc freq data = report.climate_data;
table VISIB;
run;

proc freq data = report.climate_data;
table WDSP;
run;

proc freq data = report.climate_data;
table MXSPD;
run;

proc freq data = report.climate_data;
table GUST;
run;

proc freq data = report.climate_data;
table MAX;
run;

proc freq data = report.climate_data;
table MIN;
run;

proc freq data = report.climate_data;
table PRCP;
run;

proc freq data = report.climate_data;
table SNDP;
run;

proc freq data = report.climate_data;
table FRSHTT;
run;

/* Remove unnecessary variables identified from previous frequency tables */
data report.climate_data (drop = STP MXSPD GUST PRCP SNDP FRSHTT);
	set report.climate_data;
run;

/* Create new categorical variable SEASON */
data report.new_climate_data (drop = MONTH_NUM); 
	set report.climate_data;
	MONTH_NUM = month(DATE);  

   if MONTH_NUM in (12, 1, 2) then SEASON = "Winter";
   else if MONTH_NUM in (3, 4, 5) then SEASON = "Spring";
   else if MONTH_NUM in (6, 7, 8) then SEASON = "Summer";
   else if MONTH_NUM in (9, 10, 11) then SEASON = "Fall";

run;

/* Create descriptive stats for two quant variables to make ranges to change to categorical variables */
proc means data = report.climate_data n mean median stddev range q1 q3;
	var SLP VISIB;
	run;

/* Create a categorical variable for SLP */
data report.new_climate_data (drop = MIN SLP);
   set report.new_climate_data;  
   length SLP_CAT $20;
   if SLP < 1013 then SLP_CAT = "Low Pressure";
   else if 1013 <= SLP < 1018 then SLP_CAT = "Normal Pressure";
   else if 1018 <= SLP then SLP_CAT = "High Pressure";
run;

/* Create a categorical variable for VISIB */
data report.new_climate_data (drop = VISIB);
   set report.new_climate_data;  
   length VISIB_CAT $20;
   if VISIB < 7.1 then VISIB_CAT = "Low Visibility";
   else if 7.1 <= VISIB < 10.1 then VISIB_CAT = "Moderate Visibility";
   else if 10.1 <= VISIB then VISIB_CAT = "High Visibility";
run;

/* Create frequency variables for new categorical variables */
proc freq data = report.new_climate_data;
table SLP_CAT VISIB_CAT;
run;

/* Change DATE variable to a ID variable name */
data report.new_climate_data;
	set report.new_climate_data;
	DATE_ID = DATE;
	format DATE_ID mmddyy10.
run;

/* Reorder 1 ID variable, 4 quant variables, 4 categorical variables */
data report.new_climate_data (drop = DATE);
	retain DATE_ID TEMP DEWP WDSP MAX YEAR SEASON SLP_CAT VISIB_CAT;
	set report.new_climate_data;
run;


/***** EDA *****/
/* Descriptive stats for quant variables */
title "Descriptive Statistics";
proc means data = report.new_climate_data n mean median stddev range q1 q3;
	var TEMP DEWP WDSP MAX;
	run;

/* Histograms for quant variables */
title "Histograms";
proc univariate data=report.new_climate_data; 
    histogram / normal;
	var TEMP DEWP WDSP MAX;
run;

/* Frequency tables for categorical variables */
title "Frequency Tables";
proc freq data = report.new_climate_data;
tables YEAR SEASON SLP_CAT VISIB_CAT;
run;

/* Side-by-side boxplots for categorical variables vs temperature */
proc sgplot data=report.new_climate_data;
    vbox TEMP / category=SEASON;  
    title 'Side-by-Side Box Plots of Temperature by Season';
    xaxis label='Season';  
    yaxis label='Temperature (°F)'; 
run;

proc sgplot data=report.new_climate_data;
    vbox TEMP / category=YEAR;  
    title 'Side-by-Side Box Plots of Temperature by Year';
    xaxis label='Year';  
    yaxis label='Temperature (°F)';  
run;

/* Correlation matrix for quant variables */
title "Correlation Matrix for Quantitative Variables";
proc corr data = report.new_climate_data;
	var TEMP DEWP WDSP MAX;
	run;

/* Scatter plot for quant variables */
title "Scatterplot for Dew Point vs Temperature";
proc corr data=report.new_climate_data plots=scatter(nvar=all);
    var DEWP TEMP; *MAX WDSP; 
run;


/***** Statistical Methods *****/
/* One-Way ANOVA for temperature across years, including post-hoc test */
title "One-Way ANOVA for Temperatures Across Years";
proc anova data=report.new_climate_data;
    class YEAR;
    model TEMP = YEAR; 
    means YEAR / lsd tukey cldiff;
run;

/* Subset data for summer and perform One-Way ANOVA for summer temperature across years, including post-hoc test */
title "One-Way ANOVA for Summer Temperatures Across Years";
proc anova data=report.new_climate_data;
    where SEASON = 'Summer'; 
    class YEAR; 
    model TEMP = YEAR;
    means YEAR / lsd tukey cldiff; 
run;

/* Subset data for winter and perform One-Way ANOVA for winter temperature across years, including post-hoc test */
title "One-Way ANOVA for Winter Temperatures Across Years";
proc anova data=report.new_climate_data;
    where SEASON = 'Winter'; 
    class YEAR; 
    model TEMP = YEAR;
    means YEAR / lsd tukey cldiff; 
run;

/* One-Way ANOVA for sea level pressure across years, including post-hoc test */
title "One-Way ANOVA for Temperatures Across Sea Level Pressure Ranges";
proc anova data=report.new_climate_data;
    class SLP_CAT; 
    model TEMP = SLP_CAT; 
    means SLP_CAT / lsd tukey cldiff; 
run;

/* One-Way ANOVA for visibility across years, including post-hoc test */
title "One-Way ANOVA for Temperatures Across Visibilty Ranges";
proc anova data=report.new_climate_data;
    class VISIB_CAT;
    model TEMP = VISIB_CAT; 
    means VISIB_CAT / lsd tukey cldiff;
run;

/* One-Way ANOVA for wind speed across years, including post-hoc test */
title "One-Way ANOVA for Wind Speeds Across Years";
proc anova data=report.new_climate_data;
    class YEAR;
    model WDSP = YEAR; 
    means YEAR / lsd tukey cldiff;
run;

/* T-test for wind speed between 1963 and 2023 */
title "t-Test for Wind Speeds between 1963 and 2023";
proc ttest data=report.new_climate_data;
    class YEAR;
    var WDSP; 
    where year in ("1963", "2023"); 
run;

/* T-test for temperature between 1963 and 2023 */
title "t-Test for Temperatures between 1963 and 2023";
proc ttest data=report.new_climate_data;
    class YEAR; 
    var TEMP; 
    where year in ("1963", "2023"); 
run;

/* T-test for temperature between 1975 and 2023 */
title "t-Test for Temperatures between 1975 and 2023";
proc ttest data=report.new_climate_data;
    class YEAR; 
    var TEMP; 
    where year in ("1975", "2023"); 
run;

/* T-test for max temperature between 1975 and 2023 */
title "t-Test for Max Temperatures between 1975 and 2023";
proc ttest data=report.new_climate_data;
    class YEAR; 
    var MAX; 
    where year in ("1975", "2023"); 
run;

/* T-test for summer temperature between 1975 and 2023 */
title "t-Test for Summer Temperatures between 1975 and 2023";
proc ttest data=report.new_climate_data;
    where SEASON = 'Summer' and YEAR in ("1975", "2023");  
    class YEAR;              
    var TEMP;
run;

/* T-test for winter temperature between 1975 and 2023 */
title "t-Test for Winter Temperatures between 1975 and 2023";
proc ttest data=report.new_climate_data;
    where SEASON = 'Winter' and YEAR in ("1975", "2023");  
    class YEAR;              
    var TEMP;
run;


/* Simple linear regression for dew point vs temperature */
title "Simple Linear Regression Dew Point vs. Temperature";
proc reg data=report.new_climate_data;
    model TEMP = DEWP;
run;



/***** Exporting CSV *****/
/* Export new CSV file for cleaned climate data */
proc export data=report.new_climate_data
    outfile="C:\Users\Brino\OneDrive\Desktop\Fall 2024\Statistical Methods\Week 14\Report\cleaned_climate_data.csv"
    dbms=csv
    replace;
run;

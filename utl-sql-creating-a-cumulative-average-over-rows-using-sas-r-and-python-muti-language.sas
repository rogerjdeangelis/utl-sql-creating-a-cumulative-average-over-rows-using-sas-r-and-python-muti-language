%let pgm=utl-sql-creating-a-cumulative-average-over-rows-using-sas-r-and-python-muti-language;

SQL creating a cumulative average over rows using sas r and python muti language

github
https://tinyurl.com/567bhuzd
https://github.com/rogerjdeangelis/utl-sql-creating-a-cumulative-average-over-rows-using-sas-r-and-python-muti-language

SOAPBOX ON

 Not well suited for SQL but doable.
 Weighing learning several other languages vs sql for basic analysis.

     1 dplyr
     2 data.table (example: transpose instead of shape?)
     2 tidyverse (apply, lapply , mapply, tapply ..)
     3 pandas
     4 numpy
     5 all those data structures and datatypes which have unique syntax
       in both r and worse in python.

     However packages for plotting, time series, data science ... are a must!
     Just wish the syntax was more similar between R and Python packages.

SOAPBOX OFF

   FIVE SOLUTIONS

          0 sas datastep
          1 sas sql (noy efficient for a large number of partial sums)
          2 r sql (has builtin functions for cumulative averaging - may be able to use sql lag function instead)
          3 python sql
          4 r tidyverse language

Another example of non set operations using sql

Note I have added a primary key, PK to the input.
However it is trivial to add a squence key to any data frame or sas dataset

  EXAMPLES TO AFF SEQUENCE NUMBER

    R AND PYTHON
     select
        row_number() over (order by column_name) as row_num,
     from your_table;

    SAS (montonic is not supported but if you use with minimal sql code it should be ok)
     select
        montonic() as pk
     from your_table;


related repo
https://tinyurl.com/mr2mzdkh
https://stackoverflow.com/questions/79100578/r-how-to-calculate-cumulative-mean-over-first-n-rows-and-fill-result-down-colum

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                         |                                                                  |                           */
/*   INPUT                 |       PROCESS                                                    |       OUTPUT              */
/*   =====                 |  (USEFUL IN STATISTICAL ANALYSIS)                                |       ======              */
/*                         |     (SAME CODE IN R PYTHON)                                      |                           */
/*                         |  ================================                                |                           */
/*  PK    VAR1             |                                                                  |    > want                 */
/*                         |  OF ROWS 1-3 AND THEN REPEAT                                     |       PK VAR1   SLOTIN    */
/*  1      87              |  THE 3RD CUMULATIVE AVERAGE                                      |      1   87 87.00000      */
/*  2     104              |  ONER ROWS 4-10                                                  |      2  104 95.50000      */
/*  3      83              |                                                                  |      3   83 91.33333      */
/*  4     132              |  PK VAR1   CUMAVG                                                |      4  132 91.33333      */
/*  5     107              |                                                                  |      5  107 91.33333      */
/*  6      84              |  1   87    87.0  87                                              |      6   84 91.33333      */
/*  7     110              |  2   104   95.5  (87+104)/2   avg top 2                          |      7  110 91.33333      */
/*  8     115              |  3   83    91.3  (87+104+83)/3 avf top 3                         |      8  115 91.33333      */
/*  9     112              |                                                                  |      9  112 91.33333      */
/* 10      94              |  4   132   91.3  Repeat 91.3                                     |     10   94 91.33333      */
/*                         |  5   107   91.3                                                  |                           */
/*                         |  6   84    91.3                                                  |                           */
/*                         |  7   110   91.3                                                  |                           */
/*                         |  8   115   91.3                                                  |                           */
/*                         |  9   112   91.3                                                  |                           */
/*                         | 10   94    91.3                                                  |                           */
/*                         |                                                                  |                           */
/*                         |  EXPLANATION (R solution)                                        |                           */
/*                         |                                                                  |                           */
/*                         |     1. Create view with top 3 cumulative averages                |                           */
/*                         |     2. Left join original 10 records                             |                           */
/*                         |        and slot in the top 3 cums and the 3rd cum                |                           */
/*                         |        for the remaing 7 records                                 |                           */
/*                         |                                                                  |                           */
/*                         |  want <- sqldf('                                                 |                           */
/*                         |  with top3 as (                                                  |                           */
/*                         |  select                                                          |                           */
/*                         |    pk                                                            |                           */
/*                         |   ,var1                                                          |                           */
/*                         |   ,avg(var1) over (                                              |                           */
/*                         |      rows between unbounded preceding and current row            |                           */
/*                         |    ) as cumavg                                                   |                           */
/*                         |  from have                                                       |                           */
/*                         |  where pk <4                                                     |                           */
/*                         |    )                                                             |                           */
/*                         |  select                                                          |                           */
/*                         |    l.pk                                                          |                           */
/*                         |   ,l.var1                                                        |                           */
/*                         |   ,case                                                          |                           */
/*                         |      when (l.pk < 4) then c.cumavg                               |                           */
/*                         |      when (l.pk > 3) then r.cumavg                               |                           */
/*                         |    end as slotin                                                 |                           */
/*                         |  from                                                            |                           */
/*                         |    have as l                                                     |                           */
/*                         |       left join top3 as c on l.pk = c.pk                         |                           */
/*                         |       left join top3 as r on r.pk=3                              |                           */
/*                         |                                                                  |                           */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  retain pk 0;
  input var1;
  pk=pk++1;
cards4;
87      87
104    104
83      83
132    132
107    107
84      84
110    110
115    115
112    112
94      94
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  SD1.HAVE total obs=10                                                                                                 */
/*                                                                                                                        */
/*   PK    VAR1                                                                                                           */
/*                                                                                                                        */
/*    1      87                                                                                                           */
/*    2     104                                                                                                           */
/*    3      83                                                                                                           */
/*    4     132                                                                                                           */
/*    5     107                                                                                                           */
/*    6      84                                                                                                           */
/*    7     110                                                                                                           */
/*    8     115                                                                                                           */
/*    9     112                                                                                                           */
/*   10      94                                                                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                        _       _            _
 / _ \   ___  __ _ ___    __| | __ _| |_ __ _ ___| |_ ___ _ __
| | | | / __|/ _` / __|  / _` |/ _` | __/ _` / __| __/ _ \ `_ \
| |_| | \__ \ (_| \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |
 \___/  |___/\__,_|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                                         |_|
*/

data cumulative_avg;
  set sd1.have;
  retain cum_sum cum_avg 0;
  select ;
     when (pk <= 3) do ;
          cum_sum =cum_sum + var1;
          cum_avg = cum_sum / _n_;
     end;
     otherwise;
  end;
run;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  WORK.CUMULATIVE_AVG total obs=10                                                                                      */
/*                                                                                                                        */
/*   PK    VAR1    CUM_SUM    CUM_AVG                                                                                     */
/*                                                                                                                        */
/*    1      87       87      87.0000                                                                                     */
/*    2     104      191      95.5000                                                                                     */
/*    3      83      274      91.3333                                                                                     */
/*    4     132      274      91.3333                                                                                     */
/*    5     107      274      91.3333                                                                                     */
/*    6      84      274      91.3333                                                                                     */
/*    7     110      274      91.3333                                                                                     */
/*    8     115      274      91.3333                                                                                     */
/*    9     112      274      91.3333                                                                                     */
/*   10      94      274      91.3333                                                                                     */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/

proc sql;
create view top as
select max(pk) as pk ,avg(var1) as cumavg from sd1.have where pk<=2 union all
select max(pk) as pk ,avg(var1) as cumavg from sd1.have where pk<=3
;quit;

proc sql;
create
  table want as
select
  l.Pk
 ,l.VAR1
 ,case
    when (l.pk = 1) then l.var1
    when (l.pk < 3) then C.CUMAVG
    else                 r.CUMAVG
  end as slotin
from
  sd1.have as l
     left join top as c on l.pk = c.pk
     left join top as r on r.pk=3
;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* WORK.WANT total obs=10                                                                                                 */
/*                                                                                                                        */
/*  PK    VAR1     SLOTIN                                                                                                 */
/*                                                                                                                        */
/*   1      87    87.0000                                                                                                 */
/*   2     104    95.5000                                                                                                 */
/*   3      83    91.3333                                                                                                 */
/*   4     132    91.3333                                                                                                 */
/*   5     107    91.3333                                                                                                 */
/*   6      84    91.3333                                                                                                 */
/*   7     110    91.3333                                                                                                 */
/*   8     115    91.3333                                                                                                 */
/*   9     112    91.3333                                                                                                 */
/*  10      94    91.3333                                                                                                 */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                     _
|___ \   _ __   ___  __ _| |
  __) | | `__| / __|/ _` | |
 / __/  | |    \__ \ (_| | |
|_____| |_|    |___/\__, |_|
                       |_|
*/

%utl_rbeginx;
parmcards4;
library(sqldf)
library(haven)
source("c:/oto/fn_tosas9x.r")
set.seed(1)
have<-read_sas("d:/sd1/have.sas7bdat")
have;
want <- sqldf('
with top3 as (
select
  Pk
 ,VAR1
 ,avg(VAR1) over (
    rows between unbounded preceding and current row
  ) as CUMAVG
from have
where pk <4
  )
select
  l.Pk
 ,l.VAR1
 ,case
    when (l.pk < 4) then c.CUMAVG
    when (l.pk > 3) then r.CUMAVG
  end as slotin
from
  have as l
     left join top3 as c on l.pk = c.pk
     left join top3 as r on r.pk=3
')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rwant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  > want                    SAS                                                                                         */
/*                                                                                                                        */
/*     PK VAR1   slotin       ROWNAMES    PK    VAR1     SLOTIN                                                           */
/*                                                                                                                        */
/*  1   1   87 87.00000           1        1      87    87.0000                                                           */
/*  2   2  104 95.50000           2        2     104    95.5000                                                           */
/*  3   3   83 91.33333           3        3      83    91.3333                                                           */
/*  4   4  132 91.33333           4        4     132    91.3333                                                           */
/*  5   5  107 91.33333           5        5     107    91.3333                                                           */
/*  6   6   84 91.33333           6        6      84    91.3333                                                           */
/*  7   7  110 91.33333           7        7     110    91.3333                                                           */
/*  8   8  115 91.33333           8        8     115    91.3333                                                           */
/*  9   9  112 91.33333           9        9     112    91.3333                                                           */
/*  10 10   94 91.33333          10       10      94    91.3333                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____               _   _                             _
|___ /   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
  |_ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql('''
with top3 as (
select
  Pk
 ,VAR1
 ,avg(VAR1) over (
    rows between unbounded preceding and current row
  ) as CUMAVG
from have
where pk <4
  )
select
  l.Pk
 ,l.VAR1
 ,case
    when (l.pk < 4) then c.CUMAVG
    when (l.pk > 3) then r.CUMAVG
  end as slotin
from
  have as l
     left join top3 as c on l.pk = c.pk
     left join top3 as r on r.pk=3
   ''');
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* PYTHON                        SAS                                                                                      */
/*                                                                                                                        */
/*       PK   VAR1     slotin    PK    VAR1     SLOTIN                                                                    */
/*                                                                                                                        */
/*  0   1.0   87.0  87.000000     1      87    87.0000                                                                    */
/*  1   2.0  104.0  95.500000     2     104    95.5000                                                                    */
/*  2   3.0   83.0  91.333333     3      83    91.3333                                                                    */
/*  3   4.0  132.0  91.333333     4     132    91.3333                                                                    */
/*  4   5.0  107.0  91.333333     5     107    91.3333                                                                    */
/*  5   6.0   84.0  91.333333     6      84    91.3333                                                                    */
/*  6   7.0  110.0  91.333333     7     110    91.3333                                                                    */
/*  7   8.0  115.0  91.333333     8     115    91.3333                                                                    */
/*  8   9.0  112.0  91.333333     9     112    91.3333                                                                    */
/*  9  10.0   94.0  91.333333    10      94    91.3333                                                                    */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*  _            _   _     _
| || |    _ __  | |_(_) __| |_   ___   _____ _ __ ___  ___
| || |_  | `__| | __| |/ _` | | | \ \ / / _ \ `__/ __|/ _ \
|__   _| | |    | |_| | (_| | |_| |\ V /  __/ |  \__ \  __/
   |_|   |_|     \__|_|\__,_|\__, | \_/ \___|_|  |___/\___|
                             |___/
*/

%utl_rbeginx;
parmcards4;
library(tidyverse)
library(haven)
source("c:/oto/fn_tosas9x.r")
set.seed(1)
have<-read_sas("d:/sd1/have.sas7bdat")
have;
want <- have |>
  mutate(VAR1_MEAN = if_else(PK<= 3, cummean(VAR1), NA)) |>
  fill(VAR1_MEAN)
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rrwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rrwant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  R                         SAS                                                                                         */
/*                                                        VAR1_                                                           */
/*       PK  VAR1 VAR1_MEAN   ROWNAMES    PK    VAR1      MEAN                                                            */
/*    <dbl> <dbl>     <dbl>                                                                                               */
/*  1     1    87      87         1        1      87    87.0000                                                           */
/*  2     2   104      95.5       2        2     104    95.5000                                                           */
/*  3     3    83      91.3       3        3      83    91.3333                                                           */
/*  4     4   132      91.3       4        4     132    91.3333                                                           */
/*  5     5   107      91.3       5        5     107    91.3333                                                           */
/*  6     6    84      91.3       6        6      84    91.3333                                                           */
/*  7     7   110      91.3       7        7     110    91.3333                                                           */
/*  8     8   115      91.3       8        8     115    91.3333                                                           */
/*  9     9   112      91.3       9        9     112    91.3333                                                           */
/* 10    10    94      91.3      10       10      94    91.3333                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/



/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

#!/usr/bin/env bash

source ~/.bash_profile

AWR_PATH=~/scripts/awr
#AWR_REPORT_PATH=~/awrrpt
cd $AWR_PATH

TODAY=`date -d yesterday +%Y%m%d`
BEGIN_TIME=${TODAY}$1
END_TIME=${TODAY}$2
sqlplus / as sysdba @gen_batch_quiet.sql  $BEGIN_TIME $END_TIME

sqlplus / as sysdba @batch.sql

#!/bin/bash
#
# Script for downloading GFS forecast data (GRIB files).
#

if [[ -z $USER_EMAIL ]]; then
    echo "Must provide USER_EMAIL in environment" 1>&2
    exit 1
fi

while getopts :s:e: option
do
case "${option}"
in
s) START_DATE=`date -u --date=${OPTARG} +%Y%m%d`;;
e) END_DATE=`date -u --date=${OPTARG} +%Y%m%d`;;
?) echo "No -${OPTARG} argument found.";;
esac
done

shift $((OPTIND-1))
# now do something with $@

if [ "$#" -eq  "1" ]
then
   SWIFT_GFS=$1
   echo "${SWIFT_GFS}"
else
   echo "Attempting to use existing SWIFT_GFS environment variable"
fi

#If GFS_NWP directory does not exist create it and navigate to it

if [ ! -d ${SWIFT_GFS}/GFS_NWP ];
then
   mkdir ${SWIFT_GFS}/GFS_NWP
fi

if [[ -z "${START_DATE}" ]]; then
    echo "Getting GFS data for today"
    DATE=`date -u --date='today' '+%Y%m%d %H:%M:%S'`
else
    echo "Getting GFS data for ${START_DATE}"
    DATE=`date -u --date=${START_DATE} '+%Y%m%d %H:%M:%S'`
fi

if [[ -z "${END_DATE}" ]]; then
    END_DATE=${DATE}
else
    END_DATE=`date -u --date=${END_DATE} '+%Y%m%d %H:%M:%S'`
fi

YYYY=`date -u --date="${DATE}" +%Y`
MM=`date -u --date="${DATE}" +%m`
DD=`date -u --date="${DATE}" +%d`
HH=`date -u --date="${DATE}" +%H`
YYYYMMDD=`date -u --date="${DATE}" +%Y%m%d`

if [[ -z "${START_DATE}" ]]; then
    # Depending on time find last viable GFS initialisation time (and date)
    if [ "$HH" -gt  3 ] && [ "$HH" -le  9 ]
    then
        HOURS="00"
    elif [ "$HH" -gt  9 ] && [ "$HH" -le  15 ]
    then
        HOURS="06"
    elif [ "$HH" -gt  15 ] && [ "$HH" -le  21 ]
    then
        HOURS="12"
    elif [ "$HH" -gt  21 ] && [ "$HH" -le  23 ]
    then
        HOURS="18"
    elif [ "$HH" -le  3 ]
    then
        YYYY=`date -u --date=$DATE' last day' +%Y`
        MM=`date -u --date=$DATE' last day' +%m`
        DD=`date -u --date=$DATE' last day' +%d`
        HOURS="18"
    fi
else
    # loop over all forecast times: 00, 06, 12, 18
    HOURS="00 06 12 18"
fi

# loop over dates
while : ; do

    echo ${DATE}

    for HH in ${HOURS}
    do

        HHcode="t"$HH"0"

        cd ${SWIFT_GFS}/GFS_NWP

        #create directory for latest initialisation code
        mkdir ${YYYYMMDD}${HH}
        cd ${YYYYMMDD}${HH}

        # name FTP batch file for latest date and time
        FTP_BATCH=get_GFS.batch${YYYYMMDD}${HH}

        #Forecast terms (hours) and model resolution (degrees)
        FORE_TERMS="000 "$( cat ${SWIFT_GFS_CONTROL}/controls/namelist | grep "fore:" | awk -F: '{print $2}' | tr ',' ' ')
        RESOL=0p50

        # echo commands to connect to NCEP to download latest GFS data to the FTP batch file named above make the FTP batch fiel executable and run it
        echo ftp -v -n ftp.ncep.noaa.gov \<\< \\FINFTP > $FTP_BATCH
        echo user anonymous $USER_EMAIL >> $FTP_BATCH
        echo bin >> $FTP_BATCH
        echo prompt >> $FTP_BATCH
        echo cd pub/data/nccf/com/gfs/prod >> $FTP_BATCH
        echo cd gfs.$YYYYMMDD >> $FTP_BATCH
        echo cd $HH >> $FTP_BATCH
        for f in $FORE_TERMS
        do
            echo get gfs.t${HH}z.pgrb2.${RESOL}.f${f} >> $FTP_BATCH
        done
        echo close >> $FTP_BATCH
        echo FINFTP >> $FTP_BATCH

        chmod 775 $FTP_BATCH
        ./$FTP_BATCH

        #set counter for attempts to download GFS data
        i="0"

        # Start loop to check if all requested files are present after first attempt.
        while [ ${i} -lt 24 ]
        do
            flag="0"
            echo ${flag}
            for f in $FORE_TERMS
            do
                if [ ${flag} == "0" ]
                then
                    if ! [[ -f gfs.t${HH}z.pgrb2.${RESOL}.f${f} ]]
                    then
                        flag="1"
                    fi
                fi
            done

            if [ ${flag} == "1" ]
            then
                rm -rf $FTP_BATCH
                echo ftp -v -n ftp.ncep.noaa.gov \<\< \\FINFTP > $FTP_BATCH
                echo user anonymous $USER_EMAIL >> $FTP_BATCH
                echo bin >> $FTP_BATCH
                echo prompt >> $FTP_BATCH
                echo cd pub/data/nccf/com/gfs/prod >> $FTP_BATCH
                echo cd gfs.$YYYYMMDD >> $FTP_BATCH
                echo cd $HH >> $FTP_BATCH
                for f in $FORE_TERMS
                do
                    if ! [ -f gfs.t${HH}z.pgrb2.${RESOL}.f${f} ]
                    then
                        echo get gfs.t${HH}z.pgrb2.${RESOL}.f${f} >> $FTP_BATCH
                    fi
                done
                echo close >> $FTP_BATCH
                echo FINFTP >> $FTP_BATCH
                chmod 775 $FTP_BATCH
                sleep 5m
                ./$FTP_BATCH
                i=$(($i + 1))
                echo $i
            else
                i="24"
            fi
        done

        rm $FTP_BATCH

        [[ `date -u --date=${YYYYMMDD}${HH} '+%Y%m%d %H:%M:%S'` < ${END_DATE} ]] || break
    done

    [[ ${DATE} < ${END_DATE} ]] || break

    DATE=`date -u --date="$DATE"' next day' '+%Y%m%d %H:%M:%S'`
    YYYY=`date -u --date="${DATE}" +%Y`
    MM=`date -u --date="${DATE}" +%m`
    DD=`date -u --date="${DATE}" +%d`
    YYYYMMDD=`date -u --date="${DATE}" +%Y%m%d`

done

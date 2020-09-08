#!/bin/bash

if [ "$#" -eq  "1" ]
then
   SWIFT_GFS=$1
   echo "${SWIFT_GFS}"
else
   echo "Attempting to use existing SWIFT_GFS environment variable"
fi

cd ${SWIFT_GFS}/GFS_NWP

for date in */
do

   if ! [ $( basename ${date} ) == "tape"  ]
   then  
      date=$( basename ${date} )
      YYYY=${date:0:4}
      MM=${date:4:2}
      DD=${date:6:2}
      HH=${date:8:2}

      cd ${SWIFT_GFS}/GFS_NWP/${date}

      for file in gfs*
      do
         mv ${file} ${file}.grb2
      done

      echo $NCARG_ROOT
      ncl_convert2nc gfs.t${HH}z.pgrb2.0p50.f000.grb2
      rm gfs.t${HH}z.pgrb2.0p50.f000.grb2

      # set time and rename
      cdo -settunits,hours \
          -settaxis,${YYYY}-${MM}-${DD},${HH}:00:00 \
          -setcalendar,proleptic_gregorian \
          gfs.t${HH}z.pgrb2.0p50.f000.nc analysis_gfs_4_${YYYY}${MM}${DD}_${HH}00_000.nc

      rm gfs.t${HH}z.pgrb2.0p50.f000.nc
  
      ncl_convert2nc *.grb2
      rm *.grb2
      for file in gfs*.nc
      do
         # get forecast time
         ftime=$(basename ${file} | cut -d. -f5 | sed 's/^f[0]*//g')
         echo ${ftime}
         # use chain of operations to set time and select required variables
         cdo -select,name=TMP_P0_L1_GLL0,TMP_P0_L6_GLL0,TMP_P0_L7_GLL0,TMP_P0_L100_GLL0,TMP_P0_L102_GLL0,TMP_P0_L103_GLL0,TMP_P0_L104_GLL0,TMP_P0_2L108_GLL0,TMP_P0_L109_GLL0,POT_P0_L104_GLL0,DPT_P0_L103_GLL0,APTMP_P0_L103_GLL0,SPFH_P0_L103_GLL0,SPFH_P0_2L108_GLL0,RH_P0_L4_GLL0,RH_P0_L100_GLL0,RH_P0_L103_GLL0,RH_P0_2L104_GLL0,RH_P0_L104_GLL0,RH_P0_2L108_GLL0,RH_P0_L200_GLL0,RH_P0_L204_GLL0,PWAT_P0_L200_GLL0,PRATE_P0_L1_GLL0,PRATE_P8_L1_GLL0_avg,PRATE_P8_L1_GLL0_avg3h,PRATE_P8_L1_GLL0_avg6h,SNOD_P0_L1_GLL0,WEASD_P0_L1_GLL0,CLWMR_P0_L100_GLL0,CLWMR_P0_L105_GLL0,ICMR_P0_L100_GLL0,ICMR_P0_L105_GLL0,RWMR_P0_L100_GLL0,RWMR_P0_L105_GLL0,SNMR_P0_L100_GLL0,SNMR_P0_L105_GLL0,GRLE_P0_L100_GLL0,GRLE_P0_L105_GLL0,CPRAT_P0_L1_GLL0,CPOFP_P0_L1_GLL0,CRAIN_P0_L1_GLL0,CFRZR_P0_L1_GLL0,CICEP_P0_L1_GLL0,CSNOW_P0_L1_GLL0,PEVPR_P0_L1_GLL0,UGRD_P0_L6_GLL0,UGRD_P0_L7_GLL0,UGRD_P0_L100_GLL0,UGRD_P0_L102_GLL0,UGRD_P0_L103_GLL0,UGRD_P0_L104_GLL0,UGRD_P0_2L108_GLL0,UGRD_P0_L109_GLL0,UGRD_P0_L220_GLL0,VGRD_P0_L6_GLL0,VGRD_P0_L7_GLL0,VGRD_P0_L100_GLL0,VGRD_P0_L102_GLL0,VGRD_P0_L103_GLL0,VGRD_P0_L104_GLL0,VGRD_P0_2L108_GLL0,VGRD_P0_L109_GLL0,VGRD_P0_L220_GLL0,VVEL_P0_L100_GLL0,VVEL_P0_L104_GLL0,DZDT_P0_L100_GLL0,ABSV_P0_L100_GLL0,GUST_P0_L1_GLL0,VWSH_P0_L7_GLL0,VWSH_P0_L109_GLL0,USTM_P0_2L103_GLL0,VSTM_P0_2L103_GLL0,VRATE_P0_L220_GLL0,PRES_P0_L1_GLL0,PRES_P0_L6_GLL0,PRES_P0_L7_GLL0,PRES_P0_L103_GLL0,PRES_P0_L109_GLL0,PRES_P0_L242_GLL0,PRES_P0_L243_GLL0,PRMSL_P0_L101_GLL0,ICAHT_P0_L6_GLL0,ICAHT_P0_L7_GLL0,HGT_P0_L1_GLL0,HGT_P0_L4_GLL0,HGT_P0_L6_GLL0,HGT_P0_L7_GLL0,HGT_P0_L100_GLL0,HGT_P0_L109_GLL0,HGT_P0_L204_GLL0,MSLET_P0_L101_GLL0,\5WAVH_P0_L100_GLL0,HPBL_P0_L1_GLL0,PLPL_P0_2L108_GLL0,TCDC_P0_L100_GLL0,TCDC_P0_L244_GLL0,CWAT_P0_L200_GLL0,SUNSD_P0_L1_GLL0,CAPE_P0_L1_GLL0,CAPE_P0_2L108_GLL0,CIN_P0_L1_GLL0,CIN_P0_2L108_GLL0,HLCY_P0_2L103_GLL0,LFTX_P0_L1_GLL0,\4LFTX_P0_L1_GLL0,TOZNE_P0_L200_GLL0,O3MR_P0_L100_GLL0,REFC_P0_L10_GLL0,VIS_P0_L1_GLL0,ICSEV_P0_L100_GLL0,LAND_P0_L1_GLL0,TSOIL_P0_2L106_GLL0,SOILW_P0_2L106_GLL0,WILT_P0_L1_GLL0,FLDCP_P0_L1_GLL0,HINDEX_P0_L1_GLL0 \
             -setcalendar,proleptic_gregorian \
             -shifttime,${ftime}hours \
             -settaxis,${YYYY}-${MM}-${DD},${HH}:00:00 ${file} new_${file}
         rm ${file} 
      done
   
      cdo cat new_gfs*.nc GFS_forecast_${YYYY}${MM}${DD}"_"${HH}".nc" 
      rm new_gfs.t*.nc

      ln -s ${SWIFT_GFS}/GFS_NWP/${YYYY}${MM}${DD}${HH}/GFS_forecast_${YYYY}${MM}${DD}_${HH}.nc ${SWIFT_GFS}/python/.
      ln -s ${SWIFT_GFS}/GFS_NWP/${YYYY}${MM}${DD}${HH}/analysis_gfs_4_${YYYY}${MM}${DD}_${HH}00_000.nc ${SWIFT_GFS}/python/.
   fi
done

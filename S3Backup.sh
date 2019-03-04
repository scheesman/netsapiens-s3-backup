#!/bin/bash
# Backs up NetSapiens files based on the article located at https://help.netsapiens.com/hc/en-us/articles/205235690-What-Commands-Should-I-Execute-For-Scheduled-Backups-
#
# Usage - Save file and call with the modules that needed to be backed up.
# ie: s3backup.sh core cdr conference

# Database credentials
 user="" #db username
 password="" #db password

# Other options
 backup_path="/tmp" #location to same files to during backup/upload
 date=$(date +"%Y%m%d")
 hostname=`hostname -s` #hostname vs. fqdn with just `hostname`

# S3 options
 s3cfg="" #location of .s3cfg file
 s3bucket="" #S3 Bucket Name

# Set default file permissions
 umask 177

# Loop through all command line options
while [ $# -gt 0 ]; do

  # Perform action based on command line options

  case "$1" in
    core)
      file_name="sipbxdomain_${hostname}_${date}.sql"
      echo "Backing up Core Module Config to ${file_name}.gz and moving to S3"
      mysqldump SiPbxDomain --user=${user} --password=${password} --compact --ignore-table=SiPbxDomain.cdr --ignore-table=SiPbxDomain.subscriber_cdr --ignore-table=SiPbxDomain.audit_log --ignore-table=SiPbxDomain.callqueue_stat_cdr_helper --ignore-table=SiPbxDomain.filejournal --ignore-table=SiPbxDomain.time_zone_transition --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    cdr)
      file_name="sipbxdomain-cdr_${hostname}_${date}.sql"
      echo "Backing up Core Module CDRs (25 hours) to ${file_name}.gz and moving to S3"
      mysqldump SiPbxDomain cdr --user=${user} --password=${password}  --insert-ignore --where='cdr.time_release > DATE_SUB( UTC_TIMESTAMP( ) , INTERVAL 25 HOUR )' --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    cdr2-prev)
      file_name="cdrdomain-cdr2_${hostname}_${date}.sql"
      cdr2last=`date -d "$(date +%Y-%m-1) -1 month" +%Y%m`
      echo "Backing up previous month's CDR2 to ${file_name}.gz and moving to S3"
      mysqldump CdrDomain ${cdr2last}_d ${cdr2last}_g ${cdr2last}_m ${cdr2last}_r ${cdr2last}_u --user=${user} --password=${password} --insert-ignore --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    cdr2)
      file_name="cdrdomain-cdr2_${hostname}_${date}.sql"
      cdr2current=$(date +"%Y%m")
      echo "Backing up current CDR2 to ${file_name}.gz and moving to S3"
      mysqldump CdrDomain ${cdr2current}_d ${cdr2current}_g ${cdr2current}_m ${cdr2current}_r ${cdr2current}_u --user=${user} --password=${password} --insert-ignore --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    messaging)
      file_name="messagingdomain_${hostname}_${date}.sql"
      echo "Backing up Messaging DB to ${file_name}.gz and moving to S3"
      mysqldump MessagingDomain --user=${user} --password=${password}  --insert-ignore --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    conference)
      file_name="conferencing_${hostname}_${date}.sql"
      echo "Backing up Conferencing Module to ${file_name}.gz and moving to S3"
      mysqldump NcsDomain --user=${user} --password=${password}  --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    ndp)
      file_name="ndp_${hostname}_${date}.sql"
      echo "Backing up Endpoints Module to ${file_name}.gz and moving to S3"
      mysqldump NdpDomain --user=${user} --password=${password}  --ignore-table=NdpDomain.ndp_syslog --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    ndpfiles)
      file_name="ndp-files_${hostname}_${date}.tar.gz"
      echo "Backing up Endpoints Files to ${file_name}.gz and moving to S3"
      tar -zcvf ${backup_path}/${file_name} /usr/local/NetSapiens/ndp/frm
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name} s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}
      ;;
    recording)
      file_name="recording_${hostname}_${date}.sql"
      echo "Backing up Recording Module to ${file_name}.gz and moving to S3"
      mysqldump LiCfDomain --user=${user} --password=${password}  --result-file=${backup_path}/${file_name}
      gzip -f ${backup_path}/${file_name}
      s3cmd -c ${s3cfg} put ${backup_path}/${file_name}.gz s3://${s3bucket}/${hostname}/
      rm ${backup_path}/${file_name}.gz
      ;;
    *)
    echo "Specify backup type: core,cdr,cdr2,cdr2-prev,conference,messaging,ndp,ndpfiles,recording"

  esac
  shift
done

#!/usr/bin/ksh
LOCKFILE=/tmp/nightlyone/mainscript.lock
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "Script Mainscript.ksh already running"
    exit
fi
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

if [[ "( $(date +%s) )" < $(date +%s -d"$(date +'%b %d, %Y 20:00:00')" ) ]] || [[ "( $(date +%s) )" > $(date +%s -d"$(date +'%b %d, %Y 20:02:00')") ]];then
echo "I am over 21. No New Domain Can be added now." >> /tmp/nightlyone/nightlog.log
else
LOGDATE=$(date +'%b-%d-%Y_%H')
mv /tmp/nightlyone/NightlyRefreshTable.sql /tmp/nightlyone/Backup/NightlyRefreshTable_${LOGDATE}.sql
mv /tmp/nightlyone/nightlog.log /tmp/nightlyone/Backup/nightlog_${LOGDATE}.log
mv /tmp/nightlyone/gethosts.log /tmp/nightlyone/Backup/gethosts_${LOGDATE}.log
mv /tmp/nightlyone/main.log /tmp/nightlyone/Backup/main_${LOGDATE}.log
echo "Cycling for new hosts." >> /tmp/nightlyone/nightlog.log

  for getdomain in `cat /tmp/nightlyone/nighthosts`;
  do
  ssh ${getdomain} "/bin/bash -s" < /tmp/nightlyone/gethosts.ksh >> /tmp/nightlyone/gethosts.log
  done
fi
echo "Getting the Hosts." >> /tmp/nightlyone/nightlog.log
k=$(cat /tmp/nightlyone/gethosts.log|sed '/^\s*$/d'|wc -l)
  for ((l=1;l<=$k;l++))
  do
  HOSTNAME=$(sed "${l}q;d" /tmp/nightlyone/gethosts.log|awk '{print $1}')
  DOMAIN=$(sed "${l}q;d" /tmp/nightlyone/gethosts.log|awk '{print $2}')
  VALUE=$(sed "${l}q;d" /tmp/nightlyone/gethosts.log|awk '{print $3}')
  if [[ "${VALUE}" = 0 ]];then
     for j in $l ;
     do
     ssh ${HOSTNAME} "env domain=$DOMAIN /bin/bash -s \$domain" < /tmp/nightlyone/nightanalyze.ksh >> /tmp/nightlyone/nightlog.log
     clientmnemonic=$(cat /tmp/nightlyone/nightlog.log|tail -4|head -1)
     completiontime=$(cat /tmp/nightlyone/nightlog.log|tail -3|head -1|awk '{print $1" "$2" "$3" "$4" "$5}')
     status=$(cat /tmp/nightlyone/nightlog.log|tail -2|head -1)
     sam=$(cat /tmp/nightlyone/nightlog.log|tail -1)
echo ${HOSTNAME} ${DOMAIN} ${status}
 echo "INSERT INTO NightlyRefreshTable (ClientMnemonic, Hostname, Domain, Time, Status) VALUES ('${clientmnemonic}', '${HOSTNAME}', '${DOMAIN}', '${completiontime}', '${status}');" >> /tmp/nightlyone/NightlyRefreshTable.sql
      sed -i "s/$HOSTNAME $DOMAIN $VALUE*$/$HOSTNAME $DOMAIN $sam/g" /tmp/nightlyone/gethosts.log
      done
    else
    echo "$HOSTNAME $DOMAIN already Checked for Today ." >> /tmp/nightlyone/nightlog.log
    fi
    done

echo "Please find the Nightly logs"|mailx -s "L2 NIGHTLY REFRESH" -r "L2validate" -a /tmp/nightlyone/nightlog.log -a /tmp/nightlyone/gethosts.log -a /tmp/nightlyone/main.log akash.shinde@cerner.com
rm -f ${LOCKFILE}

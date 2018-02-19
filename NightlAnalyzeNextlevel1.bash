#!/usr/bin/ksh
HOSTNAME=$(hostname)
#####
getcrontime=$(crontab -l|grep trnrfsh|grep -w ${domain}|awk '{print $2}')
getcronmin=$(crontab -l|grep trnrfsh|grep -w ${domain}|awk '{print $1}')
getcrondate=$(echo "$(date +'%b %d, %Y') $(crontab -l|grep trnrfsh|grep -w ${domain}|awk '{print $2}'):$(crontab -l|grep trnrfsh|grep -w ${domain}|awk '{print $1}'):00")
getcronstamp=$(date +%s -d"$getcrondate")
currentdate=$(date +'%b %d, %Y %H:%M:%S')
currenttime=$(date|awk '{print $4}'|awk -F: '{print $1}')
currenttimemin=$(date|awk '{print $4}'|awk -F: '{print $2}')
CLIENTMNEMONIC=$(grep search '/etc/resolv.conf'|awk '{print $3}'|head -1|awk -F. '{print $1}'|tr '[:lower:]' '[:upper:]')
echo "CLIENT - ${CLIENTMNEMONIC}"
echo "Current Date - ${currentdate}"
#echo "Currenttime - ${currenttime}"
#echo "Crontime - ${getcrontime}"
#echo "CurrentTimewithMin - ${currenttimemin}"
echo "CronTimewithMin - ${getcrondate}"
#echo "crontime - ${getcrontime}"
#echo "datestamp - $(date +%s)"
#echo "crontime - ${getcrontime}"
#echo "crontimestamp - ${getcronstamp}"


ChecksuccesOrFailed()
{
     Success=$(grep -w -A2 "/trnrfsh/do_not_delete/scripts/${domain}/crontab_master.ksh -f /trnrfsh/do_not_delete/scripts/${domain}/cwx_${domain}_auto_refresh.conf" /trnrfsh/do_not_delete/scripts/${domain}/log/master.log|grep SUCCESS|wc -l)
     Failed=$(grep -w -A2 "/trnrfsh/do_not_delete/scripts/${domain}/crontab_master.ksh -f /trnrfsh/do_not_delete/scripts/${domain}/cwx_${domain}_auto_refresh.conf" /trnrfsh/do_not_delete/scripts/${domain}/log/master.log|grep FAILURE|wc -l)
     Time=$(grep -w -A6 "/trnrfsh/do_not_delete/scripts/${domain}/crontab_master.ksh -f /trnrfsh/do_not_delete/scripts/${domain}/cwx_${domain}_auto_refresh.conf"  /trnrfsh/do_not_delete/scripts/${domain}/log/master.log|grep Completed|awk '{print $10" "$9" "$11" "$12" "$13}')
     TimeFail=$(grep -w -B2 "/trnrfsh/do_not_delete/scripts/${domain}/crontab_master.ksh -f /trnrfsh/do_not_delete/scripts/${domain}/cwx_${domain}_auto_refresh.conf"  /trnrfsh/do_not_delete/scripts/${domain}/log/master.log|head -1|awk '{print $3" "$2" "$4" "$5" "$6}')
###
				if [[ ${Success} != 0  ]];then
			sam=1
			echo "L2 Nightly Refresh at $HOSTNAME $domain has been success. Today is done in CronJobStamp ${getcrontime} & ${currenttime}."
			echo "${CLIENTMNEMONIC}"
			echo "${Time} its Completed"
			echo "Success"
			echo $sam
###
				elif [[ ${Failed} != 0 ]];then
            sam=2
            echo "L2 Nightly Refresh at $HOSTNAME $domain has been failed waiting for again to be run in CronJobStamp ${getcrontime} & ${currenttime}."
            echo "${CLIENTMNEMONIC}"
            echo "${TimeFail} its Failed"
            echo "Failed"
            echo $sam
###
				else
            sam=0
            echo "L2 Nightly  Refresh at $HOSTNAME $domain has Not Completed in CronJobStamp ${getcrontime} & ${currenttime}."
            echo "${CLIENTMNEMONIC}"
            echo "0"
            echo "NotCompleted"
            echo $sam
###
				fi
}

if [[ "${getcrontime#0}" -ge 18 ]] && [[ "${getcrontime#0}" -le 23 ]] ;then
        echo "Domain ${domain} Nightly Refresh CronJob timing is between 18 & 24."
        if [[ "${currenttime#0}" -ge "${getcrontime#0}" && "${currenttimemin#0}" -gt "${getcronmin#0}" ]] || [[ "${currenttime#0}" -gt "${getcrontime#0}" ]];then
			echo "Starting the Check as current time between 18'o clock & 23'o Clock."
			if [[ "( $(date +%s) )" > "$getcronstamp" ]];then
     
			ChecksuccesOrFailed		
			else
			sam=0
			echo "L2 Nightly Refresh at $HOSTNAME $domain has Not Started in CronJobstamp 18-24."
			echo "${CLIENTMNEMONIC}"
			echo "0"
			echo "NotStarted"
			echo $sam
			fi
		
		elif [[ "${currenttime#0}" -ge 00 ]] && [[ "${currenttime#0}" -le 07 ]];then
				echo "Starting the Check as current time between O'o clock & 18'o Clock in Special Case."
				if [[ "( $(date +%s) )" < "$getcronstamp" ]];then
					ChecksuccesOrFailed
				else
					sam=0
					echo "L2 Nightly Refresh at $HOSTNAME $domain has Not Started in CronJobstamp 18-24 In Special Case."
					echo "${CLIENTMNEMONIC}"
					echo "0"
					echo "NotStarted"
					echo $sam
				fi
		
		else
			sam=0
			echo "L2 Nightly Refresh at $HOSTNAME $domain has Not Started in CronJobstamp 18-24 after Special Case."
			echo "${CLIENTMNEMONIC}"
			echo "0"
			echo "NotStarted"
			echo $sam
		fi
		
		

elif [[ "${getcrontime#0}" -ge 00 ]] && [[ "${getcrontime#0}" -le 05 ]] ;then
	echo "Domain ${domain} Nightly Refresh timing is between 00 & 05."

		if [[ "${currenttime#0}" -ge "${getcrontime#0}" ]] && [[ "${currenttimemin#0}" -gt "${getcronmin#0}" ]];then
            if [[ "( $(date +%s) )" > "$getcronstamp" ]];then
				echo "Starting the Check as current time between 12'o clock & 5'o Clock."
				ChecksuccesOrFailed
			else
				sam=0
				echo "L2 Nightly Refresh at $HOSTNAME $domain has Not Started in CronJobstamp 00-05."
				echo "${CLIENTMNEMONIC}"
				echo "0"
				echo "NotStarted"
				echo $sam
			fi
        elif [[ "${currenttime#0}" -gt "${getcrontime#0}" ]];then
			if [[ "( $(date +%s) )" > "$getcronstamp" ]];then
            echo "Starting the Check as current time between 12'o clock & 5'o Clock."
			ChecksuccesOrFailed
		else
			sam=0
			echo "L2 Nightly Refresh at $HOSTNAME $domain has Not Started in CronJobstamp 00-05."
			echo "${CLIENTMNEMONIC}"
			echo "0"
			echo "NotStarted"
			echo $sam
			fi
			  
        fi

else 
	sam=0
	echo "L2 Nightly Refresh at $HOSTNAME $domain is out of scope between 6'o Clock pm & 5'o Clock am."
	echo "${CLIENTMNEMONIC}"
	echo "0"
	echo "Not In Scope"
	echo $sam
fi

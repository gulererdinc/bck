#!/bin/bash
#-------------------------------------------------------------------------------
#  SCRIPT DESCRIPTION
#-------------------------------------------------------------------------------
#
#  Synopsis    :  Simple script to forward data from Tpwer DB to CDI external
#                 servers as a CSV
#
#  Requirements: - postgres_client, sftp, lsftp
#                - environment variables containing credentials are expected
#                  to be read from existing secrets.
#                - SSH private key should be stored as a secret and public SSH
#                  key should be added to authorized_keys on target hosts.
#
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

REQUIREMENTS="psql sftp lftp"
SQL_RESULTS_DIR="/app/postgres-files"

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

main() {
	check_debug_mode
	set_arbitrary_id
	log_info ">>> Starting Tower-CDI sync job <<<"
	check_requirements
	generate_csv_files
	transfer_csv_files
	log_info ">>> Tower-CDI sync job successfully completed <<<"
}

check_debug_mode() {
	if [[ "$DEBUG_MODE" == "true" ]] ; then
		echo ">>> Starting Tower-Backup job in DEBUG MODE <<<"
		sleep 99999
	fi
}

set_arbitrary_id(){
	# Adds an arbitrary user to /etc/passwd as default user
	if ! whoami &> /dev/null; then
		if [ -w /etc/passwd ]; then
			echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/app:/sbin/nologin" >> /etc/passwd
		fi
	fi
}

check_requirements() {
	# Check if Postgresql required environment variables are set
    for VALUE in "${PGHOST}" \
				 "${PGPORT}" \
				 "${PGDATABASE}" \
				 "${PGUSER}" \
				 "${PGPASSWORD}"
	do
		if [ -z "$VALUE" ] || [[ "$VALUE" == "" ]] ; then
			log_fatal "Required Postgresql environment variables not set! Exiting!"
		fi
	done

 # Check if required utils are found
	for UTIL in ${REQUIREMENTS}
	do
		command -v "$UTIL" &> /dev/null \
		|| log_fatal "Required util '$UTIL' not found. Exiting!"
	done
	log_info "All requirements were met. Proceeding..."
}

pull_backup_scripts() {

# Log a fatal error and abort execution
log_fatal() {
    printf "[$(date +%Y-%m-%d\ %H:%M:%S)] [%s] ${*}\n" "FATAL"
	exit 1
}

# Log an informative message and keep going
log_info() {
    printf "[$(date +%Y-%m-%d\ %H:%M:%S)] [%s] ${*}\n" "INFO "
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main "$@"

#-------------------------------------------------------------------------------
# EOF
#-------------------------------------------------------------------------------

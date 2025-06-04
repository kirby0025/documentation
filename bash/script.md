## Useful functions

### Bash trap

- https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
```bash
# Define function called before exiting script after an error is caught.
function set_error_status() {
    echo "[$(date '+%Y%m%d %H%M%S')] : Something went wrong in the script, exiting." | tee -a "${LOGFILE}"
    echo "2 vault-snapshot-restore - KO" > ${STATUSFILE}
}
# Set the function called when the ERR signal is caught.
trap set_error_status ERR
```

### Exit immediatly on error and when variables are empty

- https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
```bash
set -eu
```

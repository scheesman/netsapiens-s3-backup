# netsapiens-s3-backup
Backup script to back up from NetSapiens to S3.  Script is based on recommendations found [here](https://help.netsapiens.com/hc/en-us/articles/205235690-What-Commands-Should-I-Execute-For-Scheduled-Backups-).  I created this script so I could have a single script on all servers that had the flexibility to back up just the modules installed on that server.  Also, by leveraging S3 buckets, you can utilize Amazon's built in expiration policy and expire files as appropriate for your organization.

File structure in the S3 bucket will be organized by hostname and service type: `bucketname->hostname->Service_date.gz`

## Instructions
Copy the script to the location of your choice.  Change relevant options in the script, such as user, password, .s3cfg location, etc.  Run script manually or via crontab.

## Requirements
* s3cmd - install via `sudo install s3cmd`
* Amazon S3 bucket with appropriate permissions
* Properly configured .s3cfg file.  Should just require setting the access_key and secret_key.

## Usage
The script takes up to 6 parameters.  You can specify anywhere from 1 to 6, depending on your needs.

Options: `core`, `cdr`, `conference`, `ndp`, `ndpfiles`, `recording`

### core
`core` backs up the Core module configuration without CDRs.

### cdr
`cdr` backs up the Core module CDRs.  This option only backs up the last 25 hours, so you will want to run this option once per day.

### conference
`conference` backs up the Conferencing module.

### ndp
`ndp` backs up the Endpoints module.

### ndpfiles
`ndpfiles` backs up the /frm folder and all of its contents.  This option was added separate from the `ndp` option as you probably don't want to back this up every night.

### recording
`recording` backs up the Recording module.

## Examples

Back up all services on a single box:

`S3Backup.sh core cdr conference ndp ndpfiles recording`

Back up just Core (NDP) files:

`S3Backup.sh core cdr conference`

## crontab
You will probably want to run these via crontab.  Below are the crontab entries I use, depending on the roles installed.  Just `sudo crontab -e` and insert what's relevant for you.  If you need help with crontab schedules, I highly recommend https://crontab-generator.org/.

`0 3 * * * /usr/local/scripts/S3backup.sh core cdr conference ndp recording > /var/log/backups.log`

`30 0 * * 0 /usr/local/scripts/S3backup.sh ndpfiles > /var/log/backups.log`

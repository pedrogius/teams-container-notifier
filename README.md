# Teams container notifier

Notify a Teams channel when docker containers are down. Keeps track of containers that are down and notifies only once, and again when they are back up.

## How to use

### Create your `config.sh` file.

```sh
cp config.sh.example config.sh
```

### Edit the `config.sh`

```sh
teamsWebhookUrl='https://teams.microsoft.com/webhook'
listOfContainers="mycontainer1 mycontainer2"
```

### Start the script

```sh
./start.sh
```

### Work with task scheduling

To work with a schedule to execute this script you can set following below.

- Set the env `TEAMS_CONTAINER_NOTIFIER_DIR` globally to current dir

```sh
sudo sh -c "echo \"TEAMS_CONTAINER_NOTIFIER_DIR=$(pwd)\" >> /etc/environment"
```

- Add scheduled job

```sh
crontab -e

  */5 * * * * sh -c "$TEAMS_CONTAINER_NOTIFIER_DIR/start.sh"
```

### Monitor job schedule logs

```sh
grep CRON /var/log/syslog

# or

tail -f /var/log/syslog | grep CRON
```

## References

- [Crontab Guru](https://crontab.guru)

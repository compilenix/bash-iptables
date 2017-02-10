## Installation

```bash
mkdir -pv /usr/sh/
git clone https://git.compilenix.org/Compilenix/bash-iptables.git /usr/sh/iptables
cd /usr/sh/iptables
git submodule init
git submodule update
cp iptables.sh.service /etc/systemd/system/
cp iptables-hostname.example.sh iptables-$(hostname).sh
ln -s /usr/sh/iptables/iptables-$(hostname).sh /usr/sbin/iptables.sh
vim iptables-$(hostname).sh
```

Change the template according to your needs.

```bash
vim /etc/rsyslog.d/iptables.conf
```

> :msg,contains,"iptables" /var/log/iptables.log

```bash
systemctl restart rsyslog.service
```

> IMPORTANT: Keep a remote shell open to the host at ANY TIME, to prevent you from an `oops` situation!!!

Now test you script and make sure everthing still works as you expect it should.

```bash
iptables.sh restart
```

And finally enable the system service to apply the script at systemstart (systemd).

```bash
systemctl enable iptables.sh.service
```

# Help?

To get a help text -> `./iptables.sh -help`.

# Troubleshooting
See log file: `/var/log/iptables.log`

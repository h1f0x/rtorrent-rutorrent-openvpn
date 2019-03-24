FROM amd64/centos:latest

# Enabled systemd
ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#VOLUME [ "/sys/fs/cgroup" ]

VOLUME [ "/config" ]
VOLUME [ "/output" ]

# copy root
COPY rootfs/ /

# OpenVPN
RUN yum install -y epel-release
RUN yum update -y
RUN yum install -y openvpn

# rtorrent + ruTorrent
RUN yum install -y net-tools initscripts
RUN chmod 755 /opt/rutorrent-installer.sh
RUN useradd rtorrent -d /home/rtorrent -G wheel
RUN sh /opt/rutorrent-installer.sh -p -a -u rtorrent::rtorrent:rtorrent -w -s --nginx --rtorrent --rutorrent
RUN cp -r /home/rtorrent/.irssi/scripts/autodl-irssi-master/* /home/rtorrent/

## Themes
WORKDIR /var/rutorrent/rutorrent/plugins/theme/themes
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/FlatUI_Dark
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/FlatUI_Light
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/FlatUI_Material
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/club-QuickBox
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/MaterialDesign
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/OblivionBlue
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/Agent46
RUN svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/Agent34

# Update autodl config
WORKDIR /home/rtorrent/.autodl
RUN cat autodl2.cfg | grep -v options >> autodl.cfg
RUN rm -rf autodl2.cfg

# Patch startup
RUN cp -r /defaults/config/startup/autodl_rtorrent /etc/init.d/autodl_rtorrent

# Patch rutorrent
RUN cp -r /defaults/config/rutorrent/config-main.php /var/rutorrent/rutorrent/conf/config.php
RUN cp -r /defaults/config/rutorrent/config-socket.php /var/rutorrent/rutorrent/conf/users/rtorrent/config.php
RUN cp -r /defaults/config/rutorrent/theme.dat /var/rutorrent/rutorrent/share/users/rtorrent/settings/theme.dat
RUN cp -r /defaults/config/rutorrent/uisettings.json /var/rutorrent/rutorrent/share/users/rtorrent/settings/uisettings.json
RUN chown nginx:nginx /var/rutorrent/rutorrent/conf/config.php
RUN chown nginx:nginx /var/rutorrent/rutorrent/conf/users/rtorrent/config.php
RUN chown nginx:nginx /var/rutorrent/rutorrent/share/users/rtorrent/settings/uisettings.json
RUN chown nginx:nginx /var/rutorrent/rutorrent/share/users/rtorrent/settings/theme.dat

# Patch nginx
RUN cp -r /defaults/config/nginx/index.html /var/rutorrent/index.html
RUN cp -r /defaults/config/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
RUN chown nginx:nginx /var/rutorrent/index.html

# crontab
RUN yum install -y cronie
RUN (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/verify-external-ip.sh") | crontab -
RUN (crontab -l 2>/dev/null; echo "@reboot /usr/bin/verify-external-ip.sh") | crontab -
RUN (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/verify-services.sh") | crontab -

#configure services (systemd)
RUN systemctl enable openvpn-own-client.service
RUN systemctl enable prepare-config.service

WORKDIR /root/

# End
CMD ["/usr/sbin/init"]
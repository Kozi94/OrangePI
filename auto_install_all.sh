sudo su
apt update
apt upgrade -y

cat > /home/orangepi/rockchip-uart4.dts << EOF
/dts-v1/;
/plugin/;
/ {
    compatible = "rockchip,rk3399";
    fragment@0 {
        target = <&spi1>;
        __overlay__ {
            status = "disabled";
        };
    };
    fragment@1 {
        target = <&uart4>;
        __overlay__ {
            status = "okay";
        };
    };
};
EOF

orangepi-add-overlay rockchip-uart4.dts

dmesg | grep Async

apt-get install x11vnc -y
x11vnc -storepasswd /home/orangepi/.vnc/passwd
cat > /lib/systemd/system/x11vnc.service << EOF
[Unit]
Description=Start x11vnc.
After=prefdm.service

[Service]
User=root
Restart=on-failure
ExecStart=/usr/bin/x11vnc -auth guess -noxfixes -forever -rfbport 5900 -shared $

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable x11vnc.service

cd /home/orangepi/
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64

# sudo su
sudo apt update
sudo apt upgrade -y

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

sudo orangepi-add-overlay /home/orangepi/rockchip-uart4.dts
rm /home/orangepi/rockchip-uart4.dts

sudo dmesg | grep Async

sudo apt-get install x11vnc -y
cd ~
mkdir .vnc
x11vnc -storepasswd
sudo cat > /lib/systemd/system/x11vnc.service << EOF
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

sudo systemctl daemon-reload
sleep  5s
sudo systemctl enable x11vnc.service
sleep  5s

cd /home/orangepi/
wget https://github.com/Kozi94/OrangePI/raw/main/code.deb
sudo apt install ./code.deb -y
rm code.deb

git clone https://github.com/orangepi-xunlong/wiringOP.git
cd wiringOP
sudo ./build clean
sudo ./build

echo "Installing OpenCV 4.8.0 on your Raspberry Pi 64-bit OS"
echo "It will take minimal 2 hour !"
cd ~
sudo apt-get install -y build-essential cmake unzip pkg-config
sudo apt-get install -y libjpeg-dev libtiff-dev libpng-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libgtk2.0-dev libcanberra-gtk* libgtk-3-dev
sudo apt-get install -y libgstreamer1.0-dev gstreamer1.0-gtk3
sudo apt-get install -y libgstreamer-plugins-base1.0-dev gstreamer1.0-gl
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y python3-dev python3-numpy python3-pip
sudo apt-get install -y libtbb2 libtbb-dev libdc1394-22-dev
# sudo apt-get install -y libv4l-dev v4l-utils
sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
sudo apt-get install -y liblapack-dev gfortran libhdf5-dev
sudo apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev
sudo apt-get install -y protobuf-compiler

cd ~ 
sudo rm -rf opencv*
git clone --depth=1 https://github.com/opencv/opencv.git
git clone --depth=1 https://github.com/opencv/opencv_contrib.git

cd ~/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D ENABLE_NEON=ON \
-D WITH_OPENMP=ON \
-D WITH_OPENCL=OFF \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D WITH_GSTREAMER=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=OFF \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D WITH_VTK=OFF \
-D WITH_QT=OFF \
-D WITH_PROTOBUF=ON \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF ..

make -j5
sudo make install
sudo ldconfig

# make clean
sudo apt-get update

echo "Congratulations!"
echo "You've successfully installed OpenCV 4.8.0 on your Raspberry Pi 64-bit OS"

# sudo shutdown -r now
#!/usr/bin/env bash
set -e

install_libjpeg_turbo() {
    local libjpeg_deb=libjpeg-turbo.deb

    wget "https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/output/${UBUNTU_CODENAME}/libjpeg-turbo_2.1.3_amd64.deb" -O "$libjpeg_deb"
    apt-get install -y "./$libjpeg_deb"
    rm "$libjpeg_deb"
}

echo "Install KasmVNC server"
cd /tmp

BUILD_ARCH=$(uname -p)
UBUNTU_CODENAME=""
COMMIT_ID="fa22ed925fadaee5cad7e9dc570096e96000cfe8"
BRANCH="master"
COMMIT_ID_SHORT=$(echo "${COMMIT_ID}" | cut -c1-6)

if [ "${DISTRO}" == "kali" ]  ;
then
    if [[ "$(arch)" =~ ^x86_64$ ]] ; then
      BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_kali-rolling_0.9.3_${BRANCH}_${COMMIT_ID_SHORT}_amd64.deb"
    else
      BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_kali-rolling_0.9.3_${BRANCH}_${COMMIT_ID_SHORT}_arm64.deb"
    fi
elif [ "${DISTRO}" == "centos" ] ; then
    BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/output/centos_core/kasmvncserver-0.9.1~beta-1.el7.x86_64.rpm"
else
    UBUNTU_CODENAME=$(grep -Po -m 1 "(?<=_CODENAME=)\w+" /etc/os-release)
    if [[ "${BUILD_ARCH}" =~ ^aarch64$ ]] ; then
        BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_${UBUNTU_CODENAME}_0.9.3_${BRANCH}_${COMMIT_ID_SHORT}_arm64.deb"
    elif [ "${UBUNTU_CODENAME}" == "bionic" ] ; then
        BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_${UBUNTU_CODENAME}_0.9.3_${BRANCH}_${COMMIT_ID_SHORT}_libjpeg-turbo-latest_amd64.deb"
    else
	BUILD_URL="https://kasmweb-build-artifacts.s3.amazonaws.com/kasmvnc/${COMMIT_ID}/kasmvncserver_${UBUNTU_CODENAME}_0.9.3_${BRANCH}_${COMMIT_ID_SHORT}_amd64.deb"
    fi
fi


if [ "${DISTRO}" == "centos" ] ; then
    wget "${BUILD_URL}" -O kasmvncserver.rpm

    yum localinstall -y kasmvncserver.rpm
    rm kasmvncserver.rpm
else
    if [[ "${UBUNTU_CODENAME}" = "bionic" ]] && [[ ! "$BUILD_ARCH" =~ ^aarch64$ ]] ; then
        install_libjpeg_turbo
    fi

    wget "${BUILD_URL}" -O kasmvncserver.deb

    apt-get update
    apt-get install -y gettext ssl-cert
    dpkg -i /tmp/kasmvncserver.deb
    apt-get -yf install
    rm -f /tmp/kasmvncserver.deb
fi
#mkdir $KASM_VNC_PATH/certs
mkdir -p $KASM_VNC_PATH/www/Downloads
chown -R 0:0 $KASM_VNC_PATH
chmod -R og-w $KASM_VNC_PATH
#chown -R 1000:0 $KASM_VNC_PATH/certs
chown -R 1000:0 $KASM_VNC_PATH/www/Downloads
ln -s $KASM_VNC_PATH/www/index.html $KASM_VNC_PATH/www/vnc.html

echo "Making ARM Trusted Firmaware: bl31.bin file "
ATF_DIR=atf_and_trusty/atf/arm-trusted-firmware
Trusty_DIR=../../trusty/trusty
NV_TEGRA_DIR=/home/vdesai6/Documents/jetson_tee/jetson_img_test/Jetson_Linux_R32.7.2_aarch64/Linux_for_Tegra/nv_tegra/tos-scripts
Test=/home/vdesai6/Documents/jetson_tee/jetson_img_test/Jetson_Linux_R32.7.2_aarch64
BL31_DIR="t186ref/tegra/t186/release"
LKBIN_DIR="t186ref/build-t186/lk.bin"
cd $ATF_DIR
TEMP_DIR=$(pwd)
echo $CROSS_COMPILE
echo $CROSS_COMPILE_AARCH64
echo $CROSS_COMPILE_ARM	
make BUILD_BASE=./t186ref \
         CROSS_COMPILE="${CROSS_COMPILE_AARCH64}" \
         DEBUG=0 LOG_LEVEL=20 PLAT=tegra SPD=trusty TARGET_SOC=t186 V=0
echo "ATF build done"
AS='/home/vdesai6/Documents/secure_serial_main/secure_serial-main'
cp $AS/$ATF_DIR/$BL31_DIR/bl31.bin $NV_TEGRA_DIR 




#echo "In TEST dir"
#cd $Test
#ls
#echo "--------------------------------"
echo " Making Trusty source: lk.bin file"
cd $Trusty_DIR
echo $CROSS_COMPILE
echo $CROSS_COMPILE_AARCH64
echo $CROSS_COMPILE_ARM

make t186 PROJECT=t186 TARGET=t186 BUILDROOT=./t186ref \
         TOOLCHAIN_PREFIX="${CROSS_COMPILE_AARCH64}" \
         ARCH_arm_TOOLCHAIN_PREFIX="${CROSS_COMPILE_ARM}" \
         ARCH_arm64_TOOLCHAIN_PREFIX="${CROSS_COMPILE_AARCH64}" \
         DEBUG=0 DEBUG_LVL=0 DEFAULT_OTE_APP_DEBUGLEVEL=1 NOECHO=@ \
         TRUSTY_VARIANT=l4t-public TRUSTY_MULTI_GUEST_CONFIGURATION= \
         TARGET_SOC=t186
cp $AS/$ATF_DIR/$BL31_DIR/bl31.bin $NV_TEGRA_DIR
.$NV_TRGRA_DIR/gen_tos_part_img.py --monitor bl31.bin --os lk.bin tos.img

#./gen_tos_part_img.py --monitor bl31.bin --os lk.bin tos.img

echo "---------------------------My sh file:Trusty build done-------------------------------"


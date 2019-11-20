#! /bin/bash

#Fix UID/GID
/startup $(id -u) $(id -g)

#Activation
export HOME=/home/${MATLAB_USER}
export MATLAB_INSTALLED_ROOT=$(echo $MATLAB_INSTALLED_ROOT | sed -e "s|muser|${MATLAB_USER}|g")
echo $MATLAB_LICENSE > ~/license_${MATLAB_VERSION}.lic 2>&1
sed -i 's|\\n|\n|g' ~/license_${MATLAB_VERSION}.lic
sed -i 's|\\"|"|g' ~/license_${MATLAB_VERSION}.lic
sed -i 's|\\ | |g' ~/license_${MATLAB_VERSION}.lic
sed -i 's|\\t|\t|g' ~/license_${MATLAB_VERSION}.lic
echo "licenseFile=${HOME}/license_${MATLAB_VERSION}.lic" >> ~/.activate.ini
${MATLAB_INSTALLED_ROOT}/bin/activate_matlab.sh -propertiesFile ~/.activate.ini
sed -i '$ d' ~/.activate.ini
rm ~/license_$MATLAB_VERSION.lic

#Command
"$@"

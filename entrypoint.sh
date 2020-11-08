#! /bin/bash

#Fix UID/GID
/startup $(id -u) $(id -g)

#Activation
if [ ! -z "$MATLAB_LICENSE" ]; then
    echo "License identified via env variable."
    echo "$MATLAB_LICENSE" | base64 -d > ~/license_${MATLAB_VERSION}.lic 2>&1
else
    echo "No license env variable. Expecting license in '~/license_${MATLAB_VERSION}.lic'."
fi
echo "licenseFile=${HOME}/license_${MATLAB_VERSION}.lic" >> ~/.activate.ini
${MATLAB_INSTALLED_ROOT}/bin/activate_matlab.sh -propertiesFile ~/.activate.ini
sed -i '$ d' ~/.activate.ini
if [ ! -z "$MATLAB_LICENSE" ]; then
    echo "Removing temporary license file."
    rm ~/license_$MATLAB_VERSION.lic
fi


#Command
"$@"

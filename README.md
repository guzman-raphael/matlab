# Matlab Docker


Full Matlab with GUI (`raphaelguzman/matlab:RXXXXx-GUI`) and a minimal Matlab (`raphaelguzman/matlab:RXXXXx-MIN`). 

Adheres to Mathworks' licensing model. 

Must supply valid Mathworks License to start containers.

Prebuilt containers are available [here](https://hub.docker.com/r/raphaelguzman/matlab).

See [docker-compose.yml](./docker-compose.yml) for instructions on how to properly start it with `docker-compose up --build`.


# Use Image

## Env Vars

```bash
MATLAB_HOSTID=xx:xx:xx:xx:xx:xx # MAC Address supplied to Mathworks as HostID associated with license.
MATLAB_USER=muser # System/ComputerLogin user associated with license. Default is muser.
MATLAB_UID=1000 # UID of your docker host. This is utilized to resolve permissions on volume data.
MATLAB_GID=1000 # GID of your docker host. This is utilized to resolve permissions on volume data.
MATLAB_IMAGE_TYPE=GUI # Available MATLAB Image types are: GUI, MIN
```

## Licensing

There are now two options to supply a valid Mathworks license to properly activate:

1. Specify it as an environment variable. See OS-specific instructions below.

   **Note: There has now been a change to utilize base64 encoding to simplify the generation and prevent parsing issues.**

   ```bash
   MATLAB_LICENSE=IyBCRUd... # Base64 encoded Mathworks license.
   ```

   ### For Linux
   
   ```bash
   MATLAB_LICENSE=$(base64 ./licenses/license_R2018b.lic -w 0) # base64 encode
   echo "$MATLAB_LICENSE" | base64 -d # base64 decode
   ```
   
   ### For MacOS
   
   ```bash
   MATLAB_LICENSE=$(base64 -i ./licenses/license_R2018b.lic) # base64 encode
   echo "$MATLAB_LICENSE" | base64 -D # base64 decode
   ```
   
   ### For WIN (Powershell)
   
   ```powershell
   $MATLAB_LICENSE=[Convert]::ToBase64String([IO.File]::ReadAllBytes(".\licenses\license_R2018b.lic")) # base64 encode
   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$MATLAB_LICENSE")) # base64 decode
   ```

2. Mount the license file in as a single file volume.

   For example, specify it as follows in `docker-compose`:
   
   ```yaml
   volumes:
     - ./licenses/license_R2018b.lic:/home/muser/license_R2018b.lic:ro
   ```

# Building Image

## Env Vars

```bash
MATLAB_VERSION=R2018b # Matlab version to be built. Must supply COMPLETE matlab_RXXXXX_glnxa64.zip for install in an installers dir.
MATLAB_FILE_KEY=xxxxx-xxxxx-xxxxx-xxxxx # Mathworks provided file key associated with installation.
PY_VERSION=3.6 # >= 3.0. Necessary to complete install of Jupyter Notebook with MATLAB kernel (GUI).
MATLAB_INSTALLED_ROOT=/home/muser/.MATLAB # Directory where MATLAB root path is located.
```

## Directory structure

```
matlab/ --------------------------- Root directory
┣ installers/ --------------------- MATLAB installation files archive
┃ ┣ matlab_R2016b_glnxa64_ALL.zip - Example complete zipped MATLAB installation files for a specific release
┃ ┣ matlab_R2018b_glnxa64_ALL.zip - Example complete zipped MATLAB installation files for a specific release
┃ ┗ matlab_R2019a_glnxa64_ALL.zip - Example complete zipped MATLAB installation files for a specific release
┣ licenses/ ----------------------- MATLAB licenses archive
┃ ┣ license_R2016b.lic ------------ Example MathWorks license file for a specific release
┃ ┣ license_R2018b.lic ------------ Example MathWorks license file for a specific release
┃ ┗ license_R2019a.lic ------------ Example MathWorks license file for a specific release
┣ .env ---------------------------- Uncommited file to define necessary environment variables for docker-compose use
┣ .gitignore ---------------------- Git ignore rules
┣ GUI.dockerfile ------------------ Image spec for GUI images
┣ MIN.dockerfile ------------------ Image spec for MIN images
┣ README.md ----------------------- Documentation
┣ activate.ini -------------------- Activation file template
┣ docker-compose.yml -------------- Image build and container launch reference
┣ entrypoint.sh ------------------- Container entrypoint; activates and resolves permissions
┣ installer_input.txt ------------- Installation file template
┣ jupyter_notebook_config.py ------ Configuration for Jupyter Notebook server on GUI images
┣ rootcerts.pem ------------------- Updated root certs; extracted from newer installations
┗ startup.go ---------------------- Utility to resolve permissions and update container user
```

## GitHub Actions CI Integration

For a reference of how this container may be used in Continuous Integration with GitHub Actions, see my repo for [compareVersions.m](https://github.com/guzman-raphael/compareVersions).
# SWIFT GFS python plotting code.

This document gives an overview of the setup required to run the SWIFT GFS python plotting code originally written by Alexander Roberts (NCAS and University of Leeds). This document will: (1) introduce the general structure of the code, (2) explain the supporting scripts including system requirements, (3) explain individual python plotting scripts and (4) describe the operation of the scripts together. This should give all the details needed to understand this repository and allow you to download and use the code for yourself.

## GitHub Repository

To begin with you should first clone the GitHub repository to do this navigate to your home directory (or where ever you wish to put the cloned repository) and run the following command.


`git clone git@github.com:earajr/GFS_plotting.git`


This should create a new directory named `GFS_plotting`. If for any reason this does not work then you click the "clone or download" button above and select to download a zipped version. Once downloaded you can unzip the repository and rename the directory from `GFS_plotting-master` to `GFS_plotting`. This is the exact same repository that you get by using the command above.


Once you have created this directory you should set an environment variable in your .bashrc file that describes the location of this directory. This will be important when running scripts later on.


`export SWIFT_GFS=full/path/to/GFS_plotting`

## Dependencies

There are a number of dependencies that you will need to make sure are installed properly on your system. Within the repository (in the scripts directory) there is a `SWIFT_plotting_dependencies.sh` script which will install all the software that is required. This has been tested on a clean CentOS 7 install and works. If you are using a different Linux OS then you will have to modify the script accordingly. Despite the install procedure being different, the dependencies will be the same. The software that is installed is detailed below.

### epel repository (CentOS, Red Hat Enterprise Linux (RHEL), Scientific Linux, Oracle Linux)

This is the Extra Packages for Enterprise Linux (EPEL) repository of packages you will have to activate before you can install certain pieces of software using yum in CentOS, (this is not available in other Linux OSs, if any of the software installed using yum is not available for your OS e.g. using apt get in Ubuntu then you will have to find another method of installation such as building the code from source).

### "Development tools"

This group install will install a number of useful (and required) packages and make sure you have the compilers you will need to build the rest of the required software. The equivalent package in Ubuntu is “build-essentials”.

**ftp**  
**wget**  
**unzip**  
**m4**  
**curl**  
**libcurl-devel**  
**cmake3**  
**python-devel**  
**python3-devel**  
**openjpeg2-tools**  
**zlib**  
**zlib-devel**  
**hdf5** (with threadsafe and unsupported enabled to allow for using POSIX thread, also built with zlib)  
**netCDF** (with netCDF 4 enabled)  
**ncl**  
**eccodes-devel**  
**jasper**  
**cdo**  

### Running the script

When running the `SWIFT_plotting_dependencies.sh` script first make sure that you have internet access and that the script is executable.

`chmod +x SWIFT_plotting_dependencies.sh`

The script will require you to have sudo access, however **do not run the script using sudo**. This affects the make commands and can cause the install of several packages to fail. The script will create an `install` directory in the `GFS_plotting` directory you created earlier (**you must have set the location of this directory as an environment variable**).

`./SWIFT_plotting_dependencies.sh`

While running there will be several prompts, some of these will ask for your sudo password while others will merely ask you to agree to the installations being made. As the script can take quite a while to install everything you might be asked for your sudo password more than once. The installation of hdf5 in particular takes a while, try to remember to keep an eye out for the sudo password prompt, if you leave it too long the script times out and quits without completing.

##Python
To run the python code there are a number of python library dependencies. To make sure that we have everything that we need it makes sense to set up a virtual environment in which to run the plotting code. Here I will describe how to do this using anaconda. However, if you are familiar and confident with another method of setting up a virtual environment feel free to do that.

###anaconda
To download the anaconda installer script visit the anaconda website (https://www.anaconda.com/). In the top right corner you should see a link labelled “downloads”. Click on this link and scroll down. You should see two options to download the python 3 and python 2 versions of anaconda. Select the python three version and download the installer.


Navigate the location of the installer script. Before being able to install anaconda you need to make sure that the script is executable.

`chmod +x Anaconda3-2019.10-Linux-x86_64.sh`

Now run the install script.

`./Anaconda3-2019.10-Linux-x86_64.sh`

```
Welcome to Anaconda3 2019.10


In order to continue the installation process, please review the license

agreement.

Please, press ENTER to continue

>>>

===================================

Anaconda End User License Agreement

===================================

…

…

…

…

Do you accept the license terms? [yes|no]
```

Accept the license terms and select a location to install anaconda. If you are happy for anaconda to be installed in your home directory just press ENTER to confirm the location.


Anaconda will now begin to unpack into your chosen directory. Once complete you will be asked whether you wish to initialize anaconda. Enter yes and your .bashrc file will be updated to include the conda initialisation. For this to take effect you will have to open a new console window or source your .bashrc from your current window.

`source ~/.bashrc`

### pyn_env environment

We could go through the process of setting up a conda environment from scratch. However, instead of doing this I have created a .yml environment file that will replicate the conda environment that I use to run the GFS plotting routines. This is a simple way of replicating a conda environment so that it should work in exactly the same way as the operational plotting for SWIFT. The yaml file (`pyn_env.yml`) can be used to create a conda environment called pyn_env (pyngl environment). This will provide all the python packages required to create the GFS images.

`conda create -f pyn_env.yml`

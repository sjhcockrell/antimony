#!/bin/bash
#
#   install
#   Basic installation script for Mac OSX. Depends on `brew` existing.


# REQUIREMENTS
R_tputcolors="https://github.com/sjhcockrell/tputcolors/archive/1.0.tar.gz"        # bash coloring
R_apacheBatik="https://github.com/sjhcockrell/Apache-Batik-1.7/archive/1.7.tar.gz" # .ttf => .svg
R_ttf2eot="http://ttf2eot.googlecode.com/files/ttf2eot-0.0.2-2.tar.gz"             # .ttf => .eot
R_sfnt2woff="http://people.mozilla.org/~jkew/woff/woff-code-latest.zip"            # .ttf => .woff

DIR_TTF="ttf2eot"
DIR_SFNT="woff"
DIR_SVG="batik-uber-1.7"

INSTALL_DIR="/usr/local/bin"
PROJECT_URL="https://github.com/sjhcockrell/antimony"


# getPackage
#   Uses `wget` to fetch a file, then extracts it using gzip or tar.
#   Will throw an error and exit if curl or the unzipping fails.
# @param $1 : url endpoint for resource
# @param $2 : variable to populate the file name
# @return   : dirname of extracted resource
#
function getPackage {

    if [[ $# -ne 2 ]]; then
        echo "$(tput setaf 1)ERROR: getPackage() requires a URL as an argument and a variable name.$(tput sgr0)"
        exit 1
    fi

    local url=$1
    local __result=$2
    local filename=$(basename $url)

    # Downloading
    echo "Downloading $filename..."
    wget $1 > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "$(tput setaf 1)ERROR: Resource download failed for $1.$(tput sgr0)"
        echo "       $(tput setaf 1)File an issue at https://github.com/sjhcockrell/antimony$(tput sgr0)"
        exit 1
    fi

    # Unpacking
    echo "Unpacking..."

    if [[ $filename =~ \.tar\.gz ]]; then
        local dirname=$(tar zft $filename | head -n1)
        tar -xzf $filename

    elif [[ $filename =~ \.zip ]]; then
        local dirname=${filename%.*}
        unzip $filename -d $dirname
    fi

    # Make, if needs making
    find $dirname/Makefile
    if [[ $? == 0 ]]; then
        cd $dirname
        make
        cd ../
    fi

    # Clean up compressed origin file
    rm $filename

    # Return variable populated with dirname
    eval $__result="'$dirname'"
}

# installScriptRequirement
#   Accepts a dependency script name, and a resource URL, then installs the
#   appropriate script in usr/local/bin.
# @param $1 : script name.
# @param $2 : Resource Url.
#
function installScriptRequirement {

    if [[ $# -ne 2 ]]; then
        echo "$(tput setaf 1)ERROR: installScriptRequirement() requires a script name and URL.$(tput sgr0)"
        exit 1
    fi

    local script=$1
    local url=$2

    echo "Checking for dependency $script..."
    find /usr/local/bin/$script > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Installing dependency $script..."
        getPackage $url dir
        cp $dir/$script /usr/local/bin/
        rm -rf $dir
    else
        echo "Already installed."
    fi

}

# =============================================================================
# {

# install homebrew
# This is in case you don't have wget, and we need to use brew
# to install.
which brew 2>&1
if [[ $? -ne 0 ]]; then
    echo "Homebrew is required for installing a few components."
    echo "Installing brew..."
    echo "(This may take a minute.)"
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
fi

# Make sure we have wget
which wget 2>&1
if [[ $? -ne 0 ]]; then
    echo "wget is required."
    echo "Installing wget..."
    echo "(This may take a minute.)"
    brew install wget
fi

# tputcolors
installScriptRequirement "tputcolors" $R_tputcolors
source tputcolors
success
echo

# batik
installScriptRequirement "batik.jar" $R_apacheBatik
success
echo

# ttf2eot
installScriptRequirement "ttf2eot" $R_ttf2eot
success
echo

# snft2woff
installScriptRequirement "sfnt2woff" $R_sfnt2woff
success
echo

# fontforge
echo "Checking for dependency fontforge..."
which fontforge > /dev/null 2>&1
if [[ $? -ne 0 ]]; then

    echo "Installing dependency fontforge..."
    brew install fontforge 2>&1
    chmod 777 /usr/local/share 2>&1
    brew link fontforge 2>&1

    if [[ $? -ne 0 ]]; then
        error "'brew link fontforge' failed." "This probably means that something in /usr/local/ doesn't have the correct permissions"
        exit
    fi

else
    echo "Already installed."
fi
success
echo

# antimony
echo "Installing antimony..."
which antimony > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Installing antimony..."
    cp antimony /usr/local/bin/
else
    echo "Already installed."

    # Prompt for what to do
    printf "${t_yellow}Options: [u]pdate or [s]kip? ${t_reset}"
    read -n 1 action
    case $action in
            u )
                printf "\nReplacing existing copy of antimony with this one...\n"
                rm /usr/local/bin/antimony
                cp antimony /usr/local/bin/
                ;;
            s )
                printf "\nSkipping.\n"
                ;;
    esac

fi
success "Install finished."
echo

exit 0

# }
# =============================================================================

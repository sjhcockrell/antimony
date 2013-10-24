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

# }
# =============================================================================













##########################
#   Checking for Homebrew.
which brew 2>&1
if [ "$?" -ne "0" ]; then
    echo "Looks like you don't have brew installed. Run to install homebrew:\n       \`ruby -e \"\$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)\"\`\n"
    exit 1
fi


#####################################################
#   Install fontforge, if it's not installed already.
echo "Installing fontforge, via HomeBrew"
which fontforge 2>&1
if [ "$?" -ne "0" ]; then
    echo "Downloading FontForge"
    brew install fontforge 2>&1

    echo "Installing"
    brew link fontforge

    # Error with Homebrew; it needs certain files to be chowned 
    # in order to work.
    if [ "$?" -ne "0" ]; then 
        echo "Seems like you don't have the correct permissions.\nTry running:\n\`sudo chown -R \$USER:admin /usr/local\`"
        exit 1
    fi

else
    echo "Already installed"
fi
echo "Success"


#################
# Install ttf2eot
echo "Installing ttf2eot"
which ttf2eot > /dev/null 2>&1
if [ "$?" -ne "0" ]; then

    echo "Downloading from http://ttf2eot.googlecode.com/"
    curl $R_ttf2eot > $DIR_TTF.tar.gz 

    if [ "$?" -ne "0" ]; then
        echo "Problem downloading ttf2eot from Google Code (http://code.google.com/p/ttf2eot/)."
        exit 1
    fi

    echo "Unpacking"
    tar -xzf $DIR_TTF.tar.gz 2>&1

    echo "Compiling"
    cd $DIR_TTF 2>&1
    make

    echo "Installing in $INSTALL_DIR"
    cp ttf2eot $INSTALL_DIR 2>&1

    echo "Cleaning up"
    cd .. 2>&1
    rm -rf $DIR_TTF 2>&1
    rm $DIR_TTF.tar.gz 2>&1


else 
    echo "Already installed"
fi
echo "Success"


####################
# Install sfnt2woff
echo "Installing sfnt2woff"
which sfnt2woff > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
    echo "Downloading from http://people.mozilla.com/~jkew/woff/"
    curl $R_sfnt2woff > $DIR_SFNT.zip
    
    echo "Unpacking"
    unzip $DIR_SFNT.zip -d $DIR_SFNT 2>&1

    echo "Compiling"
    cd $DIR_SFNT 2>&1
    make 2>&1

    echo "Installing in $INSTALL_DIR"
    cp sfnt2woff $INSTALL_DIR
    cp woff2sfnt $INSTALL_DIR

    echo "Cleaning up"
    cd .. 2>&1
    rm -rf $DIR_SFNT 2>&1
    rm $DIR_SFNT.zip 2>&1
    
else
    echo "Already installed"
fi
echo "Success"


################################
# Install apache batik (ttf2svg)
echo "Installing Apache Batik 1.7 jar"
if [ ! -f $INSTALL_DIR/$DIR_SVG.jar ]; then
    echo "Downloading from https://github.com/sjhcockrell/batik-uber-1.7.jar"
    echo "(Sorry, this jarfile is pretty big)"
    curl -L $R_apacheBatik > $DIR_SVG.jar

    if [ "$?" -ne 0 ]; then
        echo "Problem downloading batik-uber-1.7.jar from Github" 
        exit
    fi

    echo "Installing in $INSTALL_DIR"
    cp $DIR_SVG.jar $INSTALL_DIR 2>&1

    echo "Cleaning up"
    rm -rf $DIR_SVG.jar 2>&1

else
    echo "Already installed"
fi



##################
# Install antimony
echo "Installing antimony"
which antimony > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
    echo "Copying antimony to $INSTALL_DIR"
    cp antimony $INSTALL_DIR

else
    echo "Already installed"
    printf "Options: [u]pdate or [s]kip?"
    read -n 1 action 
    printf '\n'
    case $action in 
        u )
            echo "Replacing existing copy of antimony with this one"
            rm $INSTALL_DIR/antimony
            cp antimony $INSTALL_DIR
            ;;
        s )
            echo "Skipping"
            ;;
    esac
fi 
echo "Success"


#####
# END
exit 0;

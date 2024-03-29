#!/bin/bash


cat << EOF
################################################################################
################################################################################
##############################################     #############################
#####################/     ########((.######     *   ###########################
###################       *   (                  #/    #########################
#################          /                    # ##*  .########################
################/          (                      ##############################
##################         ,#                   ### ############################
####################      /##      #####         ## ############################
######################*####        ####,             ###########################
######################                                 #########################
#######################                        ######.  ########################
#######################                          ###    ########################
##########################         #              (    #########################
############################          ##*      *#####,           ,##############
############################       /##(  ,#####                #  ##############
############################        #                         ##  ##############
##########################          #/                ###    ###, ##############
#######################             /#              ############# ##############
####################(          #     #      .##.   ############## ,#############
###################             *#   #.    ######################  #############
###################              .# ,##  #################(        #############
#####################             #####  ####*         #########################
#######################           #####  (######################################
#########################        ###############################################
################################################################################
#####       #######  (###        ###  *#####       #######     #######     /####
#####  #####  (###  / *#####  #####  ( .####  #####  /#.  #####  ##   ##########
#####  ######  ##  ##( .####  ####  ###  ###  ######  #  ######(  #  ###    ####
#####  #####  ##  ####*  ###  ###  ####/  ##  #####  ##(  #####  ##.  ####  ####
#####      (###  ######(  ##  ##  #######  #      /#######*   (#######,   .#####
################################################################################
EOF

########################################################
# install Java
########################################################
echo -n "Install dependencies ... "
sudo apt-get update >/dev/null 2>&1
sudo apt-get install --yes openjdk-17-jdk >/dev/null 2>&1
sudo apt-get install --yes unzip >/dev/null 2>&1
sudo apt-get install --yes git >/dev/null 2>&1
echo "done"

########################################################
# check variables
########################################################
if [ -z "$DD_API_KEY" ]; then
    echo "DD_API_KEY not set. Please set one and try again."
    exit 1
fi

if [ -z "$DD_APP_KEY" ]; then
    echo "DD_APP_KEY not set. Please set one and try again."
    exit 1
fi

if [ -z "$DD_ENV" ]; then
    echo "DD_ENV not set. Please set this variable and try again."
    exit 1
fi

if [ -z "$DD_SERVICE" ]; then
    echo "DD_SERVICE not set. Please set this variable and try again."
    exit 1
fi

if [ -z "$CPU_COUNT" ]; then
    # the default CPU count is 2
    CPU_COUNT=2
fi

if [ "$ENABLE_PERFORMANCE_STATISTICS" = "true" ] || [ "$ENABLE_PERFORMANCE_STATISTICS" = "1"  ]; then
    ENABLE_PERFORMANCE_STATISTICS="--performance-statistics"
else 
    ENABLE_PERFORMANCE_STATISTICS=""
fi

PROJECT_ROOT=$(pwd)

########################################################
# static analyzer tool stuff
########################################################
echo -n "Install datadog static analyzer ... "
TOOL_DIRECTORY=$(mktemp -d)

if [ ! -d "$TOOL_DIRECTORY" ]; then
    echo "Tool directory $TOOL_DIRECTORY does not exist"
    exit 1
fi

cd "$TOOL_DIRECTORY" || exit 1
curl -L -o datadog-static-analyzer.zip https://github.com/DataDog/datadog-static-analyzer/releases/latest/download/datadog-static-analyzer-x86_64-unknown-linux-gnu.zip >/dev/null 2>&1 || exit 1
unzip datadog-static-analyzer >/dev/null 2>&1 || exit 1
CLI_LOCATION=$TOOL_DIRECTORY/datadog-static-analyzer

########################################################
# datadog-ci stuff
########################################################
echo -n "Install datadog-ci ..."
sudo /usr/local/bin/npm install -g @datadog/datadog-ci@2.16.1 || exit 1

DATADOG_CLI_PATH=/usr/local/bin/datadog-ci

# Check that datadog-ci was installed
if [ ! -x $DATADOG_CLI_PATH ]; then
    echo "The datadog-ci was not installed correctly, not found in $DATADOG_CLI_PATH."
    exit 1
fi
echo "done: datadog-ci available $DATADOG_CLI_PATH"
echo "Version: $($DATADOG_CLI_PATH version)"

########################################################
# output directory
########################################################
echo -n "Getting output directory ... "
OUTPUT_DIRECTORY=$(mktemp -d)

# Check that datadog-ci was installed
if [ ! -d "$OUTPUT_DIRECTORY" ]; then
    echo "Output directory ${OUTPUT_DIRECTORY} does not exist"
    exit 1
fi

OUTPUT_FILE="$OUTPUT_DIRECTORY/output.sarif"

echo "done: will output results at ${OUTPUT_FILE}"

########################################################
# execute the tool and upload results
########################################################

echo -n "Starting a static analysis ..."
$CLI_LOCATION -i "${PROJECT_ROOT}" -o "$OUTPUT_FILE" -f sarif --cpus "$CPU_COUNT" "$ENABLE_PERFORMANCE_STATISTICS" || exit 1
echo "done"

# navigate to project root, so the datadog-ci command can access the git info
cd "$PROJECT_ROOT" || exit 1
git config --global --add safe.directory "${PROJECT_ROOT}" || exit 1

echo -n "Uploading results to Datadog ..."
${DATADOG_CLI_PATH} sarif upload "${OUTPUT_FILE}" --service "${DD_SERVICE}" --env "$DD_ENV" || exit 1
echo "Done"

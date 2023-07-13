#!/bin/sh -l

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

########################################################
# static analyzer tool stuff
########################################################
TOOL_DIRECTORY=$(mktemp -d)

if [ ! -d "$TOOL_DIRECTORY" ]; then
    echo "Tool directory $TOOL_DIRECTORY does not exist"
    exit 1
fi

cd "$TOOL_DIRECTORY" || exit 1
curl -L -O http://dtdg.co/latest-static-analyzer >/dev/null 2>&1 || exit 1
unzip latest-static-analyzer > /dev/null 2>&1 || exit 1
CLI_LOCATION=$TOOL_DIRECTORY/cli-1.0-SNAPSHOT/bin/cli


########################################################
# datadog-ci stuff
########################################################
echo "Installing 'datadog-ci'"
npm install -g @datadog/datadog-ci || exit 1

DATADOG_CLI_PATH=/usr/bin/datadog-ci

# Check that datadog-ci was installed
if [ ! -x $DATADOG_CLI_PATH ]; then
    echo "The datadog-ci was not installed correctly, not found in $DATADOG_CLI_PATH."
    exit 1
fi

echo "Done: datadog-ci available $DATADOG_CLI_PATH"

########################################################
# output directory
########################################################
echo "Getting output directory"
OUTPUT_DIRECTORY=$(mktemp -d)

# Check that datadog-ci was installed
if [ ! -d "$OUTPUT_DIRECTORY" ]; then
    echo "Output directory ${OUTPUT_DIRECTORY} does not exist"
    exit 1
fi

OUTPUT_FILE="$OUTPUT_DIRECTORY/output.sarif"

echo "Done: will output results at $OUTPUT_FILE"

########################################################
# execute the tool and upload results
########################################################

echo "Starting a static analysis"
$CLI_LOCATION --directory "${GITHUB_WORKSPACE}" -t true -o "$OUTPUT_FILE" -f sarif || exit 1
echo "Done"

# navigate to workspace root, so the datadog-ci command can access the git info
cd ${GITHUB_WORKSPACE} || exit 1
git config --global --add safe.directory ${GITHUB_WORKSPACE} || exit 1

echo "Uploading results to Datadog"
${DATADOG_CLI_PATH} sarif upload "$OUTPUT_FILE" --service "$DD_SERVICE" --env "$DD_ENV" || exit 1
echo "Done"

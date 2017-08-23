# The Ant target or operation to execute
TARGET=$1

# The target org or Salesforce environment.
# This is used to dynamically construct the path to the .properties file
# containing authentication secrets.
ENVIRONMENT=$2

if [ -z $ENVIRONMENT ]; then
    ENVIRONMENT=default
fi

# This is an untracked directory in which sensitive configuration
# data may be placed, such as usernames and passwords for authentication.
ANT_CONFIG_DIR=ant

ant $TARGET -propertyfile $ANT_CONFIG_DIR/$ENVIRONMENT.properties
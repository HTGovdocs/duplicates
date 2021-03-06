pushd `dirname $0` > /dev/null;
SCRIPTPATH=`pwd`;
popd > /dev/null;

mkdir -p $SCRIPTPATH/data;
mkdir -p $SCRIPTPATH/log;

if [ -f $SCRIPTPATH/.env ]; then
    echo "there is already an .env file";
else
    echo "Writing dummy .env file to $SCRIPTPATH/.env";
    echo "data_dir_path  = $SCRIPTPATH/data" >> $SCRIPTPATH/.env;
    echo "log_dir_path   = $SCRIPTPATH/log"  >> $SCRIPTPATH/.env;

    cat << EOF >> $SCRIPTPATH/.env
## Fill in these variables.
db_driver = xx
db_url    = xx
db_user   = xx
db_pw     = xx
db_host   = xx
db_name   = xx
db_port   = xx
EOF

fi
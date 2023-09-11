#Run Monitoring Server On MySQL5
# This is NOT a OS shell script, but a Karaf script
# To execute it, open a Karaf shell for your container and type: source scripts/<This script's name>
#
#
#source scripts/runServiceActivityMonitoringOnMySql5.sh <db_url> <db_username> <db_password>
#
#Exemple : source scripts/runServiceActivityMonitoringOnMySql5.sh jdbc:mysql://localhost:3306/sam_db?serverTimezone=UTC root root 
#
db_url = $1
db_username = $2
db_password = $3
db_maxActive = 8
db_maxIdle = 30
db_maxWait = 10000

echo "Initialize Parameter ....."
	echo "DB username : $db_username"
	echo "DB password : $db_password"
	echo "DB driverClassName : com.mysql.jdbc.Driver"
	echo "DB url : $db_url"
	echo "DB maxActive :(default value 8) "
	echo "DB maxIdle :(default value 30) "
	echo "DB maxWait :(default value 10000) "
echo

echo "Start configuring ......"

echo
echo "Install MySQL driver ......"
	install mvn:mysql/mysql-connector-java/5.1.18
echo "Done"

echo
echo "Install the provided MySQL datasource feature ......."
	feature:install tesb-datasource-mysql
echo "Done"

echo
echo "Edit properties in the Container/etc/org.talend.esb.datasource.mysql.cfg according to your MySQL env ......"
	config:edit --force org.talend.esb.datasource.mysql
	echo "datasource.url=$db_url"
	config:property-set datasource.url $db_url
	echo "datasource.username=$db_username"
	config:property-set datasource.username $db_username
	echo "datasource.password=$db_password"
	config:property-set datasource.password $db_password
	echo "datasource.pool.maxActive=$db_maxActive"
	config:property-set datasource.pool.maxActive $db_maxActive
	echo "datasource.pool.maxIdle=$db_maxIdle"
	config:property-set datasource.pool.maxIdle $db_maxIdle
	echo "datasource.pool.maxWait=$db_maxWait"
	config:property-set datasource.pool.maxWait $db_maxWait
	config:update
echo "Done"

echo
echo "Install tesb:start-sam ......"
	tesb:start-sam
echo "Install tesb:stop-sam ......"
	tesb:stop-sam
echo "Done"

echo
echo "Edit etc/org.talend.esb.sam.server.cfg ......"
	config:edit --force org.talend.esb.sam.server
	echo "db.datasource = ds-mysql"
	config:property-set db.datasource ds-mysql
	echo "db.dialect = mysqlDialect"
	config:property-set db.dialect mysqlDialect
	config:update
echo "Done"

echo
echo "install SAM server by features ......"
    feature:install tesb-sam-service-soap tesb-sam-service-rest
echo "Done"

echo
echo "Initalize finished successfully."

# Talend ESB Studio needs to read the ending tag on initializing, please do not remove it.
echo "EOF"
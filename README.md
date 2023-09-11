# _service-monitoring-TalendESB_
## Objectifs
Configurer le Service Activity Monitoring sur le runtime Talend ESB.

## Outils et Versions
- Talend Open Studio for ESB Version 8.0.1
- Java Version 11
- Dbeaver Version 23.1.0
- MySQL Version 5.1.30

## Service Activity Monitoring (SAM)
Le composant SAM permet le logging et la surveillance des appels de service, réalisés avec le framework Apache CXF. Il peut être utilisé pour collecter, par exemple, les statistiques d’usage et le monitoring des fautes.

- Lancer l’ESB : 
dans le répertoire que vous venez d'extracter le Talend Open Studio, aller vers _<Runtime_ESBSE>/container/bin_ et exécuter **trun.bash** (sur windows) et **./trun** si vous êtes sur Linux ou mac. La fenêtre suivante devrait s’afficher:
![Lancer l’ESB.](/image/runtime-ESBSE.PNG "Lancer l’ESB")

### Configurer le Service Activity Monitoring:
Il y'a 2 methodes pour configurer le SAM sur le runtime Talend ESB

#### Configurer le Service Activity Monitoring CMD 
1. Lancer la commande d'installation MySQL driver dans l’invite de commande
```
install mvn:mysql/mysql-connector-java/5.1.18
```
2. Installer la fonction de source de données MySQL fournie:
```
feature:install tesb-datasource-mysql
```
![Configurer le Service Activity Monitoring CMD.](/image/conf-sam-cmd-1.PNG "Configurer le Service Activity Monitoring CMD")

3. Modifier les propriétés dans le conteneur _<Runtime_ESBSE>/container/etc/org.talend.esb.datasource.mysql.cfg_ en fonction de votre env MySQL.
```
datasource.url=jdbc:mysql://localhost:3306/sam_db?serverTimezone=UTC
datasource.username=root
datasource.password=root
datasource.pool.maxActive=20
datasource.pool.maxIdle=5
datasource.pool.maxWait=30000
```
![Configurer le Service Activity Monitoring CMD.](/image/conf-sam-cmd-2.PNG "Configurer le Service Activity Monitoring CMD")

4. Editer _<Runtime_ESBSE>/container/etc/org.talend.esb.sam.server.cfg_
```
db.datasource=ds-mysql
db.dialect=mysqlDialect
```
5. Installer le serveur SAM par fonctionnalités
```    
feature:install tesb-sam-service-soap tesb-sam-service-rest
```
![Configurer le Service Activity Monitoring CMD.](/image/conf-sam-cmd-3.PNG "Configurer le Service Activity Monitoring CMD")


> Dans le repositorie, tu peux trouver un scripte **service-activity-monitoring-mysql5.sh** qui réalise tous ces configurations.
Mettre le fichier **service-activity-monitoring-mysql5.sh** dans le repertoire _<Runtime_ESBSE>/container/scripts_, execute la commande suivante:
```
source scripts/service-activity-monitoring-mysql5.sh <db_url> <db_username> <db_password>
``` 
![Configurer le Service Activity Monitoring Script.](/image/conf-sam-script.PNG "Configurer le Service Activity Monitoring Script")


#### Configurer le Service Activity Monitoring XML
1. Créer un fichier xml **datasource-mysql.xml**
2. Remplir le fichier avec code suivant:
```
<?xml version="1.0" encoding="UTF-8"?>
<blueprint xmlns="http://www.osgi.org/xmlns/blueprint/v1.0.0"   default-activation="lazy">
   <bean id="mysqlDataSource" class="com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource">
		<property name="url" value="jdbc:mysql://localhost:3306/trace_talend?serverTimezone=Europe/Paris"/>
		<property name="user" value="root"/>
		<property name="password" value="root"/>
	</bean>
	<bean id="dataSource" class="org.apache.commons.dbcp.datasources.SharedPoolDataSource" destroy-method="close">
		<property name="connectionPoolDataSource" ref="mysqlDataSource"/>
		<property name="maxActive" value="100"/>
		<property name="maxIdle" value="10"/>
		<property name="maxWait" value="5000"/>
		<property name="validationQuery" value="select 1"/>
		<property name="testWhileIdle" value="true"/>
		<property name="testOnBorrow" value="true"/>
		<property name="testOnReturn" value="true"/>
	</bean>
	<service ref="dataSource" interface="javax.sql.DataSource">
		<service-properties>
			<entry key="osgi.jndi.service.name" value="jdbc/hatem"/>
		</service-properties>
	</service>
</blueprint>
```
3.	Mettre le fichier **datasource-mysql.xml** dans le repertoire _<Runtime_ESBSE>/container/deploy_
![Configurer le Service Activity Monitoring xml.](/image/conf-sam-xml.PNG "Configurer le Service Activity Monitoring xml")
4.  Demarrer le runtime et execute les commandes suivantes
```
install mvn:commons-dbcp/commons-dbcp/1.4/jar
install mvn:mysql/mysql-connector-java/8.0.18
feature:install jdbc
```
![Configurer le Service Activity Monitoring xml.](/image/conf-sam-xml-1.PNG "Configurer le Service Activity Monitoring xml")

5. Pour tester la connexion de la datasource, execute cette commande
```
jdbc:query "<nom datasource>" "<requete sql>"
```
exemple : jdbc:query "jdbc/hatem" "select * from trace_logs"

![Configurer le Service Activity Monitoring xml.](/image/conf-sam-xml-2.PNG "Configurer le Service Activity Monitoring xml")

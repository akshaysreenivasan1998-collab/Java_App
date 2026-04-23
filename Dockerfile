# Select the official Tomcat base image
FROM tomcat:9.0-jdk11-openjdk

# Copy your WAR file into the Tomcat webapps directory
# If you rename it to ROOT.war, it will be the default application at http://localhost:8080/
COPY target/*.war /usr/local/tomcat/webapps/

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat (CMD is inherited from the base image, but can be explicitly stated)
CMD ["catalina.sh", "run"]

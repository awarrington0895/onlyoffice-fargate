FROM onlyoffice/documentserver-de:7.0.1

# Allow OnlyOffice sample app to start automatically for testing
RUN sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf

# Set log level to DEBUG for easier examination during testing
RUN sed 's,"level": "WARN","level": "DEBUG",' -i /etc/onlyoffice/documentserver/log4js/production.json
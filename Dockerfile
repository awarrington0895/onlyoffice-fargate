FROM onlyoffice/documentserver-de:7.0.1

RUN sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf

RUN sed 's,"level": "WARN","level": "DEBUG",' -i /etc/onlyoffice/documentserver/log4js/production.json
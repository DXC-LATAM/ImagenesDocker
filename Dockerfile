FROM registry.access.redhat.com/rhel7/rhel-minimal

MAINTAINER cesar.avila@dxc.com
LABEL "Image"="MQHA DXC_LATAM" \
      "Version"="1.0.1"
LABEL "ProductName"="IBM MQ Advanced" \
      "ProductVersion"="9.0.5"

# URL Para descargar el Producto
ARG MQ_URL=https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev905_linux_x86-64.tar.gz

# Paquetes de MQ para descargar
ARG MQ_PACKAGES="ibmmq-server ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-web ibmmq-msg-.*"

# ----- VALIDAR QUE PAQUETES DE SO SE NECESITA INSTALAR
RUN microdnf update; && \
    # Descargar e instalar MQ
    export DIR_EXTRACT=/tmp/mq && \
    mkdir -p ${DIR_EXTRACT} && \
    cd ${DIR_EXTRACT} && \
    curl -LO $MQ_URL && \
    tar -zvxf ./*.tar.gz && \
    # Remover escombros de la descarga
    microdnf clean all && \
    #Buscar comandos similares para redHat apt-get purge -y \
    #           ca-certificates \
    #           curl \
    #&& apt-get autoremove -y --purge \
    # Se crea el usuario de servicio y se le asignan privilegios
    && groupadd --system --gid 999 mqm \
    && useradd --system --uid 999 --gid mqm mqm \
    && usermod -G mqm root \

#### ------ Por validar las lineas siguientes ------------- ######
# Find directory containing .deb files
&& export DIR_DEB=$(find ${DIR_EXTRACT} -name "*.deb" -printf "%h\n" | sort -u | head -1) \
# Find location of mqlicense.sh
&& export MQLICENSE=$(find ${DIR_EXTRACT} -name "mqlicense.sh") \
# Accept the MQ license
&& ${MQLICENSE} -text_only -accept \
&& echo "deb [trusted=yes] file:${DIR_DEB} ./" > /etc/apt/sources.list.d/IBM_MQ.list \
# Install MQ using the DEB packages
&& microdnf update \
&& microdnf install -y $MQ_PACKAGES \
# Remove 32-bit libraries from 64-bit container
&& find /opt/mqm /var/mqm -type f -exec file {} \; \
  | awk -F: '/ELF 32-bit/{print $1}' | xargs --no-run-if-empty rm -f \
# Remove tar.gz files unpacked by RPM postinst scripts
&& find /opt/mqm -name '*.tar.gz' -delete \
# Recommended: Set the default MQ installation (makes the MQ commands available on the PATH)
&& /opt/mqm/bin/setmqinst -p /opt/mqm -i \
# Clean up all the downloaded files
&& rm -f /etc/apt/sources.list.d/IBM_MQ.list \
&& rm -rf ${DIR_EXTRACT} \
# Apply any bug fixes not included in base Ubuntu or MQ image.
# Don't upgrade everything based on Docker best practices https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run
&& microdnf upgrade -y sensible-utils \
# End of bug fixes
&& rm -rf /var/lib/apt/lists/* \
# Optional: Update the command prompt with the MQ version
&& echo "mq:$(dspmqver -b -f 2)" > /etc/debian_chroot \
&& rm -rf /var/mqm \
# Optional: Set these values for the Bluemix Vulnerability Report
&& sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs \
&& sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t1/' /etc/login.defs \
&& sed -i 's/password\t\[success=1 default=ignore\]\tpam_unix\.so obscure sha512/password\t[success=1 default=ignore]\tpam_unix.so obscure sha512 minlen=8/' /etc/pam.d/common-password

COPY *.sh /usr/local/bin/
COPY *.mqsc /etc/mqm/
COPY admin.json /etc/mqm/

COPY mq-dev-config /etc/mqm/mq-dev-config

RUN chmod +x /usr/local/bin/*.sh

# Expose port 9443 for the web console
EXPOSE 1414 9443

ENV LANG=en_US.UTF-8;es_CL.UTF-8

ENTRYPOINT ["mq.sh"]

FROM ubuntu:18.04
LABEL maintainer="ambimanus"
LABEL creator="Tyler McPhee"
LABEL contributor="DEEZ"

# Default flags for the Cyberghost CLI
ENV CG_FLAGS='--country-code US --torrent'

RUN apt-get update -y && \
    apt-get install -y tzdata && \
    apt-get install -y lsb-core \
	sudo \
	wget \
	unzip \
	openresolv \
	iptables \
	net-tools \
	ifupdown \
	iproute2 \
	ufw \
	expect && \
    apt upgrade -y && \
    # Disable IPV6 on ufw
    sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw

# Download, prepare and install Cyberghost
RUN wget https://download.cyberghostvpn.com/linux/cyberghostvpn-ubuntu-18.04-1.3.4.zip -O cyberghostvpn_ubuntu.zip && \
    unzip cyberghostvpn_ubuntu.zip && \
    mv cyberghostvpn-ubuntu-18.04-1.3.4/* . && \
    rm -r cyberghostvpn-ubuntu-18.04-1.3.4 && \
    rm cyberghostvpn_ubuntu.zip && \
    sed -i 's/cyberghostvpn --setup/#cyberghostvpn --setup/g' install.sh && \
    bash install.sh

COPY start.sh run.sh auth.sh ./
RUN chmod +x start.sh && \
    chmod +x run.sh && \
    chmod +x auth.sh

CMD ["bash", "/start.sh"]

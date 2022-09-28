#! /bin/bash

# Check sudo
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit
fi

# Check args (a/d) – activate/deactivate
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit
fi

# Activate/Dectivate mode
mode="$1"
echo $mode
if [ ! "$mode" = "a" ] && [ ! "$mode" = "d" ]; then
    echo "Wrong args. 'a' or 'd' are possible."
    exit
fi

# Check CRT's exist
if [[ ! -f  russian_*.crt ]]
then
    echo "Local CER's not found. Downloading..."
    # Download Russian Trusted Root CA
    wget https://gu-st.ru/content/Other/doc/russian_trusted_root_ca.cer
    
    # Download sub certificates
    wget https://gu-st.ru/content/Other/doc/russian_trusted_sub_ca.cer

    # Convert CER to CRT
    echo "Convering CER's to CRT's..."
    openssl x509 -inform DER -in russian_trusted_root_ca.cer -out russian_trusted_root_ca.crt
    openssl x509 -inform DER -in russian_trusted_sub_ca.cer -out russian_trusted_sub_ca.crt
    
    # Del CER's
    echo "Removing CER's..."
    rm russian_trusted_root_ca.cer russian_trusted_sub_ca.cer
    
    # Create dir for extra certificates
    if [[ ! -d /usr/local/share/ca-certificates/extra ]]
    then
	echo "Dir for extra certs not found, creating..."
        mkdir /usr/local/share/ca-certificates/extra
    fi

fi

case $mode in
    [a]*)  echo "Adding MITM CRT's..." && \
	    sudo cp -f russian_trusted_root_ca.crt /usr/local/share/ca-certificates/extra/russian_trusted_root_ca.crt && \
	    sudo cp -f russian_trusted_sub_ca.crt /usr/local/share/ca-certificates/extra/russian_trusted_sub_ca.crt ;;  
    [d]*)  echo "Removing MITM CRT's" && \
	    sudo rm /usr/local/share/ca-certificates/extra/russian_trusted_root_ca.crt && \
	    sudo rm /usr/local/share/ca-certificates/extra/russian_trusted_sub_ca.crt;;
esac

# Updating ca-certificates
echo "Updating ca-certificates..."
sudo update-ca-certificates
echo "Done."


#!/bin/bash

## Create june 2025
## use to check if SSL private key matches SSL cert
## can pass files (path or just the file, should tab complete paths)
## output will show sha256sum and if it matches
## 

{

#colors:
RED='\e[31m'
GREEN='\e[32m'

    printf "Enter SSL file paths:\n";
    read -ep "Private key: " PK;
    read -ep "Certificate: " CRT;
    printf "\n\n";
    printf "Private key file: {$PK} \n";
    openssl pkey -in "$PK" -pubout -outform pem | sha256sum ;
    printf "Certificate file: {$CRT} \n";
    openssl x509 -in "$CRT" -pubkey -noout -outform pem | sha256sum ;
    printf "\n\n" ;

PK_SUM=$(openssl pkey -in "$PK" -pubout -outform pem | sha256sum ;)
CRT_SUM=$(openssl x509 -in "$CRT" -pubkey -noout -outform pem | sha256sum)


    if [[ "$PK_SUM" = "$CRT_SUM" ]]; then
      printf "${GREEN}Private key and Cert match, proceed with install. \n\n"
     else
      printf "${RED}Private key and Cert do not match, REVIEW key and crt before proceeding. \n\n"
    fi
}

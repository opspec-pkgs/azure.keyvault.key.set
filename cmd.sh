#!/usr/bin/env bash

set -e

### begin login
loginCmd='az login -u "$loginId" -p "$loginSecret"'

# handle opts
if [ "$loginTenantId" != " " ]; then
    loginCmd=$(printf "%s --tenant %s" "$loginCmd" "$loginTenantId")
fi

case "$loginType" in
    "user")
        echo "logging in as user"
        ;;
    "sp")
        echo "logging in as service principal"
        loginCmd=$(printf "%s --service-principal" "$loginCmd")
        ;;
esac
eval "$loginCmd" >/dev/null

echo 'setting default subscription'
az account set --subscription "$subscriptionId"
### end login

echo 'checking if key exists'
if [ "$(az keyvault key show --name "$name" --vault-name "$vault")" ]; then
    echo "key exists"
    exit
fi

createCmd='az keyvault key create'
createCmd=$(printf "%s --name %s" "$createCmd" "$name")
createCmd=$(printf "%s --vault-name %s" "$createCmd" "$vault")
createCmd=$(printf "%s --protection %s" "$createCmd" "$protection")
createCmd=$(printf "%s --size %s" "$createCmd" "$size")

# handle opts
if [ "$expires" = " " ]; then
    createCmd=$(printf "%s --expires %s" "$createCmd" $(date -u -d next-year +%Y-%m-%d'T'%H:%M:%S'Z'))
else
    createCmd=$(printf "%s --expires %s" "$createCmd" "$expires")
fi

if [ "$notBefore" = " " ]; then
    createCmd=$(printf "%s --not-before %s" "$createCmd" $(date -u +%Y-%m-%d'T'%H:%M:%S'Z'))
else
    createCmd=$(printf "%s --not-before %s" "$createCmd" "$notBefore")
fi

if [ "$ops" != "all" ]; then
    createCmd=$(printf "%s --ops %s" "$createCmd" "$ops")
fi

echo "creating key"
eval "$createCmd" >/dev/null

echo "${_group}Creating volumes for persistent storage ..."

echo "Created $(docker volume create --name=sentry-clickhouse)."
echo "Created $(docker volume create --name=sentry-data)."
echo "Created $(docker volume create --name=sentry-kafka)."
echo "Created $(docker volume create --name=sentry-symbolicator)."

echo "${_endgroup}"

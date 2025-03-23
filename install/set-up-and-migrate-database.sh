echo "${_group}Setting up / migrating database ..."

# Add this before running migrations to test the PostgreSQL connection
echo "Testing PostgreSQL connection..."
$dcr web shell -c "
try:
    from django.db import connection
    connection.ensure_connection()
    print('PostgreSQL connection successful!')
except Exception as e:
    print('ERROR: Failed to connect to PostgreSQL database')
    print(f'Error details: {str(e)}')
    print('Database settings from Django:')
    from django.conf import settings
    db_settings = settings.DATABASES['default']
    # Print connection info without password
    print(f'  Host: {db_settings.get(\"HOST\", \"\")}')
    print(f'  Port: {db_settings.get(\"PORT\", \"\")}')
    print(f'  Name: {db_settings.get(\"NAME\", \"\")}')
    print(f'  User: {db_settings.get(\"USER\", \"\")}')
    exit(1)
"

# If the above command exits with an error, the script will stop here

  # Using django ORM to provide broader support for users with external databases
  $dcr web shell -c "
from django.db import connection

with connection.cursor() as cursor:
  cursor.execute('ALTER TABLE IF EXISTS sentry_groupedmessage DROP CONSTRAINT IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;')
  cursor.execute('DROP INDEX IF EXISTS sentry_groupedmessage_project_id_id_515aaa7e_uniq;')
"

  if [[ -n "${CI:-}" || "${SKIP_USER_CREATION:-0}" == 1 ]]; then
    $dcr web upgrade --noinput --create-kafka-topics
    $dcr web createuser --no-input --superuser --email $SENTRY_USER_EMAIL --password $SENTRY_USER_PASSWORD
    echo "Created user $SENTRY_USER_EMAIL"
  else
    $dcr web upgrade --create-kafka-topics
  fi
else
  echo "Skipped DB migrations due to SKIP_SENTRY_MIGRATIONS=$SKIP_SENTRY_MIGRATIONS"
fi
echo "${_endgroup}"

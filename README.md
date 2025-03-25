# Self-Hosted Sentry

[Sentry](https://sentry.io/) is feature-complete and packaged for low-volume deployments and proofs-of-concept. This repository provides the necessary configurations and scripts to deploy Sentry in a self-hosted environment.

**Important:** This setup requires you to provide your own external Postgres and Redis instances, as the default services have been removed from the Docker Compose configuration. Update the following files with your Postgres and Redis connection details:

- [relay/config.example.yml](relay/config.example.yml)
- [sentry/config.example.yml](sentry/config.example.yml)
- [sentry/sentry.conf.example.py](sentry/sentry.conf.example.py)
- [docker-compose.yml](docker-compose.yml)

**Configuration Notes:**

- Ensure that SSL/TLS is configured correctly in `sentry/sentry.conf.example.py`.
- Add your domain to `CSRF_TRUSTED_ORIGINS` in your Sentry configuration.
- The email and password have been modified in `install/set-up-and-migrate-database.sh`.
- For detailed instructions and configuration options, refer to the [official documentation](https://develop.sentry.dev/self-hosted/).

## Setup on AWS EC2

These instructions outline the steps to deploy self-hosted Sentry on an AWS EC2 instance.

### Prerequisites

- Minimum specifications: 4 CPU cores, 16 GB RAM, 50 GB storage
- Ensure that your Postgres and Redis hosts are reachable from the EC2 instance. You can test this using `telnet`:

  ```bash
  telnet <<postgres_host>> 5432
  telnet <<redis_host>> 6379
  ```

### Installation Steps

1.  **Install Docker:**

    ```bash
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update -y && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    ```

2.  **Install Docker Compose:**

    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```

3.  **Make Docker Compose Executable:**

    ```bash
    sudo chmod +x /usr/local/bin/docker-compose
    ```

4.  **Allow Docker to Run Without Sudo:**

    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo reboot
    ```

5.  **Mount Sentry Config Volume (Optional):**

    If you need to mount a specific volume for Sentry data, follow these steps:

    ```bash
    lsblk # Look for the volume name (e.g., starting with nvme...)
    sudo mkdir -p /sentry # Create the /sentry directory if it doesn't exist
    sudo mount /dev/nvme1n1 /sentry # Replace /dev/nvme1n1 with your volume name
    echo '/dev/nvme1n1 /sentry ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab # Add to /etc/fstab for persistent mounting
    ```

6.  **Update Docker Data Root (Optional):**

    If you want to change the Docker data root directory:

    ```bash
    sudo nano /lib/systemd/system/docker.service
    ```

    Modify the `ExecStart` line to include `--data-root=/sentry/docker`:

    ```
    ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/sentry/docker
    ```

    Then, reload the systemd configuration and restart Docker:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    docker info | grep "Docker Root Dir" # Verify the change
    ```

7.  **Create Directories for Docker Compose Volumes:**

    Create the necessary directories for Docker Compose volumes:

    ```bash
    mkdir -p /sentry/data/sentry-data
    mkdir -p /sentry/data/sentry-kafka
    mkdir -p /sentry/data/sentry-clickhouse
    mkdir -p /sentry/data/sentry-symbolicator
    mkdir -p /sentry/data/sentry-nginx-www
    mkdir -p /sentry/data/sentry-vroom
    mkdir -p /sentry/data/sentry-secrets
    mkdir -p /sentry/data/sentry-smtp
    mkdir -p /sentry/data/sentry-nginx-cache
    mkdir -p /sentry/data/sentry-kafka-log
    mkdir -p /sentry/data/sentry-smtp-log
    mkdir -p /sentry/data/sentry-clickhouse-log
    ```

    Ensure the directories are accessible by the current user:

    ```bash
    sudo chown -R 1000:1000 /sentry/data
    ```

8.  **Run the Installation Script:**

    ```bash
    cd sentry-arm-selfhost
    ./install.sh
    docker compose up -d # Run in detached mode
    ```

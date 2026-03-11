# Coder Server with Docker Compose

This directory contains the configuration for running [Coder](https://coder.com) - an open-source platform that enables teams to create self-service developer environments - using Docker Compose.

## Features

- **Coder Server**: Modern development environment platform
- **PostgreSQL Database**: Reliable backend storage for Coder
- **Docker Integration**: Provision Docker-based workspaces
- **Preconfigured Setup**: Ready-to-use configuration files

## Prerequisites

- Docker (v24 or later recommended)
- Docker Compose (v2.20 or later recommended)
- At least 8GB RAM available
- At least 20GB disk space for data persistence

## Installation

### Step 1: Clone and Navigate

```bash
cd docker/coder
```

### Step 2: Configure Environment

Copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit `.env` with your specific configuration:

```bash
# Required: Set your server's public IP or domain
CODER_ACCESS_URL=http://YOUR_SERVER_IP:7080

# Recommended: Generate a strong password
# Use: openssl rand -base64 32
POSTGRES_PASSWORD=your_secure_password_here
```

### Step 3: Get Docker Group ID (Optional)

If you need Coder to provision Docker containers on your host, get your Docker group ID:

```bash
getent group docker | cut -d: -f3
```

Update `DOCKER_GROUP_ID` in `.env` with this value if needed.

### Step 4: Start the Services

```bash
docker-compose up -d
```

### Step 5: Verify Installation

Check that both containers are running:

```bash
docker-compose ps
```

Expected output:
```
NAME                IMAGE                       STATUS
coder-server        ghcr.io/coder/coder:latest  Up (healthy)
coder-database      postgres:16-alpine          Up (healthy)
```

### Step 6: Access Coder

Open your browser to: `http://YOUR_SERVER_IP:7080`

Follow the on-screen setup wizard to create your first user account.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `coder_admin` | PostgreSQL username |
| `POSTGRES_PASSWORD` | *(required)* | PostgreSQL password (generate with `openssl rand -base64 32`) |
| `POSTGRES_DB` | `coder` | PostgreSQL database name |
| `CODER_ACCESS_URL` | `http://localhost:7080` | Public URL for Coder access |
| `CODER_ADDRESS` | `0.0.0.0:7080` | Internal listening address |
| `CODER_PG_CONNECTION_URL` | *(auto-generated)* | PostgreSQL connection string |
| `DOCKER_GROUP_ID` | `996` | Host's Docker group ID |
| `CODER_TELEMETRY_ENABLE` | `false` | Enable/disable telemetry |
| `CODER_UPDATE_CHECK` | `false` | Enable/disable update checks |
| `CODER_PORT` | `7080` | Host port for Coder access |

### Security Recommendations

1. **Use Strong Passwords**: Generate passwords with `openssl rand -base64 32`
2. **Enable HTTPS**: Use a reverse proxy (NGINX, Traefik) with SSL certificates
3. **Limit Network Exposure**: Don't expose PostgreSQL port (5432) to the public
4. **Regular Backups**: Implement database backup procedures (see Maintenance)
5. **Update Regularly**: Keep Docker images updated for security patches

### Example: Production-Ready Setup with HTTPS

```yaml
# Add to docker-compose.yml (see docker/coder folder)
reverse-proxy:
  image: traefik:latest
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - ./traefik-config:/etc/traefik
```

## Usage

### Starting Services

```bash
# Start in background
docker-compose up -d

# Start and view logs
docker-compose up
```

### Stopping Services

```bash
# Stop containers (keeps data)
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f coder
docker-compose logs -f database
```

### Running Commands

```bash
# Execute command in container
docker-compose exec coder coder <command>
docker-compose exec database psql -U coder_admin -d coder
```

## Maintenance

### Database Backups

Create a backup:

```bash
docker-compose exec database pg_dump -U coder_admin coder > backup.sql
```

Restore from backup:

```bash
docker-compose exec -T database psql -U coder_admin -d coder < backup.sql
```

### Updating Coder

```bash
# Pull latest images
docker-compose pull

# Update and restart
docker-compose up -d --build
```

### Database Maintenance

Clean up old data:

```bash
docker-compose exec database vacuumdb -U coder_admin -d coder -v
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker-compose logs
```

Common issues:
- Port 7080 already in use → Change `CODER_PORT` in `.env`
- Database connection failed → Verify `CODER_PG_CONNECTION_URL`

### Coder Access URL Issues

If Coder isn't accessible:
1. Verify `CODER_ACCESS_URL` matches your server's IP/domain
2. Check firewall settings allow traffic on port 7080
3. Ensure your reverse proxy is correctly configured (if used)

### Docker Socket Permission Denied

Get correct Docker group ID:
```bash
getent group docker | cut -d: -f3
```

Update `.env` with correct GID and restart:
```bash
docker-compose down && docker-compose up -d
```

### Database Connection Failed

Reset database (deletes all data):
```bash
docker-compose down -v
docker-compose up -d
```

### Health Check Failing

Wait 60-90 seconds after startup for services to be ready. Check health:
```bash
docker-compose ps
```

## Support

- [Coder Documentation](https://coder.com/docs)
- [Coder Community](https://coder.com/community)
- [Docker Compose Docs](https://docs.docker.com/compose/)

## License

This configuration is provided as-is for use with the NVIDIA DGX Spark Utilities project.
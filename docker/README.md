# Docker Images

This directory contains the Dockerfile for building marimo Docker images.

## Available Images

- `marimo-slim`: Minimal image with just marimo installed
- `marimo-data`: Includes marimo plus data science packages (pandas, numpy, altair) and marimo[recommended,lsp]
- `marimo-sql`: Extends the data image with SQL support (marimo[recommended,lsp,sql])
- `marimo-cloud`: Includes SQL variant plus cloud storage mounting via s3fs-fuse (S3, R2, GCS)

## Testing locally

To build all images, from the root

```bash
# Build your image, and tag it as my_app
docker build -t my_app . -f docker/Dockerfile

# Start your container, mapping port 8080
docker run -p 8080:8080 -it my_app

# Visit http://localhost:8080
```

## Cloud Storage Mounting (cloud variant)

The `cloud` variant includes s3fs-fuse for mounting cloud storage buckets as local filesystems.

### Building the cloud image

```bash
docker build -t marimo-cloud --target cloud -f docker/Dockerfile.from-source .
```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `CLOUD_STORAGE_TYPE` | Storage provider: `s3`, `gcs`, `r2` | `s3` |
| `CLOUD_STORAGE_BUCKET` | Bucket name | `my-bucket` |
| `CLOUD_STORAGE_MOUNT` | Mount point (default: `/acuity`) | `/acuity` |
| `CLOUD_STORAGE_OPTIONS` | Additional s3fs options | `nonempty,retries=3` |
| `AWS_ACCESS_KEY_ID` | AWS/R2 access key | |
| `AWS_SECRET_ACCESS_KEY` | AWS/R2 secret key | |
| `AWS_REGION` | AWS region (auto-detected if not set) | `us-west-2` |
| `AWS_ENDPOINT_URL` | Custom S3 endpoint (for MinIO, R2, etc.) | `http://localhost:9000` |

### AWS S3 Example

```bash
docker run -p 8080:8080 \
  --cap-add SYS_ADMIN --device /dev/fuse \
  -e CLOUD_STORAGE_TYPE=s3 \
  -e CLOUD_STORAGE_BUCKET=my-bucket \
  -e AWS_ACCESS_KEY_ID=AKIA... \
  -e AWS_SECRET_ACCESS_KEY=... \
  marimo-cloud
```

### Cloudflare R2 Example

```bash
docker run -p 8080:8080 \
  --cap-add SYS_ADMIN --device /dev/fuse \
  -e CLOUD_STORAGE_TYPE=r2 \
  -e CLOUD_STORAGE_BUCKET=my-bucket \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  -e AWS_ENDPOINT_URL=https://<account_id>.r2.cloudflarestorage.com \
  marimo-cloud
```

### MinIO Example (S3-compatible)

```bash
docker run -p 8080:8080 \
  --cap-add SYS_ADMIN --device /dev/fuse \
  -e CLOUD_STORAGE_TYPE=s3 \
  -e CLOUD_STORAGE_BUCKET=my-bucket \
  -e AWS_ACCESS_KEY_ID=minioadmin \
  -e AWS_SECRET_ACCESS_KEY=minioadmin \
  -e AWS_ENDPOINT_URL=http://minio:9000 \
  marimo-cloud
```

### Google Cloud Storage Example

GCS mounting uses the S3-compatible interoperability API. You need to generate HMAC keys in the GCP Console (Storage > Settings > Interoperability).

```bash
docker run -p 8080:8080 \
  --cap-add SYS_ADMIN --device /dev/fuse \
  -e CLOUD_STORAGE_TYPE=gcs \
  -e CLOUD_STORAGE_BUCKET=my-bucket \
  -e AWS_ACCESS_KEY_ID=<HMAC_ACCESS_KEY> \
  -e AWS_SECRET_ACCESS_KEY=<HMAC_SECRET> \
  marimo-cloud
```

### Security Note

FUSE mounting requires elevated privileges (`--cap-add SYS_ADMIN --device /dev/fuse`). For security-sensitive environments, consider using the fsspec Python libraries (included in the cloud image) instead of FUSE mounting.

### Python-only Access (no FUSE)

The cloud image also includes Python libraries for cloud storage access without FUSE:

```python
import s3fs
import fsspec

# S3
fs = s3fs.S3FileSystem()
fs.ls('my-bucket/')

# GCS
fs = fsspec.filesystem('gcs')
fs.ls('my-bucket/')

# Azure
fs = fsspec.filesystem('abfs', account_name='...')
```

#!/bin/bash
set -e

# Cloud storage mounting entrypoint script
# Supports: AWS S3, Cloudflare R2, Google Cloud Storage (via s3fs-fuse)

MOUNT_POINT="${CLOUD_STORAGE_MOUNT:-/acuity}"

mount_s3() {
    local bucket="$1"
    local mount_point="$2"
    local extra_opts="$3"

    echo "Mounting S3 bucket '$bucket' to '$mount_point'..."

    # Build s3fs options
    local opts="allow_other"

    # Add endpoint URL for S3-compatible services (R2, MinIO, etc.)
    if [ -n "$AWS_ENDPOINT_URL" ]; then
        echo "Using custom endpoint: $AWS_ENDPOINT_URL"
        opts="${opts},url=${AWS_ENDPOINT_URL},use_path_request_style"
        # Also add region if specified (needed for some S3-compatible services)
        if [ -n "$AWS_REGION" ]; then
            opts="${opts},endpoint=${AWS_REGION}"
        fi
    elif [ -n "$AWS_REGION" ]; then
        # Use region-specific endpoint
        opts="${opts},url=https://s3.${AWS_REGION}.amazonaws.com,endpoint=${AWS_REGION}"
    else
        # Auto-detect region using boto3
        echo "Auto-detecting bucket region..."
        DETECTED_REGION=$(python3 -c "
import boto3, os
try:
    s3 = boto3.client('s3',
        aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'))
    resp = s3.get_bucket_location(Bucket='$bucket')
    region = resp.get('LocationConstraint') or 'us-east-1'
    print(region)
except Exception as e:
    print('us-east-1')
" 2>/dev/null)
        echo "Detected region: $DETECTED_REGION"
        opts="${opts},url=https://s3.${DETECTED_REGION}.amazonaws.com,endpoint=${DETECTED_REGION}"
    fi

    # Add any extra options
    if [ -n "$extra_opts" ]; then
        opts="${opts},${extra_opts}"
    fi

    # Check for credentials
    if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
        # Use environment credentials
        echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > /tmp/.passwd-s3fs
        chmod 600 /tmp/.passwd-s3fs
        s3fs "$bucket" "$mount_point" -o "passwd_file=/tmp/.passwd-s3fs,${opts}"
    elif [ -f "$HOME/.passwd-s3fs" ]; then
        # Use credentials file
        s3fs "$bucket" "$mount_point" -o "passwd_file=$HOME/.passwd-s3fs,${opts}"
    elif [ -f "/etc/passwd-s3fs" ]; then
        # Use system credentials file
        s3fs "$bucket" "$mount_point" -o "passwd_file=/etc/passwd-s3fs,${opts}"
    else
        # Try IAM role (for EC2/ECS)
        s3fs "$bucket" "$mount_point" -o "iam_role=auto,${opts}"
    fi

    echo "Successfully mounted '$bucket' to '$mount_point'"
}

mount_gcs() {
    local bucket="$1"
    local mount_point="$2"
    local extra_opts="$3"

    echo "Mounting GCS bucket '$bucket' to '$mount_point' via s3fs interop..."

    # GCS has S3-compatible API via interoperability
    # Requires HMAC keys set as AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    local opts="allow_other,use_path_request_style,url=https://storage.googleapis.com"

    if [ -n "$extra_opts" ]; then
        opts="${opts},${extra_opts}"
    fi

    if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > /tmp/.passwd-s3fs
        chmod 600 /tmp/.passwd-s3fs
        s3fs "$bucket" "$mount_point" -o "passwd_file=/tmp/.passwd-s3fs,${opts}"
    else
        echo "Error: GCS mounting requires HMAC keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY)"
        echo "Generate HMAC keys in GCP Console: Storage > Settings > Interoperability"
        exit 1
    fi

    echo "Successfully mounted GCS bucket '$bucket' to '$mount_point'"
}

mount_r2() {
    local bucket="$1"
    local mount_point="$2"
    local extra_opts="$3"

    echo "Mounting Cloudflare R2 bucket '$bucket' to '$mount_point'..."

    # R2 is S3-compatible, requires endpoint URL
    if [ -z "$AWS_ENDPOINT_URL" ]; then
        echo "Error: R2 requires AWS_ENDPOINT_URL (e.g., https://<account_id>.r2.cloudflarestorage.com)"
        exit 1
    fi

    mount_s3 "$bucket" "$mount_point" "$extra_opts"
}

# Check if FUSE is available
check_fuse() {
    if [ -e /dev/fuse ]; then
        return 0
    else
        return 1
    fi
}

# Main logic
if [ -n "$CLOUD_STORAGE_TYPE" ] && [ -n "$CLOUD_STORAGE_BUCKET" ]; then
    # Check if FUSE mounting is possible
    if ! check_fuse; then
        echo "Warning: /dev/fuse not available. FUSE mounting disabled."
        echo "To enable FUSE mounting, run with: --cap-add SYS_ADMIN --device /dev/fuse"
        echo "Cloud storage is still accessible via Python libraries (s3fs, fsspec, etc.)"
    else
        # Ensure mount point exists
        mkdir -p "$MOUNT_POINT"

        case "$CLOUD_STORAGE_TYPE" in
            s3|aws)
                mount_s3 "$CLOUD_STORAGE_BUCKET" "$MOUNT_POINT" "$CLOUD_STORAGE_OPTIONS"
                ;;
            gcs|google)
                mount_gcs "$CLOUD_STORAGE_BUCKET" "$MOUNT_POINT" "$CLOUD_STORAGE_OPTIONS"
                ;;
            r2|cloudflare)
                mount_r2 "$CLOUD_STORAGE_BUCKET" "$MOUNT_POINT" "$CLOUD_STORAGE_OPTIONS"
                ;;
            azure)
                echo "Note: Azure Blob Storage FUSE mounting not supported."
                echo "Use fsspec/adlfs Python library instead for Azure access."
                ;;
            *)
                echo "Error: Unknown storage type '$CLOUD_STORAGE_TYPE'"
                echo "Supported types: s3, gcs, r2, azure (Python only)"
                exit 1
                ;;
        esac
    fi
else
    if [ -n "$CLOUD_STORAGE_TYPE" ] || [ -n "$CLOUD_STORAGE_BUCKET" ]; then
        echo "Warning: Both CLOUD_STORAGE_TYPE and CLOUD_STORAGE_BUCKET must be set for mounting"
        echo "Skipping cloud storage mount..."
    fi
fi

# Execute the main command
exec "$@"

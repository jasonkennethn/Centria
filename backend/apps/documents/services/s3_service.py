"""
Neon Object Cloud (S3-compatible) Storage Service for Centria Enterprise.
Uses Boto3 to interact with Neon S3 endpoint.
"""

import os
import uuid
import mimetypes
import logging
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError
from django.conf import settings

logger = logging.getLogger(__name__)

def get_s3_client():
    """
    Initializes and returns a configured Boto3 S3 client for Neon Object Cloud.
    """
    endpoint_url = settings.AWS_ENDPOINT_URL_S3
    access_key = settings.AWS_ACCESS_KEY_ID
    secret_key = settings.AWS_SECRET_ACCESS_KEY
    region = settings.AWS_REGION or "ap-southeast-1"

    if not endpoint_url or not access_key or not secret_key:
        logger.warning("Neon S3 credentials not fully configured.")
        return None

    try:
        session = boto3.session.Session()
        s3_client = session.client(
            service_name='s3',
            endpoint_url=endpoint_url,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region,
            config=Config(signature_version='s3v4')
        )
        return s3_client
    except Exception as e:
        logger.error(f"Failed to initialize S3 client: {str(e)}")
        return None


def upload_file_to_s3(file_obj, filename: str, folder: str = "documents") -> dict:
    """
    Uploads a file object to Neon S3 Object Cloud and returns file metadata and URL.
    """
    bucket_name = settings.AWS_STORAGE_BUCKET_NAME or "centria"
    s3_client = get_s3_client()

    # Generate a unique key
    ext = os.path.splitext(filename)[1]
    unique_key = f"{folder}/{uuid.uuid4()}{ext}"
    content_type, _ = mimetypes.guess_type(filename)
    if not content_type:
        content_type = "application/octet-stream"

    if s3_client:
        try:
            # Ensure bucket exists
            try:
                s3_client.head_bucket(Bucket=bucket_name)
            except ClientError:
                try:
                    s3_client.create_bucket(Bucket=bucket_name)
                except Exception as b_err:
                    logger.info(f"Bucket check/create note: {b_err}")

            # Read file data
            if hasattr(file_obj, 'read'):
                file_data = file_obj.read()
            else:
                file_data = file_obj

            file_size = len(file_data)

            s3_client.put_object(
                Bucket=bucket_name,
                Key=unique_key,
                Body=file_data,
                ContentType=content_type
            )

            # Generate URL
            endpoint = settings.AWS_ENDPOINT_URL_S3.rstrip('/')
            file_url = f"{endpoint}/{bucket_name}/{unique_key}"

            return {
                "success": True,
                "file_url": file_url,
                "s3_key": unique_key,
                "filename": filename,
                "file_size": file_size,
                "mime_type": content_type
            }
        except Exception as e:
            logger.error(f"Error uploading to Neon S3: {str(e)}")
            # Fallback for local dev media
            return _local_file_fallback(file_obj, filename, folder)
    else:
        return _local_file_fallback(file_obj, filename, folder)


def _local_file_fallback(file_obj, filename: str, folder: str) -> dict:
    """
    Fallback saving to local media storage if S3 is unavailable.
    """
    ext = os.path.splitext(filename)[1]
    unique_name = f"{uuid.uuid4()}{ext}"
    save_dir = os.path.join(settings.MEDIA_ROOT, folder)
    os.makedirs(save_dir, exist_ok=True)
    file_path = os.path.join(save_dir, unique_name)

    if hasattr(file_obj, 'read'):
        data = file_obj.read()
    else:
        data = file_obj

    with open(file_path, 'wb') as f:
        f.write(data)

    content_type, _ = mimetypes.guess_type(filename)
    file_url = f"{settings.BACKEND_URL}/media/{folder}/{unique_name}"

    return {
        "success": True,
        "file_url": file_url,
        "s3_key": f"{folder}/{unique_name}",
        "filename": filename,
        "file_size": len(data),
        "mime_type": content_type or "application/octet-stream"
    }

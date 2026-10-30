import io
import os
import uuid
import logging
from PIL import Image
from django.conf import settings
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from .models import MediaAsset

logger = logging.getLogger('centria.media')


MAX_MEDIA_BYTES = 50 * 1024 * 1024  # 50 MB limit


def convert_image_to_avif(file_bytes, quality=80):
    """
    Converts image bytes to AVIF format for high visual fidelity and tiny file sizes.
    Returns (avif_bytes, width, height).
    """
    try:
        # Register pillow-avif plugin if needed
        import pillow_avif  # noqa: F401
    except ImportError:
        pass

    try:
        img = Image.open(io.BytesIO(file_bytes))
        width, height = img.size
    except Image.DecompressionBombError as e:
        logger.error(f"Image rejected due to decompression bomb: {e}")
        raise ValueError("Image dimensions too large.")

    # Convert RGBA/P to RGB if saving without alpha or keep RGBA if transparency exists
    if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
        pass  # AVIF supports alpha channel
    elif img.mode != 'RGB':
        img = img.convert('RGB')

    output = io.BytesIO()
    try:
        img.save(output, format='AVIF', quality=quality)
        return output.getvalue(), width, height
    except Exception as e:
        logger.warning(f"AVIF encoding failed, falling back to WebP: {e}")
        output = io.BytesIO()
        img.save(output, format='WEBP', quality=quality)
        return output.getvalue(), width, height


def get_s3_client():
    """Build boto3 S3 client if configured."""
    endpoint = getattr(settings, 'AWS_ENDPOINT_URL_S3', '')
    access_key = getattr(settings, 'AWS_ACCESS_KEY_ID', '')
    secret_key = getattr(settings, 'AWS_SECRET_ACCESS_KEY', '')
    region = getattr(settings, 'AWS_REGION', 'ap-southeast-1')

    if not endpoint or not access_key:
        return None

    import boto3
    from botocore.config import Config
    return boto3.client(
        's3',
        endpoint_url=endpoint,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name=region,
        config=Config(signature_version='s3v4', connect_timeout=5, read_timeout=5)
    )


def process_and_upload_media(uploaded_file, company, user=None, folder='uploads'):
    """
    Processes uploaded image into AVIF format, stores to S3 (or local media fallback),
    and creates a MediaAsset record.
    """
    original_name = os.path.basename(uploaded_file.name)
    raw_content = uploaded_file.read()
    if len(raw_content) > MAX_MEDIA_BYTES:
        raise ValueError("File size exceeds maximum allowable limit of 50 MB.")
    content_type = uploaded_file.content_type or 'application/octet-stream'

    is_image = content_type.startswith('image/')
    width = None
    height = None

    if is_image:
        try:
            processed_bytes, width, height = convert_image_to_avif(raw_content)
            base_name, _ = os.path.splitext(original_name)
            final_filename = f"{base_name}.avif"
            file_mime = 'image/avif'
        except Exception as e:
            logger.error(f"Image processing error: {e}")
            processed_bytes = raw_content
            final_filename = original_name
            file_mime = content_type
    else:
        processed_bytes = raw_content
        final_filename = original_name
        file_mime = content_type

    company_slug = company.slug if company else 'public'
    key = f"{company_slug}/{folder}/{uuid.uuid4().hex[:12]}_{final_filename}"
    bucket = getattr(settings, 'S3_BUCKET_NAME', 'centria-media')

    file_url = None
    s3 = get_s3_client()
    if s3:
        try:
            put_kwargs = {
                'Bucket': bucket,
                'Key': key,
                'Body': processed_bytes,
                'ContentType': file_mime,
            }
            if getattr(settings, 'AWS_S3_ENABLE_ACL', False):
                put_kwargs['ACL'] = 'public-read'
            s3.put_object(**put_kwargs)
            endpoint = settings.AWS_ENDPOINT_URL_S3.rstrip('/')
            file_url = f"{endpoint}/{bucket}/{key}"
        except Exception as e:
            logger.warning(f"S3 upload failed ({e}), falling back to local storage")

    if not file_url:
        # Local media fallback
        saved_path = default_storage.save(key, ContentFile(processed_bytes))
        file_url = default_storage.url(saved_path)

    media_asset = MediaAsset.objects.create(
        company=company,
        uploader=user if user and user.is_authenticated else None,
        original_filename=original_name,
        file_type=file_mime,
        size_bytes=len(processed_bytes),
        s3_key=key,
        url=file_url,
        width=width,
        height=height,
    )
    return media_asset

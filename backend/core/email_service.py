import logging
import requests
from django.conf import settings
from django.utils.html import escape

logger = logging.getLogger('centria.email')


def send_email(to_email, subject, html_content, to_name=None):
    """
    Sends transactional email via Brevo API with verified sender 'Centria <no-reply@celarox.com>'.
    Sanitizes headers to prevent email header injection attacks.
    """
    api_key = getattr(settings, 'BREVO_API_KEY', '')
    sender_name = getattr(settings, 'EMAIL_SENDER_NAME', 'Centria')
    sender_email = getattr(settings, 'EMAIL_SENDER_ADDRESS', 'no-reply@celarox.com')

    clean_subject = str(subject).replace('\r', '').replace('\n', '').strip()
    clean_to_name = str(to_name).replace('\r', '').replace('\n', '').strip() if to_name else None

    if not api_key:
        logger.warning(f"[EMAIL MOCK] To: {to_email} | Subject: {clean_subject} | Content: {html_content[:100]}...")
        return True

    payload = {
        "sender": {"name": sender_name, "email": sender_email},
        "to": [{"email": to_email, "name": clean_to_name or to_email}],
        "subject": clean_subject,
        "htmlContent": html_content,
    }

    try:
        response = requests.post(
            "https://api.brevo.com/v3/smtp/email",
            headers={
                "api-key": api_key,
                "Content-Type": "application/json",
                "accept": "application/json",
            },
            json=payload,
            timeout=10,
        )
        if response.status_code in (200, 201, 202):
            logger.info(f"Email sent successfully to {to_email} via Brevo")
            return True
        else:
            logger.error(f"Brevo API failed ({response.status_code}): {response.text}")
            return False
    except Exception as e:
        logger.error(f"Failed to send email to {to_email}: {e}")
        return False


def send_otp_email(to_email, otp_code, user_name="User"):
    """
    Sends 6-digit OTP verification email for password reset.
    HTML-escapes all user-controlled values to eliminate email XSS vulnerabilities.
    """
    safe_user_name = escape(str(user_name or "User").strip())
    safe_otp = escape(str(otp_code).strip())

    subject = f"{safe_otp} is your Centria verification code"
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f7f8f5; margin: 0; padding: 40px 20px; }}
        .card {{ max-width: 500px; margin: 0 auto; background: #ffffff; border: 1px solid #dfe6df; border-radius: 16px; padding: 36px; }}
        .brand {{ display: inline-flex; align-items: center; gap: 8px; font-weight: 700; font-size: 20px; color: #176b5d; margin-bottom: 24px; }}
        h1 {{ font-size: 22px; color: #182a27; margin: 0 0 12px; }}
        p {{ color: #52665e; font-size: 14px; line-height: 1.6; margin: 0 0 20px; }}
        .otp-box {{ background: #eff3ee; border: 1px solid #dce5da; border-radius: 12px; text-align: center; padding: 18px; margin: 24px 0; }}
        .otp-code {{ font-family: monospace; font-size: 32px; letter-spacing: 6px; font-weight: 700; color: #176b5d; }}
        .expiry {{ font-size: 12px; color: #7a8780; }}
        .footer {{ font-size: 12px; color: #859087; border-top: 1px solid #e8eee6; padding-top: 16px; margin-top: 28px; }}
      </style>
    </head>
    <body>
      <div class="card">
        <div class="brand">centria</div>
        <h1>Password Reset Request</h1>
        <p>Hello {safe_user_name},</p>
        <p>We received a request to reset your Centria account password. Use the verification code below to complete the reset. This code is valid for 10 minutes.</p>
        <div class="otp-box">
          <div class="otp-code">{safe_otp}</div>
        </div>
        <p class="expiry">If you did not request this, you can safely ignore this email.</p>
        <div class="footer">
          &copy; Centria — Company work, connected.
        </div>
      </div>
    </body>
    </html>
    """
    return send_email(to_email, subject, html_content, to_name=user_name)

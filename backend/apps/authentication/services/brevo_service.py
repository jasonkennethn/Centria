"""
Brevo Transactional Email Service for Centria Enterprise.
Sender: Centira <no-reply@celarox.com>
"""

import logging
import requests
from django.conf import settings

logger = logging.getLogger(__name__)

BREVO_API_URL = "https://api.brevo.com/v3/smtp/email"

def send_brevo_email(to_email: str, to_name: str, subject: str, html_content: str, text_content: str = None) -> bool:
    """
    Sends an email using the Brevo REST API v3.
    """
    api_key = settings.BREVO_API_KEY
    sender_name = settings.BREVO_SENDER_NAME or "Centira"
    sender_email = settings.BREVO_SENDER_EMAIL or "no-reply@celarox.com"

    if not api_key:
        logger.warning(f"BREVO_API_KEY not configured. Email to {to_email} skipped.")
        return False

    headers = {
        "accept": "application/json",
        "api-key": api_key,
        "content-type": "application/json",
    }

    payload = {
        "sender": {
            "name": sender_name,
            "email": sender_email
        },
        "to": [
            {
                "email": to_email,
                "name": to_name or to_email.split('@')[0]
            }
        ],
        "subject": subject,
        "htmlContent": html_content,
    }

    if text_content:
        payload["textContent"] = text_content

    try:
        response = requests.post(BREVO_API_URL, json=payload, headers=headers, timeout=10)
        if response.status_code in [200, 201, 202]:
            logger.info(f"Email successfully sent to {to_email} via Brevo. Status: {response.status_code}")
            return True
        else:
            logger.error(f"Failed to send email to {to_email}. Brevo response: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        logger.error(f"Exception sending email to {to_email} via Brevo: {str(e)}")
        return False


def send_otp_email(to_email: str, otp_code: str, user_name: str = "") -> bool:
    """
    Sends a branded 6-digit OTP verification email for Centria.
    """
    subject = f"Centria Verification Code: {otp_code}"
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #0d1117; color: #e6edf3; margin: 0; padding: 40px 20px; }}
        .container {{ max-width: 540px; margin: 0 auto; background: #161b22; border: 1px solid #30363d; border-radius: 12px; padding: 36px; box-shadow: 0 8px 24px rgba(0,0,0,0.4); }}
        .logo {{ font-size: 24px; font-weight: 700; color: #58a6ff; letter-spacing: 0.5px; margin-bottom: 24px; display: inline-block; }}
        .heading {{ font-size: 20px; font-weight: 600; color: #ffffff; margin-bottom: 12px; }}
        .text {{ font-size: 14px; color: #8b949e; line-height: 1.6; margin-bottom: 24px; }}
        .otp-box {{ background: #21262d; border: 1px dashed #58a6ff; border-radius: 8px; padding: 18px; text-align: center; margin-bottom: 24px; }}
        .otp-code {{ font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #58a6ff; font-family: monospace; }}
        .footer {{ font-size: 12px; color: #484f58; border-top: 1px solid #21262d; padding-top: 18px; margin-top: 24px; }}
      </style>
    </head>
    <body>
      <div class="container">
        <div class="logo">CENTRIA</div>
        <div class="heading">Security Verification Code</div>
        <div class="text">Hello {user_name or 'there'},<br>Use the following 6-digit one-time code to authenticate your Centria Enterprise workspace. This code is valid for 10 minutes.</div>
        <div class="otp-box">
          <div class="otp-code">{otp_code}</div>
        </div>
        <div class="text">If you did not request this verification code, you can safely ignore this email.</div>
        <div class="footer">
          &copy; Centria Enterprise Operating System. Sent via Centira &lt;no-reply@celarox.com&gt;
        </div>
      </div>
    </body>
    </html>
    """
    return send_brevo_email(to_email, user_name, subject, html_content)


def send_workflow_approval_email(to_email: str, approver_name: str, workflow_title: str, details: str, action_url: str) -> bool:
    """
    Sends a workflow approval notification email.
    """
    subject = f"[Action Required] Centria Approval: {workflow_title}"
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #0d1117; color: #e6edf3; padding: 40px 20px; }}
        .container {{ max-width: 560px; margin: 0 auto; background: #161b22; border: 1px solid #30363d; border-radius: 12px; padding: 32px; }}
        .logo {{ font-size: 22px; font-weight: 700; color: #58a6ff; margin-bottom: 20px; }}
        .btn {{ display: inline-block; background-color: #238636; color: #ffffff; padding: 12px 24px; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 14px; margin-top: 16px; }}
      </style>
    </head>
    <body>
      <div class="container">
        <div class="logo">CENTRIA ENTERPRISE</div>
        <h3>Approval Requested: {workflow_title}</h3>
        <p>Hello {approver_name},</p>
        <p>{details}</p>
        <a href="{action_url}" class="btn">Review & Approve in Centria</a>
      </div>
    </body>
    </html>
    """
    return send_brevo_email(to_email, approver_name, subject, html_content)

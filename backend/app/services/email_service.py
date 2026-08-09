import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class EmailService:
    """
    Handles secure email delivery via SMTP (mail.cohabio@gmail.com)
    for account verification OTPs, security notifications, and password resets.
    """

    @staticmethod
    def send_verification_otp(to_email: str, otp_code: str, user_name: str = "CoHabio User") -> bool:
        subject = f"{otp_code} is your CoHabio Verification Code"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; margin: 0; padding: 20px; }}
            .container {{ max-width: 520px; background: #ffffff; margin: 0 auto; border-radius: 16px; padding: 32px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }}
            .brand {{ font-size: 24px; font-weight: 800; color: #16A34A; text-decoration: none; display: inline-block; margin-bottom: 20px; }}
            .title {{ font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 12px; }}
            .text {{ font-size: 15px; color: #475569; line-height: 1.6; margin-bottom: 24px; }}
            .otp-box {{ background-color: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 24px; }}
            .otp-code {{ font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #16A34A; margin: 0; }}
            .footer {{ font-size: 12px; color: #94a3b8; text-align: center; border-top: 1px solid #e2e8f0; padding-top: 20px; margin-top: 24px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <div class="brand">CoHabio</div>
            <div class="title">Verify Your Account</div>
            <div class="text">Hi <strong>{user_name}</strong>,<br>Thank you for joining CoHabio! Use the 6-digit verification code below to confirm your email address:</div>
            <div class="otp-box">
              <div class="otp-code">{otp_code}</div>
            </div>
            <div class="text" style="font-size: 13px; color: #64748b;">This verification code expires in <strong>10 minutes</strong>. Do not share this code with anyone.</div>
            <div class="footer">
              Sent by CoHabio Technologies • mail.cohabio@gmail.com<br>
              Find Your People. Find Your Place.
            </div>
          </div>
        </body>
        </html>
        """
        
        return EmailService._send_email(to_email, subject, html_content, fallback_otp=otp_code)

    @staticmethod
    def send_verification_status_update(to_email: str, user_name: str, status_text: str) -> bool:
        subject = f"CoHabio Identity Verification Update: {status_text.replace('_', ' ').title()}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; padding: 20px; }}
            .container {{ max-width: 520px; background: #ffffff; margin: 0 auto; border-radius: 16px; padding: 32px; border: 1px solid #e2e8f0; }}
            .brand {{ font-size: 24px; font-weight: 800; color: #16A34A; }}
            .text {{ font-size: 15px; color: #475569; line-height: 1.6; }}
            .status-badge {{ display: inline-block; padding: 6px 14px; background: #dcfce7; color: #15803d; font-weight: 700; border-radius: 20px; margin: 12px 0; }}
          </style>
        </head>
        <body>
          <div class="container">
            <div class="brand">CoHabio</div>
            <h3>Verification Status Update</h3>
            <p class="text">Hi <strong>{user_name}</strong>,</p>
            <p class="text">Your identity verification status has been updated to:</p>
            <div class="status-badge">{status_text.upper()}</div>
            <p class="text">You can now access enhanced roommate discovery features matching your verification tier.</p>
          </div>
        </body>
        </html>
        """
        return EmailService._send_email(to_email, subject, html_content)

    @staticmethod
    def send_waitlist_confirmation(to_email: str, user_name: str = "Friend", target_city: str = "your city") -> bool:
        subject = "🚀 Welcome to the Cohabio Early Access Waitlist!"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; margin: 0; padding: 20px; }}
            .container {{ max-width: 520px; background: #ffffff; margin: 0 auto; border-radius: 16px; padding: 32px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }}
            .brand {{ font-size: 24px; font-weight: 800; color: #16A34A; text-decoration: none; display: inline-block; margin-bottom: 20px; }}
            .title {{ font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 12px; }}
            .text {{ font-size: 15px; color: #475569; line-height: 1.6; margin-bottom: 24px; }}
            .city-badge {{ background-color: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px; padding: 16px; text-align: center; margin-bottom: 24px; font-weight: 700; color: #16A34A; }}
            .footer {{ font-size: 12px; color: #94a3b8; text-align: center; border-top: 1px solid #e2e8f0; padding-top: 20px; margin-top: 24px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <div class="brand">Cohabio</div>
            <div class="title">You're on the Early Access List! 🚀</div>
            <div class="text">Hi <strong>{user_name}</strong>,<br><br>Thank you for signing up for Cohabio! We're thrilled to have you join our community-first relocation platform.</div>
            <div class="city-badge">
              📍 Destination City Priority: {target_city.capitalize()}
            </div>
            <div class="text">We're rolling out early access invitations in batches. We'll send you your exclusive download link as soon as Cohabio launches in {target_city.capitalize()}!</div>
            <div class="footer">
              Sent by CoHabio Technologies • mail.cohabio@gmail.com<br>
              Find Your People. Find Your Place.
            </div>
          </div>
        </body>
        </html>
        """
        return EmailService._send_email(to_email, subject, html_content)

    @staticmethod
    def _send_email(to_email: str, subject: str, html_content: str, fallback_otp: str = None) -> bool:
        raw_pass = settings.SMTP_PASSWORD or ""
        clean_pass = raw_pass.replace(" ", "").strip()
        smtp_user = settings.SMTP_USER or settings.SMTP_FROM_EMAIL

        # Check if SMTP password is available for live email dispatch
        if not clean_pass or clean_pass == "your-gmail-app-password":
            logger.info(f"[DEVELOPMENT MODE] SMTP_PASSWORD not set. Email to {to_email} logged cleanly.")
            print(f"\n=======================================================")
            print(f"📧 [DEV EMAIL SIMULATOR] To: {to_email}")
            print(f"   Subject: {subject}")
            if fallback_otp:
                print(f"   🔑 VERIFICATION OTP CODE: {fallback_otp}")
            print(f"=======================================================\n")
            return True

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{settings.SMTP_FROM_NAME} <{smtp_user}>"
            msg["To"] = to_email

            part = MIMEText(html_content, "html")
            msg.attach(part)

            server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
            server.starttls()
            server.login(smtp_user, clean_pass)
            server.sendmail(smtp_user, to_email, msg.as_string())
            server.quit()
            logger.info(f"Successfully sent live SMTP email to {to_email}")
            print(f"✅ Successfully sent live SMTP confirmation email to {to_email}")
            return True
        except Exception as e:
            logger.error(f"Failed to send SMTP email to {to_email}: {str(e)}")
            print(f"⚠️ SMTP Send Error: {str(e)}")
            return False

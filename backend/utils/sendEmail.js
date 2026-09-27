const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  // Create a test account for local development if no SMTP is configured
  let testAccount;
  if (!process.env.SMTP_HOST) {
    testAccount = await nodemailer.createTestAccount();
  }

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.ethereal.email',
    port: process.env.SMTP_PORT || 587,
    auth: {
      user: process.env.SMTP_EMAIL || testAccount?.user,
      pass: process.env.SMTP_PASSWORD || testAccount?.pass,
    },
  });

  const message = {
    from: `${process.env.FROM_NAME || 'RentHive'} <${process.env.FROM_EMAIL || 'noreply@renthive.com'}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
  };

  const info = await transporter.sendMail(message);

  if (!process.env.SMTP_HOST) {
    console.log('Message sent: %s', info.messageId);
    console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));
  }
};

module.exports = sendEmail;

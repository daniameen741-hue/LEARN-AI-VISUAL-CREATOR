/**
 * AI VISUAL CREATOR — Google Apps Script
 * 
 * Paste this into Extensions → Apps Script, then:
 * 1. Update YOUR_EMAIL below
 * 2. Deploy → New deployment → Web app (Execute as: Me, Anyone can access)
 * 3. Copy the web app URL into register.html
 */

var YOUR_EMAIL = 'your-email@gmail.com';
var SITE_NAME = 'AI VISUAL CREATOR';

function doPost(e) {
  if (!e) {
    return ContentService
      .createTextOutput(JSON.stringify({ success: false, message: 'No event object' }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  try {
    var sheet = SpreadsheetApp.getActiveSheet();

    // Create headers if first row is empty
    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'Timestamp', 'Submitted At (PKT)', 'Full Name', 'Gender',
        'WhatsApp', 'Email', 'Occupation', 'Study What', 'Study Where',
        'Job Title', 'Industry', 'Services', 'About', 'Experience Level',
        'Learning Interests', 'How Did You Hear', 'Goals'
      ]);
      var headerRange = sheet.getRange(1, 1, 1, 17);
      headerRange.setFontWeight('bold');
      headerRange.setBackground('#E8652A');
      headerRange.setFontColor('#ffffff');
      sheet.setFrozenRows(1);
    }

    // Parse all parameters from the POST body
    var params = {};
    if (e.postData && e.postData.contents) {
      e.postData.contents.split('&').forEach(function(pair) {
        var parts = pair.split('=');
        var key = decodeURIComponent(parts[0]);
        var val = decodeURIComponent(parts[1] || '');
        // Handle multiple values with same key (learn checkboxes)
        if (params[key]) {
          if (Array.isArray(params[key])) {
            params[key].push(val);
          } else {
            params[key] = [params[key], val];
          }
        } else {
          params[key] = val;
        }
      });
    } else if (e.parameter) {
      params = e.parameter;
    }

    // Build learn interests string
    var learnInterests = '';
    if (Array.isArray(params.learn)) {
      learnInterests = params.learn.join(', ');
    } else if (params.learn) {
      learnInterests = params.learn;
    }

    // Format time in PKT (UTC+5)
    var now = new Date();
    var pktTime = new Date(now.getTime() + (5 * 60 * 60 * 1000));
    var formattedTime = Utilities.formatDate(pktTime, 'Asia/Karachi', 'dd MMM yyyy, hh:mm:ss a');

    // Append row
    var row = [
      now.toISOString(),
      formattedTime,
      params.fullName || '',
      params.gender || '',
      params.whatsapp || '',
      params.email || '',
      params.occupation || '',
      params.studyWhat || '',
      params.studyWhere || '',
      params.jobTitle || '',
      params.industry || '',
      params.services || '',
      params.aboutSelf || '',
      params.experience || '',
      learnInterests,
      params.referral || '',
      params.motivation || ''
    ];

    sheet.appendRow(row);

    // Send email notification
    var subject = 'New Registration — ' + (params.fullName || 'Unknown') + ' (' + (params.email || 'no email') + ')';
    var mailBody =
      'New registration on ' + SITE_NAME + '\n\n' +
      'Name: ' + (params.fullName || 'N/A') + '\n' +
      'Email: ' + (params.email || 'N/A') + '\n' +
      'WhatsApp: ' + (params.whatsapp || 'N/A') + '\n' +
      'Occupation: ' + (params.occupation || 'N/A') + '\n' +
      'Experience: ' + (params.experience || 'N/A') + '\n' +
      'Wants to learn: ' + learnInterests + '\n' +
      'Goals: ' + (params.motivation || 'N/A') + '\n' +
      'Referral: ' + (params.referral || 'N/A') + '\n\n' +
      'View all submissions in Google Sheets.';

    MailApp.sendEmail(YOUR_EMAIL, subject, mailBody);

    return ContentService
      .createTextOutput(JSON.stringify({ success: true, message: 'Registration received' }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    console.error('Error: ' + error.toString());
    return ContentService
      .createTextOutput(JSON.stringify({ success: false, message: error.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function doGet(e) {
  return ContentService
    .createTextOutput(JSON.stringify({ status: 'ok', message: 'AI Visual Creator registration API' }))
    .setMimeType(ContentService.MimeType.JSON);
}

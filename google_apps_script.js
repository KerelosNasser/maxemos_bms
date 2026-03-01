// Maxemos BMS - Google Apps Script
//
// INSTRUCTIONS FOR DEPLOYMENT:
// 1. Go to script.google.com and create a New Project.
// 2. Clear the default code and paste this entire file's content.
// 3. Create a folder in your Google Drive where you want the books to live.
// 4. Copy that Folder's ID from the URL (e.g., drive.google.com/drive/folders/YOUR_FOLDER_ID)
// 5. Replace 'YOUR_DRIVE_FOLDER_ID_HERE' below with the actual ID.
// 6. Click "Deploy" > "New deployment" in the top right.
// 7. Select type "Web app".
// 8. Execute as: "Me".
// 9. Who has access: "Anyone". (This is safe because only your Flutter app will use this URL).
// 10. Click "Deploy", copy the "Web app URL", and provide it to me in the prompt!

const FOLDER_ID = "YOUR_DRIVE_FOLDER_ID_HERE"; // <-- UPDATE THIS

// Handles POST requests
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const action = data.action;
    const secret = data.secret;

    // VERY BASIC SECURITY
    // In production, compare this against a Script Property.
    const EXPECTED_SECRET = "YOUR_SCRIPT_SECRET_HERE";
    if (secret !== EXPECTED_SECRET) {
      return ContentService.createTextOutput(
        JSON.stringify({ success: false, error: "401 Unauthorized" })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    if (action === "list") {
      const folder = DriveApp.getFolderById(FOLDER_ID);
      const files = folder.getFiles();
      const fileList = [];

      while (files.hasNext()) {
        const file = files.next();
        let categories = [];
        let summary = "";
        
        try {
          const desc = file.getDescription();
          if (desc) {
            const meta = JSON.parse(desc);
            if (meta.categories) categories = meta.categories;
            if (meta.summary) summary = meta.summary;
          }
        } catch (e) {
          // Ignore parse errors, just use defaults
        }

        fileList.push({
          id: file.getId(),
          name: file.getName(),
          url: file.getUrl(),
          size: file.getSize(),
          dateCreated: file.getDateCreated(),
          categories: categories,
          summary: summary,
        });
      }

      return ContentService.createTextOutput(
        JSON.stringify({ success: true, files: fileList })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    // UPLOAD FILE
    if (action === "upload") {
      const folder = DriveApp.getFolderById(FOLDER_ID);
      const fileBlob = Utilities.newBlob(
        Utilities.base64Decode(data.base64),
        data.mimeType,
        data.fileName
      );
      const newFile = folder.createFile(fileBlob);

      return ContentService.createTextOutput(
        JSON.stringify({
          success: true,
          fileId: newFile.getId(),
          name: newFile.getName(),
        })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    // UPDATE FILE METADATA
    if (action === "update") {
      const fileId = data.fileId;
      const file = DriveApp.getFileById(fileId);
      
      const meta = {
        categories: data.categories || [],
        summary: data.summary || ""
      };
      
      file.setDescription(JSON.stringify(meta));

      return ContentService.createTextOutput(
        JSON.stringify({
          success: true,
          message: "File metadata updated",
        })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    // DELETE FILE
    if (action === "delete") {
      const fileId = data.fileId;
      const file = DriveApp.getFileById(fileId);
      file.setTrashed(true);

      return ContentService.createTextOutput(
        JSON.stringify({
          success: true,
          message: "File moved to trash",
        })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    return ContentService.createTextOutput(
      JSON.stringify({ success: false, error: "Unknown action" })
    ).setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(
      JSON.stringify({ success: false, error: error.toString() })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

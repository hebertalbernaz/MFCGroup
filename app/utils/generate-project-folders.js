/*
  generateProjectFolders — File system folder generation utility.

  BROWSER ENVIRONMENT (current):
  --------------------------------
  Logs a mock success message to the console and returns a structured
  result. No actual file system operations are performed.

  NODE.JS ENVIRONMENT (production export):
  ----------------------------------------
  Replace the entire function body with the real fs-extra copy:

    import fse from 'fs-extra';
    import path from 'path';

    export async function generateProjectFolders({ templatePath, destinationPath, projectId, clientName }) {
      const rootFolderName = `${projectId} - ${clientName}`;
      const destRoot = path.join(destinationPath, rootFolderName);
      await fse.copy(templatePath, destRoot);
      return {
        success: true,
        rootFolder: destRoot,
        message: `Server Folders Created Successfully for ${projectId}`,
      };
    }

  The return shape is identical in both environments — the UI layer
  never needs to change.
*/

export async function generateProjectFolders({
  templatePath,
  destinationPath,
  projectId,
  clientName,
}) {
  const rootFolderName = `${projectId} - ${clientName}`;
  const destRoot = `${destinationPath}/${rootFolderName}`;

  const mockMessage = `Mock: Copied all files and folders from ${templatePath} to ${destRoot}`;
  console.info(`[MFC Folder Engine] ${mockMessage}`);

  return {
    success: true,
    rootFolder: destRoot,
    message: `Server Folders Created Successfully for ${projectId}`,
    detail: mockMessage,
  };
}

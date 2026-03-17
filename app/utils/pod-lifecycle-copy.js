export function podLifecycleCopy({ enquiryProjectId, newProjectId, clientName, podEnquiriesPath, podProjectsPath }) {
  const enquiryFolderName = `${enquiryProjectId} - ${clientName}`;
  const projectFolderName = `${newProjectId} - ${clientName}`;
  const enquiryFolder = `${podEnquiriesPath}/${enquiryFolderName}`;
  const projectFolder = `${podProjectsPath}/${projectFolderName}`;
  const message = `Mock: COPIED contents from ${enquiryFolder} to ${projectFolder}`;

  console.info(`[MFC Folder Engine - POD Lifecycle] ${message}`);

  return { enquiryFolder, projectFolder, projectFolderName, message };
}

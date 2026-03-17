export function podLifecycleCopy({ projectId, clientName, podEnquiriesPath, podProjectsPath }) {
  const numericPart = projectId.startsWith('PD') ? projectId.slice(2) : projectId;
  const enquiryFolder = `${podEnquiriesPath}/${projectId}`;
  const projectFolderName = `POD-${numericPart} - ${clientName}`;
  const projectFolder = `${podProjectsPath}/${projectFolderName}`;
  const message = `Mock: COPIED all contents from ${enquiryFolder} to ${projectFolder}`;

  console.info(`[MFC Folder Engine - POD Lifecycle] ${message}`);

  return { enquiryFolder, projectFolder, projectFolderName, message };
}

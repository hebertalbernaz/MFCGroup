export function podLifecycleCopy({ projectId, clientName, podEnquiriesPath, podProjectsPath }) {
  const numericPart = projectId.startsWith('PD') ? projectId.slice(2) : projectId;
  const newProjectId = `POD-${numericPart}`;
  const enquiryFolderName = `${projectId} - ${clientName}`;
  const projectFolderName = `${newProjectId} - ${clientName}`;
  const enquiryFolder = `${podEnquiriesPath}/${enquiryFolderName}`;
  const projectFolder = `${podProjectsPath}/${projectFolderName}`;
  const message = `Mock: COPIED contents from ${enquiryFolder} to ${projectFolder}`;

  console.info(`[MFC Folder Engine - POD Lifecycle] ${message}`);

  return { newProjectId, enquiryFolder, projectFolder, projectFolderName, message };
}

// Match the app's stable ID format. Never forward arbitrary URLs or schemes.
export function settingLinkForPath(pathname) {
  const match = /^\/settings\/([a-z0-9_]+(?:\.[a-z0-9_]+)+)\/?$/.exec(pathname);
  return match ? `pastiera://setting/${match[1]}` : null;
}

export function tryOpenSetting(link, navigate) {
  try {
    navigate(link);
  } catch {
    // Browsers can block automatic app launches. The visible anchor stays usable.
  }
}

/// Utility functions for content manipulation
library;

/// Splits long poem content into multiple pages for sharing.
///
/// Ensures natural breaks at newlines to preserve stanza integrity.
///
/// Parameters:
/// - [content]: The full poem text to split
/// - [maxCharsPerPage]: Maximum characters per page (default: 700)
///
/// Returns a list of content strings, one per page.
List<String> splitContentIntoPages(
  String content, {
  int maxCharsPerPage = 450,
}) {
  final List<String> pages = [];

  // Create a mutable copy of content to work with
  String remainingContent = content.trim();

  while (remainingContent.length > maxCharsPerPage) {
    // Take a chunk of the limit
    String chunk = remainingContent.substring(0, maxCharsPerPage);

    // Find Safe Cut Point: Look for the last index of a newline
    int cutIndex = chunk.lastIndexOf('\n');

    // Fallback 1: If no newline, look for space
    if (cutIndex == -1) {
      cutIndex = chunk.lastIndexOf(' ');
    }

    // Fallback 2: If still no good break, force cut at limit
    if (cutIndex == -1) {
      cutIndex = maxCharsPerPage;
    }

    // Execute Cut
    // Add the clean page content
    pages.add(remainingContent.substring(0, cutIndex).trim());

    // Update content to start after that cut point (skip whitespace/newline)
    remainingContent = remainingContent.substring(cutIndex).trim();
  }

  // Finalize: Add the remaining content
  if (remainingContent.isNotEmpty) {
    pages.add(remainingContent);
  }

  return pages;
}

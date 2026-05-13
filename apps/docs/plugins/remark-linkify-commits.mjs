import { visit } from 'unist-util-visit';

const HASH_REGEX = /\b([0-9a-f]{7,40})\b/g;

function splitTextToNodes(value, repo) {
  const nodes = [];
  let cursor = 0;
  let match;

  while ((match = HASH_REGEX.exec(value)) !== null) {
    const [full, hash] = match;
    const index = match.index;

    if (index > cursor) {
      nodes.push({ type: 'text', value: value.slice(cursor, index) });
    }

    nodes.push({
      type: 'link',
      url: `https://github.com/${repo}/commit/${hash}`,
      children: [{ type: 'text', value: hash.slice(0, 12) }]
    });

    cursor = index + full.length;
  }

  if (cursor < value.length) {
    nodes.push({ type: 'text', value: value.slice(cursor) });
  }

  return nodes;
}

export function remarkLinkifyCommits(options = {}) {
  const repo = options.repo;
  if (!repo) return () => {};

  return (tree) => {
    visit(tree, 'text', (node, index, parent) => {
      if (!parent || typeof index !== 'number') return;
      if (parent.type === 'link' || parent.type === 'linkReference' || parent.type === 'inlineCode' || parent.type === 'code') {
        return;
      }

      HASH_REGEX.lastIndex = 0;
      if (!HASH_REGEX.test(node.value)) return;
      HASH_REGEX.lastIndex = 0;

      const replacement = splitTextToNodes(node.value, repo);
      if (replacement.length === 0) return;

      parent.children.splice(index, 1, ...replacement);
    });
  };
}

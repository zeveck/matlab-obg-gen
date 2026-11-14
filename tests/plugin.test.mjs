// Checks for the plugin's packaging. Run with: node --test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const plugin = join(root, 'skills');
const skill = join(plugin, 'matlab-obg-gen');
const json = (p) => JSON.parse(readFileSync(p, 'utf8'));

test('marketplace lists the plugin from ./skills', () => {
  const m = json(join(root, '.claude-plugin', 'marketplace.json'));
  assert.equal(m.name, 'matlab-obg-gen');
  const p = m.plugins.find((x) => x.name === 'matlab-obg-gen');
  assert.ok(p, 'plugin entry');
  assert.equal(p.source, './skills');
});

test('plugin.json is complete and points at the skill', () => {
  const p = json(join(plugin, '.claude-plugin', 'plugin.json'));
  assert.equal(p.name, 'matlab-obg-gen');
  assert.match(p.version, /^\d{4}\.\d{1,2}\.\d{1,2}\.\d+$/);
  assert.equal(p.skills, './matlab-obg-gen');
  assert.ok(existsSync(join(plugin, 'LICENSE')));
});

test('changelog has an entry for the current version', () => {
  const p = json(join(plugin, '.claude-plugin', 'plugin.json'));
  assert.ok(readFileSync(join(root, 'CHANGELOG.md'), 'utf8').includes(`## ${p.version}`));
});

test('SKILL.md has the right frontmatter', () => {
  const s = readFileSync(join(skill, 'SKILL.md'), 'utf8');
  const fm = s.match(/^---\n([\s\S]*?)\n---/);
  assert.ok(fm, 'frontmatter');
  assert.match(fm[1], /^name: matlab-obg-gen$/m);
  assert.match(fm[1], /^description: /m);
});

test('every reference and tool SKILL.md names exists', () => {
  const s = readFileSync(join(skill, 'SKILL.md'), 'utf8');
  const named = new Set([...s.matchAll(/(references|tools)\/[\w.-]+\.(md|m|ps1)/g)].map((m) => m[0]));
  assert.ok(named.size > 5);
  for (const f of named) assert.ok(existsSync(join(skill, f)), `missing ${f}`);
});

test('no machine-specific paths in the plugin', () => {
  const walk = (d) => readdirSync(d).flatMap((f) => {
    const p = join(d, f);
    return statSync(p).isDirectory() ? walk(p) : [p];
  });
  for (const f of walk(plugin)) {
    const t = readFileSync(f, 'utf8');
    for (const bad of ['LocalDev', 'RM Conlan', '.claude/skills/matlab-obg-gen']) {
      assert.ok(!t.includes(bad), `${f} contains "${bad}"`);
    }
  }
});

test('README images exist', () => {
  const r = readFileSync(join(root, 'README.md'), 'utf8');
  for (const m of r.matchAll(/\]\((docs\/images\/[^)]+)\)/g)) {
    assert.ok(existsSync(join(root, m[1])), `missing ${m[1]}`);
  }
});

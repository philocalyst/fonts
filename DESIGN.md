# A font distribution specification
## Media
- All global, font-family media will lie in the assets/ directory. Here this means any documentation, specimens, photos, etc. that are meaningful in context to the COLLECTION of fonts. Pairings are a good example.
- Any media that is specific to a family member should lie in THAT directory.
- You can assume speicimens will be treated differently, as they are meant to be restricted to example usages of the font. Any file prefixed by specimen will be read as such.

## Source files
There exists no compiled, ready-to-use font files under versioning. Every font is defined by its UFO(Unified Font Object) file, which is, effectively, a series property list and XML files that describe how each glyph should be laid out.

- Within each directory that implements the spec, there will be a "source/" directory.
  - The source directory will include a directory for EACH family member within the font-family.
    - Inside this directory can exist: A info.toml override for particular features that have changed within the family and another assets folder with family member-specific specimens and documentation.
    - Inside this directory there MUST be the relevant UFO files. They are named by the attributes over the font-family the hold. Like, "Regular.ufo". A mix of attributes is signaled by a joining '+', as in "Regular+Italic.ufo"
- There will also be a CHANGELOG.txt, which implements the "Keep a Changelog" recommendations (spec?)
- A LICENSE (Should be the OFL)
- A info.toml which defines the global information for the font-family, including
  - A publication date for the family/children
  - A SPDX license identifier for the family/children
  - A summary key for a 1-2 sentence description of the family/children
  - A fontform key for the by-and-large shape of the CHILDREN
  - A copyright key for any copyright notices
  - A trademark key for any trademark notices
  - A description key for a longer-length description of the bacgkround behind the family/children
  - A foundary for the studio responsible
  - A contributor and designer table
    - Both take an email, website, name, and role
- A contributing document that defines how the author intends to process contributors. If not, there's a fallback (which makes the assumption it's under our responsibilities).

## Consumption
Connecting this all together is a Rust module that parses the relevant UFO files and, depending on the options given, outputs them and a JSON lock file that contains the complete manifest of all fonts and their data.
  - You can interface with this program in one of two ways: on the CLI or through a published GitHub action.
  - Can output to ttf, ttc, woff, or SVGs (Although the SVGs will probably never be used)
  - The outputted JSON is more or less a reflection of the TOML, but with some extra properties that are best computed dynamically. Things like the postscript name of the font, it's coverage across font systems, available weights, available glyphs, etc.

Every repository that implements the standard should have a .fontfamily extension, and tagged with that relevant tag. This is for discovery and validation. If you're using the action, it will automatically create all possible artifacts and compress them as a tgz for others to consume from the releases page. The manifest information is found in the same place.

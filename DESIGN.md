# A Font Distribution Specification

## Media

-   All global, font-family media will lie in the `Assets/` directory. Here this means any documentation, specimens, photos, etc., that are meaningful in context to the **collection** of fonts. Pairings are a good example.
    -   **Media Naming:** Global media files should follow a convention such as `[font_family_name]_[media_type].[ext]` (e.g., `MyFont_pairing.jpg`).
    -   **Image Formats:** Images should primarily be JPEGs (for photos) or PNGs (for illustrations/screenshots). Vector assets should be SVGs. Recommended resolution for display is 1920px on the longest side.
-   Any media that is specific to a family member should lie in **that** directory.
    -   **Media Naming:** Family member-specific media should follow a convention such as `[family_member_name]_[media_type].[ext]` (e.g., `MyFont-Regular_specimen_bodycopy.png`).
    -   **Image Formats:** Same recommendations as global media.
-   You can assume specimens will be treated differently, as they are meant to be restricted to example usages of the font. Any file prefixed by `specimen` will be read as such.

## Source Files

There exists no compiled, ready-to-use font files under versioning. Every font is defined by its UFO (Unified Font Object) file, which is, effectively, a series of property list and XML files that describe how each glyph should be laid out.

-   Within each directory that implements the spec, there will be a `source/` directory.
    -   The source directory will include a directory for **EACH** family member within the font-family.
        -   Inside this directory can exist: an `info.toml` override for particular features that have changed within the family, and another `Assets/` folder with family member-specific specimens and documentation.
            -   **`info.toml` Overrides:** The `info.toml` within a family member directory can override specific keys from the global `info.toml`. Primarily, this is for `description`, `summary`, `publication_date` if a particular style was released much later, and any font-specific features. Other keys like `foundry`, `copyright`, and `designers` are typically global and should not be overridden.
        -   Inside this directory there **MUST** be the relevant UFO files. They are named by the attributes over the font-family they hold. Like, "Regular.ufo". A mix of attributes is signaled by a joining '+', as in "Regular+Italic.ufo".
            *   **UFO Versioning:** All UFO files within a given font family **MUST** conform to the UFO 3 OR the UFO 2 specification.
-   There will also be a `CHANGELOG.md`, which implements the "Keep a Changelog" recommendations.
-   A `LICENSE.md` file. This **MUST** contain the full text of the Open Font License (OFL) version 1.1.
-   A `info.toml` which defines the global information for the font-family. The schema is as follows:

    ```toml
    # info.toml - Global Font Family Information

    # Date of the initial publication for the family or first child.
    # Format: YYYY-MM-DD (e.g., "2023-10-27")
    # If the month or day is not known, fallback to 01-01 (the first day of January)
    publication_date = "YYYY-MM-DD"

    # SPDX License Identifier for the font family. REQUIRED.
    # For OFL-1.1, use "OFL-1.1"
    license = "OFL-1.1"

    # A concise 1-2 sentence description of the font family. REQUIRED.
    summary = "A modern sans-serif typeface designed for high legibility across various applications, blending geometric forms with humanistic touches."

    # General classification of the font's shape. (e.g., "serif", "sans-serif", "script", "display", "monospace")
    # This describes the general form of the CHILDREN. REQUIRED.
    fontform = "sans-serif"

    # Full copyright notice for the font family. ENCOURAGED.
    # If not specified, we will assume you hold no copyrights
    copyright = "© YYYY [Copyright Holder Name]. All Rights Reserved."

    # Trademark notice for the font family. OPTIONAL.
    trademark = "MyFont™ is a trademark of [Trademark Holder Name]."

    # A longer, detailed description covering the background, design rationale,
    # and intended use cases for the font family. ENCOURAGED.
    description = """
    This extensive description provides insights into the historical influences behind MyFont,
    the design principles applied during its development, and its suitability for
    different media, from print to digital interfaces. It highlights unique glyph features
    and potential stylistic applications.
    """

    # Information about the studio or entity responsible for the font. REQUIRED.
    [foundry]
    name = "Awesome Fonts Studio"
    website = "https://www.awesomefonts.com" # OPTIONAL
    email = "info@awesomefonts.com" # OPTIONAL

    # Array of contributors to the project (e.g., developers, testers, proofreaders). OPTIONAL.
    [[contributors]]
    name = "Alice Developer"
    email = "alice@example.com" # OPTIONAL
    website = "https://alice.dev" # OPTIONAL
    role = "Lead Developer" # OPTIONAL

    [[contributors]]
    name = "Bob QA"
    email = "bob@example.com"
    role = "Quality Assurance"

    # Array of designers who worked on the font family. REQUIRED.
    [[designers]]
    name = "Charlie Creator"
    email = "charlie@example.com" # OPTIONAL
    website = "https://charlie.design" # OPTIONAL
    role = "Principal Designer" # OPTIONAL

    [[designers]]
    name = "Dana Draftswoman"
    email = "dana@example.com"
    role = "Glyph Designer"
    ```

-   A `CONTRIBUTING.md` document that defines how the author intends to process contributors. If not present, the author implicitly agrees to standard community contribution guidelines as determined by the our Rust module's default contribution policy, in which we assume the project is under our organizational responsibility.

## Consumption

Connecting this all together is a Rust module, that parses the relevant UFO files and, depending on the options given, outputs compiled font files and a JSON lock file that contains the complete manifest of all fonts and their data.

-   You can interface with this program in one of two ways: on the CLI or through a published GitHub Action.
-   The `font_builder` can output to `ttf`, `ttc`, `woff`, or SVGs (Although the SVGs will probably never be used and output as individual glyph SVGs within a dedicated directory).
    -   **Output Naming:** Compiled font files will be named using the convention: `[FontFamilyName]-[StyleName].[ext]` (e.g., `MyFont-Regular.ttf`, `MyFont-Italic.woff`). For TTC files, the name will be `[FontFamilyName].ttc`.
-   The outputted JSON lock file is more or less a reflection of the `info.toml`, but with some extra properties that are best computed dynamically. This JSON file serves as the definitive manifest for the released font family. Its schema is as follows:

    ```json
    {
      "manifest_version": "1.0",
      "font_family_name": "MyFont",
      "publication_date": "YYYY-MM-DD",
      "spdx_license_identifier": "OFL-1.1",
      "summary": "...",
      "fontform": "...",
      "copyright": "...",
      "trademark": "...",
      "description": "...",
      "foundry": {
        "name": "...",
        "website": "...",
        "email": "..."
      },
      "contributors": [
        {
          "name": "...",
          "email": "...",
          "website": "...",
          "role": "..."
        }
      ],
      "designers": [
        {
          "name": "...",
          "email": "...",
          "website": "...",
          "role": "..."
        }
      ],
      "family_members": [
        {
          "style_name": "Regular",
          "postscript_name": "MyFont-Regular",
          "full_font_name": "MyFont Regular",
          "version": "1.0.0",
          "font_files": {
            "ttf": "MyFont-Regular.ttf",
            "woff": "MyFont-Regular.woff"
          },
          "unicode_ranges": ["U+0000-007F", "U+0100-024F"],
          "available_glyphs": ["A", "B", "C", "..."],
          "weights": {
            "value": 400,
            "css_name": "normal",
            "open_type_name": "Regular"
          },
          "slopes": {
            "value": 0,
            "css_name": "normal",
            "open_type_name": "Roman"
          },
          "width": {
            "value": 100,
            "css_name": "normal",
            "open_type_name": "Medium"
          },
          "opentype_features": {
            "liga": true,
            "kern": true,
            "smcp": false
          },
          "overrides": {
            "description": "...",
            "publication_date": "..."
          }
        },
        {
          "style_name": "Italic",
          "postscript_name": "MyFont-Italic",
          "full_font_name": "MyFont Italic",
          "version": "1.000",
          "font_files": {
            "ttf": "MyFont-Italic.ttf",
            "woff": "MyFont-Italic.woff"
          },
          "unicode_ranges": ["U+0000-007F", "U+0100-024F"],
          "available_glyphs": ["A", "B", "C", "..."],
          "weights": {
            "value": 400,
            "css_name": "normal",
            "open_type_name": "Regular"
          },
          "slopes": {
            "value": 12,
            "css_name": "italic",
            "open_type_name": "Italic"
          },
          "width": {
            "value": 100,
            "css_name": "normal",
            "open_type_name": "Medium"
          },
          "opentype_features": {
            "liga": true,
            "kern": true,
            "smcp": false
          },
          "overrides": {}
        }
      ]
    }
    ```

    -   **Input Validation:** The `font_builder` module will perform strict validation on all `info.toml` files against the defined schemas and on UFO files to ensure adherence to the UFO 2/3 specification and consistency across the family. Errors will halt compilation with descriptive messages.

Every repository that implements this standard should have a `.fontfamily` extension (e.g., `my-font.fontfamily`), and be tagged with that relevant tag in its repository topics for discovery and validation. If you're using the GitHub Action, it will automatically create all possible artifacts and compress them as a `.tgz` for others to consume from the releases page. The manifest information is found in the same place.

---

### Example Repository Structure:

```
my-font.fontfamily/
├── Assets/
│   ├── myfont_pairing.jpg
│   └── Docs/
│       └── myfont_collection_overview.md
├── Source/
│   ├── Regular/
│   │   ├── Regular.ufo
│   │   ├── Assets/
│   │   │   └── specimen_quote.png
│   │   └── info.toml # (optional override for description/publication_date)
│   └── Italic/
│       ├── Italic.ufo
│       └── Assets/
│           └── specimen_quote.png
├── CHANGELOG.md
├── LICENSE.md # Full OFL 1.1 text
├── info.toml
└── CONTRIBUTING.md
```

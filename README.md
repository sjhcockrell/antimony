# [Sb] Antimony

Simple command line font conversion.

Takes an `.otf` file exported from a program like [Glyphs](http://glyphsapp.com) and converts it into webfont-friendly `.woff`, `.svg`, `.eot`, and `.ttf` files.

Antimony is element 51 on the periodic table. When alloyed with lead, it enhances the definition of cast metal type.

## Requirements

- Mac OS X 10.6 - 10.9
- Xcode

## Installation & Use

Clone a copy:

```bash
$ git clone git://github.com/sjhcockrell/antimony.git
```

Run the install script.

```bash
$ cd antimony
$ ./install
```

Antimony should be available to use globally from the command line now. Run this to see options:

```bash
$ antimony -h
```

## Future

Version 0.1 is extremely bare-bones. To make it what I'd consider a 1.0 release that actually covers all the basics, Antimony needs:

* Subsetting with character ranges.
* Em Square values.
* Compressed output, if/when possible.

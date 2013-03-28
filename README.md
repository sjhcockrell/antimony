# [Sb] Antimony

## Simple command line font conversion. 

Takes an `.otf` file exported from a program like [Glyphs](http://glyphsapp.com) and converts it into webfont-friendly `.woff`, `.svg`, `.eot`, and `.ttf` files.

I realized this was something I needed when I wanted to automate the build process for my icon fonts without having to go to a website, upload a file, select some config, download more files, then move them into my project.

The project is named after element 51. Alloyed with lead, antimony enhances the definition of cast metal type.

## Installation & Use

Clone a copy:

    git clone git://github.com/sjhcockrell/antimony.git

Run the install script. 

    cd antimony
    ./install

Antimony should be available to use from the command line now.

    antimony [otf font file];

## Possible Features

* Exporting character ranges.
* Compressed output.
* Programmatic Em values.

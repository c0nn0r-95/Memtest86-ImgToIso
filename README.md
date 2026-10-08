# Memtest86 IMG to ISO

Simple Windows tool to convert a Memtest86 USB `.img` file into a bootable ISO.

Very useful if you want boot Memtest86 throught a PXE server like iVentoy which accept only ISO files.

## How to use

1. Download the latest release
2. Extract the zip
3. Drag and drop your `memtest86-usb.img` onto `convert.bat`  
   **or** double-click `convert.bat` and paste the path to the .img file

The ISO will be created next to the original .img file.

## Requirements

Nothing to install.  
Everything needed is already included in the `tools` folder.

## Included tools

- **7-Zip** (LGPL) - used to extract the GPT partitions from the .img
- **xorriso** (GPL) - used to create the bootable ISO

## License

This project (the batch script) is released under the MIT License.  
The included binaries keep their original licenses (7-Zip LGPL / xorriso GPL).

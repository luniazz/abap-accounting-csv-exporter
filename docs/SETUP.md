# SAP Setup

## 1. Create the ABAP Objects

Create the following objects in the desired SAP package:

* Executable Report: `ZFII001_15E`
* Include: `ZFII001_15E_TOP`
* Include: `ZFII001_15E_SEL`
* Include: `ZFII001_15E_F01`

Copy the contents of the files from the `src` folder into their corresponding ABAP objects.

## 2. Maintain the Text Symbols

Maintain the text symbols listed in `docs/TEXT_SYMBOLS.md`.

## 3. Create the Transaction

Create a report transaction pointing to the main program:

* Transaction: `ZFITI001_15E`
* Program: `ZFII001_15E`

## 4. Execute

Run the program through the transaction or directly from the report.

Enter:

* Company Code
* Document Number, optional
* Fiscal Year, mandatory

At the end of the execution, select the local path where the CSV file should be saved.

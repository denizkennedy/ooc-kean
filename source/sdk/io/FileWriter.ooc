import io/Writer, io/File

/**
 * Implement the Writer interface for file output
 *
 * By default, files are opened in binary mode. If you want to open
 * them in text mode, use the new~withMode variant, but beware: on
 * mingw, rewind()/mark() won't work correctly.
 */
FileWriter: class extends Writer {
	/** The underlying file descriptor */
	file: FStream

	/**
	   Create a new file writer on the given file object.
	   @param append If true, appends to the file. If false, overwrites it.
	 */
	init: func ~withFile (fileObject: File, append: Bool) {
		init(fileObject getPath(), append)
	}

	/**
	   Create a new file write on the given file object, overwriting it.
	*/
	init: func ~withFileOverwrite (fileObject: File) {
		init(fileObject, false)
	}

	init: func ~withFileAndFlags (fileObject: File, flags: Int) {
		init(fileObject getPath(), "wb", flags)
	}

	/**
	   Create a new file writer on the given file path.
	   @param append If true, appends to the file. If false, overwrites it.
	 */
	init: func ~withName (fileName: String, append: Bool) {
		// mingw fseek/ftell are *really* unreliable with text mode
		// if for some weird reason you need to open in text mode, use
		// FileWriter new(fileName, "at") or "wt"
		init(fileName, append ? "ab" : "wb")
	}

	init: func ~withMode (fileName, mode: String) {
		file = FStream open(fileName, mode)
		if (!file) {
			Exception new(This, "Error creating FileWriter for: " + fileName) throw()
		}
	}

	init: func ~withModeAndFlags (fileName, mode: String, flags: Int) {
		file = FStream open(fileName, mode, flags)
		if (!file) {
			Exception new(This, "File not found: " + fileName) throw()
		}
	}

	/**
		Create a new file writer from a given FStream
	*/
	init: func ~withFStream (=file)

	/**
	   Create a new file writer on the given file path, overwriting it.
	 */
	init: func ~withNameOverwrite (fileName: String) {
		init(fileName, false)
	}

	/**
	   Write a given number of bytes to this file, and return
	   the number that has been effectively written.
	 */
	write: override func (bytes: Char*, length: SizeT) -> SizeT {
		file write(bytes, 0, length)
	}

	/**
	   Write a single byte to this file.
	 */
	write: override func ~chr (chr: Char) {
		file write(chr)
	}

	/**
	   Close this writer and free the associated system resources, if any.
	 */
	close: override func {
		file close()
	}

	createTempFile: static func (pattern, mode: String) -> This {
	version (!windows) {
		return new(fdopen(mkstemp(pattern), mode))
	}
	version (windows) {
		// mkstemp is missing on Windows, that sucks, but let's use the
		// worse method instead
		new(mktemp(pattern) toString(), mode)
	}
	Exception new("FileWriter createTempFile() is unsupported on your os") throw()
	null
	}
}

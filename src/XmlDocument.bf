using System;
using System.IO;
using System.Collections;


namespace tinyxml2
{
	class XmlDocument : XmlNode
	{
		private bool _processEntities;
		private Whitespace _whitespaceMode;
		private bool _writeBOM, _useBOM;
		private XmlError _errorID;
		private int _errorLineNum;
		private StrPair _errorStr ~ delete _;
		private uint8[] _charBuffer ~ delete _;
		private int _parseCurLineNum;
		private int _parsingDepth;
		private List<XmlNode> _unlinked ~ delete _;

		private static readonly String[] _errorNames =
			new String[(int) XmlError.XML_ERROR_COUNT](
				"XML_SUCCESS",
				"XML_NO_ATTRIBUTE",
				"XML_WRONG_ATTRIBUTE_TYPE",
				"XML_ERROR_FILE_NOT_FOUND",
				"XML_ERROR_FILE_COULD_NOT_BE_OPENED",
				"XML_ERROR_FILE_READ_ERROR",
				"XML_ERROR_PARSING_ELEMENT",
				"XML_ERROR_PARSING_ATTRIBUTE",
				"XML_ERROR_PARSING_TEXT",
				"XML_ERROR_PARSING_CDATA",
				"XML_ERROR_PARSING_COMMENT",
				"XML_ERROR_PARSING_DECLARATION",
				"XML_ERROR_PARSING_UNKNOWN",
				"XML_ERROR_EMPTY_DOCUMENT",
				"XML_ERROR_MISMATCHED_ELEMENT",
				"XML_ERROR_PARSING",
				"XML_CAN_NOT_CONVERT_TEXT",
				"XML_NO_TEXT_NODE",
				"XML_ELEMENT_DEPTH_EXCEEDED"
			) ~ delete _;


		public this(bool processEntities = true, Whitespace whitespacemode = .PRESERVE_WHITESPACE) : base(this)
		{
			_writeBOM = false;
			_processEntities = processEntities;
			_errorID = .XML_SUCCESS;
			_whitespaceMode = whitespacemode;
			_errorStr = new StrPair();
			_parseCurLineNum = 0;
			_parsingDepth = 0;
			_errorLineNum = 0;
			_unlinked = new List<XmlNode>();
		}

		public ~this()
		{
			Clear();
		}


		public override XmlDocument ToDocument() => this;


		/**
			Parse an XML file from a character string.
			Returns XML_SUCCESS (0) on success, or
			an errorID.
			You may optionally pass in the 'nBytes', which is
			the number of bytes which will be parsed. If not
			specified, TinyXML-2 will assume 'xml' points to a
			null terminated string.
		*/
		public XmlError Parse(char8* p, uint len = 0xFFFF'FFFF)
		{
			Clear();

			if (len == 0 || p == null || *p == 0)
			{
				SetError(.XML_ERROR_EMPTY_DOCUMENT, 0, null);
				return _errorID;
			}

			var length = len;

			if (length == 0xFFFF'FFFF)
			{
				length = utilities.strlen(p);
			}

			_charBuffer = new uint8[len + 1];
			Internal.MemCpy(&_charBuffer[0], p, (.) length);

			_charBuffer[(int) length] = 0;

			Parse();

			if (Error())
			{
				DeleteChildren();
			}

			return _errorID;
		}

		/**
			Load an XML file from disk.
			Returns XML_SUCCESS (0) on success, or
			an errorID.
		*/
		public XmlError LoadFile(char8* filename)
		{
			if (filename == null)
			{
				SetError(.XML_ERROR_FILE_COULD_NOT_BE_OPENED, 0, "filename=<null>");
				return _errorID;
			}

			Clear();

			FileStream fs = scope FileStream();
			switch(fs.Open(StringView(filename), .Read, .Read))
			{
			case .Ok:
				break;
			case .Err:
				SetError(.XML_ERROR_FILE_COULD_NOT_BE_OPENED, 0, "filename={}", filename);
				return _errorID;
			}

			LoadFile(fs);
			fs.Close();

			return _errorID;
		}


		/**
			Load an XML file from disk. You are responsible
			for providing and closing the FILE*.
		    NOTE: The file should be opened as binary ("rb")
		    not text in order for TinyXML-2 to correctly
		    do newline normalization.
			Returns XML_SUCCESS (0) on success, or
			an errorID.
		*/
		public XmlError LoadFile(Stream stream)
		{
			Clear();

			if (!stream.CanRead || stream.Length <= 0)
			{
				SetError(.XML_ERROR_FILE_READ_ERROR, 0, null);
				return _errorID;
			}

			stream.Seek(0, .Absolute);

			_charBuffer = new uint8[stream.Length + 1];

			switch (stream.TryRead(_charBuffer))
			{
			case .Ok:
				break;
			case .Err:
				SetError(.XML_ERROR_FILE_READ_ERROR, 0, null);
				return _errorID;
			}

			_charBuffer[stream.Length] = 0;

			Parse();
			
			return _errorID;
		}


		/**
			Save the XML file to disk.
			Returns XML_SUCCESS (0) on success, or
			an errorID.
		*/
		public XmlError SaveFile(char8* filename, bool compact = false)
		{
			if (filename == null)
			{
				SetError(.XML_ERROR_FILE_COULD_NOT_BE_OPENED, 0, "filename=<null>");
				return _errorID;
			}

			FileStream fs = scope FileStream();
			switch(fs.Create(StringView(filename), .ReadWrite, .ReadWrite))
			{
			case .Ok:
				break;
			case .Err:
				SetError(.XML_ERROR_FILE_COULD_NOT_BE_OPENED, 0, "filename={}", filename);
				return _errorID;
			}

			SaveFile(fs, compact);

			fs.Close();

			return _errorID;
		}

		/**
			Save the XML file to disk. You are responsible
			for providing and closing the FILE*.
			Returns XML_SUCCESS (0) on success, or
			an errorID.
		*/
		public XmlError SaveFile(Stream fp, bool compact = false)
		{
			ClearError();
			XmlPrinter str = scope .(fp, compact);
			Print(str);
			return _errorID;
		}

		[Inline]
		public bool ProcessEntities() => _processEntities;

		[Inline]
		public Whitespace WhitespaceMode() => _whitespaceMode;

		[Inline]
		public bool HasBOM() => _writeBOM;

		[Inline]
		public void SetBOM(bool useBOM) { _writeBOM = useBOM; }


		/** Return the root element of DOM. Equivalent to FirstChildElement().
		    To get the first node, use FirstChild().
		*/
		public XmlElement RootElement() => FirstChildElement();


		/** Print the Document. If the Printer is not provided, it will
		    print to stdout. If you provide Printer, this can print to a file:
			@verbatim
			XMLPrinter printer( fp );
			doc.Print( &printer );
			@endverbatim
			Or you can use a printer to print to memory:
			@verbatim
			XMLPrinter printer;
			doc.Print( &printer );
			// printer.CStr() has a const char* to the XML
			@endverbatim
		*/
		public void Print(XmlPrinter streamer = null)
		{
			if (streamer != null)
			{
				Accept(streamer);
			}
			else
			{
				XmlPrinter stdoutStream = scope .();
				Accept(stdoutStream);
			}
		}

		public override bool Accept(XmlVisitor visitor)
		{
			if (visitor.VisitEnter(this))
			{
				for (var node = FirstChild(); node != null; node = node.NextSibling())
				{
					if (!node.Accept(visitor))
						break;
				}
			}

			return visitor.VisitExit(this);
		}



		/**
			Create a new Element associated with
			this Document. The memory for the Element
			is managed by the Document.
		*/
		public XmlElement NewElement(char8* name)
		{
			var ele = CreateUnlinkedNode<XmlElement>();
			ele.SetName(name);
			return ele;
		}

		/**
			Create a new Comment associated with
			this Document. The memory for the Comment
			is managed by the Document.
		*/
		public XmlComment NewComment(char8* comment)
		{
			var com = CreateUnlinkedNode<XmlComment>();
			com.SetValue(comment);
			return com;
		}

		/**
			Create a new Text associated with
			this Document. The memory for the Text
			is managed by the Document.
		*/
		public XmlText NewText(char8* text)
		{
			var t = CreateUnlinkedNode<XmlText>();
			t.SetValue(text);
			return t;
		}

		/**
			Create a new Declaration associated with
			this Document. The memory for the object
			is managed by the Document.
			If the 'text' param is null, the standard
			declaration is used.:
			@verbatim
				<?xml version="1.0" encoding="UTF-8"?>
			@endverbatim
		*/
		public XmlDeclaration NewDeclaration(char8* text = null)
		{
			var dec = CreateUnlinkedNode<XmlDeclaration>();
			dec.SetValue(text != null ? text : "xml version=\"1.0\" encoding=\"UTF-8\"");
			return dec;
		}

		/**
			Create a new Unknown associated with
			this Document. The memory for the object
			is managed by the Document.
		*/
		public XmlUnknown NewUnknown(char8* text)
		{
			var unk = CreateUnlinkedNode<XmlUnknown>();
			unk.SetValue(text);
			return unk;
		}

		/**
			Delete a node associated with this document.
			It will be unlinked from the DOM.
		*/
		public void DeleteNode(XmlNode node)
		{
			if (node.[Friend]_parent != null)
			{
				node.[Friend]_parent.DeleteChild(node);
			}
			else
			{
				XmlNode.DeleteNode(this);
			}	
		}

		public void ClearError()
		{
			SetError(.XML_SUCCESS, 0, null);
		}

		[Inline]
		public bool Error() => _errorID != .XML_SUCCESS;

		[Inline]
		public XmlError ErrorID() => _errorID;

		public char8* ErrorName()
		{
			return ErrorIDToName(_errorID);
		}

		

		public static char8* ErrorIDToName(XmlError errorID)
		{
			return _errorNames[(int) errorID];
		}

		public char8* ErrorStr()
		{
			return _errorStr.Empty() ? "" : _errorStr.GetStr();
		}

		public void PrintError()
		{
			Console.WriteLine(scope String(ErrorStr()));
		}

		[Inline]
		public int ErrorLineNume() => _errorLineNum;

		public void Clear()
		{
			DeleteChildren();

			while (_unlinked.Count != 0)
			{
				DeleteNode(_unlinked[0]);
			}
		}

		/**
			Copies this document to a target document.
			The target will be completely cleared before the copy.
			If you want to copy a sub-tree, see XMLNode::DeepClone().
			NOTE: that the 'target' must be non-null.
		*/
		public void DeepCopy(XmlDocument target)
		{
			if (target == this)
				return;

			target.Clear();

			for (var node = FirstChild(); node != null; node = node.NextSibling())
			{
				target.InsertEndChild(node.DeepClone(target));
			}
		}

		public char8* Identify(char8* pp, out XmlNode node)
		{
			char8* p = pp;
			char8* start = p;
			int startLine = _parseCurLineNum;
			XMLUtil.SkipWhiteSpace(ref p, &_parseCurLineNum);

			if (*p == 0)
			{
				node = null;
				return p;
			}

			XmlNode returnNode = null;

			if (XMLUtil.StringEqual(p, XML_HEADER, XML_HEADER_LEN))
			{
				returnNode = CreateUnlinkedNode<XmlDeclaration>();
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p += XML_HEADER_LEN;
			}
			else if (XMLUtil.StringEqual(p, COMMENT_HEADER, COMMENT_HEADER_LEN))
			{
				returnNode = CreateUnlinkedNode<XmlComment>();
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p += COMMENT_HEADER_LEN;
			}
			else if (XMLUtil.StringEqual(p, CDATA_HEADER, CDATA_HEADER_LEN))
			{
				XmlText text = CreateUnlinkedNode<XmlText>();
				returnNode = text;
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p += CDATA_HEADER_LEN;
				text.SetCData(true);
			}
			else if (XMLUtil.StringEqual(p, DTD_HEADER, DTD_HEADER_LEN))
			{
				returnNode = CreateUnlinkedNode<XmlUnknown>();
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p += DTD_HEADER_LEN;
			}
			else if (XMLUtil.StringEqual(p, ELEMENT_HEADER, ELEMENT_HEADER_LEN))
			{
				returnNode = CreateUnlinkedNode<XmlElement>();
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p += ELEMENT_HEADER_LEN;
			}
			else
			{
				returnNode = CreateUnlinkedNode<XmlText>();
				returnNode.[Friend]_parseLineNum = _parseCurLineNum;
				p = start;
				_parseCurLineNum = startLine;
			}

			node = returnNode;

			return p;
		}

		public void MarkInUse(XmlNode node)
		{
			for (var i < _unlinked.Count)
			{
				if (node == _unlinked[i])
				{
					_unlinked.RemoveAt(i);
					break;
				}
			}
		}

		public override XmlNode ShallowClone(XmlDocument document)
		{
			return null;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			return false;
		}

		private T CreateUnlinkedNode<T>() where T: XmlNode
		{
			T t = new T(this);

			_unlinked.Add(t);

			return t;
		}



		private void Parse()
		{
			_parseCurLineNum = 1;
			_parseLineNum = 1;

			var p = (char8*) &_charBuffer[0];

			XMLUtil.SkipWhiteSpace(ref p, &_parseCurLineNum );
			p = XMLUtil.ReadBOM(p, &_writeBOM);

			if (*p == 0)
			{
				SetError(.XML_ERROR_EMPTY_DOCUMENT, 0, null);
				return;
			}

			ParseDeep(p, null, &_parseCurLineNum);
		}

		public void SetError(XmlError error, int lineNum, char8* format, params Object[] args)
		{
			_errorID = error;
			_errorLineNum = lineNum;
			_errorStr.Reset();

			char8* buffer = new char8[1000]*;

			if (format != null)
			{
				String s = scope String(buffer, 1000);
				s..AppendF(StringView(format), args);
			}

			_errorStr.SetStr(buffer);
			delete buffer;
		}


		public class DepthTracker
		{
			private XmlDocument _document;

			public this(XmlDocument doc)
			{
				_document = doc;
				_document.PushDepth();
			}

			~this()
			{
				_document.PopDepth();
			}
		}


		private void PushDepth()
		{
			_parsingDepth++;
			if (_parsingDepth == TINYXML2_MAX_ELEMENT_DEPTH)
			{
				SetError(.XML_ELEMENT_DEPTH_EXCEEDED, _parseCurLineNum, "Element nesting is too deep.");
			}
		}

		private void PopDepth()
		{
		 	--_parsingDepth;
		}
	}
}

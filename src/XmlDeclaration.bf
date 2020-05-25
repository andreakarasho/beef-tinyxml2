namespace tinyxml2
{
	/** In correct XML the declaration is the first entry in the file.
		@verbatim
			<?xml version="1.0" standalone="yes"?>
		@endverbatim
		TinyXML-2 will happily read or write files without a declaration,
		however.
		The text of the declaration isn't interpreted. It is parsed
		and written as a string.
	*/
	class XmlDeclaration : XmlNode
	{
		public this(XmlDocument doc) : base(doc)
		{

		}


		public override XmlDeclaration ToDeclaration() => this;

		public override bool Accept(XmlVisitor visitor)
		{
			return visitor.Visit(this);
		}

		public override XmlNode ShallowClone(XmlDocument document)
		{
			var doc = document;
			if (doc == null)
			{
				doc = _document;
			}

			XmlDeclaration dec = doc.NewDeclaration(Value());
			return dec;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			let dec = compare.ToDeclaration();
			return dec != null && XMLUtil.StringEqual(dec.Value(), Value());
		}

		protected override char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			var p = _value.ParseText(pp, "?>", (.) TIXML2_ACTION.NEEDS_NEWLINE_NORMALIZATION, curLineNumPtr);
			if (p == null)
			{
				_document.SetError(.XML_ERROR_PARSING_DECLARATION, _parseLineNum, null);
			}

			return p;
		}


	}
}

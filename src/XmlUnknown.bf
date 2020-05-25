namespace tinyxml2
{
	/** Any tag that TinyXML-2 doesn't recognize is saved as an
		unknown. It is a tag of text, but should not be modified.
		It will be written back to the XML, unchanged, when the file
		is saved.
		DTD tags get thrown into XMLUnknowns.
	*/
	class XmlUnknown : XmlNode
	{
		public this(XmlDocument doc) : base(doc)
		{

		}

		public override XmlUnknown ToUnknown() => this;

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

			XmlUnknown unk = doc.NewUnknown(Value());
			return unk;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			let unk = compare.ToUnknown();
			return unk != null && XMLUtil.StringEqual(unk.Value(), Value());
		}

		protected override char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			var p = _value.ParseText(pp, ">", (.) TIXML2_ACTION.NEEDS_NEWLINE_NORMALIZATION, curLineNumPtr);
			if (p == null)
			{
				_document.SetError(.XML_ERROR_PARSING_UNKNOWN, _parseLineNum, null);
			}

			return p;
		}
	}
}

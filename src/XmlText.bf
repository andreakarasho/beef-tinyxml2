namespace tinyxml2
{
	/** XML text.
		Note that a text node can have child element nodes, for example:
		@verbatim
		<root>This is <b>bold</b></root>
		@endverbatim
		A text node can have 2 ways to output the next. "normal" output
		and CDATA. It will default to the mode it was parsed from the XML file and
		you generally want to leave it alone, but you can change the output mode with
		SetCData() and query it with CData().
	*/
	class XmlText : XmlNode
	{
		private bool _isCData;

		public this(XmlDocument doc) : base(doc)
		{
			_isCData = false;
		}




		public override bool Accept(XmlVisitor visitor)
		{
			return visitor.Visit(this);
		}

		public override XmlText ToText() => this;


		public void SetCData(bool isCData)
		{
			_isCData = isCData;
		}

		public bool CData() => _isCData;

		public override XmlNode ShallowClone(XmlDocument document)
		{
			var doc = document;

			if (doc == null)
			{
				doc = _document;
			}

			XmlText text = doc.NewText(Value());
			text.SetCData(CData());

			return text;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			let text = compare.ToText();

			return text != null && XMLUtil.StringEqual(text.Value(), Value());
		}



		protected override char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			var p = pp;

			if (CData())
			{
				p = _value.ParseText(p, "]]>", (.) TIXML2_ACTION.NEEDS_NEWLINE_NORMALIZATION, curLineNumPtr);
				if (p == null)
				{
					_document.SetError(.XML_ERROR_PARSING_CDATA, _parseLineNum, null);
				}

				return p;
			}
			else
			{
				var flags = _document.ProcessEntities() ? TIXML2_ACTION.TEXT_ELEMENT : TIXML2_ACTION.TEXT_ELEMENT_LEAVE_ENTITIES;

				if (_document.WhitespaceMode() == .COLLAPSE_WHITESPACE)
				{
					flags |= .NEEDS_WHITESPACE_COLLAPSING;
				}

				p = _value.ParseText(p, "<", (.) flags, curLineNumPtr);
				if (p != null && *p != 0)
				{
					return p - 1;
				}

				if (p == null)
				{
					_document.SetError(.XML_ERROR_PARSING_TEXT, _parseLineNum, null);
				}
			}

			return null;
		}
	}
}

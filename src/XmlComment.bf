namespace tinyxml2
{
	/** An XML Comment. */
	class XmlComment : XmlNode
	{
		public this(XmlDocument doc) : base(doc)
		{

		}


		public override XmlComment ToComment() => this;

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

			XmlComment comment = doc.NewComment(Value());
			return comment;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			let comment = compare.ToComment();
			return comment != null && XMLUtil.StringEqual(comment.Value(), Value());
		}

		protected override char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			var p = _value.ParseText(pp, "-->", (.) TIXML2_ACTION.COMMENT, curLineNumPtr);
			if (p == null)
			{
				_document.SetError(.XML_ERROR_PARSING_COMMENT, _parseLineNum, null);
			}	

			return p;
		}


	}
}

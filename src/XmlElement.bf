using System;

namespace tinyxml2
{
	/** The element is a container class. It has a value, the element name,
		and can contain other elements, text, comments, and unknowns.
		Elements also contain an arbitrary number of attributes.
	*/
	class XmlElement : XmlNode
	{
		private XmlAttribute _rootAttribute;
		private ElementClosingType _closingtype;


		public this(XmlDocument doc) : base(doc)
		{
			_closingtype = .OPEN;
			_rootAttribute = null;
		}

		private ~this()
		{
			while (_rootAttribute != null)
			{
				let next = _rootAttribute.[Friend]_next;
				DeleteAttribute(_rootAttribute);
				_rootAttribute = next;
			}
		}



		public char8* Name() => Value();

		public void SetName(char8* str, bool staticMem = false)
		{
			SetValue(str, staticMem);
		}

		public override XmlElement ToElement() => this;

		public override bool Accept(XmlVisitor visitor)
		{
			if (visitor.VisitEnter(this, _rootAttribute))
			{
				for (var node = FirstChild(); node != null; node = node.NextSibling())
				{
					if (!node.Accept(visitor))
						break;
				}
			}
			return visitor.VisitExit(this);
		}


		/** Given an attribute name, Attribute() returns the value
			for the attribute of that name, or null if none
			exists. For example:
			@verbatim
			const char* value = ele->Attribute( "foo" );
			@endverbatim
			The 'value' parameter is normally null. However, if specified,
			the attribute will only be returned if the 'name' and 'value'
			match. This allow you to write code:
			@verbatim
			if ( ele->Attribute( "foo", "bar" ) ) callFooIsBar();
			@endverbatim
			rather than:
			@verbatim
			if ( ele->Attribute( "foo" ) ) {
				if ( strcmp( ele->Attribute( "foo" ), "bar" ) == 0 ) callFooIsBar();
			}
			@endverbatim
		*/
		public char8* Attribute(char8* name, char8* value = null)
		{
			let a = FindAttribute(name);
			if (a == null)
				return null;

			if (value == null || XMLUtil.StringEqual(a.Value(), value))
			{
				return a.Value();
			}

			return null;
		}

		/** Given an attribute name, IntAttribute() returns the value
			of the attribute interpreted as an integer. The default
		    value will be returned if the attribute isn't present,
		    or if there is an error. (For a method with error
			checking, see QueryIntAttribute()).
		*/
		public int IntAttribute(char8* name, int defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryIntAttribute(name, ref i);
			return i;
		}

		public uint UnsignedAttribute(char8* name, uint defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryUnsignedAttribute(name, ref i);
			return i;
		}

		public int64 Int64Attribute(char8* name, int64 defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryInt64Attribute(name, ref i);
			return i;
		}

		public uint64 Int64Attribute(char8* name, uint64 defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryUnsigned64Attribute(name, ref i);
			return i;
		}

		public bool BoolAttribute(char8* name, bool defaultvalue = false)
		{
			var i = defaultvalue;
			QueryBoolAttribute(name, ref i);
			return i;
		}

		public double DoubleAttribute(char8* name, double defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryDoubleAttribute(name, ref i);
			return i;
		}

		public float FloatAttribute(char8* name, float defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryFloatAttribute(name, ref i);
			return i;
		}


		/** Given an attribute name, QueryIntAttribute() returns
			XML_SUCCESS, XML_WRONG_ATTRIBUTE_TYPE if the conversion
			can't be performed, or XML_NO_ATTRIBUTE if the attribute
			doesn't exist. If successful, the result of the conversion
			will be written to 'value'. If not successful, nothing will
			be written to 'value'. This allows you to provide default
			value:
			@verbatim
			int value = 10;
			QueryIntAttribute( "foo", &value );		// if "foo" isn't found, value will still be 10
			@endverbatim
		*/

		public XmlError QueryIntAttribute(char8* name, ref int value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryIntValue(ref value);
		}

		public XmlError QueryUnsignedAttribute(char8* name, ref uint value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryUnsignedValue(ref value);
		}

		public XmlError QueryInt64Attribute(char8* name, ref int64 value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryInt64Value(ref value);
		}

		public XmlError QueryUnsigned64Attribute(char8* name, ref uint64 value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryUnsigned64Value(ref value);
		}

		public XmlError QueryBoolAttribute(char8* name, ref bool value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryBoolValue(ref value);
		}

		public XmlError QueryDoubleAttribute(char8* name, ref double value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryDoubleValue(ref value);
		}

		public XmlError QueryFloatAttribute(char8* name, ref float value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			return a.QueryFloatValue(ref value);
		}

		public XmlError QueryStringAttribute(char8* name, ref char8* value)
		{
			XmlAttribute a = FindAttribute(name);
			if (a != null)
				return .XML_NO_ATTRIBUTE;

			value = a.Value();

			return .XML_SUCCESS;
		}






		public void SetAttribute(char8* name, char8* value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, int value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, uint value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, int64 value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, uint64 value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, bool value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, double value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}

		public void SetAttribute(char8* name, float value)
		{
			XmlAttribute a = FindOrCreateAttribute(name);
			a.SetAttribute(value);
		}






		/**
			Delete an attribute.
		*/
		public void DeleteAttribute(char8* name)
		{
			XmlAttribute prev = null;

			for (var a = _rootAttribute; a != null; a = a.[Friend]_next)
			{
				if (XMLUtil.StringEqual(name, a.Name()))
				{
					if (prev != null)
					{
						prev = prev.[Friend]_next;
					}
					else
					{
						_rootAttribute = a.[Friend]_next;
					}

					DeleteAttribute(a);
					break;
				}

				prev = a;
			}
		}

		[Inline]
		public XmlAttribute FirstAttribute() => _rootAttribute;


		/** Convenience function for easy access to the text inside an element. Although easy
			and concise, GetText() is limited compared to getting the XMLText child
			and accessing it directly.
			If the first child of 'this' is a XMLText, the GetText()
			returns the character string of the Text node, else null is returned.
			This is a convenient method for getting the text of simple contained text:
			@verbatim
			<foo>This is text</foo>
				const char* str = fooElement->GetText();
			@endverbatim
			'str' will be a pointer to "This is text".
			Note that this function can be misleading. If the element foo was created from
			this XML:
			@verbatim
				<foo><b>This is text</b></foo>
			@endverbatim
			then the value of str would be null. The first child node isn't a text node, it is
			another element. From this XML:
			@verbatim
				<foo>This is <b>text</b></foo>
			@endverbatim
			GetText() will return "This is ".
		*/
		public char8* GetText()
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				return FirstChild().Value();
			}

			return null;
		}

		/** Convenience function for easy access to the text inside an element. Although easy
			and concise, SetText() is limited compared to creating an XMLText child
			and mutating it directly.
			If the first child of 'this' is a XMLText, SetText() sets its value to
			the given string, otherwise it will create a first child that is an XMLText.
			This is a convenient method for setting the text of simple contained text:
			@verbatim
			<foo>This is text</foo>
				fooElement->SetText( "Hullaballoo!" );
		 	<foo>Hullaballoo!</foo>
			@endverbatim
			Note that this function can be misleading. If the element foo was created from
			this XML:
			@verbatim
				<foo><b>This is text</b></foo>
			@endverbatim
			then it will not change "This is text", but rather prefix it with a text element:
			@verbatim
				<foo>Hullaballoo!<b>This is text</b></foo>
			@endverbatim
			For this XML:
			@verbatim
				<foo />
			@endverbatim
			SetText() will generate
			@verbatim
				<foo>Hullaballoo!</foo>
			@endverbatim
		*/
		public void SetText(char8* inText)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				FirstChild().SetValue(inText);
			}
			else
			{
				XmlText text =GetDocument().NewText(inText);
				InsertFirstChild(text);
			}
		}

		public void SetText(int vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(uint vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(int64 vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(uint64 vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(bool vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(double vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}

		public void SetText(float vvalue)
		{
			String str = scope String(BUFF_SIZE);
			vvalue.ToString(str);
			SetText(str);
		}




		/**
			Convenience method to query the value of a child text node. This is probably best
			shown by example. Given you have a document is this form:
			@verbatim
				<point>
					<x>1</x>
					<y>1.4</y>
				</point>
			@endverbatim
			The QueryIntText() and similar functions provide a safe and easier way to get to the
			"value" of x and y.
			@verbatim
				int x = 0;
				float y = 0;	// types of x and y are contrived for example
				const XMLElement* xElement = pointElement->FirstChildElement( "x" );
				const XMLElement* yElement = pointElement->FirstChildElement( "y" );
				xElement->QueryIntText( &x );
				yElement->QueryFloatText( &y );
			@endverbatim
			@returns XML_SUCCESS (0) on success, XML_CAN_NOT_CONVERT_TEXT if the text cannot be converted
					 to the requested type, and XML_NO_TEXT_NODE if there is no child text to query.
		*/
		public XmlError QueryIntText(ref int v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (int.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryUnsignedText(ref uint v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (uint.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryInt64Text(ref int64 v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (int64.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryUnsigned64Text(ref uint64 v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (uint64.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryBoolText(ref bool v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (t)
				{
				case "True":
				case "TRUE":
				case "true":
					v = true;
					return .XML_SUCCESS;

				case "False":
				case "FALSE":
				case "false":
					v = false;
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryDoubleText(ref double v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (Double.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}

		public XmlError QueryFloatText(ref float v)
		{
			if (FirstChild() != null && FirstChild().ToText() != null)
			{
				let t = FirstChild().Value();

				switch (Float.Parse(StringView(t)))
				{
				case .Ok(v):
					return .XML_SUCCESS;

				default:
					return .XML_CAN_NOT_CONVERT_TEXT;
				}
			}

			return .XML_NO_TEXT_NODE;
		}




		public int IntText(int defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryIntText(ref i);
			return i;
		}

		public uint UnsignedText(uint defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryUnsignedText(ref i);
			return i;
		}

		public int64 Int64Text(int64 defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryInt64Text(ref i);
			return i;
		}

		public uint64 Unsigned64Text(uint64 defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryUnsigned64Text(ref i);
			return i;
		}

		public bool BoolText(bool defaultvalue = false)
		{
			var i = defaultvalue;
			QueryBoolText(ref i);
			return i;
		}

		public double DoubleText(double defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryDoubleText(ref i);
			return i;
		}

		public float FloatText(float defaultvalue = 0)
		{
			var i = defaultvalue;
			QueryFloatText(ref i);
			return i;
		}


		/**
		    Convenience method to create a new XMLElement and add it as last (right)
		    child of this node. Returns the created and inserted element.
		*/
		public XmlElement InsertNewChildElement(char8* name)
		{
			XmlElement node = _document.NewElement(name);
			return InsertEndChild(node) != null ? node : null;
		}

		public XmlComment InsertNewComment(char8* comment)
		{
			XmlComment node = _document.NewComment(comment);
			return InsertEndChild(node) != null ? node : null;
		}

		public XmlText InsertNewText(char8* text)
		{
			XmlText node = _document.NewText(text);
			return InsertEndChild(node) != null ? node : null;
		}

		public XmlDeclaration InsertNewDeclaration(char8* text)
		{
			XmlDeclaration node = _document.NewDeclaration(text);
			return InsertEndChild(node) != null ? node : null;
		}

		public XmlUnknown InsertNewUnknown(char8* text)
		{
			XmlUnknown node = _document.NewUnknown(text);
			return InsertEndChild(node) != null ? node : null;
		}



		[Inline]
		public ElementClosingType ClosingType() => _closingtype;



		public override XmlNode ShallowClone(XmlDocument document)
		{
			var doc = document;

			if (doc == null)
			{
				doc = _document;
			}

			XmlElement element = doc.NewElement(Value());

			for (var a = FirstAttribute(); a != null; a = a.Next())
			{
				element.SetAttribute(a.Name(), a.Value());
			}

			return element;
		}

		public override bool ShallowEqual(XmlNode compare)
		{
			let other = compare.ToElement();

			if (other != null && XMLUtil.StringEqual(other.Name(), Name()))
			{
				var a = FirstAttribute();
				var b = other.FirstAttribute();

				while (a != null && b != null)
				{
					if (!XMLUtil.StringEqual(a.Value(), b.Value()))
					{
						return false;
					}

					a = a.Next();
					b = b.Next();
				}

				if (a != null || b != null)
				{
					return false;
				}

				return true;
			}

			return false;
		}

		protected override char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			var p = pp;

			XMLUtil.SkipWhiteSpace(ref p, curLineNumPtr);

			if (*p == '/')
			{
				_closingtype = .CLOSING;
				++p;
			}

			p = _value.ParseName(p);
			if (_value.Empty())
			{
				return null;
			}

			p = ParseAttributes(p, curLineNumPtr);

			if (p == null || *p == 0 || _closingtype != .OPEN)
			{
				return p;
			}

			p = base.ParseDeep(p, parentEndTag, curLineNumPtr);

			return p;
		}




		public XmlAttribute FindAttribute(char8* name)
		{
			for (var a = _rootAttribute; a != null; a = a.[Friend]_next)
			{
				if (XMLUtil.StringEqual(a.Name(), name))
					return a;
			}

			return null;
		}




		private XmlAttribute FindOrCreateAttribute(char8* name)
		{
			XmlAttribute last = null;
			XmlAttribute attrib = null;

			for (attrib = _rootAttribute; attrib != null; last = attrib, attrib = attrib.[Friend]_next)
			{
				if (XMLUtil.StringEqual(attrib.Name(), name))
					break;
			}

			if (attrib == null)
			{
				attrib = CreateAttribute();

				if (last != null)
				{
					last.[Friend]_next = attrib;
				}
				else
				{
					_rootAttribute = attrib;
				}

				attrib.SetName(name);
			}

			return attrib;
		}

		private char8* ParseAttributes(char8* pp, int* curLineNumPtr)
		{
			XmlAttribute prevAttribute = null;
			var p = pp;

			while (p != null)
			{
				XMLUtil.SkipWhiteSpace(ref p, curLineNumPtr);

				if (*p == 0)
				{
					_document.SetError(.XML_ERROR_PARSING_ELEMENT, _parseLineNum, "XmlElement name= {}", Name());
					return null;
				}


				if (XMLUtil.IsNameStartChar((.) *p))
				{
					XmlAttribute attrib = CreateAttribute();

					attrib.[Friend]_parseLinNum = _document.[Friend]_parseCurLineNum;

					let attrLineNum = attrib.[Friend]_parseLinNum;

					p = attrib.ParseDeep(p, _document.ProcessEntities(), curLineNumPtr);
					if (p == null || Attribute(attrib.Name()) != null)
					{
						DeleteAttribute(attrib);
						_document.SetError(.XML_ERROR_PARSING_ATTRIBUTE, attrLineNum, "XmlElement name = {}", Name());
						return null;
					}

					if (prevAttribute != null)
					{
						prevAttribute.[Friend]_next = attrib;
					}
					else
					{
						_rootAttribute = attrib;
					}

					prevAttribute = attrib;
				}
				else if (*p == '>')
				{
					++p;
					break;
				}
				else if (*p == '/' && *(p + 1) == '>')
				{
					_closingtype = .CLOSED;
					return p + 2;
				}
				else
				{
					_document.SetError(.XML_ERROR_PARSING_ELEMENT, _parseLineNum, null);
					return null;
				}
			}

			return p;
		}

		private static void DeleteAttribute(XmlAttribute attribute)
		{
			if (attribute == null)
				return;

			delete attribute;
		}

		private XmlAttribute CreateAttribute()
		{
			XmlAttribute attrib = new XmlAttribute();
			return attrib;
		}
	}
}

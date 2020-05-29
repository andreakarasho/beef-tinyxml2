using System;

namespace tinyxml2
{
	/** An attribute is a name-value pair. Elements have an arbitrary
		number of attributes, each with a unique name.
		@note The attributes are not XMLNodes. You may only query the
		Next() attribute in a list.
	*/
	sealed class XmlAttribute
	{
		private StrPair _name~ delete _;
		private StrPair _value ~ delete _;
		private int _parseLinNum;
		private XmlAttribute _next;

		public this()
		{
			_name = new StrPair();
			_value = new StrPair();
			_parseLinNum = 0;
			_next = null;
		}


		[Inline]
		public char8* Name()
		{
			return _name.GetStr();
		}

		[Inline]
		public void SetName(char8* n)
		{
			_name.SetStr(n);
		}

		[Inline]
		public char8* Value()
		{
			return _value.GetStr();
		}

		[Inline]
		public int GetLineNum() => _parseLinNum;

		[Inline]
		public XmlAttribute Next() => _next;


		public int IntValue()
		{
			int i = 0;
			QueryIntValue(ref i);
			return i;
		}

		public int64 Int64Value()
		{
			int64 i = 0;
			QueryInt64Value(ref i);
			return i;
		}

		public uint64 Unsigned64Value()
		{
			uint64 i = 0;
			QueryUnsigned64Value(ref i);
			return i;
		}

		public uint UnsignedValue()
		{
			uint i = 0;
			QueryUnsignedValue(ref i);
			return i;
		}

		public bool BoolValue()
		{
			bool b = false;
			QueryBoolValue(ref b);
			return b;
		}

		public double DoubleValue()
		{
			double d = 0;
			QueryDoubleValue(ref d);
			return d;
		}

		public float FloatValue()
		{
			float f = 0;
			QueryFloatValue(ref f);
			return f;
		}


		public XmlError QueryIntValue(ref int v)
		{
			switch (int.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public XmlError QueryUnsignedValue(ref uint v)
		{
			switch (uint.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public XmlError QueryInt64Value(ref int64 v)
		{
			switch (int64.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public XmlError QueryUnsigned64Value(ref uint64 v)
		{
			switch (uint64.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public XmlError QueryBoolValue(ref bool v)
		{
			switch (Value())
			{
			case "True":
				fallthrough;
			case "TRUE":
				fallthrough;
			case "true":
				v = true;
				return .XML_SUCCESS;

			case "False":
				fallthrough;
			case "FALSE":
				fallthrough;
			case "false":
				v = false;
				return .XML_SUCCESS;
			}

			v = false;
			return .XML_WRONG_ATTRIBUTE_TYPE;
		}

		public XmlError QueryDoubleValue(ref double v)
		{
			switch (Double.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public XmlError QueryFloatValue(ref float v)
		{
			switch (Float.Parse(StringView(Value())))
			{
			case .Ok(v):
				return .XML_SUCCESS;
			default:
				return .XML_WRONG_ATTRIBUTE_TYPE;
			}
		}

		public void SetAttribute(char8* value)
		{
			_value.SetStr(value);
		}

		public void SetAttribute(int value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(uint value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(uint64 value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(int64 value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(bool value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(double value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}

		public void SetAttribute(float value)
		{
			String str = scope String(BUFF_SIZE);
			value.ToString(str);
			_value.SetStr(str);
		}



		public char8* ParseDeep(char8* pp, bool processEntities, int* curLineNumPtr)
		{
			var p = _name.ParseName(pp);
			if (p == null || *p == 0)
			{
				return null;
			}

			XMLUtil.SkipWhiteSpace(ref p, curLineNumPtr);

			if (*p != '=')
				return null;

			++p;

			XMLUtil.SkipWhiteSpace(ref p, curLineNumPtr);

			if (*p != '\"' && *p != '\'')
			{
				return null;
			}

			char8[2] endTag = .(*p, 0);
			++p;

			p = _value.ParseText(p, &endTag, processEntities ? (.) TIXML2_ACTION.ATTRIBUTE_VALUE : (.) TIXML2_ACTION.ATTRIBUTE_VALUE_LEAVE_ENTITIES, curLineNumPtr);

			return p;
		}
	}
}

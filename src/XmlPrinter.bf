using System;
using System.IO;
using System.Collections;

namespace tinyxml2
{
	class XmlPrinter : XmlVisitor
	{
		private const int ENTITY_RANGE = 64;
		private const int BUF_SIZE = 200;

		protected bool _elementJustOpened;
		private bool _firstElement;
		private Stream _fp;
		private int _depth;
		private int _textDepth;
		private bool _processEntities;
		private bool _compactMode;
		private bool[ENTITY_RANGE] _entitiyFlag = .(false,);
		private bool[ENTITY_RANGE] _restrictedEntityFlag = .(false,);
		private List<char8*> _stack = new List<char8*>() ~ delete _;
		private List<char8*> _buffer = new List<char8*>() ~ delete _;

		public this(Stream stream = null, bool compact = false, int depth = 0)
		{
			_elementJustOpened = false;
			_firstElement = true;
			_fp = stream;
			_depth = depth;
			_textDepth = -1;
			_processEntities = true;
			_compactMode = compact;


			for (var i < NUM_ENTITIES)
			{
				let entityValue = entities[i].value;

				_entitiyFlag[entityValue] = true;
			}

			_restrictedEntityFlag[(int) '&'] = true;
			_restrictedEntityFlag[(int) '<'] = true;
			_restrictedEntityFlag[(int) '>'] = true;

			_buffer.Add(null);
		}



		public void PushHeader(bool writeBOM, bool writeDeclaration)
		{
			if (writeBOM)
			{
				char8[] bom = scope char8[4];
				bom[0] = (char8) TIXML_UTF_LEAD_0;
				bom[1] = (char8) TIXML_UTF_LEAD_1;
				bom[2] = (char8) TIXML_UTF_LEAD_2;
				bom[3] = 0;

				Write(&bom[0]);
			}

			if (writeDeclaration)
			{
				PushDeclaration("xml version=\"1.0\"");
			}
		}

		public void OpenElement(char8* name, bool compactMode = false)
		{
			SealElementIfJustOpened();
			_stack.Add(name);

			if (_textDepth < 0 && !_firstElement && !compactMode)
			{
				Putc('\n');
				PrintSpace(_depth);
			}

			Write("<");
			Write(name);

			_elementJustOpened = true;
			_firstElement = false;
			++_depth;
		}

		public void PushAttribute(char8* name, char8* value)
		{
			Putc(' ');
			Write(name);
			Write("=\"");
			PrintString(value, false);
			Putc('\"');
		}

		public void PushAttribute(char8* name, int value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, uint value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, int64 value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, uint64 value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, bool value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, double value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public void PushAttribute(char8* name, float value)
		{
			String s = scope .();
			value.ToString(s);
			PushAttribute(name, s);
		}

		public virtual void CloseElement(bool combactMode = false)
		{
		 	--_depth;

			var name = _stack.PopBack();

			if (_elementJustOpened)
			{
				Write("/>");
			}
			else
			{
				if (_textDepth < 0 && !combactMode)
				{
					Putc('\n');
					PrintSpace(_depth);
				}

				Write("</");
				Write(name);
				Write(">");
			}

			if (_textDepth == _depth)
			{
				_textDepth = -1;
			}

			if (_depth == 0 && !combactMode)
			{
				Putc('\n');
			}

			_elementJustOpened = false;
		}

		public void PushText(char8* text, bool cdata = false)
		{
			_textDepth = _depth - 1;

			SealElementIfJustOpened();

			if (cdata)
			{
				Write("<![CDATA[");
				Write(text);
				Write("]]>");
			}
			else
			{
				PrintString(text, true);
			}
		}

		public void PushText(int value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(uint value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(int64 value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(uint64 value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(bool value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(float value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushText(double value)
		{
			String s = scope .();
			value.ToString(s);
			PushText(s, false);
		}

		public void PushComment(char8* comment)
		{
			SealElementIfJustOpened();

			if (_textDepth < 0 && !_firstElement && !_compactMode)
			{
				Putc('\n');
				PrintSpace(_depth);
			}

			_firstElement = false;

			Write("<!--");
			Write(comment);
			Write("-->");
		}

		public void PushDeclaration(char8* value)
		{
			SealElementIfJustOpened();

			if (_textDepth < 0 && !_firstElement && !_compactMode)
			{
				Putc('\n');
				PrintSpace(_depth);
			}

			_firstElement = false;

			Write("<?");
			Write(value);
			Write("?>");
		}

		public void PushUnknown(char8* value)
		{
			SealElementIfJustOpened();

			if (_textDepth < 0 && !_firstElement && !_compactMode)
			{
				Putc('\n');
				PrintSpace(_depth);
			}

			_firstElement = false;

			Write("<!");
			Write(value);
			Putc('>');
		}

		public override bool VisitEnter(XmlDocument doc)
		{
			_processEntities = doc.ProcessEntities();
			if (doc.HasBOM())
			{
				PushHeader(true, false);
			}
			return true;
		}

		public override bool VisitExit(XmlDocument doc)
		{
			 return true;
		}

		public override bool VisitEnter(XmlElement element, XmlAttribute attribute)
		{
			XmlElement parentElem = null;

			if (element.Parent() != null)
			{
				parentElem = element.Parent().ToElement();
			}

			var attribute1 = attribute;
			var comactmode = parentElem != null ? CompactMode(parentElem) : _compactMode;
			OpenElement(element.Name(), comactmode);

			while (attribute1 != null)
			{
				PushAttribute(attribute1.Name(), attribute1.Value());
				attribute1 = attribute1.Next();
			}

			return true;
		}

		public override bool VisitExit(XmlElement element)
		{
			CloseElement(CompactMode(element));
			return true;
		}

		public override bool Visit(XmlText text)
		{
			PushText(text.Value(), text.CData());
			return true;
		}

		public override bool Visit(XmlComment comment)
		{
			PushComment(comment.Value());
			return true;
		}

		public override bool Visit(XmlDeclaration declaration)
		{
			PushDeclaration(declaration.Value());
			return true;
		}

		public override bool Visit(XmlUnknown unk)
		{
			PushUnknown(unk.Value());
			return true;
		}



		protected virtual bool CompactMode(XmlElement element)
		{
			return _compactMode;
		}

		protected virtual void PrintSpace(int depth)
		{
			for (var i < depth)
			{
				Write("    ");
			}
		}

		protected void Print(char8* format, params Object[] args)
		{
			if (_fp != null)
			{
				_fp.WriteStrUnsized(scope String()..AppendF(StringView(format), args));
			}
			else
			{
				// IDK :D
			}
		}

		protected void Write(char8* data, uint size)
		{
			if (_fp != null)
			{
				for(var i < size)
				{
					_fp.Write((.) data[i]);
				}
			}
			else
			{
				char8* p = _buffer[_buffer.Count - 1] - 1;
				Internal.MemCpy(p, data, (.) size);
				p[size] = 0;
			}
		}

		protected void Write(char8* data)
		{
			Write(data, utilities.strlen(data));
		}

		protected void Putc(char8 c)
		{
			if (_fp != null)
			{
				_fp.Write(c);
			}
			else
			{
				char8* p = _buffer[_buffer.Count - 1] - 1;

				p[0] = c;
				p[1] = 0;
			}
		}

		protected void SealElementIfJustOpened()
		{
			if (!_elementJustOpened)
				return;

			_elementJustOpened = false;
			Putc('>');
		}

		private void PrintString(char8* pp, bool restricted )
		{
			char8* q = pp;
			char8* p = pp;

			if (_processEntities)
			{
				var flag = restricted ? _restrictedEntityFlag : _entitiyFlag;

				while (*q != 0)
				{
					if (*q > 0 && *q < (.) ENTITY_RANGE)
					{
						if (flag[(*q)])
						{
							while (p < q)
							{
								let delta = q - p;
								let toPrint = (Int32.MaxValue < delta) ? Int32.MaxValue : (int) delta;

								Write(p, (uint) toPrint);

								p += toPrint;
							}

							bool entityPatternPrinted = false;

							for(var i < NUM_ENTITIES)
							{
								if (entities[i].value == *q)
								{
									Putc('&');
									Write(entities[i].pattern, (.) entities[i].length);
									Putc(';');
									entityPatternPrinted = true;
									break;
								}
							}

							if (!entityPatternPrinted)
							{

							}

							++p;
						}
					}
					++q;
				}

				if (p < q)
				{
					let delta = q - p;
					let toPrint = (Int32.MaxValue < delta) ? Int32.MaxValue : (int) delta;

					Write(p, (uint) toPrint);
				}	
			}
			else
			{
				Write(p);
			}
		}
	}
}

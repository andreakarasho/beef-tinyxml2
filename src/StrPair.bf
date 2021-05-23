using System;

namespace tinyxml2
{
	[AllowDuplicates]
	public enum TIXML2_ACTION
	{
		NEEDS_ENTITY_PROCESSING = 0x01,
		NEEDS_NEWLINE_NORMALIZATION = 0x02,
		NEEDS_WHITESPACE_COLLAPSING = 0x04,

		TEXT_ELEMENT = NEEDS_ENTITY_PROCESSING | NEEDS_NEWLINE_NORMALIZATION,
		TEXT_ELEMENT_LEAVE_ENTITIES = NEEDS_NEWLINE_NORMALIZATION,
		ATTRIBUTE_NAME = 0,
		ATTRIBUTE_VALUE = NEEDS_ENTITY_PROCESSING | NEEDS_NEWLINE_NORMALIZATION,
		ATTRIBUTE_VALUE_LEAVE_ENTITIES = NEEDS_NEWLINE_NORMALIZATION,
		COMMENT = NEEDS_NEWLINE_NORMALIZATION
	}

	sealed class StrPair
	{
		private const int NEEDS_FLUSH = 0x100;
		private const int NEEDS_DELETE = 0x200;


		private int _flags;
		private char8* _start;
		private char8* _end;


		public this()
		{
			_flags = 0;
			_start = null;
			_end = null;
		}

		public ~this()
		{
			Reset();
		}


		public void Set(char8* start, char8* end, int flags)
		{
			Reset();
			_start = start;
			_end = end;
			_flags = flags | NEEDS_FLUSH;
		}

		public void Reset()
		{
			if ((_flags & NEEDS_DELETE) != 0)
			{
				delete _start;
			}

			_flags = 0;
			_start = null;
			_end = null;
		}

		public char8* GetStr()
		{
			if ((_flags & NEEDS_FLUSH) != 0)
			{
				*_end = 0;
				_flags ^= NEEDS_FLUSH;

				if (_flags != 0)
				{
					var p = _start;
					var q = _start;

					while (p < _end)
					{
						if ((_flags & (.)TIXML2_ACTION.NEEDS_NEWLINE_NORMALIZATION) != 0 && *p == CR)
						{
							if (*(p + 1) == LF)
								p += 2;
							else
								++p;

							*q = LF;
							++q;
						}
						else if ((_flags & (.)TIXML2_ACTION.NEEDS_NEWLINE_NORMALIZATION) != 0 && *p == LF)
						{
							if (*(p + 1) == CR)
								p += 2;
							else
								++p;

							*q = LF;
							++q;
						}
						else if ((_flags & (.)TIXML2_ACTION.NEEDS_ENTITY_PROCESSING) != 0 && *p == '&')
						{
							if (*(p + 1) == '#')
							{
								const int buflen = 10;
								char8[] buf = scope char8[buflen](0,);
								int len = 0;
								char8* adjusted = XMLUtil.GetCharacterRef(p, buf, &len);

								if (adjusted == null)
								{
									*q = *p;
									++p;
									++q;
								}
								else
								{
									p = adjusted;
									Internal.MemCpy(q, &buf, len);
									q += len;
								}
							}
							else
							{
								bool entityFound = false;

								for (var i < NUM_ENTITIES)
								{
									let entity = ref entities[i];

									if (utilities.strncmp(p + 1, entity.pattern, (uint)entity.length) == 0 &&
										*(p + entity.length + 1) == ';')
									{
										*q = entity.value;
										++q;
										p += entity.length + 2;
										entityFound = true;
										break;
									}
								}

								if (!entityFound)
								{
									++p;
									++q;
								}
							}
						}
						else
						{
							*q = *p;
							++p;
							++q;
						}
					}
					*q = 0;
				}

				if ((_flags & (.)TIXML2_ACTION.NEEDS_WHITESPACE_COLLAPSING) != 0)
				{
					CollapseWhitespace();
				}

				_flags = (_flags & NEEDS_DELETE);
			}

			return _start;
		}

		[Inline]
		public bool Empty() => _start == _end;

		public void SetInternedStr(char8* str)
		{
			Reset();
			_start = str;
		}

		public void SetStr(char8* str, int flags = 0)
		{
			// todo: assert

			Reset();
			if (str == null)
			{
				_start = null;
				_end = null;
			}
			else
			{
				uint len = utilities.strlen(str);

				_start = new char8[len + 1]*;
				Internal.MemCpy(&_start[0], &str[0], (int)len + 1);

				_end = _start + len;
			}

			_flags = flags | NEEDS_DELETE;
		}

		public char8* ParseText(char8* pp, char8* endTag, int strFlags, int* curLineNumPtr)
		{
			// todo asserts
			var p = pp;
			char8* start = p;
			let endChar = *endTag;
			uint length = utilities.strlen(endTag);

			while (*p != 0)
			{
				if (*p == endChar && utilities.strncmp(p, endTag, length) == 0)
				{
					Set(start, p, strFlags);
					return p + length;
				}
				else if (*p == '\n')
					++(*curLineNumPtr);

				++p;
			}

			return null;
		}

		public char8* ParseName(char8* p)
		{
			if (p == null || *p == 0)
			{
				return null;
			}

			if (!XMLUtil.IsNameStartChar((.) *p))
				return null;

			let start = p;
			var pp = p;
			++pp;

			while (*pp != 0 && XMLUtil.IsNameChar((.) *pp))
			{
				++pp;
			}

			Set(start, pp, 0);

			return pp;
		}

		public void TransferTo(StrPair other)
		{
			if (this == other)
				return;

			// todo: asserts

			other.Reset();

			other._flags = _flags;
			other._start = _start;
			other._end = _end;


			_flags = 0;
			_start = null;
			_end = null;
		}



		private void CollapseWhitespace()
		{
			XMLUtil.SkipWhiteSpace(ref _start);

			if (*_start != 0)
			{
				var p = _start;
				var q = _start;

				while (*p != 0)
				{
					if (XMLUtil.IsWhiteSpace(*p))
					{
						XMLUtil.SkipWhiteSpace(ref p);

						if (*p == 0)
							break;
					}

					*q = ' ';
					++q;
				}

				*q = 0;
			}
		}
	}
}

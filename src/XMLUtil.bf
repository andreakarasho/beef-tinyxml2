using System;

namespace tinyxml2
{
	static class XMLUtil
	{
		public static readonly char8* writeBoolTrue = "true";
		public static readonly char8* writeBoolFalse = "false";

		public static void SetBoolSerialization(char8* writeTrue, char8* writeFalse)
		{
		}

		public static char8* ReadBOM(char8* p, bool* bom)
		{
			*bom = false;

			let pu = (uint8*)(p);
			var pp = p;

			if (*(pu + 0) == TIXML_UTF_LEAD_0 &&
				*(pu + 1) == TIXML_UTF_LEAD_1 &&
				*(pu + 2) == TIXML_UTF_LEAD_2)
			{
				*bom = true;
				pp += 3;
			}

			return pp;
		}

		public static bool IsNameChar(uint8 p)
		{
			return IsNameStartChar(p)  ||
				   ((Char8) p).IsDigit ||
				   p == '.' ||
				   p == '-';
		}

		public static bool IsNameStartChar(uint8 c)
		{
			if (c >= 128)
				return true;

			if (((Char8) c).IsLetter)
				return true;

			return c == ':' || c == '_';
		}

		public static void SkipWhiteSpace(ref char8* start, int* curLineNumPtr)
		{
			while (IsWhiteSpace(*start))
			{
				if (curLineNumPtr != null && *start == '\n')
				{
					++(*curLineNumPtr);
				}

				++start;
			}
		}

		public static void SkipWhiteSpace(ref char8* start)
		{
			while (IsWhiteSpace(*start))
			{
				++start;
			}
		}

		public static bool IsWhiteSpace(char8 p)
		{
			return !IsUTF8Continuation(p) && utilities.isspace(p);
		}

		public static bool StringEqual(char8* p, char8* q, int nChar = int32.MaxValue)
		{
			if (p == q)
				return true;

			return utilities.strncmp(p, q, (uint) nChar) == 0;
		}

		public static bool IsUTF8Continuation(char8 p) => ((int) p & 0x80) != 0;

		public static char8* GetCharacterRef(char8* p, char8[] buf, int* len)
		{
			*len = 0;

			if (*(p + 1) == '#' && *(p + 2) != 0)
			{
				uint64 ucs = 0;

				uint delta = 0;
				int mult = 1;

				const char8 SEMICOLON = ';';

				if (*(p + 2) == 'x')
				{
					var q = p + 3;

					if (*q == 0)
						return null;

					q = utilities.strchr(q, SEMICOLON);

					if (q == null)
						return null;

					delta = (uint)(q - p);
					--q;

					while (*q != 'x')
					{
						int digit = 0;

						if (*q >= '0' && *q <= '9')
						{
							digit = *q - '0';
						}
						else if (*q >= 'a' && *q <= 'f')
						{
							digit = *q - 'a' + 10;
						}
						else if (*q >= 'A' && *q <= 'F')
						{
							digit = *q - 'A' + 10;
						}
						else
						{
							return null;
						}

						int digitScaled = mult * digit;
						ucs += (uint)digitScaled;
						mult *= 16;
						--q;
					}
				}
				else
				{
					var q = p + 2;

					if (*q == 0)
						return null;

					q = utilities.strchr(q, SEMICOLON);
					if (q == null)
						return null;

					delta = (uint)(q - p);
					--q;

					while (*q != '#')
					{
						if (*q >= '0' && *q <= '9')
						{
							var digit = *q - '0';
							var digitScaled = mult * digit;
							ucs += (uint)digitScaled;
						}
						else
						{
							return null;
						}

						mult *= 10;
						--q;
					}
				}

				return p + delta + 1;
			}

			return p + 1;
		}

		public static void ToStr(int v, char8* buf, int buffSize)
		{
			String s = scope .(buf, buffSize);
		}
	}
}

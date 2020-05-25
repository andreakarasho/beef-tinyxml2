using System;

namespace tinyxml2
{
	static class utilities
	{
		public static uint strlen(char8* str)
		{
			uint len = 0;
			char8* ptr = str;

			while (*ptr++ != 0)
			{
				len++;
			}

			return len;
		}

		public static int strcmp(char8* s1, char8* s2)
		{
			char8* p1 = s1;
			char8* p2 = s2;

			while (*p1 != 0 && *p1 == *p2)
			{
				++p1;
				++p2;
			}

			int i = *p2 - *p1;

			return i < 0 ? -1 : i > 0 ? 1 : 0;
		}

		public static int strncmp(char8* s1, char8* s2, uint n)
		{
			char8* p1 = s1;
			char8* p2 = s2;
			var n1 = n;

			while (n1 != 0 && *p1 != 0 && *p1 == *p2)
			{
				++p1;
				++p2;
				n1--;
			}

			if (n1 == 0)
				return 0;

			int i = *p2 - *p1;

			return i < 0 ? -1 : i > 0 ? 1 : 0;
		}

		public static char8* strchr(char8* str, char8 c)
		{
			var p1 = str;

			while (*p1 != 0)
			{
				if (*p1 == c)
					return p1;

				++p1;
			}

			return null;
		}

		public static bool isspace(char8 c)
		{
			return c == ' '  ||
				   c == '\t' ||
				   c == '\n' ||
				   c == '\v' ||
				   c == '\f' ||
				   c == '\r';
		}
	}
}

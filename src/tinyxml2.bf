using System;



static
{
	public const int TIXML2_MAJOR_VERSION = 8;
	public const int TIXML2_MINOR_VERSION = 0;
	public const int TIXML2_PATCH_VERSION = 0;



	// A fixed element depth limit is problematic. There needs to be a
	// limit to avoid a stack overflow. However, that limit varies per
	// system, and the capacity of the stack. On the other hand, it's a trivial
	// attack that can result from ill, malicious, or even correctly formed XML,
	// so there needs to be a limit in place.
	public const int TINYXML2_MAX_ELEMENT_DEPTH = 100;



	public const char8 LINE_FEED = (char8) 0x0A;
	public const char8 LF = LINE_FEED;
	public const char8 CARRIAGE_RETURN = (char8) 0x0D;
	public const char8 CR = CARRIAGE_RETURN;
	public const char8 SINGLE_QUOTE = '\'';
	public const char8 DOUBLE_QUOTE = '\"';


	// Bunch of unicode info at:
	//		http://www.unicode.org/faq/utf_bom.html
	//	ef bb bf (Microsoft "lead bytes") - designates UTF-8
	public const uint8 TIXML_UTF_LEAD_0 = 0xefU;
	public const uint8 TIXML_UTF_LEAD_1 = 0xbbU;
	public const uint8 TIXML_UTF_LEAD_2 = 0xbfU;

	public const int BUFF_SIZE = 200;
}


namespace tinyxml2
{
	public typealias size_t = uint;

	struct Entity
	{
		public this(char8* patt, int len, char8 val)
		{
			pattern = patt;
			length = len;
			value = val;
		}

		public char8* pattern;
		public int length;
		public char8 value;
	}

	static
	{
		public const int NUM_ENTITIES = 5;
		public static Entity[NUM_ENTITIES] entities = .(
			.("quote", 4, DOUBLE_QUOTE),
			.("amp", 3, '&'),
			.("apos", 4, SINGLE_QUOTE),
			.("lt", 2, '<'),
			.("gt", 2, '>'),
			);



		public const char8* XML_HEADER = "<?";
		public const char8* COMMENT_HEADER = "<!--";
		public const char8* CDATA_HEADER = "<![CDATA[";
		public const char8* DTD_HEADER = "<!";
		public const char8* ELEMENT_HEADER = "<";
		public const int XML_HEADER_LEN = 2;
		public const int COMMENT_HEADER_LEN = 4;
		public const int CDATA_HEADER_LEN = 9;
		public const int DTD_HEADER_LEN = 2;
		public const int ELEMENT_HEADER_LEN = 1;
	}
}

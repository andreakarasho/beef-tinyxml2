namespace tinyxml2
{
	/**
		A XMLHandle is a class that wraps a node pointer with null checks; this is
		an incredibly useful thing. Note that XMLHandle is not part of the TinyXML-2
		DOM structure. It is a separate utility class.
		Take an example:
		@verbatim
		<Document>
			<Element attributeA = "valueA">
				<Child attributeB = "value1" />
				<Child attributeB = "value2" />
			</Element>
		</Document>
		@endverbatim
		Assuming you want the value of "attributeB" in the 2nd "Child" element, it's very
		easy to write a *lot* of code that looks like:
		@verbatim
		XMLElement* root = document.FirstChildElement( "Document" );
		if ( root )
		{
			XMLElement* element = root->FirstChildElement( "Element" );
			if ( element )
			{
				XMLElement* child = element->FirstChildElement( "Child" );
				if ( child )
				{
					XMLElement* child2 = child->NextSiblingElement( "Child" );
					if ( child2 )
					{
						// Finally do something useful.
		@endverbatim
		And that doesn't even cover "else" cases. XMLHandle addresses the verbosity
		of such code. A XMLHandle checks for null pointers so it is perfectly safe
		and correct to use:
		@verbatim
		XMLHandle docHandle( &document );
		XMLElement* child2 = docHandle.FirstChildElement( "Document" ).FirstChildElement( "Element" ).FirstChildElement().NextSiblingElement();
		if ( child2 )
		{
			// do something useful
		@endverbatim
		Which is MUCH more concise and useful.
		It is also safe to copy handles - internally they are nothing more than node pointers.
		@verbatim
		XMLHandle handleCopy = handle;
		@endverbatim
		See also XMLConstHandle, which is the same as XMLHandle, but operates on const objects.
	*/
	class XmlHandle
	{
		private XmlNode _node;

		public this(XmlNode node)
		{
			_node = node;
		}

		

		public XmlHandle FirstChild()
		{
			return new XmlHandle(_node?.FirstChild());
		}

		public XmlHandle FirstChildElement(char8* name = null)
		{
			return new XmlHandle(_node?.FirstChildElement(name));
		}

		public XmlHandle LastChild()
		{
			return new XmlHandle(_node?.LastChild());
		}

		public XmlHandle LastChildElement(char8* name = null)
		{
			return new XmlHandle(_node?.LastChildElement(name));
		}

		public XmlHandle PreviousSibling()
		{
			return new XmlHandle(_node?.PreviousSibling());
		}

		public XmlHandle PreviousSiblingElement(char8* name = null)
		{
			return new XmlHandle(_node?.PreviousSiblingElement(name));
		}

		public XmlHandle NextSibling()
		{
			return new XmlHandle(_node?.NextSibling());
		}

		public XmlHandle NextSiblingElement(char8* name = null)
		{
			return new XmlHandle(_node?.NextSiblingElement(name));
		}

		public XmlNode ToNode() => _node;

		public XmlElement ToElement() => _node?.ToElement();

		public XmlText ToText() => _node?.ToText();

		public XmlUnknown ToUnknown() => _node?.ToUnknown();

		public XmlDeclaration ToDeclaration() => _node?.ToDeclaration();
	}


	/**
		A variant of the XMLHandle class for working with const XMLNodes and Documents. It is the
		same in all regards, except for the 'const' qualifiers. See XMLHandle for API.
	*/
	class XmlConstHandle : XmlHandle
	{
		public this(XmlNode node) : base(node)
		{

		}
	}
}

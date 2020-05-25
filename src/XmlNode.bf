using System;

namespace tinyxml2
{
	/** XMLNode is a base class for every object that is in the
		XML Document Object Model (DOM), except XMLAttributes.
		Nodes have siblings, a parent, and children which can
		be navigated. A node is always in a XMLDocument.
		The type of a XMLNode can be queried, and it can
		be cast to its more defined type.
		A XMLDocument allocates memory for all its Nodes.
		When the XMLDocument gets deleted, all its Nodes
		will also be deleted.
		@verbatim
		A Document can contain:	Element	(container or leaf)
								Comment (leaf)
								Unknown (leaf)
								Declaration( leaf )
		An Element can contain:	Element (container or leaf)
								Text	(leaf)
								Attributes (not on tree)
								Comment (leaf)
								Unknown (leaf)
		@endverbatim
	*/

	abstract class XmlNode
	{
		protected XmlDocument _document;
		protected int _parseLineNum;
		protected XmlNode _parent, _firstChild, _lastChild, _prev, _next;
		protected void* _userData;
		protected StrPair _value ~ delete _;



		public this(XmlDocument doc)
		{
			_document = doc;
			_parent = null;
			_value = new StrPair();
			_parseLineNum = 0;
			_firstChild = null;
			_lastChild = null;
			_userData = null;
		}

		~this()
		{
			DeleteChildren();
			if (_parent != null)
			{
				_parent.Unlink(this);
			}
		}



		[Inline]
		public XmlDocument GetDocument() => _document;

		public virtual XmlElement ToElement()
		{
			return null;
		}

		public virtual XmlText ToText()
		{
			return null;
		}

		public virtual XmlComment ToComment()
		{
			return null;
		}

		public virtual XmlDocument ToDocument()
		{
			return null;
		}

		public virtual XmlDeclaration ToDeclaration()
		{
			return null;
		}

		public virtual XmlUnknown ToUnknown()
		{
			return null;
		}


		/** The meaning of 'value' changes for the specific type.
			@verbatim
			Document:	empty (NULL is returned, not an empty string)
			Element:	name of the element
			Comment:	the comment text
			Unknown:	the tag contents
			Text:		the text string
			@endverbatim
		*/
		[Inline]
		public char8* Value()
		{
			if (ToDocument() != null)
				return null;

			return _value.GetStr();
		}

		public void SetValue(char8* str, bool static_mem = false)
		{
			if (static_mem)
				_value.SetInternedStr(str);
			else
				_value.SetStr(str);
		}

		[Inline]
		public int GetLineNum() => _parseLineNum;

		[Inline]
		public XmlNode Parent() => _parent;

		[Inline]
		public bool NoChildren() => _firstChild == null;

		[Inline]
		public XmlNode FirstChild() => _firstChild;

		public XmlElement FirstChildElement(char8* name = null)
		{
			for (var node = _firstChild; node != null; node = node._next)
			{
				let element = node.ToElementWidthName(name);
				if (element != null)
					return element;
			}

			return null;
		}

		[Inline]
		public XmlNode LastChild() => _lastChild;

		public XmlElement LastChildElement(char8* name = null)
		{
			for (var node = _lastChild; node != null; node = node._prev)
			{
				let element = node.ToElementWidthName(name);
				if (element != null)
					return element;
			}

			return null;
		}

		[Inline]
		public XmlNode PreviousSibling() => _prev;

		public XmlElement PreviousSiblingElement(char8* name = null)
		{
			for (var node = _prev; node != null; node = node._prev)
			{
				let element = node.ToElementWidthName(name);
				if (element != null)
					return element;
			}

			return null;
		}

		[Inline]
		public XmlNode NextSibling() => _next;

		public XmlElement NextSiblingElement(char8* name = null)
		{
			for (var node = _next; node != null; node = node._next)
			{
				let element = node.ToElementWidthName(name);
				if (element != null)
					return element;
			}

			return null;
		}

		/**
			Add a child node as the last (right) child.
			If the child node is already part of the document,
			it is moved from its old location to the new location.
			Returns the addThis argument or 0 if the node does not
			belong to the same document.
		*/
		public XmlNode InsertEndChild(XmlNode addThis)
		{
			if (addThis._document != _document)
			{
				return null;
			}

			InsertChildPreamble(addThis);

			if (_lastChild != null)
			{
				_lastChild._next = addThis;
				addThis._prev = _lastChild;
				_lastChild = addThis;

				addThis._next = null;
			}
			else
			{
				_firstChild = _lastChild = addThis;

				addThis._prev = null;
				addThis._next = null;
			}

			addThis._parent = this;

			return addThis;
		}

		public XmlNode LinkEndChild(XmlNode addThis)
		{
			return InsertEndChild(addThis);
		}


		/**
			Add a child node as the first (left) child.
			If the child node is already part of the document,
			it is moved from its old location to the new location.
			Returns the addThis argument or 0 if the node does not
			belong to the same document.
		*/
		public XmlNode InsertFirstChild(XmlNode addThis)
		{
			if (addThis._document != _document)
			{
				return null;
			}

			InsertChildPreamble(addThis);

			if (_firstChild != null)
			{
				_firstChild._prev = addThis;
				addThis._next = _firstChild;
				_firstChild = addThis;

				addThis._prev = null;
			}
			else
			{
				_firstChild = _lastChild = addThis;

				addThis._prev = null;
				addThis._next = null;
			}

			addThis._parent = this;

			return addThis;
		}


		/**
			Add a node after the specified child node.
			If the child node is already part of the document,
			it is moved from its old location to the new location.
			Returns the addThis argument or 0 if the afterThis node
			is not a child of this node, or if the node does not
			belong to the same document.
		*/
		public XmlNode InsertAfterChild(XmlNode afterThis, XmlNode addThis)
		{
			if (addThis._document != _document)
			{
				return null;
			}

			if (afterThis._parent != this)
			{
				return null;
			}


			if (addThis == addThis)
			{
				return addThis;
			}


			if (afterThis._next == null)
			{
				return InsertEndChild(addThis);
			}

			InsertChildPreamble(addThis);

			addThis._prev = afterThis;
			addThis._next = afterThis._next;
			afterThis._next._prev = addThis;
			afterThis._next = addThis;
			addThis._parent = this;

			return addThis;
		}


		/**
			Delete all the children of this node.
		*/
		public void DeleteChildren()
		{
			while (_firstChild != null)
			{
				DeleteChild(_firstChild);
			}

			_firstChild = _lastChild = null;
		}

		/**
			Delete a child of this node.
		*/
		public void DeleteChild(XmlNode node)
		{
			Unlink(node);
			DeleteNode(node);
		}


		/**
			Make a copy of this node, but not its children.
			You may pass in a Document pointer that will be
			the owner of the new Node. If the 'document' is
			null, then the node returned will be allocated
			from the current Document. (this->GetDocument())
			Note: if called on a XMLDocument, this will return null.
		*/
		public virtual XmlNode ShallowClone(XmlDocument document)
		{
			return null;
		}


		/**
			Make a copy of this node and all its children.
			If the 'target' is null, then the nodes will
			be allocated in the current document. If 'target'
		    is specified, the memory will be allocated is the
		    specified XMLDocument.
			NOTE: This is probably not the correct tool to
			copy a document, since XMLDocuments can have multiple
			top level XMLNodes. You probably want to use
		    XMLDocument::DeepCopy()
		*/
		public XmlNode DeepClone(XmlDocument target)
		{
			XmlNode clone = ShallowClone(target);
			if (clone == null)
				return null;

			for (var child = FirstChild(); child != null; child = child.NextSibling())
			{
				var childClone = child.DeepClone(target);
				clone.InsertEndChild(childClone);
			}

			return clone;
		}


		/**
			Test if 2 nodes are the same, but don't test children.
			The 2 nodes do not need to be in the same Document.
			Note: if called on a XMLDocument, this will return false.
		*/
		public virtual bool ShallowEqual(XmlNode compare)
		{
			return false;
		}


		/** Accept a hierarchical visit of the nodes in the TinyXML-2 DOM. Every node in the
			XML tree will be conditionally visited and the host will be called back
			via the XMLVisitor interface.
			This is essentially a SAX interface for TinyXML-2. (Note however it doesn't re-parse
			the XML for the callbacks, so the performance of TinyXML-2 is unchanged by using this
			interface versus any other.)
			The interface has been based on ideas from:
			- http://www.saxproject.org/
			- http://c2.com/cgi/wiki?HierarchicalVisitorPattern
			Which are both good references for "visiting".
			An example of using Accept():
			@verbatim
			XMLPrinter printer;
			tinyxmlDoc.Accept( &printer );
			const char* xmlcstr = printer.CStr();
			@endverbatim
		*/
		public virtual bool Accept(XmlVisitor visitor)
		{

			return false;
		}


		/**
			Set user data into the XMLNode. TinyXML-2 in
			no way processes or interprets user data.
			It is initially 0.
		*/
		public void SetUserData(void* userData) => _userData = userData;


		/**
			Get user data set into the XMLNode. TinyXML-2 in
			no way processes or interprets user data.
			It is initially 0.
		*/
		public void* GetUserData() => _userData;






		protected virtual char8* ParseDeep(char8* pp, StrPair parentEndTag, int* curLineNumPtr)
		{
			//XmlDocument.DepthTracker tracker = scope .(_document);
			if (_document.Error())
				return null;

			var p = pp;

			while (p != null && *p != 0)
			{
				XmlNode node = null;

				p = _document.Identify(p, out node);

				if (node == null)
					break;

				let initialLineNum = node._parseLineNum;

				StrPair endTag = scope .();
				p = node.ParseDeep(p, endTag, curLineNumPtr);

				if (p == null)
				{
					DeleteNode(node);

					if (!_document.Error())
					{
						_document.SetError(.XML_ERROR_PARSING, initialLineNum, null);
					}

					break;
				}

				let decl = node.ToDeclaration();

				if (decl != null)
				{
					bool wellLocated= false;

					if (ToDocument() != null)
					{
						if (FirstChild() != null)
						{
							wellLocated = FirstChild().ToDeclaration() != null &&
								          LastChild()?.ToDeclaration() != null;
						}
						else
						{
							wellLocated = true;
						}
					}

					if (!wellLocated)
					{
						_document.SetError(.XML_ERROR_PARSING_DECLARATION, initialLineNum, "XmlDeclaration value = {}", decl.Value());
						DeleteNode(node);
						break;
					}
				}

				XmlElement ele = node.ToElement();

				if (ele != null)
				{
					if (ele.ClosingType() == .CLOSING)
					{
						if (parentEndTag != null)
						{
							ele._value.TransferTo(parentEndTag);
						}

						DeleteNode(node);
						return p;
					}

					bool mismatch = false;

					if (endTag.Empty())
					{
						if (ele.ClosingType() == .OPEN)
						{
							mismatch = true;
						}
					}
					else
					{
						if (ele.ClosingType() != .OPEN)
						{
							mismatch = true;
						}
						else if (!XMLUtil.StringEqual(endTag.GetStr(), ele.Name()))
						{
							mismatch = true;
						}
					}

					if (mismatch)
					{
						_document.SetError(.XML_ERROR_MISMATCHED_ELEMENT, initialLineNum, "XmlElement name = {}", ele.Name());
						DeleteNode(node);
						break;
					}
				}

				InsertEndChild(node);
			}	

			return null;
		}




		private void Unlink(XmlNode child)
		{
			if (child == _firstChild)
			{
				_firstChild = _firstChild._next;
			}

			if (child == _lastChild)
			{
				_lastChild = _lastChild._prev;
			}

			if (child._prev != null)
			{
				child._prev._next = child._next;
			}

			if (child._next != null)
			{
				child._next._prev = child._prev;
			}

			child._next = null;
			child._prev = null;
			child._parent = null;
		}

		public static void DeleteNode(XmlNode node)
		{
			if (node == null)
				return;

			if (node.ToDocument() == null)
			{
				node._document.MarkInUse(node);
			}

			delete node;
		}

		private void InsertChildPreamble(XmlNode insertThis)
		{
			if (insertThis._parent != null)
			{
				insertThis._parent.Unlink(insertThis);
			}
			else
			{
				insertThis._document.MarkInUse(insertThis);
			}
		}

		private XmlElement ToElementWidthName(char8* name)
		{
			let element = ToElement();

			if (element == null)
				return null;

			if (name == null)
				return element;

			if (XMLUtil.StringEqual(element.Name(), name))
				return element;

			return null;
		}
	}
}

namespace tinyxml2
{
	
	/**
		Implements the interface to the "Visitor pattern" (see the Accept() method.)
		If you call the Accept() method, it requires being passed a XMLVisitor
		class to handle callbacks. For nodes that contain other nodes (Document, Element)
		you will get called with a VisitEnter/VisitExit pair. Nodes that are always leafs
		are simply called with Visit().
		If you return 'true' from a Visit method, recursive parsing will continue. If you return
		false, <b>no children of this node or its siblings</b> will be visited.
		All flavors of Visit methods have a default implementation that returns 'true' (continue
		visiting). You need to only override methods that are interesting to you.
		Generally Accept() is called on the XMLDocument, although all nodes support visiting.
		You should never change the document from a callback.
		@sa XMLNode::Accept()
	*/

	abstract class XmlVisitor
	{
		public virtual bool VisitEnter(XmlDocument doc)
		{
			return true;
		}

		public virtual bool VisitExit(XmlDocument doc)
		{
			return true;
		}

		public virtual bool VisitEnter(XmlElement element, XmlAttribute attribute)
		{
			return true;
		}

		public virtual bool VisitExit(XmlElement element)
		{
			return true;
		}

		public virtual bool Visit(XmlDeclaration declaration)
		{
			return true;
		}

		public virtual bool Visit(XmlText text)
		{
			return true;
		}

		public virtual bool Visit(XmlComment comment)
		{
			return true;
		}

		public virtual bool Visit(XmlUnknown unk)
		{
			return true;
		}
	}
}
